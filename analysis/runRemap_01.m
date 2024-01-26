%% Analysis of LIP/FEF single unit data for RF remapping in delay and perisaccadic periods
% For each unit, visual responses to flashed probes in the current (initial fixation), delay, perisaccadic, and future
% (postsaccadic) periods were recorded from an array of spatial positions.
% The data were preprocessed by Yang Lin to align on the probe onset, and for the perisaccdic period, also on the
% saccade onset.
% The code generates response heat maps, RF shift vector and direction (polar) plots, and RF shift time courses.

% 2023-09-14 Xiao Wang. Wrote and cleaned up all the code files


%% Before running the code, set the correct paths
clear; close all;
running_root = '/Users/wangxiao/Desktop/matlab/LIP-FEF/'; % Xiao's path
% Go to the right folder and add the path.
cd(running_root);
addpath(pwd);
%% Set parameters
para = setPara01(running_root);
%% Get the filenames of the neurons in each folder.
All_fef=dir([[para.data_root,para.file_names{1}],'*.','mat']);
All_lip=dir([[para.data_root,para.file_names{2}],'*.','mat']);
All_cell = {All_fef,All_lip}; % array of 2 matlab cells for the two areas
%% if para.subset is empty, run all the cells;
if para.subset
    loop_cells = para.subset;
else
    loop_cells = 1:length(All_cell{para.brainIndex});
end

% Initial the some empty arrays and structures for collecting the results;
ploar_vec_rf = []; %% main result array for ploting polar and vector plots,contains the centers of crf frf and prf; Numofcell X 7...
% ...[crfx,crfy,frfx,frfy,prfx/drfx,prfy/drfy,saccade amplitude]
time_shift_direc = []; % time course of shift direction: Numofcell X timebins
time_shift_mag   = []; %time course of shift magnitude (normalized by to saccade amplitude): Numofcell X timebins
time_shift_mag_target   = []; %time course of shift magnitude (normalized by crf to target distance): Numofcell X timebins
% Initial arrays for parallel decomposition of shift vectors
tot_sacamp = []; %  saccade amplitudes
tot_fwd_rmp = []; % decomposed forward components
tot_cvg_rmp = []; % decomposed convergent components
tot_crf2tar = []; % crf to target distances

