% LateralInteractions1D (COSIVINA toolbox)
%   Connective element that performs a 1D convolution with a Mexican hat
%   kernel (difference of two Gaussians) with a global component.
%
% Constructor call:
% LateralInteractions1D(label, size, sigmaExc, amplitudeExc, ...
%     sigmaInh, amplitudeInh, amplitudeGlobal, circular, normalized, ...
%     cutoffFactor)
%   size - size of input and output of the convolution
%   sigmaExc - width parameter of excitatory Gaussian
%   amplitudeExc - amplitude of excitatory Gaussian
%   sigmaInh - width parameter of inhibitory Gaussian
%   amplitudeInh - amplitude of inhibitory Gaussian
%   amplitudeGlobal - amplitude of global component
%   circular - flag indicating whether convolution is circular (default is
%     true)
%   normalized - flag indicating whether local kernel components are
%     normalized before scaling with amplitude (default is true)
%   cutoffFactor - multiple of larger sigma at which the kernel is cut off
%     (global component is treated separately; default value is 5)


classdef myLateralInteractions1D < Element
  
  properties (Constant)
    parameters = struct('size', ParameterStatus.Fixed, 'sigmaExc', ParameterStatus.InitStepRequired, ...
      'amplitudeExc', ParameterStatus.InitStepRequired, 'sigmaInh', ParameterStatus.InitStepRequired, ...
      'amplitudeInh', ParameterStatus.InitStepRequired, 'amplitudeGlobal', ParameterStatus.Changeable, ...
      'circular', ParameterStatus.InitStepRequired, 'normalized', ParameterStatus.InitStepRequired, ...
      'cutoffFactor', ParameterStatus.InitStepRequired);
    components = {'kernel', 'amplitudeGlobal', 'fullSum', 'output'};
    defaultOutputComponent = 'output';
  end
  
  properties
    % parameters
    size = [1, 1];
    sigmaExc = 1;
    amplitudeExc = 0;
    sigmaInh = 1;
    amplitudeInh = 0;
    amplitudeGlobal = 0;
    circular = true;
    normalized = true;
    cutoffFactor = 5;
    
    % accessible structures
    kernel
    output
    fullSum
  end
  
  properties (SetAccess = protected)
    kernelRangeLeft
    kernelRangeRight
    extIndex
  end
  
  methods
    % constructor
    function obj = myLateralInteractions1D(label, size, sigmaExc, amplitudeExc, sigmaInh, amplitudeInh, ...
        amplitudeGlobal, circular, normalized, cutoffFactor)
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
        obj.amplitudeGlobal = amplitudeGlobal;
      end
      if nargin >= 8
        obj.circular = circular;
      end
      if nargin >= 9
        obj.normalized = normalized;
      end
      if nargin >= 10
        obj.cutoffFactor = cutoffFactor;
      end
      
      if numel(obj.size) == 1
        obj.size = [1, obj.size];
      end
    end
    
    
    % step function
    function obj = step(obj, time, deltaT) %#ok<INUSD>
       input = obj.inputElements{1}.(obj.inputComponents{1});
       obj.output = obj.amplitudeExc.* input*obj.kernel;
            
            
    
    end
    
    
    % initialization
    function obj = init(obj)
     
     
       temp=ones(obj.size);
       temp=ones(1,obj.size(2))
       temp_diag=diag(temp(1:end-1),-1);
       obj.kernel = temp_diag;
      
      
      obj.output = zeros(obj.size);
      
    end

  end
end


