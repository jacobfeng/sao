classdef Emitter 
   %Abstract class for emitter (spherical/plane/etc.). all emitter
   %implementation should inherits from this class
   methods (Abstract)
       result = emit(obj, wavefrontHeader) % emit a wavefront
       result = getEmissionVector(obj, point) % get the direction vector from emitter towards a point 
   end
end