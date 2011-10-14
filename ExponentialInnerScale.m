classdef ExponentialInnerScale
% the innerscale class represent spectrum modifier rather than pure
% innerscale
% from Hardy, "Adaptive Optics for astronomical telescope", eq, 3.96
% we know that for von Karman spectrum the equation of -11/6 should be
% modified to f(k) = ((k^2 + k0^2)^(-11/6)) * (exp(-k^2/ki^2))
% k0 = 2pi/L0, L0 is the outter scale
% ki = 5.92/l0, l0 is the inner scale
    properties
        innerscalevalue = 0;
    end
    methods
        function obj = ExponentialInnerScale(innerscaleValue)
            obj.innerscalevalue = innerscaleValue;
        end
        function result = UniqueName(obj)
           result = 'Exponential Inner Scale'; 
        end
        function result = value(obj, spatialFrequency)
        % return the value at a given spatial frequency
        % eq 3.96 in Hardy
            result = exp(-(spatialFrequency.^2)*(obj.innerscalevalue.^2)/(5.92^2));
        end
        function result = eq(a,b)
            result = (a.innerscalevalue==b.innerscalevalue); 
        end
        function result = ne(a,b)
            result = ~(a==b); 
        end
    end
end