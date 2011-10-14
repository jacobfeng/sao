classdef Rotation < OrthonormalTransformation
    % rotation is clockwise, rotation degree is in radian
    methods
       function obj = Rotation(varargin)           
            obj = obj@OrthonormalTransformation();
            if nargin==0  % null constructor
                % doing nothing, mate
            elseif nargin==1 && isa(varargin{1}, 'Rotation') % copy constructor
                obj = obj.setTransformation(varargin{1});
            elseif nargin==3 && ...
                   isa(varargin{1}, 'Point') && ...
                   isa(varargin{2}, 'Vector') && ...
                   isa(varargin{3}, 'double')
                tp = varargin{1}; tv = varargin{2}; angle = varargin{3};
                if tv.length()==0
                    error('three rotation constructor error, rotation axis should not be 0 length vector');
                end
                tmpv = Vector(tv);
                tmpv = tmpv.*(1/tmpv.length());
                tf = Frame();
                px = tp.x(tf); 
                py = tp.y(tf); 
                pz = tp.z(tf);
                vx = tmpv.x(tf); vy = tmpv.y(tf); vz = tmpv.z(tf);
                ca = cos(angle); sa = sin(angle);
                % http://www.siggraph.org/education/materials/HyperGraph/modeling/mod_tran/3drota.htm
                obj.transformationMatrix(1:3,:) = [
                    ca + (1-ca)*(vx^2), (1-ca)*vx*vy+sa*vz, (1-ca)*vx*vz-sa*vy,  px*(1-ca-(1-ca)*(vx^2))-py*((1-ca)*vx*vy+sa*vz)-pz*((1-ca)*vx*vz-sa*vy)
                    (1-ca)*vx*vy-sa*vz, ca+(1-ca)*(vy^2), (1-ca)*vy*vz+sa*vx,  -px*((1-ca)*vx*vy-sa*vz)+py*(1-ca-(1-ca)*(vy^2))-pz*((1-ca)*vy*vz+sa*vx)
                    (1-ca)*vz*vx+sa*vy, (1-ca)*vz*vy-sa*vx, ca+(1-ca)*(vz^2),  -px*((1-ca)*vz*vx+sa*vy)-py*((1-ca)*vz*vy-sa*vx)+pz*(1-ca-(1-ca)*(vz^2))
                ];
            end
       end
   end
end