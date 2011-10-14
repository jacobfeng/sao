classdef PlaneOptic < Optic & Frame
    properties
        
    end
    methods
        function result = getPointOfIntersection(tp, tv)
            result = getRayPlaneIntersection(tp,tv,obj,obj.z());       
        end    
        function [origin_offset, dx, dy] = getProjectedWavefrontPixelSpacing(obj, wf)
            % not tested yet
            if abs(wf.z().*obj.z())<Frame.precision
               error('projection error, wavefront plane is orthogonal to plane optic');
            end
            origin_offset = wf.getzp() - obj.getzp();
            if abs(origin_offset.*obj.z())>Frame.precision
               error('projection error, wavefront plane is not in the transverse plane of the optic'); 
            end
            
            wf_pixel_scale = wf.getPixelScale();
            dx = wf.x().*wf_pixel_scale;
            dy = wf.y().*wf_pixel_scale;
            dx = parallelProjection(dx, obj.z(), wf.z());
            dy = parallelProjection(dy, obj.z(), wf.z());
            if ~obj.foreshortening
                dx = dx.*(wf_pixel_scale/dx.length());
                dy = dy.*(wf_pixel_scale/dy.length());
            end
        end
    end
end