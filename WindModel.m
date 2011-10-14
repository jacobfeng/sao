classdef WindModel
   % abstract class for wind model derivative
   methods 
       function obj = WindModel() 
       end
   end
   methods(Abstract)
       result = getRandomWindVectors(height, ref_frame)
   end
end