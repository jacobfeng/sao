classdef Aperture < PlaneOptic & OneToOneOptic
    % abstract class for different type of aperture
    properties
        areal_weighting = true; % for wavefront pixel that straddle across 
        %the pixel on/off the edge the aperture, wether to weight them 
        %according to the overlapped area is controlled by this parameter
    end
    methods
        function obj = Aperture(varargin)
        % constructor
        % format:
        % 1. Null constructor
        % 2. copy constructor
            if nargin == 0
                obj.areal_weighting = true;
            elseif nargin == 1 && isa(varargin, 'Aperture')
                obj.areal_weighting = varargin.areal_weighting;
            end
        
        end
        function result = getArealWeighting(obj)
            result = obj.areal_weighting;
        end
        function obj = setArealWeighting(obj, weighting)
            obj.areal_weighting = weighting;
        end
    end
    methods (Abstract)
        % function to return the overlapping area between wavefront and the
        % aperture optics, note that the vertices of the polygon must be in
        % the same plane of the aperture
        result = convexPolygonOverlap(obj, polygon_vertices);
    end
end