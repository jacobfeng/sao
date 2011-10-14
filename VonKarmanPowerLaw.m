classdef VonKarmanPowerLaw < PowerLaw
   % description can be found in, Patrick Cassen, 'Extrasolar planets',
   % eq. 175, eq 176 for calculation of the power spectrum    
   properties
   % coefficient * (spatial_frequency.^exponent); 
       outerscalevalue = 0;
   end
   methods
       function obj = VonKarmanPowerLaw(varargin)
       % constructors
       % 1. obj = VonKarmanPowerLaw() Null constructor
       % 2. obj = VonKarmanPowerLaw(VonKarmanPowerLaw) copy constructor
       % 3. obj = VonKarmanPowerLaw(double exponent, double coeff, double outscale) 
       % 4. obj = VonKarmanPowerLaw(double exponent, double r0_meters, double
       % r0_refwavelength_meters, double outscale)
            if nargin==0
                obj.exponent = 0;
                obj.coefficient = 0;
                obj.outerscalevalue = 0;
            elseif nargin==1
                in = varargin{1};
                obj.exponent = in.exponent;
                obj.coefficient = in.coefficient;
                obj.outerscalevalue = in.outerscalevalue;
            elseif nargin==3
                obj.exponent = varargin{1};
                obj.coefficient = varargin{2};
                obj.outerscalevalue = varargin{3};
            elseif nargin==4
                obj.exponent = varargin{1};
                r0_meters = varargin{2};
                r0_ref_meters = varargin{3};
                obj.outerscalevalue = varargin{4};
                % the following equation comes from the definiton of fried
                % parameter
                % r0 = (0.423 * (2pi/lamda)^2 * integrated_cn2)^(-3/5)
                integrated_cn2_profile = (r0_meters^(-5./3))*(r0_ref_meters^2)/.423/4/(pi^2);
                % check [Davis, 1994, eq.12], [Hardy, 1998, eq.3.14]
                % obj.coefficient = 2*pi*.033*integrated_cn2_profile;
                obj.coefficient = .033*integrated_cn2_profile;
            end
       end
       function result = value(obj, spatialfrequency)
           % spatial frequency is in pi/m 
          result = obj.coefficient * ((spatialfrequency.^2+(2*pi/obj.outerscalevalue)^2).^(obj.exponent/2)); 
       end
       function result = poleAtZeroSpatialFrequency(obj)
       % for standard kolmogorov spectrum, there is a pole at zero    
          result = false; 
       end
       function result = getOuterScale(obj)
          result = obj.outerscalevalue;
       end
       function result = eq(a,b)
          if isa(a, 'VonKarmanPowerLaw') && isa(b, 'VonKarmanPowerLaw')
              if (a.exponent == b.exponent) && (a.coefficient == b.coefficient) && (a.outerscalevalue == b.outerscalevalue)
                    result = true;
              end
          end
          result = false;
       end
       function result = ne(a,b)
          result = ~(a==b); 
       end
   end 
end