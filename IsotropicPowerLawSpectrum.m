classdef IsotropicPowerLawSpectrum < PowerSpectrum
    methods
        function obj = IsotropicPowerLawSpectrum(varargin)
        % constructor
        % 1. obj = IsotropicPowerLawSpectrum(IsotropicPowerLawSpectrum) copy
        % constructor
        % 2. obj = IsotropicPowerLawSpectrum(powerlaw, innerscale) 

            % null constructor
            if nargin == 1
                obj.powerlaw = varargin{1}.powerlaw;
                obj.innerscale = varargin{1}.innerscale;
            % copy constructor
            elseif nargin == 2
            % constructor 2
                obj.powerlaw = varargin{1};
                obj.innerscale = varargin{2};
            end
        end
        function result = getCoefficient(obj)
            result = obj.powerlaw.getCoefficient();
        end
        function result = value(obj, spatialFrequency)
            result = obj.powerlaw.value(spatialFrequency).*obj.innerscale.value(spatialFrequency);
        end
        function result = poleAtZeroSpatialFrequency(obj)
            result = obj.powerlaw.poleAtZeroSpatialFrequency();
        end
        function result = getPowerLaw(obj)
           result = obj.powerlaw; 
        end
        function result = getInnerScale(obj)
           result = obj.innerscale; 
        end
    end
end