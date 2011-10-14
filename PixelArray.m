classdef PixelArray 
   properties
      private_nelem = -1; % elements number % this value should be obsolete, since all data are public
      axes = zeros(2,1); % pixels number in x/y direction, axes(1) is the row number, axes(20 is the column number
      pixeldata = [];
      pixelwts = [];
   end
   methods
       function obj = setAxes(obj, in_axes)
       % note each time the axes is reset, the pixeldata related would be reinitialized
           if sum(in_axes-obj.axes)~=0
               obj.axes = in_axes;
               obj.private_nelem = in_axes(1)*in_axes(2);
               obj.pixeldata = zeros(obj.axes(1), obj.axes(2));
               obj.pixelwts = [];
           end
       end
       function obj = allocateWeights(obj, wt)
       % allocate weights
           [sizex, sizey] = size(obj.pixeldata);
           obj.pixelwts = wt*ones(sizex, sizey);
       end
       function obj = deallocateWeights(obj)
       % deallocate weights
           obj.pixelwts = [];
       end
       function obj = normalizeByWeights(obj)
       % functions to normalize data by weights
           if ~weightsAllocated()
               return;
           end
           maxwts = max(max(obj.pixelwts));
           for i=1:size(obj.axes(1))
               for j=1:size(obj.axes(2))
                   if obj.pixelwts(i,j)<maxwts || obj.pixelwts(i,j)~=0
                       obj.pixeldata(i,j) = maxwts/(obj.pixelwts(i.j))*obj.pixeldata(i,j);
                       obj.pixelwts(i,j) = maxwts;
                   elseif obj.pixelwts(i,j)==0
                       obj.pixeldata(i,j) = 0;
                   end
               end
           end
       end
       function obj = descimate(obj, nadd)
       % function to bin data together n amplitude, only works for 2d amplitude array
       % along with data binning, the weights array if allocated, will also
       % be binned and summed, and put into the new weights array
            if length(obj.axes)~=2
                error('can not decimate with the current number of dimension');
            end
            if nadd<0 || nadd>obj.axes(1) || nadd>obj.axes(2)
                error('can not decimate by a factor of nadd')
            end
            if nadd==0 || nadd==1 
                return;
            end
            newaxes = zeros(2,1);
            newaxes(1) = floor(obj.axes(1)/nadd); 
            newaxes(2) = floor(obj.axes(2)/nadd);
            olddata = obj.pixeldata;
            obj.pixeldata = zeros(newaxes(1), newaxes(2));
            if obj.weightsAllocated()
               oldwts = obj.pixelwts;
               obj.pixelwts = zeros(newaxes(1), newaxes(2)); 
            end
            for i=1:newaxes(1)
                for j=1:newaxes(2)
                    datablk = olddata((i-1)*nadd+1:(i*nadd), (j-1)*nadd+1:(j*nadd));
                    if obj.weightsAllocated()
                        wtsblk = oldwts((i-1)*nadd+1:(i*nadd), (j-1)*nadd+1:(j*nadd));
                        wtsum = sum(sum(datablk.*wtsblk));
                        obj.pixelwts(i,j) = wtsum;
                    else
                        wtsum = sum(sum(datablk));
                    end
                    obj.pixeldata(i,j) = wtsum;
                end
            end
            obj.axes = newaxes;
            obj.private_nelem = obj.axes(1)*obj.axes(2);
       end
       function obj = mask(obj, varargin)
       % function to make this pixel array into a mask of 1s and 0s based on the value of the pixeldata    
       % 1. obj = mask(obj)
       % function to apply a mask
       % 2. obj = mask(obj, pixarray)
            if isempty(varargin{:})==0
                obj.pixeldata = double(obj.pixeldata~=0);
                obj.pixelwts = obj.pixeldata;
            elseif length(varargin{:})==1
                pixarray = varargin{1};
                if pixarray.getAxes()~=obj.axes;
                    error('shape mismatched');
                end
                obj.pixelwts = double(pixarray.pixeldata~=0);
                obj.pixeldata = obj.pixeldata.*obj.pixelwts;
            end
       end
       function obj = flagZeroWts(obj, pixarr)
       % function to flag weights that are zero in arg
            if isempty(pixarr.pixelwts)
               error('object does not have weight allocated'); 
            end
            obj.pixelwts = double(pixarr.pixelwts~=0);
            obj.pixeldata = obj.pixeldata.*obj.pixelwts;
       end
       function obj = PixelArray(varargin)
       % constructor
       % 1. PixelArray() Null constructor
       % 2. PixelArray(pixelArray) copy constructor
       % 3. PixelArray(pixelArray, array<double> pixelLimits) partial copy
       % constructor
       % 4. PixelArray(array<double>inaxes, double data=zeros, double wts=zeros)
       % constructor, please note that inaxes should be like [5;5] which
       % has size (2,1)
       
            if nargin==0 % null constructor
                obj.private_nelem = -1;
                obj.pixeldata = [];
                obj.pixelwts = [];
                obj.axes = [];
            elseif nargin==1 
                if isa(varargin{1},'PixelArray') % copy constructor
                    obj.private_nelem = varargin{1}.private_nelem;
                    obj.axes = varargin{1}.axes;
                    obj.pixeldata = varargin{1}.pixeldata;
                    obj.pixelwts = varargin{1}.pixelwts;
                elseif isa(varargin{1}, 'double') % 4th constructor with default value
                    obj = obj.setAxes(varargin{1});
                end
            elseif nargin==2
                if isa(varargin{1},'PixelArray') % partial copy constructor, currently only works for 2D pixel array
                    pixelarr = varargin{1};
                    pixelLimits = varargin{2};
                    paxes = pixelarr.getAxes();
                    % for x axis
                    if pixelLimits(2)>paxes(1) || pixelLimits(1)<0
                        error('out of boundary');
                    end
                    tmpaxes = zeros(2,1);
                    tmpaxes(1) = pixelLimits(2)-pixelLimits(1)+1;
                    if tmpaxes(1)<=0
                        error('undefined pixel limits');
                    end
                    % for y axis
                    if pixelLimits(4)>paxes(2) || pixelLimits(3)<0
                        error('out of boundary');
                    end
                    tmpaxes(2) = pixelLimits(4)-pixelLimits(3)+1;
                    if tmpaxes(2)<=0
                        error('undefined pixel limits');
                    end    
                    obj = obj.setAxes(tmpaxes);
                    if ~isempty(pixelarr.pixelwts)
                       obj = obj.allocateWeights(0);
                    else 
                        obj.pixelwts = [];
                    end
                    obj.pixeldata = pixelarr.pixeldata(pixelLimits(1):pixelLimits(2), pixelLimits(3):pixelLimits(4));
                    if ~isempty(obj.pixelwts)
                        obj.pixelwts = pixelarr.pixelwts(pixelLimits(1):pixelLimits(2), pixelLimits(3):pixelLimits(4));
                    end
                elseif isa(varargin{1}, 'double') % 4th constructor with default value for data
                    obj = obj.setAxes(varargin{1});
                    if (obj.axes)'~=(size(varargin{2}))
                       error('axis size does not correspond to pixel data size'); 
                    end
                    obj.pixeldata = varargin{2};
                end
            elseif nargin==3 % 4th constructor with non default value
                %%%%%%%%%% something fishy here
                obj = obj.setAxes(varargin{1});
                if (obj.axes)'~=(size(varargin{2}))
                       error('axis size does not correspond to pixel data size'); 
                end
                obj.pixeldata = varargin{2};
                obj.pixelwts = varargin{3};
            end
       end
       function result = eq(a, b)
       % overloading eq function    
           if sum(a.axes-b.axes)~=0
               result = false;
               return;
           end
           if sum(a.pixeldata-b.pixeldata)~=0
               result = false;
               return;
           end
           if sum(a.pixelwts-b.pixelwts)~=0
               result = false;
               return;
           end
           result = true;
       end
       function result = totalSpace(obj)
       % return the total size of the obj
        if obj.private_nelem>0
            result = obj.private_nelem;
            return;
        end
        result = naxes(1)*naxes(2);
       end
       function result = weightsAllocated(obj)
       % determine wether the object has allocated its weights    
           if isempty(obj.pixelwts)
               result = false;
           else
               result = true;
           end  
       end
       function result = getAxes(obj)
       % return the axes of the 
           result = obj.axes;
       end
       function result = data(obj, n)
       % data is stored columwise in Matlab, but rowwise in C
       % so in C n=(i-1)*obj.axes(1)+(j-1)+1
           if n<1 || n>obj.totalSpace()
               error('out of range')
           end
           row = floor((n-1)/obj.axes(2))+1;
           col = mod(n-1, obj.axes(2))+1;
           result = obj.pixeldata(row,col);
       end
       function obj = setData(obj, n, val)
       % data is stored columwise in Matlab, but rowwise in C
       % so in C n=(i-1)*obj.axes(1)+(j-1)+1
           if n<1 || n>obj.totalSpace()
               error('out of range')
           end
           row = floor((n-1)/obj.axes(2))+1;
           col = mod(n-1, obj.axes(2))+1;
           obj.pixeldata(row, col) = val;          
       end
       function result = wt(obj, elem)
       % data is stored columwise in Matlab, but rowwise in C
       % so in C n=(i-1)*obj.axes(1)+(j-1)+1
           if elem<1 || elem>obj.totalSpace()
               error('out of range')
           end
           row = floor((elem-1)/obj.axes(2))+1;
           col = mod(elem-1, obj.axes(2))+1;
           result = obj.pixelwts(row,col);  
       end
       function [minresult, maxresult, minrow, mincol, maxrow, maxcol] = minAndMax(obj, rowsmin, rowsmax, colmin, colmax)
           [tmp, minrow] = min(obj.pixeldata(rowsmin:rowsmax, colmin:colmax));
           [minresult, mincol] = min(tmp);
           [tmp, maxrow] = max(obj.pixeldata(rowsmin:rowsmax, colmin:colmax));
           [maxresult, maxcol] = max(tmp);
       end
       function obj = flipX(obj)
           obj.pixeldata = fliplr(obj.pixeldata);
           obj.pixelwts = fliplr(obj.pixelwts);
       end
       function obj = flipY(obj)
           obj.pixeldata = flipud(obj.pixeldata);        
           obj.pixelwts = fliplr(obj.pixelwts);
       end
       function obj = flipXY(obj)
           obj = obj.flipX();
           obj = obj.flipY();
       end
       function obj = flip45(obj)
           obj.pixeldata = obj.pixeldata'; 
           obj.pixelwts = obj.pixelwts';
           obj.axes = flipud(obj.axes);
       end
       function obj = padArray(obj, npad, value)
       % pad each edge of array by npad pixels and initizliat to the speicified value     
           if npad<0
              error('pad error can not pad by negative number of pixels'); 
           end
           if npad==0 || (obj.axes(1)==0 && obj.axes(2)==0)
              return; 
           end
           olddata = obj.pixeldata;
           oldwts = obj.pixelwts;
           new_dimen = obj.axes+npad*2;
           % allocate and initialize the value
           obj.pixeldata = ones(new_dimen(1), new_dimen(2))*value;
           if ~isempty(oldwts)
              obj.pixelwts = zeros(new_dimen(1), new_dimen(2));
           end
           % copy all the old load to the new shit loads
           obj.pixeldata(npad+1:(new_dimen(1)-npad),npad+1:(new_dimen(2)-npad)) = olddata;
           if ~isempty(oldwts)
              obj.pixelwts(npad+1:(new_dimen(1)-npad),npad+1:(new_dimen(2)-npad)) = oldwts;
           end
           obj.axes = new_dimen;
           obj.private_nelem = new_dimen(1)*new_dimen(2);
       end
       function obj = clipArray(obj, nclip)
       % clip the array by nclip pixels on each edge
           if nclip==0 
               return;
           end
           if nclip<0
               error('can not clip by negative number of pixels')
           end
           obj.axes = obj.axes-2*nclip;
           for i=1:2
               if obj.axes(i)<=0
                    error('clipping original array into a non positive array size');
               end
           end
           olddata = obj.pixeldata;
           oldwts = obj.pixelwts;
           rows = size(olddata,1); cols = size(olddata,2);
           obj.pixeldata = olddata(nclip+1:(rows-nclip),nclip+1:(cols-nclip));
           if ~isempty(oldwts)
               obj.pixelwts = oldwts(nclip+1:(rows-nclip), nclip+1:(cols-nclip));
           end
           obj.private_nelem = obj.axes(1)*obj.axes(2);
       end
       function obj = shiftByFFT(obj, dx, dy)
       % this function currently directly use the function provided by FourierShift2D()
       % this function also shift the weights for the pixel array. please
       % note this. disable this feature if not use
       % right and down is positive
       if ~isempty(obj.pixelwts)
                obj.pixelwts = FourierShift2D(obj.pixelwts,[dy,dx]);
            end
            obj.pixeldata = FourierShift2D(obj.pixeldata,[dy,dx]);
       end
       function obj = rotateByFFT(obj, angle_in_radian)
       % this function is implemented with the 3 pass FFT methods, which is
       % super slow, but might be necessary for subpixel precision, doesn't
       % support a pixelwts allocated pixelArray, angle is in radian,
       % postiive direction is counter clockwise
            if ~isempty(obj.pixelwts)
                error('doese not support pixel weighted pixel array');
            end
            obj.pixeldata = RotateImage(obj.pixeldata, angle_in_radian/pi*180);
       end
       function result = crossCorrelate(obj, pixarr)
       % this function calculate the 2D cross correlate of the current pixel array with the input pixarr
       % doesn't use the pixelwts
            result = PixelArray();
            result.pixeldata = xcorr2(obj.pixeldata, pixarr.pixeldata);
            result.pixelwts = [];
            result.axes = zeros(2,1);
            result.axes(1) = size(result.pixeldata,1);
            result.axes(2) = size(result.pixeldata,2);
       end
       function offsets = offset(obj, refPixArray, usfac)
       % 2d 	 registration by cross correlation, the images are
       % registered to within 1/usfac of a pixel
       % "Efficient subpixel image registration algorithms"
       % Manuel Guizar Sicairos
            upsamplingFactor = 1/usfac;
            output = dftregistration(fft2(refPixArray.pixeldata), fft2(obj.pixeldata),  upsamplingFactor);
            offsets = zeros(2,1); 
            offsets(1) = -1*output(3); % row shift 
            offsets(2) = -1*output(4); % col shift
       end
       function result = plus(a,b)
           if sum(a.axes-b.axes)~=0
               error('input arrays size mismatched')
           end
           result = PixelArray();
           result.axes = a.getAxes();
           result.pixeldata = a.pixeldata+b.pixeldata;
           if (~isempty(a.pixelwts) && isempty(b.pixelwts))
               result.pixelwts = a.pixelwts;
           elseif (~isempty(b.pixelwts) && isempty(a.pixelwts))
               result.pixelwts = b.pixelwts;
           elseif ~isempty(a.pixelwts) && ~isempty(b.pixelwts)
               result = a.pixelwts + b.pixelwts;
           end
       end
       function result = minus(a,b)
       % mind this although pixel array's data is doing all kinds of
       % calculation, pixel array's weights only do sum
           if sum(a.axes-b.axes)~=0
               error('input arrays size mismatched')
           end
           result = PixelArray();
           result.axes = a.getAxes();
           result.pixeldata = a.pixeldata-b.pixeldata;
           if (~isempty(a.pixelwts) && isempty(b.pixelwts))
               result.pixelwts = a.pixelwts;
           elseif (~isempty(b.pixelwts) && isempty(a.pixelwts))
               result.pixelwts = b.pixelwts;
           elseif ~isempty(a.pixelwts) && ~isempty(b.pixelwts)
               result = a.pixelwts + b.pixelwts;
           end
       end
       function result = times(a,b)
       % this implementation is different from the arroyo version from weights calculation
       % here weights is not modified as a.pixel_wts+b.pixel_wts
           if sum(a.axes-b.axes)~=0
               error('input arrays size mismatched')
           end
           result = PixelArray();
           result.axes = a.getAxes();
           result.pixeldata = a.pixeldata.*b.pixeldata;
           
%            if (~isempty(a.pixelwts) && isempty(b.pixelwts))
%                result.pixelwts = a.pixelwts;
%            elseif (~isempty(b.pixelwts) && isempty(a.pixelwts))
%                result.pixelwts = b.pixelwts;
%            elseif ~isempty(a.pixelwts) && ~isempty(b.pixelwts)
%                result = a.pixelwts + b.pixelwts;
%            end
       end
       function result = mrdrivide(a,b)
           if a.axes~=b.axes
               error('input arrays size mismatched')
           end
           result = PixelArray();
           result.axes = a.getAxes();
           result.pixeldata = a.pixeldata./b.pixeldata;
       end
   end 
end