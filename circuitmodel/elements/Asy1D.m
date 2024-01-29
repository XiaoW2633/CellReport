% AsymtryLateral1D (COSIVINA toolbox)
%   Connective perform asymtry connection pattern, element that performs a 1D convolution with a Mexican hat
% plus its derivation



classdef Asy1D < Element
    
    properties (Constant)
        parameters = struct('size', ParameterStatus.Fixed, 'sigmaExc', ParameterStatus.InitStepRequired, ...
            'amplitudeExc', ParameterStatus.InitStepRequired, 'sigmaInh', ParameterStatus.InitStepRequired, ...
            'amplitudeInh', ParameterStatus.InitStepRequired, 'amplitudeGlobal', ParameterStatus.Changeable, ...
            'velocity', ParameterStatus.InitStepRequired,...
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
        velocity = -100;
        later1D
        cutoffFactor = 5;
        normalized = false;
        % accessible structures
        kernel1
        kernel
        output
        fullSum
        sym
        asy
    end
    
    properties (SetAccess = protected)
        kernelRangeLeft
        kernelRangeRight
        extIndex
    end
    
    methods
        % constructor
        function obj = Asy1D(label, size, sigmaExc, amplitudeExc, sigmaInh, amplitudeInh, ...
                amplitudeGlobal, velocity, later1D ,normalized,cutoffFactor)
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
                obj.velocity = velocity;
            end
            if nargin >= 9
                obj.later1D = later1D;
            end
            if nargin >= 10
                obj.normalized = normalized;
            end
            if nargin >= 11
                obj.cutoffFactor = cutoffFactor;
            end
            
            if numel(obj.size) == 1
                obj.size = [1, obj.size];
            end
        end
        
        
        % step function
        function obj = step(obj, time, deltaT) %#ok<INUSD>
            input = obj.inputElements{1}.(obj.inputComponents{1});
            obj.fullSum = sum(input, 2);
            
            
            obj.output = conv2(1, obj.kernel, input, 'same') ...
                + obj.amplitudeGlobal * obj.fullSum;
            
        end
        
        
        % initialization
        function obj = init(obj)
            kernelRange = obj.cutoffFactor ...
                * max( (obj.amplitudeExc ~= 0) * obj.sigmaExc, (obj.amplitudeInh ~= 0) * obj.sigmaInh );
            %       if obj.circular
            %         obj.kernelRangeLeft = min(ceil(kernelRange), floor((obj.size(2)-1)/2));
            %         obj.kernelRangeRight = min(ceil(kernelRange), ceil((obj.size(2)-1)/2));
            %         obj.extIndex = [obj.size(2) - obj.kernelRangeRight + 1 : obj.size(2), 1 : obj.size(2), 1 : obj.kernelRangeLeft];
            %       else
            obj.kernelRangeLeft = min(ceil(kernelRange), (obj.size(2)-1));
            obj.kernelRangeRight = obj.kernelRangeLeft;
            obj.extIndex = [];
            if obj.normalized
                
                W_1D_o = obj.amplitudeExc * gaussNorm(-obj.kernelRangeLeft : obj.kernelRangeRight, 0, obj.later1D(1));
                W_1D_ = gauss_drv(-obj.kernelRangeLeft : obj.kernelRangeRight,0,obj.later1D(1));
                
                W_exc_o = obj.amplitudeExc * gauss(-obj.kernelRangeLeft : obj.kernelRangeRight, 0, obj.sigmaExc);
                W_exc_  =  gauss_normdrv(-obj.kernelRangeLeft : obj.kernelRangeRight,0,obj.sigmaExc);
                
                W_inh_o= obj.amplitudeInh * gauss(-obj.kernelRangeLeft : obj.kernelRangeRight, 0, obj.sigmaInh);
                W_inh_= gauss_normdrv(-obj.kernelRangeLeft : obj.kernelRangeRight,0,obj.sigmaInh);
                
                W_exc=W_exc_o+obj.velocity*gauss_drv(-obj.kernelRangeLeft : obj.kernelRangeRight,0,obj.later1D(1));
                W_inh=W_inh_o+0*gauss_drv(-obj.kernelRangeLeft : obj.kernelRangeRight,0,obj.later1D(3))/3;
                obj.kernel=(W_exc-W_inh)/(obj.size(2)/20);%p=20
                %  obj.kernel = obj.kernel+obj.velocity*gauss_drv(-obj.kernelRangeLeft : obj.kernelRangeRight,0,obj.later1D(1));
            else
%                 W_1D_o = obj.amplitudeExc * gauss(-obj.kernelRangeLeft : obj.kernelRangeRight, 0, obj.later1D(1));
%                 W_1D_ = gauss_drv(-obj.kernelRangeLeft : obj.kernelRangeRight,0,obj.later1D(1));
%                 
%                 W_exc_o = obj.amplitudeExc * gauss(-obj.kernelRangeLeft : obj.kernelRangeRight, 0, obj.sigmaExc);
%                 W_exc_ = gauss_drv(-obj.kernelRangeLeft : obj.kernelRangeRight,0,obj.sigmaExc);
%                 
%                 W_inh_o= obj.amplitudeInh * gauss(-obj.kernelRangeLeft : obj.kernelRangeRight, 0, obj.sigmaInh);
%                 W_inh_= gauss_drv(-obj.kernelRangeLeft : obj.kernelRangeRight,0,obj.sigmaInh);
%                 
%                 W_exc=W_exc_o+obj.velocity*gauss_drv(-obj.kernelRangeLeft : obj.kernelRangeRight,0,obj.later1D(1));
%                 W_inh=W_inh_o+0*gauss_drv(-obj.kernelRangeLeft : obj.kernelRangeRight,0,obj.later1D(3))/3;
%                 obj.kernel=(W_exc-W_inh)/(obj.size(2)/20);%p=2.3
              
                
                
                W_exc_o = obj.amplitudeExc * gauss(-obj.kernelRangeLeft : obj.kernelRangeRight, 0, obj.sigmaExc);
                
                
                W_inh_o= obj.amplitudeInh * gauss(-obj.kernelRangeLeft : obj.kernelRangeRight, 0, obj.sigmaInh);
                
                obj.asy = obj.velocity*gauss_drv(-obj.kernelRangeLeft : obj.kernelRangeRight,0,obj.later1D(1));
                obj.asy = obj.asy/(obj.size(2)/20);
                
                
                obj.kernel1=(W_exc_o-W_inh_o)/(obj.size(2)/20);%p=2.3
                obj.kernel = obj.kernel1 + obj.asy;
            end
            
            obj.fullSum = 0;
            obj.output = zeros(obj.size);
            
        end
        
    end
end


