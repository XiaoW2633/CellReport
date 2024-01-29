%% set parameters for the circuit model


function para = SetModelPara01(timeFlag)
% common parameters for all time periods
para.saveFlag=0;
para.savedata='data/';
para.fieldSize = 50; % network size (degree)
para.tMax = 120; % total simulation time (ms).
para.recordT = [0,100]; % recoding time window.
para.recordCell = [15,15];%% excample cell location;
para.fp = [38,38]; % row,coloum;
para.tar = [20,38];
para.AllrecordCellx = 1:5:para.fieldSize ; % 
para.AllrecordCelly = 1:5:para.fieldSize ; % 
para.sacOn   = 100; % set the end of sim as  sac onset, we only care about pre-saccadic period.
para.sigmSac = 65;% sigma for time course cd signal(ms). 
% parameters of the nerual dynamics;
para.tau = 20; %time constant (ms); 
para.h = -2; % resting state. 
para.alpha = 0.5;
%% parameters of the visual input
para.stiSigma = 7;
para.stiAmp = 5;

% parameters of the connections
para.wSigmaExc = 12; % degree
para.wSigmaInh = 18;
para.wAmpExc = 8;   %  (mV/spikes/s)
para.wAmpInh = 4;
% parameters of the attention and cd modulation.
para.attSigma = 20; %degree 
%para.attAmp   = 0.4;
%para.cd       = 0;
para.cutoffFactor = 5;
para.gammashape = 5; % 
para.gammascale = 10; % 
if timeFlag == 1
    para.tar_attAmp = 0;
    para.fp_attAmp = 0.4;
    para.cd       = 0;
    para.timePeriod = 'cRF';
elseif timeFlag == 2
    para.tar_attAmp   = 0.2;
    para.fp_attAmp = 0.8;
    para.cd       = 0;
    para.timePeriod = 'dRF1';
elseif timeFlag == 3
    para.tar_attAmp   = 0.3;
    para.fp_attAmp = 0.6;
    para.cd       = 0;
    para.timePeriod = 'dRF2';
elseif timeFlag == 4
    para.tar_attAmp   = 0.45;
    para.fp_attAmp = 0;
    para.cd       = 0.1;
    para.timePeriod = 'pRF1';
elseif timeFlag == 5
    para.tar_attAmp   = 0.2;
    para.fp_attAmp = 0;
    para.cd       = 0.6;
    para.timePeriod = 'pRF2';
else
    error('Invalid time flag');
end



end