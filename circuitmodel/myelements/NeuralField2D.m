% NeuralField2D (modified from COSIVINA toolbox/NeuralField)
%   Creates a 2D dynamic neural field (or set of discrete dynamic nodes) of
%   arbitrary dimensionality with sigmoid/relu output function. 
% 
% Constructor call:
% NeuralField(label, size, tau, h, beta)
%   label - element label
%   size - field size
%   tau - time constant (default = 10)
%   h - resting level (default = -5)
%   beta - steepness of sigmoid output function (default = 4)


classdef NeuralField2D < Element
  
  properties (Constant)
    parameters = struct('size', ParameterStatus.Fixed, 'tau', ParameterStatus.Changeable, ...
      'h', ParameterStatus.Changeable, 'alpha', ParameterStatus.Changeable...
       );
    components = {'activation', 'output', 'h'};
    defaultOutputComponent = 'output';
  end
  
  properties
    % parameters
    size = [1, 1];
    tau = 10;
    h = -5;
    alpha = 0.5; %
    % accessible structures
    activation
    output
    
  end
  
  methods
    % constructor and parse the inputs.
    function obj = NeuralField2D(label, size, tau, h, alpha)
      if nargin > 0
        obj.label = label;
        obj.size = size;
      end
      if nargin >= 3
        obj.tau = tau;
      end
      if nargin >= 4
        obj.h = h;
      end
      if nargin >= 5
        obj.alpha = alpha;
      end
      if nargin >= 6
        obj.m = m;
      end
      if nargin >= 7
        obj.tauV = tauV;
      end
      
      if numel(obj.size) == 1
        obj.size = [1, obj.size];
      end
    end
    
    
    % step function Euler method.
    function obj = step(obj, time, deltaT) %
      input = 0;
      % recieve two inputs: visual input('stimulus 1') and recurrent
      % ('field u -> field u').
      for i = 1 : obj.nInputs
        input = input + obj.inputElements{i}.(obj.inputComponents{i});
      end
      % Euler method
      obj.activation = obj.activation + deltaT/obj.tau * (- obj.activation + obj.h + input);
      
      % relu activation function.
      obj.output=obj.alpha*max(obj.activation,0);
    end
    
    
    % intialization
    function obj = init(obj)
      obj.activation = zeros(obj.size) ;

      obj.output=obj.alpha*max(obj.activation,obj.h);
    end
  end
end


