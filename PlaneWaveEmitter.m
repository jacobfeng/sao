classdef PlaneWaveEmitter < Emitter & Vector
% Vector is the propagation direction
% Emitter is used for generating specific directed wavefront
    methods
        function obj = PlaneWaveEmitter(varargin)
        % constructors
        % 1. obj = PlaneWaveEmitter() null constructor
        % 2. obj = PlaneWaveEmitter(planewaveemitter) copy constructor
        % 3. obj = PlaneWaveEmitter(vector) 
            if nargin==1 && isa(varargin{1}, 'PlaneWaveEmitter')
                obj.coors = varargin{1}.coors;
            elseif nargin==1 && isa(varargin{1}, 'Vector')
                obj.coors = varargin{1}.coors;
            end
        end
        function result = emit(obj, wavefrontHeader) 
        % emit a wavefront, result is a diffractive wavefront
            tmpvec = obj*wavefrontHeader.z();
            if tmpvec.length()>Vector.precision
                error('vector misaligned');
            end
            result = DiffractiveWavefront(wavefrontHeader);
            value = ones(wavefrontHeader.axes(1), wavefrontHeader.axes(2));
            result = result+value;
        end
        function result = getEmissionVector(obj)
        % original version is to get the direction vector from the emitter towads a point
        % but it is impossible to determine a direction towards a point by
        % single vector, so only show the vector 
            result = Vector(obj);
        end
        function result = eq(a,b)
            result = (Vector(a)==Vector(b));
        end
        function result = ne(a,b)
            result = ~(a==b); 
        end
    end
end