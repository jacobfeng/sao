classdef Scaling < OrthonormalTransformation
    methods
        function obj = Scaling(varargin)
        %function type 
        % obj = Scaling()
        % obj = Scaling(point, scale)
        % obj = Scaling(point, vector, scale)
            obj = obj@OrthonormalTransformation();
            if nargin==2 && isa(varargin{1}, 'Point')
            % uniform scaling
                tp = varargin{1}; tf = Frame();scale =varargin{2}; scale = 1/scale;
                if scale<=0
                   error('scale factor is not positive'); 
                end
                obj.transformationMatrix(1:3,1:4) = [
                    scale,0,0,tp.x(tf)*(1-scale)
                    0,scale,0,tp.y(tf)*(1-scale)
                    0,0,scale,tp.z(tf)*(1-scale)
                ];
            elseif nargin==3 && isa(varargin{1}, 'Point') && isa(varargin{2}, 'Vector')
            % scale along one axis
                tp = varargin{1}; tf = Frame();tv =varargin{2}; scale =varargin{3}; scale = 1/scale;
                if scale<=0 || tv.length()<=0
                   error('input error for geometrical scaling') 
                end
                tmpv = tv;
                tmpv = tmpv.*(1/tmpv.length());
                px = tp.x(tf); py = tp.y(tf); pz = tp.z(tf);
                vx = tmpv.x(tf); vy = tmpv.y(tf); vz = tmpv.z(tf);
                dot = px*vx+py*vy+pz*vz;
                fac = 1-scale;
                obj.transformationMatrix(1:3,1:4) = [
                    1-fac*vx*vx, -fac*vx*vy, -fac*vx*vz, fac*dot*vx
                    -fac*vx*vy, 1-fac*vy*vy, -fac*vy*vz, fac*dot*vy
                    -fac*vx*vz, -fac*vy*vz, 1-fac*vz*vz, fac*dot*vz
                ];
            end
        end   
    end    
end
    
