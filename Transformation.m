% Translation only provides as a base class for all the transformation type

classdef Transformation
    properties
        % refer to http://www.cosc.brocku.ca/Offerings/3P98/course/lectures/2d_3d_xforms/
        transformationMatrix = eye(4);
    end
    methods 
        function obj = Transformation(varargin)
        % constructor
        % 1. obj = Transformation() % null constructor
        % 2. obj = Transformation(transformation) % copy constructor
        % 3. obj = Transformation(transformationmatrix) % build directly
        % from transformation matrix
            if nargin == 0
                obj.transformationMatrix = eye(4);
            elseif nargin==1 && isa(varargin{1}, 'Transformation')
                tr= varargin{1};
                obj.transformationMatrix = tr.transformationMatrix;
            elseif nargin==1
                obj.transformationMatrix = varargin{1};
            end           
        end
        function obj = setTransformation(obj, tr)
            obj.transformationMatrix = tr.transformationMatrix;   
        end
        function result = transform(obj, in)
        % numerical error can be negligeable
        % function type
        % 1. point = Transformation.transform(point)
        % 2. vector = Transformation.transform(vector)
            result = in;
            tm = obj.transformationMatrix; %limitation caused by non handle class  
            if isa(in,'Point') || isa(in, 'Frame') 
                result.coors(1) = sum(tm(1,1:3).*(in.coors')) + tm(1,4);
                result.coors(2) = sum(tm(2,1:3).*(in.coors')) + tm(2,4);
                result.coors(3) = sum(tm(3,1:3).*(in.coors')) + tm(3,4);
            else isa(in, 'Vector')
                result.coors(1) = sum(tm(1,1:3).*(in.coors'));
                result.coors(2) = sum(tm(2,1:3).*(in.coors'));
                result.coors(3) = sum(tm(3,1:3).*(in.coors'));     
            end
        end
        function result = eq(a,b)
            if ~isa(a,'Transformation') || ~isa(b,'Transformation')
               error('input argument type error'); 
            end
            if a.transformationMatrix == b.transformationMatrix
                result = true;
            else
                result = false;
            end
        end
        function result = ne(a,b)
            if a==b
                result = false;
            else
                result = true;
            end 
        end
        function result = mtimes(tt1, tt2)
        % Multiply two transformations to yield a 3rd.
        % The application of these transformations
        % to a point, vector, or frame is defined
        % in the sense that first the transformation tt2
        % is applied, and then the transformation tt1
        % is applied.  In matrix form, this means
        % that this function performs a left matrix
        % multiply of the transformation tt2 by the 
        % transformation tt1.  That is, the arguments
        % are read right to left.     
            result = Transformation(tt1.transformationMatrix*tt2.transformationMatrix);
        end    
        function result = inverse(obj)
        % can't directly inverse the transformation matrix
            mat = obj.transformationMatrix;
            dx = mat(1,4); dy = mat(2,4); dz = mat(3,4);
            mat = mat(1:3,1:3);
            matinv = inv(mat);
            mat = eye(4); mat(1:3, 1:3) = matinv;
            transformation1 = Transformation(mat);
            mat = eye(4); 
            mat(1,4) = dx; mat(2,4) = dy; mat(3,4) = dz; % this part is different from Arroyo definition
            transformation2 = Transformation(mat);
            result = transformation2 * transformation1;
        end
    end
end

