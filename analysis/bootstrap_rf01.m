%% 1000 times bootstrap of RF centers and compute the visual response in the particular time window.
%% save the results to "newfolder" and then change para.file_names in setPara01.m to "newfolder"  
%% and run runRemap_01.m
%% 2022-08-20, Xiao Wang, V-1.0;
data_root ='/Users/wangxiao/Desktop/torch/RFdataset/';
running_root = '/Users/wangxiao/Desktop/matlab/LIP-FEF-data-analysis/';
% get parameters, only the contour criteria and time window parameters are needed,
% it doesn't matter what kind of flags is used here.
para = setPara_bootstrap01(running_root); %
areaFlag = para.brainFlag ;%%brainFlag=1 when bootstrap FEF while brainFlag=2 when bootstrap LIP.

%file_names={'all_pop_FEFresp1/','all_pop_LIPresp1/'};
All_fef=dir([[data_root,para.file_names{1}],'*.','mat']);
All_lip=dir([[data_root,para.file_names{2}],'*.','mat']);
All_cell = {All_fef,All_lip};
%% get the new data folder name,avoid duplicate folder names with old ones.

if areaFlag == 1
    newfolder = [data_root,'all_pop_FEF5']; %
    
elseif areaFlag == 2
    newfolder = [data_root,'all_pop_LIP5']; %
    
else
    error('Invalid saveFlag');
end


save_newdata_path = [data_root,newfolder];
cell_probelem = [];% for debug
for ncell=1:length(All_cell{areaFlag})
    %try
    ncell
    All_cell_tmp = All_cell{areaFlag};
    name=All_cell_tmp(ncell).name;
    
    
    load([data_root,para.file_names{areaFlag},name]);
    if ~isfield(P,'XI')
        
        NonPcell=[NonPcell,name];
        P.XI = s(2).XI;
        P.YI = s(2).YI;
    end
    
    x_fp=P.fixLoc(1);
    y_fp=P.fixLoc(2);
    x_tg=P.tarLoc(1);
    y_tg=P.tarLoc(2);
    
    Xrange=unique(P.XI(:));
    Yrange=flipud(unique(P.YI(:)));
    
    [X,Y] = meshgrid(Xrange,Yrange);
    Xrange_interp=Xrange(1):0.1:Xrange(end);
    Yrange_interp=Yrange(1):-0.1:Yrange(end);
    
    
    [~,x_fp_interp]=min(abs(Xrange_interp-x_fp));
    
    
    [~,y_fp_interp]=min(abs(Yrange_interp-y_fp));
    
    
    [~,x_tg_interp]=min(abs(Xrange_interp-x_tg));
    
    
    [~,y_tg_interp]=min(abs(Yrange_interp-y_tg));
    
    targetnfixation_interp=[x_fp_interp;y_fp_interp;x_tg_interp;y_tg_interp];
    [XI,YI] = meshgrid(Xrange_interp,Yrange_interp);
    
    
    
    
    %% compute the visual response and organized the sipke data in each time period.
    % para.align = 'probeon';
    
    for i = [1,2,3,5] % all time periods
        i
        %tmp_spk = contour_loc.loc_resp_spike;
        %para.tP = i; % i is time period index from yang lin's data.
        [loc_resp_spike,loc_resp_fr] = getBslVis(contour_loc,para,i);
        contour_loc(i).loc_resp_fr=loc_resp_fr; %% rf heat map (firing rate in each grid)
        contour_loc(i).loc_resp_spike = loc_resp_spike; %% firing rate of the each trial and each grid.
        
        [contour_loc(i).boot_center_poiss,contour_loc(i).boot_center_replace]=boot_center_fit(contour_loc(i).loc_resp_spike,X,Y,XI,YI,para);
        
    end
    %for i = 3 % perisaccade probe onset alignment
    % when i = 3  perisaccade probe onset alignment
    %if para.timewindow100 == 1 % 50?150ms time window
    
    %         [loc_resp_spike,loc_resp_fr] = getBslVis(contour_loc,para,i);
    %         contour_loc(3).loc_resp_fr=loc_resp_fr; %% rf heat map (firing rate in each grid)
    %         contour_loc(3).loc_resp_spike = loc_resp_spike; %% firing rate of the each trial and each grid.
    %
    %         [contour_loc(3).boot_center_poiss,contour_loc(3).boot_center_replace]=boot_center_fit(contour_loc(3).loc_resp_spike,X,Y,XI,YI,para);
    
    % select trials that perisaccadic probes occurred within 150 ms before saccade onset.
    % time window of 50 ~ 350 ms after probe onset
    para.pre_probe =  50;
    para.post_probe=  350;
    tmp_contour = contour_loc(3).fr;
    [fr,Probe2sac] = rearangeSpk(tmp_contour,TrialInfo,para);
    contour_loc(9).fr = fr;
    
    [loc_resp_spike,loc_resp_fr] = getBslVis(contour_loc,para,3);
    contour_loc(9).loc_resp_fr=loc_resp_fr; %% rf heat map (firing rate in each grid)
    contour_loc(9).loc_resp_spike = loc_resp_spike; %% firing rate of the each trial and each grid.
    
    [contour_loc(9).boot_center_poiss,contour_loc(9).boot_center_replace]=boot_center_fit(contour_loc(9).loc_resp_spike,X,Y,XI,YI,para);
end


%end


%% save the data.
%  save([save_newdata_path,name],'contour_loc','P','s');


%     catch
%         cell_probelem = [cell_probelem,ncell];
%     end


%end