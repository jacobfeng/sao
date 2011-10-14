classdef PowerLaw
   properties
   % coefficient * (spatial_frequency.^exponent); 
       exponent = 0;
       coefficient = 0;
   end
   methods
       function obj = PowerLaw(varargin)
       % constructors
       % 1. obj = PowerLaw() Null constructor
       % 2. obj = PowerLaw(double exponent, double coeff) 
       % 3. obj = PowerLaw(double exponent, double r0_meters, double
       % r0_refwavelength_meters)
            if nargin==0
                obj.exponent = 0;
                obj.coefficient = 0;
            elseif nargin==2
                obj.exponent = varargin{1};
                obj.coefficient = varargin{2};
            elseif nargin==3
                obj.exponent = varargin{1};
                r0_meters = varargin{2};
                r0_ref_meters = varargin{3};
                % the following equation comes from the definiton of fried
                % parameter
                % r0 = (0.423 * (2pi/lamda)^2 * integrated_cn2)^(-3/5)
                % lambda = r0_ref_meters
                integrated_cn2_profile = (r0_meters^(-5/3))*(r0_ref_meters^2)/.423/4/(pi^2);
                % check [Davis, 1994, eq.12], [Hardy, 1998, eq.3.14]
                % the whole calculation is based on Johansson & Gavel,
                % "Simulation of stellar speckle imaging", eq(4)
                obj.coefficient = 0.033*integrated_cn2_profile;
            end
       end
       function result = value(obj, spatialfrequency)
           % spatial frequency is in pi/m 
          result = obj.coefficient * (spatialfrequency.^obj.exponent); 
       end
       function result = poleAtZeroSpatialFrequency(obj)
       % for standard kolmogorov spectrum, there is a pole at zero    
          result = true; 
       end
       function result = getCoefficient(obj)
          result = obj.coefficient; 
       end
       function result = getExponent(obj)
          result = obj.exponent; 
       end
       function result = eq(a,b)
          if isa(a, 'PowerLaw') && isa(b, 'PowerLaw')
              if (a.exponent == b.exponent) && (a.coefficient == b.coefficient)
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