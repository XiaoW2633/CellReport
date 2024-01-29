% (modified from COSIVINA toolbox/NeuralField)LateralInteractions2D
%Connective element that performs a 2D convolution with a Mexican hat
%   kernel (difference of two Gaussians). The
%   element also provides the sum of the element's input (typically the
%   output of a neural field) along the horizontal, vertical, and both
%   dimensions, to be used for projections onto lower-dimensional
%   structures.
%% Constructor call:
% ModelConnect(label, size, sigmaExc,amplitudeExc,sigmaInh, amplitudeInh,...
%         attAmp,attSigma,Tar,cd,Fix,cutoffFactor)
%   label - element label
%   size - field size
%   sigmaExc - width parameter of excitatory gaussian kernel 
%   amplitudeExc - amplitude of excitatory kernel
%   sigmaInh - width parameter of inhibitory gaussian kernel 
%   amplitudeInh - amplitude of inhibitory kernel
%   tar_attAmp - amplitude of target attention modulation
%   fp_attAmp - amplitude of fixation attention modulation
%   attSigma - width parameter of attention modulation
%   Tar - Target location
%   cd - amplitude of cd signal
%   Fp - Fixation point location
%   cutoffFactor - multiple of sigma at which the kernel is cut off
%     (default value is 5)
%
classdef ModelConnect < Element
    properties (Constant)
        parameters =struct('size', ParameterStatus.Fixed, 'sigmaExc', ParameterStatus.InitStepRequired, ...
            'amplitudeExc', ParameterStatus.InitStepRequired, 'sigmaInh', ParameterStatus.InitStepRequired, ...
            'amplitudeInh', ParameterStatus.InitStepRequired, 'amplitudeGlobal', ParameterStatus.Changeable, ...
            'tar_attAmp',ParameterStatus.Changeable,'attSigma',ParameterStatus.Changeable,'Tar',ParameterStatus.Changeable,...
            'cd', ParameterStatus.InitStepRequired,'fp_attAmp',ParameterStatus.Changeable,'Fp',ParameterStatus.Changeable);
        %components = {'kernel', 'amplitudeGlobal', 'fullSum', 'output'};
         components = {'kernelExcY', 'kernelExcX', 'kernelInhY', 'kernelInhX', 'amplitudeGlobal', ...
      'output'};
        defaultOutputComponent = 'output';
    end
    
    properties
        % default parameters 
        size = [1, 1];
        sigmaExc = 1;
        amplitudeExc = 0;
        sigmaInh = 1;
        amplitudeInh = 0;
        amplitudeGlobal = 0;
        tar_attAmp=0.1;
        fp_attAmp = 0;
        attSigma=15;
        Tar=[38,38];
        Fp=[20,38]
        cd=0;
        
        cutoffFactor = 5;  
        
        % accessible structures
        kernelExcY
        kernelExcX
        kernelInhY
        kernelInhX
        
%         verticalSum
%         horizontalSum
%         fullSum
        tarMod
        fpMod
        kernel
        output
        
    end
    
    properties (SetAccess = private)
        kernelRangeExcY
        kernelRangeExcX
        kernelRangeInhY
        kernelRangeInhX
        extIndexExcY
        extIndexExcX
        extIndexInhY
        extIndexInhX
        
%         kernelExcX
%         kernelExcY
%         kernelInhX
%         kernelInhY
    end
    methods
    function obj=ModelConnect(label, size, sigmaExc,amplitudeExc,sigmaInh, amplitudeInh,...
         tar_attAmp,attSigma,Tar,cd,fp_attAmp,Fp,cutoffFactor)
    if nargin > 0
        obj.label = label;
        obj.size = size;
    end
    if nargin >= 3
        obj.sigmaExc = sigmaExc;
    end
    if nargin >= 4
        obj.amplitudeExc = amplitudeExc;
    end
    if nargin >= 5
        obj.sigmaInh = sigmaInh;
    end
    if nargin >= 6
        obj.amplitudeInh = amplitudeInh;
    end
    
    if nargin >= 7
        obj.tar_attAmp = tar_attAmp;
    end
    if nargin >= 8
        obj.attSigma = attSigma;
    end
    if nargin >= 9
        obj.Tar = Tar;
    end
    if nargin >=10
        obj.cd=cd;
    end
    if nargin >=11
        obj.fp_attAmp=fp_attAmp;
    end
    if nargin >=12
        obj.Fp=Fp;
    end
   
    if nargin >= 12
        obj.cutoffFactor = cutoffFactor;
    end
    if numel(obj.size) == 1
        obj.size = [1, obj.size];
    end
    end
    % step function
    function obj=step(obj,time,deltaT)
    % get the input components: neural field's output(neurons' firing rates).
    input = obj.inputElements{1}.(obj.inputComponents{1});

    xygrid = 1:obj.size(2);
    
    
