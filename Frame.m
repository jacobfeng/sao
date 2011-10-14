classdef Frame < Point
   properties
       basis = zeros(9, 1); %basis is used for representing x,y,z vectors, superclass, coors is used for representing zero point
   end
   methods
       function obj = Frame(varargin)
           % constructor
           % 1. obj = Frame(), with (1,0,0),(0,1,0),(0,0,1) as x,y,z vector
           % 2. obj = Frame(frame), copy constructor
           % 3. obj = Frame(point, vector, vector, vector), point is the
           % zero point of the coordinate system, three vectors as x, y, z
           if(nargin==0)
               sup_arg = {};
           elseif(nargin==1 ||...
                  nargin==4)
               sup_arg{1} = varargin{1}.coors(1); 
               sup_arg{2} = varargin{1}.coors(2); 
               sup_arg{3} = varargin{1}.coors(3);
           end
           obj = obj@Point(sup_arg{:});
          
           if(nargin==0)
               obj.basis(1) = 1;
               obj.basis(5) = 1;
               obj.basis(9) = 1;
           elseif(isa(varargin, 'Frame'))
               obj.coors = varargin.coors;
               obj.basis = varargin.basis;
           elseif(isa(varargin{1}, 'Point') && ...
                  isa(varargin{2}, 'Vector') && ...
                  isa(varargin{3}, 'Vector') && ...
                  isa(varargin{4}, 'Vector'))
                  %obj.coors = varargin{1}.coors; % a dirty solution because of the current matlab class rules
                  v1 = varargin{2};
                  v2 = varargin{3};
                  v3 = varargin{4};
                  
                  vectorx = v1.*(1/v1.length);
                  vectory = v2.*(1/v2.length);
                  vectorz = v3.*(1/v3.length);
                  if((abs(vectorx.*vectory) > obj.precision) || ...
                     (abs(vectory.*vectorz) > obj.precision) || ...
                     (abs(vectorz.*vectorx) > obj.precision))
                     error('vectors are not mutually orthornomal')
                  end
                  obj.basis(1) = vectorx.x(Frame());
                  obj.basis(2) = vectorx.y(Frame());
                  obj.basis(3) = vectorx.z(Frame());
                  obj.basis(4) = vectory.x(Frame());
                  obj.basis(5) = vectory.y(Frame());
                  obj.basis(6) = vectory.z(Frame());                  
                  obj.basis(7) = vectorz.x(Frame());
                  obj.basis(8) = vectorz.y(Frame());
                  obj.basis(9) = vectorz.z(Frame());
           end
       end
       function result = getzp(obj)
          result = Point(obj.coors(1),obj.coors(2),obj.coors(3)); 
       end
       function result = eq(a, b)
       %overloaded == function    
           if(a.getzp()~=b.getzp())
               result = false;
           else
               if(sum(a.basis~=b.basis)~=0)
                   result = false;
               else
                   result = true;
               end
           end
       end
       function result = ne(a, b)
       %overloaded ~= function    
          if(a==b)
              result = false;
          else
              result = true;
          end
       end
       function result = isRightHandFrame(obj)
       %determine the coordinate system is right hand or not
       %bool = frame.isRightHandFrame(); 
           temp = obj.x() * obj.y();
           if((temp.*obj.z())>0)
               result = true;
           else
               result = false;
           end
       end
       function result = x(obj)
       %return the vector of x axis of the coordinate system
       %vector = frame.x();
            result = Vector(obj.basis(1), obj.basis(2), obj.basis(3), Frame());
       end
       function result = y(obj)
       %return the vector of y axis of the coordinate system
       %vector = frame.y()
            result = Vector(obj.basis(4), obj.basis(5), obj.basis(6), Frame());
       end
       function result = z(obj)
       %return the vector of z axis of the coordinate system
       %vector = frame.y()
            result = Vector(obj.basis(7), obj.basis(8), obj.basis(9), Frame());
       end
       function display(obj)
       %overloaded display function for class
           zeroPoint = Point(obj.coors(1), obj.coors(2), obj.coors(3));
           globalFr = Frame(); %reference coordinate system
           disp(' Frame');
           disp(' Zero point @');
           disp(' x     y     z');
           fprintf('%5.2f %5.2f %5.2f\n', zeroPoint.x(globalFr), zeroPoint.y(globalFr), zeroPoint.z(globalFr));       
           disp(' X arm');
           tmp = obj.x();
           disp(' xx    xy    xz');
           fprintf('%5.2f %5.2f %5.2f\n', tmp.x(globalFr),tmp.y(globalFr),tmp.z(globalFr));
           disp(' Y arm');
           tmp = obj.y();
           disp(' yx    yy    yz');
           fprintf('%5.2f %5.2f %5.2f\n', tmp.x(globalFr),tmp.y(globalFr),tmp.z(globalFr));
           disp(' Z arm');
           tmp = obj.z();
           disp(' zx    zy    zz');
           fprintf('%5.2f %5.2f %5.2f\n', tmp.x(globalFr),tmp.y(globalFr),tmp.z(globalFr));     
       end
       function plot(obj)
           hold on;
           view(45,45);
           grid on;
           hArrow = mArrow3(obj.coors, [obj.basis(1:3)]+obj.coors, 'stemWidth', 0.01, 'color', 'red');           
           % mark x axis as red 
           hArrow = mArrow3(obj.coors, [obj.basis(4:6)]+obj.coors, 'stemWidth', 0.01, 'color', 'green');
           % mark y axis as green           
           hArrow = mArrow3(obj.coors, [obj.basis(7:9)]+obj.coors, 'stemWidth', 0.01, 'color', 'yellow');           
           % mark z axis as yellow     
           hold off;
       end
       
   end
end