classdef PixelAmpArray < PixelArray
   properties
       
   end
   properties(Constant=true)
       
   end
   methods
       function obj = PixelAmpArray(varargin)
            % class constructor
            % could be
            % 1. pixelAmpArray()
            % 2. pixelAmpArray(pixelAmpArray)
            % 3. pixelAmpArray(pixelArray)
            % 4. pixelAmpArray(double axes, double data[], double wts[])
            superarg = varargin;
            obj = obj@PixelArray(superarg{:});
       end
       function [mean, rms] = meanAndRMS(obj)
       
       end
       function obj = sigmaClip(obj, niter, sigma_clip)
           
       end
       function obj = ampClip(obj, min, max)
           
       end
       function obj = interpolate(obj)
       
       end
       function [fitted_psf, fit_residual, orig] = fitAmpArray(psf, differential_amplitude, relative_offset)
       
       end
       
   end
end