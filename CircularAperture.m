classdef CircularAperture < Aperture
    % haven't added the unique name for this class, think MATLAB has class
    % name inquiry
    properties
        diameter = 0;
    end
    methods
        function obj = CircularAperture(varargin)
        % constructor, damn i hate writing class constructor in matlab
        % format:
        % 1. Null constructor
        % 2. Copy constructor
        % 3. obj = CircularAperture(diameter)
            if nargin==0
                obj.diameter = 0;
            elseif nargin==1 && isa(varargin, 'CircularAperture')
                obj.foreshortening = varargin.foreshortening;
                obj.areal_weighting = varargin.areal_weighting;
                obj.diameter = varargin.diameter;
            elseif nargin==1 && isa(varargin, 'double')
                obj.diameter = varargin;
            end
        end
        function result = getDiameter(obj)
           result = obj.diameter; 
        end
        function result = getCoveringRegion(obj, tf)
        % return a rectangular region on wavefront that will encircle aperture totally
        % result is RectangularRegion object
           result = {};
           if abs(obj.z().*tf.z())<Frame.precision
              error('provided tf is orthogonal to the aperture');
           end
           projected_radius = 0;
           tmp = obj.z() * tf.z();
           if obj.foreshortening && tmp.length()>Frame.precision
              projected_radius = abs(.5*obj.diameter/(obj.z().*tf.z()));
           else
              projected_radius = .5*obj.diameter;
           end
           intersection_tp = obj.getPointOfIntersection(tf, tf.z()); %center of the intersection plane z vector and optic z vector
           offset_vector = obj - intersection_tp; %determine the distance between the point and aperture center
           xmax = abs(offset_vector.x(obj))+projected_radius;
           ymax = abs(offset_vector.y(obj))+projected_radius;
           
           if obj.foreshortening && tmp.length()>Frame.precision
              xmax = xmax/(obj.z().*tf.z());
              ymax = ymax/(obj.z().*tf.z());
           end
           result{1} = intersection_tp + tf.x().*xmax + tf.y().*ymax;
           result{2} = intersection_tp + tf.x().*xmax - tf.y().*ymax;
           result{3} = intersection_tp - tf.x().*xmax - tf.y().*ymax;
           result{4} = intersection_tp - tf.x().*xmax + tf.y().*ymax;
        end
        function result = transform(obj, wf)
        % haven't implemented
           [origin_offset, dx, dy] = obj.getProjectedWavefrontPixelSpacing(wf);
           % check wether the wavefront is intersected with the aperture
           if origin_offset.length()>obj.diameter
               wf = wf*0;
           end
           
           %half pixel 
           wf_axes = wf.getAxes();
           x_halfpix = 0; y_halfpix = 0;
           x_extrapix = 1; y_extrapix = 1;
           if mod(wf_axes(2),2)==0 %matlab definition[row;column], here, [y,x]
               x_halfpix = .5;
               x_extrapix = 0;
           end
           if mod(wf_axes(1),2)==0
               y_halfpix = .5;
               y_extrapix = 0;
           end
           
           
           
        end
        function result = convexPolygonOverlap(obj, polygon_vertices)
           intersection_vertices = getConvexPolygonCircleIntersection(polygon_vertices, obj, .5*diameter);
           if length(intersection_vertices)<=2
                result = 0;
           else
                result = getAreaOfPolygon(intersection_vertices);
           end
        end
    end
end