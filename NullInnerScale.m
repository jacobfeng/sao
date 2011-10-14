classdef NullInnerScale
   methods
       function obj = NullInnerScale()
       end
       function result = UniqueName(obj)
          result = 'Null Inner Scale'; 
       end
       function result = value(obj, spatialFrequency)
       % return the value at a given spatial frequency
          result = ones(size(spatialFrequency)); 
       end
   end
end