%     input=input.*obj.tarMod; 
%     input=input.*obj.fixMod;
    outputExc = conv2(1, obj.kernelExcX, input, 'same');
    outputInh = conv2(1, obj.kernelInhX, input, 'same');
    %testE=conv2(1, obj.kernelExcX, input, 'same');
    
    outputExc = conv2(obj.kernelExcY, 1, outputExc, 'same');
    outputInh = conv2(obj.kernelInhY, 1, outputInh, 'same');
    
    % modualte the recurrent input;
    outputExcAtt = outputExc.*obj.tarMod.*obj.fpMod;
    outputInhAtt = outputInh.*obj.tarMod.*obj.fpMod;
%     obj.verticalSum = sum(input, 1);
%     obj.horizontalSum = sum(input, 2)';
%     obj.fullSum = sum(obj.verticalSum);
    
    obj.output = outputExcAtt - outputInhAtt;% + obj.amplitudeGlobal * obj.fullSum;
    end
    
    function obj=init(obj)
    xygrid = 1:obj.size(2);
    %obj.Mod=1+obj.attAmp*gauss2d(xygrid,xygrid,obj.Tar(1),obj.Tar(2),obj.attSigma,obj.attSigma;
    
    obj.kernelRangeExcX = computeKernelRange(obj.sigmaExc, obj.cutoffFactor, obj.size(2), false);
    obj.kernelRangeExcY = computeKernelRange(obj.sigmaExc, obj.cutoffFactor, obj.size(1), false);
    obj.kernelRangeInhX = computeKernelRange(obj.sigmaInh, obj.cutoffFactor, obj.size(2), false);
    obj.kernelRangeInhY = computeKernelRange(obj.sigmaInh, obj.cutoffFactor, obj.size(1), false);
    
    obj.extIndexExcX = [];
    obj.extIndexInhX = [];
    obj.extIndexExcY = [];
    obj.extIndexInhY = [];
    %get the length of the connection kernel.
    len=length(-obj.kernelRangeExcX(1) : obj.kernelRangeExcX(2));
    % symmetric excitatory connection kernel on x-axis.
    W_excX = obj.amplitudeExc * gauss(-obj.kernelRangeExcX(1) : obj.kernelRangeExcX(2), 0, obj.sigmaExc);
    % first-order derivative of excitatory kernel on x-axis.
    W_excX_ = gauss_drv(-obj.kernelRangeExcX(1) : obj.kernelRangeExcX(2),0,obj.sigmaExc);
    % symmetric excitatory connection kernel on y-axis.
    W_excY = gauss(-obj.kernelRangeExcY(1) : obj.kernelRangeExcY(2), 0, obj.sigmaExc);
    % symmetric inhibitory connection kernel on x-axis.
    W_inhX = obj.amplitudeInh * gauss(-obj.kernelRangeInhX(1) : obj.kernelRangeInhX(2), 0, obj.sigmaInh);
    % first-order derivative of inhibitory kernel on x-axis.
    W_inhX_ = obj.amplitudeInh * gauss_drv(-obj.kernelRangeInhX(1) : obj.kernelRangeInhX(2),0,obj.sigmaInh);
    % symmetric inhibitory connection kernel on y-axis.
    W_inhY = gauss(-obj.kernelRangeInhY(1) : obj.kernelRangeInhY(2), 0, obj.sigmaInh);
    
    % build up the exitatory kernel.
    obj.kernelExcX = (W_excX+obj.cd*W_excX_)/len;
    obj.kernelExcY = W_excY/len;
    % build up the inhibitory kernel.
    obj.kernelInhX =(W_inhX+obj.cd*W_inhX_)/len;
    obj.kernelInhY = W_inhY/len;
    
    obj.output = zeros(obj.size);
    
    % attention modulation factors. % attention to the target.
    obj.tarMod = 1+obj.tar_attAmp*gauss2d(xygrid,xygrid,obj.Tar(1),obj.Tar(2),obj.attSigma,obj.attSigma);
    % attention to the fixation.
    obj.fpMod = 1+obj.fp_attAmp*gauss2d(xygrid,xygrid,obj.Fp(1),obj.Fp(2),obj.attSigma,obj.attSigma);
%     obj.verticalSum = zeros(1, obj.size(2));
%     obj.horizontalSum = zeros(1, obj.size(1));
%     obj.fullSum = 0;
    end
    
    end
end


