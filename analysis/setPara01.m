function para = setPara01(running_root)
% Set all the parameters for the analysis
para.version='01';
para.brainIndex = 2; % brain area: 1 FEF, 2 LIP
para.timeFlag  = 1; % time period: 1 delay, 2 perisaccade
para.alignFlag =1; % alignment: 1 probe onset, 2 saccade offset,3 saccade onset
para.vecFlag   = 0; % mean vector plot Flag,1:r-theta mean. 0: x-y mean.
if para.timeFlag == 1 && para.alignFlag ~= 1
    error('Non perisaccadic responses should only be aligned on probe onset');
end
para.normalize = 1;% Flag for normalize method, 1 is normalize rf to [0,1],0  is unnormalized but substract the baseline(-50~0ms probe onset)
para.bootstrap = 1;% Flag for bootstrap method, 0: resampling with replacement, 1 Poisson
para.svfigFlag = 0; % Flag for save the figures
para.svecFlag  = 0; % flag for save vector data
para.drawHeatmap = 0; % Flag for drawing the heatmap of receptive field.
para.timewindow100 = 1;% Flag for the time window.1: 50~150ms , 0: 50~350ms
% if para.subset is empty, run all the cells, otherwise only run those with 
% indeces manually in para.subset.
para.subset = []; 
%para.subset = [321   323   339   341   342   343   345]; % oblique cells' indeces;
%% define data and result paths.
%para.data_root = '/Users/wangxiao/Desktop/model/FEFLIP/';
para.data_root='/Users/wangxiao/Desktop/model/';
% the following folders already contain bootstrap data. If bootstrap_rf01
% bootstap_rf01.m is run, then change the following folder names to these
% in bootstap_rf01.m
para.file_names={'all_pop_FEF2/','all_pop_LIP2/'}; % dataset folder

%para.results_root = '/Users/wangxiao/Desktop/matlab/FEFLIP/results/';
    
%% organization of results folder

para.nboot = 1000; % number of repeats for bootstrap
para.intpItv = 0.1;

%structure index indicates data on different time period,get data from
%yangling's data ??
para.CURRENT = 1; %% crf
para.DELAY = 2;   %% drf
para.PERI_PROBE = 3; %% prf aligned on probe onset
para.FUTURE = 4;     %% frf
para.PERI_SAC = 8;    %% prf aligned on saccade offset
%Column number indicates rf data centers on different time periods, save the data.
% 1,3,5,7 are x axis, 2,4,6,8 are y axis.
para.CRF2FP = 1; %% crf to fixation vector
para.CRF2FRF= 3; %% crf to frf vector
para.CRF2PRF= 5; %% crf to prf/drf vector
para.CRF2TG = 7; %% crf to target vector

% Column number for saccade amplitude
para.SACAMP = 9;



%% cell screening criteria
para.rf=0.85; %% 85% of max firing rate countour.
para.edge =0.20; %% completeness = 1-edge
%para.area=0.5;
para.sigLevel=0.05; %% visual response signaficant level
para.shift_level = 0.1; %% significant shift test level(1-0.95 = 0.05)
para.trialNum = 5; % minimum trial number
%%calculate mean response time window, time parameters (ms)
para.bsl_start = -50; %% baseline time window start time ,0 means probe onset
para.bsl_end   = 0;   %% baseline time window end time,
if para.timewindow100 == 1
    para.pre_probe =  50; %% visual respone time window start time, 0 means probe onset
    para.post_probe=  150; %% visual response time window end time
else
    para.pre_probe =  50; %% visual respone time window start time, 0 means probe onset
    para.post_probe=  350; %% visual response time window end time
end
para.pre_sac = -50;   %% visual response time window start time, 0 means saccade on set.
para.post_sac=  50;    %% visual response time window end time.

para.pre_sacon = 0;   %% visual response time window start time, 
para.post_sacon=  100;
%brain flag indicates which brain area to analyze.
% 1 is FEF and 2 is LIP
if para.brainIndex ==1 %%  
    %para.brainIndex = 1;
    para.brain = 'FEF'; 
elseif para.brainIndex ==2
   % para.brainIndex = 2;
    para.brain = 'LIP';
else
    error('Invalid brain flag');
end

% time period flag indicates which time period to analyze.
% 1 is delay period and 2 is peri-saccade period.
para.binsz = 50;
para.sbinsz = 1; % step size 
if para.timeFlag == 1
    %tP = 2 for dRF
    para.tP = 2; % struct array index for the data from Yang Lin
    para.RFtime = 'dRF'; 
    para.align = 'probeon';
    %para.bin = 0:25:200; 
    para.bin = 75:para.binsz:300; % coarse bin centers
    para.sbin = 75 : para.sbinsz : 300; % fine bin centers
    
    para.timecourse_xlabel = 'Time from probe onset(ms)';
elseif para.timeFlag == 2
    para.RFtime = 'pRF';
    
    if para.alignFlag == 1 
        %tP = 3 for pRF probe onset
        para.tP = 3;
        para.align = 'probeon';
        para.timecourse_xlabel = 'Time from probe onset(ms)';
        para.bin = 75:para.binsz:300; % coarse bin centers
        para.sbin = 75 : para.sbinsz : 300; %fine bin centers
    elseif para.alignFlag == 2
        %tP = 8 for pRF sac offset
        para.tP = 8;
        para.align = 'sacoff';
        para.timecourse_xlabel = 'Time from saccade offset(ms)';
        para.bin = -125:para.binsz:200;
        para.sbin = -125 : para.sbinsz : 200;
    elseif para.alignFlag == 3
         %tP = 8 for pRF sac onset
        para.tP = 5;
        para.align = 'sacon';
        para.timecourse_xlabel = 'Time from saccade onset(ms)';
        para.bin = -50:para.binsz:200; %-100 
        para.sbin = -50:para.sbinsz:200; %225
        
    else
        error('Invalid alignment flag')
    end
else
    error('Invalid timeFlag');
end

%para.bin = para.bin-12.5;
para.results_root = [running_root, 'results',para.version,'/'];
para.heatmap_root = [para.results_root,'heatmap/',para.align,'/', para.brain,'/',para.RFtime,'/'];

%para.heatmap_root = [para.results_root,para.brain,'/',para.align,'/','heatmap/'];

%% Spike counts to firing rates conversion factors
para.nSpk2fr = 1000/(para.bin(2)-para.bin(1));
para.nSpk2fr_probe = 1000/(para.post_probe-para.pre_probe);
para.nSpk2fr_sac = 1000/(para.post_sac-para.pre_sac);
para.nSpk2fr_bsl = 1000/(para.bsl_end -para.bsl_start);

%% number of time bins in time course figure.
para.max_T = length(para.bin);
% para.expanAngle = [0,0]; % 0,0
% para.splitRatio = 0.5;
end