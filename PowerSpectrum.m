classdef PowerSpectrum
% power spectrum is the defined as in Davis 1994 eq.12
% powerspectrum = powerlaw*innerscalefunction 
% abstract class
    properties
        powerlaw;
        innerscale;
    end
    methods(Abstract)
        result = value(obj, spatialFrequency)
        result = getCoefficient(obj)
        result = poleAtZeroSpatialFrequency(obj)
    end
end