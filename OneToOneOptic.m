classdef OneToOneOptic < Optic
   methods (Access=protected)
       function result = getWavefrontData(wf)
          result = wf.wfdata; 
       end
       function result = isRealImagStorage(wf)
          result = wf.realImag;
       end
       function result = isInterleavedStorage(wf)
          result = wf.interleaved;
       end
       function new_wf = wavefrontRealImagConversion(wf)
          new_wf = wf.realImagConversion(); 
       end
       function new_wf = wavefrontAmpPhaseConversion(wf)
          new_wf = wf.ampPhaseConversion(); 
       end
   end
   
   methods (Abstract)
        wf = transform(wf); % don't know this one is useful or not
   end
end