tot=0;  % to record the cell number.
tot_rfvec = []; % array for time course analysis
tot_ncell = [];
for ncell=loop_cells
    ncell
    % load the cell data
    All_cell_tmp = All_cell{para.brainIndex};
    name = All_cell_tmp(ncell).name;
    load([para.data_root, para.file_names{para.brainIndex}, name]); % Get P,s,contour_loc
    % P contains some parameters like probe matrix, fixation and target
    % locations.
    % contour_loc contains spike data of the four time periods aligned on
    % probe onset and saccade onset/offset.
    % s contains some results for analysis (created by yang lin).
    
    % Screen neurons, visual response, trial number, completeness, and significant shift test.
    [rf_clear,rf_shift,direc,cordn] = screenNeurons01(P,s,contour_loc,para);
    % rf_shift flag for pRF or dRF is specified by para.timeFlag  = 2; % time period: 1 dRF, 2 pRF
    
    if  rf_clear && rf_shift % if the cell passed the screening
        
        tot = tot + 1;
        tot_ncell = [tot_ncell,ncell];
        % record the cell names.
        %all_cell_names{para.brainIndex} = [all_cell_names{para.brainIndex},name];
        % rotate the vectors to align the saccade rightward;
        % negtive direction in order to turn saccade direction rightward.
        tmp_rfvec = ConvertAngle(P,cordn.crfCenter,cordn.frfCenter,cordn.prfCenter,-direc);
        % Distance of crf to target (degree)
        dist_crf2target = norm(tmp_rfvec(para.CRF2TG:para.CRF2TG+1));
        % Parallel decomposition of shift vectors
        [fwd_rmp,cvg_rmp]  =  discom([tmp_rfvec,cordn.sacamp],para);
        if fwd_rmp>=0 & cvg_rmp>=0 % only collect when the components are positive
            tot_sacamp = [tot_sacamp,cordn.sacamp];
            
            tot_fwd_rmp = [tot_fwd_rmp,fwd_rmp];
            tot_cvg_rmp = [tot_cvg_rmp,cvg_rmp];
            tot_crf2tar = [tot_crf2tar,dist_crf2target];
        end
        
        
        
        ploar_vec_rf=[ploar_vec_rf;[tmp_rfvec,cordn.sacamp]]; % add the saccade amplitude.
        
        if para.drawHeatmap
            % draw/save the heatmap of the cell
            % compute the shift direction and shift amplitude.
            [shift_direc,shift_amplitude] = vec2polar(tmp_rfvec(para.CRF2PRF),tmp_rfvec(para.CRF2PRF+1));  %% shift_direc: theta, shift_amplitude: magnitude.
            if ~exist(para.heatmap_root,'dir') % create heatmap folder if it is not exist.
                mkdir(para.heatmap_root);
            end
            drawHeatMap(P,cordn,name,para.heatmap_root,ncell,shift_direc);% draw and save heatmap
            %savename=[para.results_root,'exampledata/',para.brain,para.align,'.mat'];
            %save(savename,'P','cordn','shift_direc');
            %close all;
        end
        
        
        % Start to compute the time course of dRF/pRF shift direction and magnitude by using sliding window.
        % para.PERI_PROBE and para.DELAY are indeces for baseline firing rates ??
        tmp_contour=contour_loc(para.tP).fr;    % get spike data from pRF/dRF  aligned saccade onset/probe onset.
        if para.tP == 5 || para.tP == 3 %% baseline data for peri-saccadic period should be before probe onset
            baseline_contour = contour_loc(para.PERI_PROBE).fr; %% choose the right baseline spike data when analysis the prf
        else
            baseline_contour = contour_loc(para.DELAY).fr; %choose the right baseline spike data when analysis the drf
        end
       
        siz=size(tmp_contour); %% size of the grid;
        tmp_vec = zeros(2,para.max_T-1);% Initialize time course of the shift vectors (2*time)
        tmp_direc = zeros(1,para.max_T-1); % Initialize the time course of shift direction
        tmp_magnitude = zeros(1,para.max_T-1);  %% Initialize the time course of magnitude (nomalized by saccade amplitude)
        tmp_magnitude_target = zeros(1,para.max_T-1); % Initialize the time course of magnitude (nomalized by crf2target distance)
        % Compute the time course for each time bin.
        tot_rfvec_bin = []; % Initial the array for each cell's time course analysis.
        for sbin = 1:length(para.sbin)
            
            start_bin  = para.sbin(sbin)-para.binsz/2; %start time of each time bin
            end_bin = para.sbin(sbin)+para.binsz/2; % end time of each time bin
            tmp_Rf_sbin = zeros(siz); % size of the probe grids
            loc_resp1_sbin = cell(siz);% cell array to save the firing rate of each trial and each time bin.
            % Collect the neural response of each probe
            for k = 1:siz(2)
                for l = 1:siz(1)
                    trials = tmp_contour{l,k};
                    baseline_trials = baseline_contour{l,k};
                    for i=1:length(trials) 
                        loc_resp1_sbin{l,k}(i,4) = para.nSpk2fr*sum((trials{i}>=start_bin) & (trials{i}<end_bin));                   
                    end
                    tmp_Rf_sbin(l,k) = mean(loc_resp1_sbin{l,k}(:,4)); % mean firing rate in each grid
                    
                    
                end
            end
            % Compute the cRF/dRF/fRF centers of each time bin
            sRFbin=CenterOfMass(tmp_Rf_sbin,cordn.X,cordn.Y,cordn.XI,cordn.YI,...
                cordn.Xrange_interp,cordn.Yrange_interp,para);
            % pRF center of each time bin
            prfCenterBin = sRFbin.center;
            % rotate the vectors to align the saccade rightward;
            tmp_rfvec_bin=  ConvertAngle(P,cordn.crfCenter,cordn.frfCenter,prfCenterBin,-direc);% 
            thetaNmag = vec2angle(tmp_rfvec_bin,para);%% direction(radians) and  magnitude structure(degrees).
            tmp_direc(sbin) = thetaNmag.crf2prfAngle; %% shift direction in radians
            tmp_magnitude(sbin) = thetaNmag.crf2prfMag./cordn.sacamp; %%magnitude nomalized by saccade amplitude;
            tmp_magnitude_target(sbin) = thetaNmag.crf2prfMag./dist_crf2target;%%magnitude nomalized by crf2target amplitude;
            tmp_rfvec_bin = [tmp_rfvec_bin,cordn.sacamp]; % add the saccade amplitude to the array
            tot_rfvec_bin = [tot_rfvec_bin;tmp_rfvec_bin];
            
        end
        tot_rfvec = cat(3,tot_rfvec,tot_rfvec_bin); % (timebins*9*Numofcell)
        time_shift_direc  = [time_shift_direc;tmp_direc]; %total time course of shift directions : Numofcell X timebins
        time_shift_mag      = [time_shift_mag;tmp_magnitude]; %total time course of shift magnitudes  : Numofcell X timebins
        time_shift_mag_target = [time_shift_mag_target;tmp_magnitude_target];
    end
    
    
    
    
    
end

tot_rfvec = permute(tot_rfvec,[1,3,2]); %(timebin,Numofcell,9);

%% Plot and save the figure
% compute the vectors' directions and magnitudes.
outputPolar  = vec2angle(ploar_vec_rf,para);
 %polar plot
 %ppolar = drawPolar(outputPolar,para);
% vector plot
%drawVecplot(ploar_vec_rf,outputPolar,para); %
% plot time course figure
plot_areaerrorbar(time_shift_mag, time_shift_direc,outputPolar ,para);
savename=[para.results_root,'plots/',para.brain, para.RFtime,para.align,'_sld_300ms.mat']; %% 300ms means time from saccade/probe onset.
%save(savename,'tot_rfvec','para','time_shift_mag','time_shift_direc','outputPolar','tot_ncell','time_shift_mag_target',tot_sacamp,tot_fwd_rmp,tot_cvg_rmp,tot_crf2tar);






