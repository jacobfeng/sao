% AO simulation - software for simulation of em wave propagation through turbulence and optics
% Based on Arroyo from Dr. Matthew Britton.
% 
% Copyright (c) 2011 National Observatories Of China.  Written by
% Dr. Lu, Feng.  For comments or questions about this software,
% please contact the author at jacobfeng@gmail.com.
% 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as  published by the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version.
% 
% This program is provided "as is" and distributed in the hope that it
% will be useful, but WITHOUT ANY WARRANTY; without even the implied
% warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  In no
% event shall National Observatories of China be liable to any party
% for direct, indirect, special, incidental or consequential damages,
% including lost profits, arising out of the use of this software and its
% documentation, even if National Observatories of China has been
% advised of the possibility of such damage.   The National Observatories of 
% China has no obligation to provide maintenance, support, updates,
% enhancements or modifications.  See the GNU General Public License for
% more details.
% 
% You should have received a copy of the GNU General Public License along
% with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.

classdef Point 
% this class implement point definiton
% each Point has three properties representing x,y,z representing the global
% coordination, yet each Point can also be defined using referenced frame
% system, but converting right away into global coordination system
    properties
       coors = zeros(3,1); % coordination of the point to the global system
    end
    properties (Constant = true)
        precision = 1e-10; % precision requirement for determining geometrical relationship
    end
    methods
        function obj = Point(varargin)
        % constructor function 
        % 1. obj = Point(), default constructor 
        % 2. obj = Point(double, double, double, Frame), define a point related to
        % reference coordinate system
        % 3. obj = Point(double, double, double), define a point related to
        % global coordinate system
        % 3. obj = Point(Point), copy constructor
            if nargin == 0
                obj.coors = zeros(3,1);
            elseif nargin == 3
                obj.coors(1) = varargin{1};
                obj.coors(2) = varargin{2};
                obj.coors(3) = varargin{3};
            elseif (nargin == 4 && ...
                    isa(varargin{4}, 'Frame'))
                v = Vector(varargin{1}, varargin{2}, varargin{3}, varargin{4});
                frameZeroPoint = Point(varargin{4}.coors(1), varargin{4}.coors(2), varargin{4}.coors(3));
                frameZeroVector = frameZeroPoint-Point();
                v = v + frameZeroVector;
                obj = Point();
                obj = obj+v;
            elseif isa(varargin, 'Point')
                obj.coors = varargin.coors;
            end      
        end
        function obj = plus(a, bvector)
        % implement obj = a + bvector, can be called with
        % point = point + vector
            if( isa(a, 'Point') && ...
                isa(bvector, 'Vector'))    
                obj = Point();
                obj.coors = a.coors + bvector.coors;
            else
                error('argument type is incorrect')
            end
        end
        function obj = minus(a, b)
        % implement obj = a - b, can be called with 
        % point = point - vector, retrieval for one end
        % vector = point - point, get two points defined vector
             if(isa(a, 'Point') && ...
                isa(b, 'Vector'))    
                obj = Point();
                obj.coors = a.coors - b.coors;
             elseif(isa(a,'Point') && ...
                    isa(b,'Point'))
                obj = Vector(a.coors(1)-b.coors(1),...
                             a.coors(2)-b.coors(2),...
                             a.coors(3)-b.coors(3));
             else
                error('argument type is incorrect')
            end
        end
        function result = eq(a,b)
        % implement result = a==b, can be called with
        % result = point == point
            if( isa(a, 'Point') && ...
                isa(b, 'Point'))    
               if(sqrt(sum((a.coors-b.coors).^2))<a.precision)
                    result = true;
               else
                    result = false;
               end
            else
                error('argument type is incorrect')
            end
        end
        function result = ne(a,b)
        % implement result = a~=b, can be called with
        % result = point~=point
            if(eq(a,b))
                result = false;
            else
                result = true;
            end
        end
        function display(obj)
        %display overload function   
            disp(' Point');
            disp(' x     y     z');
            fprintf('%5.2f %5.2f %5.2f\n', obj.coors);
        end
        function result = x(obj, frame)
        % return a point's x coordinate regarding to a reference frame
           result = (obj-frame).*frame.x(); 
        end
        function result = y(obj, frame)
        % return a point's y coordinate regarding to a reference frame
           result = (obj-frame).*frame.y();
        end     
        function result = z(obj, frame)
        % return a point's z coordinate regarding to a reference frame
           result = (obj-frame).*frame.z();
        end
        function plot(obj)
           scatter3(obj.coors(1),obj.coors(2),obj.coors(3)); 
        end
    end
end