classdef Translation < OrthonormalTransformation
%class implements the orthonormal translation from one point to another
%point, could be used for point, frame, vector
    methods
       function obj = Translation(varargin)
       % constructor
       % obj = Translation()
       % obj = Translation(translation)
       % obj = Translation(vector)
         obj = obj@OrthonormalTransformation();
         if nargin == 1 && isa(varargin{1},'Translation')
             tr = varargin{1};
             obj.transformationMatrix = tr.transformationMatrix;
         elseif nargin == 1 && isa(varargin{1},'Vector')
             tf = Frame();
             v = varargin{1};
             obj.transformationMatrix = eye(4);
             obj.transformationMatrix(1,4) = v.x(tf);
             obj.transformationMatrix(2,4) = v.y(tf);
             obj.transformationMatrix(3,4) = v.z(tf);
         end         
       end
       function result = inverse(obj)
           result = Translation();
           tmp = inverse@OrthonormalTransformation(obj);
           result = result.setTransformation(tmp);
       end
   end
end