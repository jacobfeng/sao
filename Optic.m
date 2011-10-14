classdef Optic
   properties
       foreshortening = true;
   end
   methods
       function obj = Optic(varargin)
            arg = {};
            if nargin~=0
               arg = varargin{:}; 
            end
            if nargin==1 && isa(arg,'Optic')
               obj.foreshortening = arg.foreshortening; 
            elseif islogical(arg)
               obj.foreshortening = arg;
            end
       end
       function result = getForeShortening(obj)
          result = obj.foreshortening;
       end
       function obj = setForeShortening(obj, var)
          obj.foreshortening = var; 
       end
   end
   methods(Abstract)
       getCoveringRegion(tf);
       getPointOfIntersection(tp, tv)
   end    
end