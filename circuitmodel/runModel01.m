%% Center-surround circuit model simulation of LIP/FEF reccptive field remapping on fixation,delay and
%% peri-saccadic period.
%% 2022-9-16, Xiao Wang -V.1.0.
clear;clc;close all;
running_root='/Users/wangxiao/Desktop/matlab/circuitModel3/';
setpath(running_root);
% set the timeFlag,1 is crf, 2 is drf1, 3 is drf2, 4 is prf1, 5 is prf2
timeFlag = 5;
para = SetModelPara01(timeFlag);
% initial the array to save the example cell recptive filed across time.
CellRF = zeros(para.fieldSize,para.fieldSize,para.tMax);
% initial a high dimension array to save multi-cells' recptive fileds across time.
allCellRF =...
zeros(length(para.AllrecordCellx),length(para.AllrecordCelly),para.fieldSize,para.fieldSize,para.tMax);

% initial a simulator, then you can add neural network, visual input and difine the connections;
sim=Simulator();% 

% add visual input to simulator,labeled as 'stimulus 1'.
sim.addElement(GaussInput2D('stimulus 1',[para.fieldSize,para.fieldSize],para.stiSigma,para.stiSigma,para.stiAmp,...
    0, 0,0,0));
% add neural field to simulator,labeled as 'field u'. NeuralField2D field u will receive input from 'stimulus 1'.
sim.addElement(NeuralField2D('field u',[para.fieldSize,para.fieldSize],para.tau,para.h,para.alpha),...
    {'stimulus 1'}); 
% add recurrent connections 'field u'->'field u' to the simulator, labeled as 'u -> u'.
sim.addElement(ModelConnect('u -> u', [para.fieldSize, para.fieldSize], para.wSigmaExc, para.wAmpExc, ...
    para.wSigmaInh, para.wAmpInh, para.tar_attAmp,para.attSigma,para.tar,para.cd,para.tar_attAmp,para.fp,para.cutoffFactor), 'field u', [], 'field u',[]);

% Create the gamma input
gammaInput = gampdf(1:para.tMax,para.gammashape,para.gammascale);
gammaInput = gammaInput./(max(gammaInput(:)));

for stiX = 1:para.fieldSize %para.fieldSize %% loop the 2D grids, X and Y coordinates;
    
    for stiY = 1:para.fieldSize %para.fieldSize
        % set time visual stimulus location
        sim.setElementParameters('stimulus 1','positionY',stiY);
        sim.setElementParameters('stimulus 1','positionX',stiX);
        % set time gamma visual stimulus amplitude.
        
        sim.init();
        % run the model step by step.
        while sim.t < para.tMax
            sim.step();
            sim.setElementParameters('stimulus 1','amplitude',gammaInput(sim.t)*para.stiAmp);
            allCellreps = sim.getComponent('field u','output');
            CellRF(stiY,stiX,sim.t)=allCellreps(para.recordCell(1),para.recordCell(2));
            allCellRF(:,:,stiY,stiX,sim.t) = allCellreps(para.AllrecordCelly,para.AllrecordCellx);
%             if sim.t > para.stimOff % probe offset
%                   sim.setElementParameters('stimulus 1','amplitude',0);
%             end
            sim.setElementParameters('u -> u','cd',para.cd*exp(-((sim.t-para.sacOn)/para.sigmSac).^6)); % time dependent cd signal  
            
            
        end
        %sim.step();
        
        
    end
end
if para.saveFlag
    timestamp=datestr(now,31);
    timestamp(11)='@';
    timestamp(timestamp == ':'| timestamp=='-')='_';
    
    dataFolder = fullfile(running_root,'data');
    if ~exist(dataFolder)
        mkdir(dataFolder);
    end
    dataFile=sprintf('%s/%s%d%s.mat',dataFolder,'rf',timeFlag,timestamp);
    save(dataFile,'CellRF','para');
end
%%
%plotRF(CellRF,para);
