classdef Reflection < OrthonormalTransformation
    methods
        function obj = Reflection(varargin)
        % function type 
        % obj = Reflection(); % Null constructor
        % obj = Reflection(Reflection); % copy constructor
        % obj = Reflection(point, vector) % reflection from a plane defined
        % by point and a normal vector
            superarg = {};
            if nargin==0 || (nargin==1 && isa(varargin{1},'Reflection'))
                superarg = varargin;
            end
            obj = obj@OrthonormalTransformation(superarg{:});
            if nargin==2 && isa(varargin{1},'Point') && isa(varargin{2},'Vector')
                tp = varargin{1}; tv = varargin{2};
                tmpv = tv; tmpv = tmpv.*(1/tmpv.length());
                tf = Frame();
                px = tp.x(tf); py = tp.y(tf); pz = tp.z(tf);
                vx = tmpv.x(tf); vy = tmpv.y(tf); vz = tmpv.z(tf);
                dot = px*vx+py*vy+pz*vz;
                obj.transformationMatrix(1:3,1:4) = [
                    1-2*vx*vx, -2*vx*vy, -2*vx*vz, 2*dot*vx
                    -2*vy*vx, 1-2*vy*vy  -2*vy*vz, 2*dot*vy
                    -2*vz*vx,  -2*vz*vy, 1-2*vz*vz,2*dot*vz
                ];
            end  
        end
    end
end