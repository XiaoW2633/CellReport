function para = setPara_bootstrap01(running_root)
% Set all the parameters for the analysis
para.version='01';
para.brainFlag = 1; % brain area: 1 FEF, 2 LIP
para.timeFlag  = 2; % time period: 1 delay, 2 perisaccade
para.alignFlag =3; % alignment: 1 probe onset, 2 saccade offset,3 saccade onset
para.vecFlag   = 0; % mean vector plot Flag,1:r-theta mean. 0: x-y mean.
if para.timeFlag ~= 2 && para.alignFlag ~= 1
    error('Non perisaccadic responses should only be aligned on probe onset');
end

para.svfigFlag = 0; % Flag for save the figures
para.drawHeatmap = 0; % Flag for drawing the heatmap of receptive field.
para.svecFlag = 1;
%para.timewindow100 = 1;% Flag for the time window in pRF(probe onset).% 1 50-150ms
% if para.subset is empty, run all the cells, otherwise only run those with 
% indeces manually in para.subset.
para.subset = []; 
%para.subset = [321   323   339   341   342   343   345]; % oblique cells' indeces;
%% define data and result paths.
%para.data_root = '/Users/wangxiao/Desktop/model/FEFLIP/';
para.data_root='/Users/wangxiao/Desktop/torch/RFdataset/';
para.file_names={'all_pop_FEF3/','all_pop_LIP3/'}; % dataset folder
%para.file_names={'all_pop_FEFresp2/','all_pop_LIPresp2/'};
%para.results_root = '/Users/wangxiao/Desktop/matlab/FEFLIP/results/';


%% organization of results folder
% Confusing dir structure ??
% /results   % put time stamp ast this level?? then brain area, then alignment, then heatmap ??
%    --/FEF   : results  of FEF (polar,vector and time course)
%         --/probeon  : dRF pRF and heatmap folder
%         --/sacoff  :  pRF results and heatmap folder
%    --/LIP    : results of LIP (polar,vector and time course)
%         --/probeon  : dRF  pRF results and heatmap folder
%         --/sacoff  : pRF results and heatmap folder


para.nboot = 1000; % number of samples for bootstrap
para.bootstrap = 1; % flag for bootstrap method, 1 is fitting a poisson distribution, 0 is resampling with replacement

para.intpItv = 0.1;

%structure index indicates data on different time period,get data from yangling's data 
para.CURRENT = 1; %% crf
para.DELAY = 2;   %% drf
para.PERI_PROBE = 3; %% prf aligned on probe onset
para.FUTURE = 4;     %% frf
para.PERI_SAC =8;    %% prf aligned on saccade offset
%Column number indicates rf data centers on different time periods, save the data.
% 1,3,5,7 are x axis, 2,4,6,8 are y axis.
para.CRF2FP = 1; %% crf to fixation vector
para.CRF2FRF= 3; %% crf to frf vector
para.CRF2PRF= 5; %% crf to prf/drf vector
para.CRF2TG = 7; %% crf to target vector

% Column number for saccade amplitude
para.SACAMP = 9;



%% cell screening criteria
para.rf=0.75; %% 85% of max firing rate countour.
para.edge =0.2; %% completeness (1-0.8),
%para.area=0.5;
para.sigLevel=0.05; %% visual response test level
para.shift_level = 0.90; %% significant shift test level
para.trialNum = 5;
%%calculate mean response time window, time parameters (ms)
para.bsl_start = -50; %% baseline time window start time ,0 means probe onset
para.bsl_end   = 0;   %% baseline time window end time,
%if para.timewindow100 == 1
    para.pre_probe =  50; %% visual respone time window start time, 0 means probe onset
    para.post_probe=  150; %% visual response time window end time
% else
%     para.pre_probe =  50; %% visual respone time window start time, 0 means probe onset
%     para.post_probe=  350; %% visual response time window end time
% end
para.pre_sac = -50;  % 0 %% visual response time window start time, 0 means saccade off set.
para.post_sac=  50;   % 100 %% visual response time window end time.

para.pre_sacon = 0;   %% visual response time window start time, 0 means saccade off set.
para.post_sacon=  100;
%brain flag indicates which brain area to analyze.
% 1 is FEF and 2 is LIP
if para.brainFlag ==1 
    para.brainIndex = 1;
    para.brain = 'FEF'; 
elseif para.brainFlag ==2
    para.brainIndex = 2;
    para.brain = 'LIP';
else
    error('Invalid brain flag');
end

% time period flag indicates which time period to analyze.
% 1 is delay period and 2 is peri-saccade period.
%para.binsz = 25;
para.binsz = 50;
if para.timeFlag == 1
    para.tP = 2; % struct array index for the data from Yang Lin
    para.RFtime = 'dRF'; 
    para.align = 'probeon';
    %para.bin = 0:25:200; 
    para.bin = 50:para.binsz:200; % ?? 
    para.timecourse_xlabel = 'Time from probe onset(ms)';
elseif para.timeFlag == 2
    para.RFtime = 'pRF';
    % alignment flag, 1 is probe onset and 2 is saccade offset.
    if para.alignFlag == 1 
        if para.probeonset == 0
         para.tP = 3;
        else
         para.tP = 9;
        end
        para.align = 'probeon';
        para.timecourse_xlabel = 'Time from probe onset(ms)';
        para.bin = 50:para.binsz:200; % ??
    elseif para.alignFlag == 2
        para.tP = 8;
        para.align = 'sacoff';
        para.timecourse_xlabel = 'Time from saccade offset(ms)';
        para.bin = -125:para.binsz:175;
    elseif para.alignFlag == 3
        para.alignFlag == 3
        para.tP = 5;
        para.align = 'sacon';
        para.timecourse_xlabel = 'Time from saccade onset(ms)';
        %para.bin = -100:para.binsz:200; %225
         para.bin = -50:para.binsz:200; %225
        
    else
        error('Invalid alignment flag')
    end
else
    error('Invalid timeFlag');
end

%para.bin = para.bin-12.5;
para.results_root = [running_root, 'results',para.version,'/'];
para.heatmap_root = [para.results_root,'heatmap/',para.align,'/', para.brain,'/',para.RFtime,'/'];

para.heatmap_root = [para.results_root,para.brain,'/',para.align,'/','heatmap/'];

%% Spike counts to firing rates conversion factors
para.nSpk2fr = 1000/(para.bin(2)-para.bin(1));
para.nSpk2fr_probe = 1000/(para.post_probe-para.pre_probe);
para.nSpk2fr_sac = 1000/(para.post_sac-para.pre_sac);
para.nSpk2fr_sacon = 1000/(para.post_sacon-para.pre_sacon);
para.nSpk2fr_bsl = 1000/(para.bsl_end -para.bsl_start);

%% number of time bins in time course figure.
para.max_T = length(para.bin);



end