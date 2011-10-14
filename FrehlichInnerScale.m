classdef FrehlichInnerScale
% a power spectrum modifier, for detailed equations please refer to the
% following two paper
% Charles A. Davis and D. L. Walters, "Atmospheric inner-scale effects on normalized irradiance variance," Appl. Opt. 33, 8406-8411 (1994) 
% R. G. Frehlich, "Laser Scintillation Measurement of the temperature spectrum in the atmospheric suface layer". Journal of the atmophseric sciences, Vol.49, No.16, (1991)
   properties
       innerscale = 0;
   end
   methods
       function obj = FrehlichInnerScale(innerScale)
            obj.innerscale = innerScale;
       end
       function result = UniqueName(obj)
       % for plotting, adding legend
            result = 'FrehlichInnerScale';
       end
       function result = value(obj, spatialFrequency)
       % return the value at a given spatial frequency in unit of (rad/m)
       % eq 23 in Frehlich 
           delta = 1.109; 
           a = [0.70937,2.8235,-0.28086,0.08277];
           tmp = 1+(spatialFrequency*obj.innerscale)*a(1)+((spatialFrequency*obj.innerscale).^2)*a(2)+((spatialFrequency*obj.innerscale).^3)*a(3)+((spatialFrequency*obj.innerscale).^4)*a(4);
           expo = exp(-delta*spatialFrequency*obj.innerscale);
           result = tmp.*expo;
       end
       function result = eq(a,b)
           result = (a.innerscalevalue==b.innerscalevalue); 
       end
       function result = ne(a,b)
           result = ~(a==b); 
       end
   end
end