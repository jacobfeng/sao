classdef Vector 
% class implements vector definition
% each vector has x, y, z defining the length of the vector projected to x,
% y, z axis
    properties
      coors = zeros(3,1);
    end
    properties(Constant=true)
      precision = 1e-10; % precision requirement for determining geometrical relationship 
    end
    methods
        function obj = Vector(varargin)
           %constructor
           % 1. obj = Vector(), default constructor
           % 2. obj = Vector(double, double, double), define a vector with
           % x, y, z projection in global coordination system
           % 3. obj = Vector(double, double, double, frame), define a vector
           % related to a reference coordinate system
           % 4. obj = Vector(Vector), copy constructor
           if nargin == 0
               obj.coors = zeros(3,1);
           elseif(nargin ==3)
               obj.coors(1) = varargin{1};
               obj.coors(2) = varargin{2};
               obj.coors(3) = varargin{3};
           elseif(nargin == 4 && ...
                  isa(varargin{4},'Frame')) 
               frame = varargin{4};
               coors_ = [varargin{1}; varargin{2}; varargin{3}];
               obj.coors(1) = sum(coors_.*frame.basis(1:3:end));
               obj.coors(2) = sum(coors_.*frame.basis(2:3:end));
               obj.coors(3) = sum(coors_.*frame.basis(3:3:end));               
           elseif isa(varargin{1},'Vector')
               tmpv = varargin{1};
               obj.coors = tmpv.coors;
           end
        end
        function result = length(obj)
        % return the length of the vector
            result =  sqrt(obj.coors(1)^2 + obj.coors(2)^2+obj.coors(3)^2);
        end
        function result = plus(avec, bvec)
        % implement vectorC = vectorA + vectorB
            if(isa(avec, 'Vector') && ...
               isa(bvec, 'Vector'))
                result = Vector();
                result.coors = avec.coors+bvec.coors;
            else
                error('argument type is incorrect');
            end    
        end
        function result = minus(avec, bvec)
        % implement vectorC = vectorA - vectorB
            if(isa(avec, 'Vector') && ...
               isa(bvec, 'Vector'))
                result = Vector();
                result.coors = avec.coors-bvec.coors;
            else
                error('argument type is incorrect');
            end
        end
        function result = times(a, b)
        % 1. vectorC = vectorA .* scalarB
        % 2. scalar = vectorA .* vectorB
            if(isa(a,'Vector') && ...
               isa(b,'double'))
                result = Vector;
                result.coors = a.coors*b;
            elseif(isa(a,'Vector') && ...
                   isa(b,'Vector'))
                result = sum(a.coors.*b.coors);
            end
        end
        
        function result = mtimes(avec, bvec)
        % implement vectorC = vectorA * vectorA
            if(isa(avec,'Vector') && ...
               isa(bvec,'Vector'))
                result = Vector();
                result.coors(1) = avec.coors(2)*bvec.coors(3)-avec.coors(3)*bvec.coors(2);
                result.coors(2) = avec.coors(3)*bvec.coors(1)-avec.coors(1)*bvec.coors(3);
                result.coors(3) = avec.coors(1)*bvec.coors(2)-avec.coors(2)*bvec.coors(1);            
            end
        end
        function result = eq(avec, bvec)
        % implement result = avec==bvec; 
            if(isa(avec, 'Vector') && ...
               isa(bvec, 'Vector'))
               if(sqrt(sum((avec.coors-bvec.coors).^2)) < avec.precision)
                   result=true;
               else
                   result=false;
               end
            else
               error('argument type is incorrect'); 
            end
        end
        function result = ne(avec, bvec)
        % implement result = avec==bvec; 
            if(eq(avec,bvec))
                result = false;
            else
                result = true;
            end
        end
        function result = x(obj, frame)
        % return x of the vector in a certain frame
            result = obj.*frame.x();
        end
        function result = y(obj, frame)
        % return y of the vector in a certain frame
            result = obj.*frame.y();            
        end
        function result = z(obj, frame)
        % return z of the vector in a certain frame
            result = obj.*frame.z();
        end
        function result = parallelProjection(vectorToBeProjected, ...
                                             vectorNormalToViewPlane, ...
                                             vectorOfProjectDirection)
        % implements parallel projection of a vector
        % called with vector = parallelProjection(vector, vector, vector);
        % one occasion to use this funcion is when considering the
        % fore-shortening effect, an inclined wavefront projected onto the
        % wavefront sensor, so for subaperture axis, it needs to prolonged
        % regarding to the wavefront direction
            if(~(isa(vectorToBeProjected,'Vector') &&...
               isa(vectorNormalToViewPlane, 'Vector') && ...
               isa(vectorOfProjectDirection, 'Vector')))
                error('input argument is incorrect');
            end
            if(abs(vectorNormalToViewPlane.*vectorOfProjectDirection)<vectorToBeProjected.precision)
                error('Projection direction vector cant be in the same direction as view plane normal vector');
            end
            result = vectorToBeProjected - vectorOfProjectDirection.*((vectorToBeProjected.*vectorNormalToViewPlane)...
                                          .*(1/(vectorOfProjectDirection.*vectorNormalToViewPlane)));
        end
        function display(obj)
        % display overload function    
            disp(' Vector');
            disp(' x     y     z');
            fprintf('%5.2f %5.2f %5.2f\n', obj.coors);
        end
      
    end
end