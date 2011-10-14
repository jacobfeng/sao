classdef RectangularRegion < RegionBase
    % haven't been fully tested yet
    properties
        corners = cell(4,1); % contains 4 points describing te 4 corners of the region
    end
    methods
        function result = region_status(obj, rectangularRegion)
        % This function will find the overlap status of the two rectangles
        % There are a number of return values:
        % no overlap              - no overlap between the rectangles
        % match                   - rectangles identical
        % four corner container   - first contains second
        % four corner containee   - second contains first
        % two corner container    - two corners of the second are contained by the first
        % two corner containee    - two corners of the first are contained by the second
        % one corner              - one corner of each rectangle is contained by the other     
            if(~isa(rectangularRegion, 'RectangularRegion'))
               error('input arg type is incorrect') 
            end
            if(~obj.isAligned(rectangularRegion))
               error('input rectangular region is not properly aligned with the current region'); 
            end
            contains = 0; % this region contains N number of nodes of input region
            contained = 0; % this region's N number of nodes are contained in the input region
            %count how many points contained by each other
            for i=1:4
                if(pointWithinPolygon(obj.corners{i}, rectangularRegion.corners))
                   contained = contained+1;
                end
                if(pointWithinPolygon(rectangularRegion.corners{i}, obj.corners))
                   contains = contains+1;
                end
            end
            if(contains == 4 && contained == 4) % contained each other
                result = 'match';
                return;
            elseif(contains == 0 && contained == 0) % contained non of each other
                result = 'no overlap';
                return;
            elseif(contains == 4) % contain all 4 nodes of input arg
                result = 'four corner container';
                return;
            elseif(contained == 4) % all 4 nodes are contained by the input arg
                result = 'four corner containee';
                return;
            elseif(contains == 2 && contained <= 2) % has two points of input arg, contained less than two
                result = 'two corner container';
                return;
            elseif(contains <= 1 && contained == 2) % has one points of input arg, has exactly two point contained 
                result = 'two corner containee';
                return;
            elseif(contains == 1 && contained == 1) % has one point each
                result = 'one corner'
                return;
            else % else is impossible, unless input geometrical relationship is bullshit, or input arg is bullshit
                %error report is a short version of the original function
                %design
                error('Rectangulare.regionStatus(rectangularRegion) function error');
            end
        end
        
        function obj = sortCorners(obj)        
        % Function to sort corners
        % so that the index on the 
        % corners runs clockwise or
        % counterclockwise around the
        % rectangle
            tmp_corners = obj.corners;
            max_index = 1;
            max_length = 0;
            % search for the longest distance between each corner
            % also marks the node
            for i=2:4
               tmp_vector = tmp_corners{1} - tmp_corners{i};
               length = tmp_vector.length();
               if(length>max_length)
                    max_length = length;
                    max_index = i;
               end
            end
            obj.corners{3} = tmp_corners{max_index}; %put it to the diagonal position
            one = true;
            %fill in the rest two nodes
            for i=2:4
               if(i==max_index) 
                   continue
               end
               if(one)
                   obj.corners{2} = tmp_corners{i};
                   one = false;
               else
                   obj.corners{4} = tmp_corners{i};
               end
            end
        end
        
        function obj = RectangularRegion(varargin)
        % constructor
        % 1. obj = RectangularRegion() null constructor
        % 2. obj = RectangularRegion(rectangularRegion) copy constructor
        % 3. obj = RectangularRegion(cell(4,1)) constructor from 4 points,
        % which should be coplanar and form a rectangular region
        % 4. obj = RectangularRegion(frame, axes[2,1], double pixelscale)
        % construct from a frame, a set of axes, and a pixel scale
        % 5. obj = RectangularRegion(rectangularRegion, vector
        % normal_vector, bool along_normal)
        % Construct from another rectangular region
        % by projecting it onto a plane with normal
        % vector nrml.  The normal vector must be
        % orthogonal to one of the two transverse
        % vectors defined by the sides of the rectangle
        % in order for the projected area to be
        % itself rectangular.  If this is not the
        % case, an error is thrown.
        % The bool along_nrml determines whether the 
        % projection is carried out along the three_vector 
        % nrml, or along the vector normal to the 
        % rectangular region.
        % If the projection is carried out along the three_vector
        % nrml, the resulting rectangular region is smaller than 
        % the original.  This method is used to find the rectangular
        % region that covers a foreshortened aperture.
        % If the projection is carried out along the normal 
        % to the rectangular region, the resulting rectangular 
        % region is larger than the original.  This method is used
        % to find the rectangular region of a wavefront projected
        % onto an optic.
        % In both cases, the new rectangular region has 
        % the same center as the original.
        % Constructing a rectangular region with along_nrml==false
        % and then using that region to construct another with 
        % along_nrml==true yields the original region.
        % 6. obj = RectangularRegion(rectangularRegion, double pix)
        % Construct from another rectangular_region
        % so that the resulting rectangular_region
        % has dimensions evenly divisible by pix.
        % This constructor rounds the dimensions of 
        % the rectangular_region up to get the smallest
        % possible rectangular region.  The center of
        % the original rectangular region is preserved
                    
        % 1. obj = RectangularRegion() null constructor
        % 2. obj = RectangularRegion(rectangularRegion) copy constructor
        % 3. obj = RectangularRegion(cell(4,1)) constructor from 4 points,
        % which should be coplanar and form a rectangular region
        % 4. obj = RectangularRegion(frame, axes[2,1], double pixelscale)
        % construct from a frame, a set of axes, and a pixel scale
        % 5. obj = RectangularRegion(rectangularRegion, vector
        % normal_vector, bool along_normal)
        % 6. obj = RectangularRegion(rectangularRegion, double pix)
            if isempty(varargin)
                arg = {};
            else
                arg = varargin{:};
            end
            
            if length(arg)==1 && isa(arg{1}, 'RectangularRegion')
                obj.corners = varargin.corners;
                return;
            elseif isempty(arg)==0
                for i=1:4
                   obj.corners{i} = Point(); 
                end
                return;
            elseif length(arg)==4 ...
                   && isa(arg{1}, 'Point') && isa(arg{2}, 'Point') ...
                   && isa(arg{3}, 'Point') && isa(arg{4}, 'Point')
                for i=1:4
                   obj.corners{i} = arg{i}; 
                end
                obj = obj.sortCorners();
                % verify that non of the corners match
                for i=1:4
                        for j=(i+1:4)
                            if obj.corners{i}==obj.corners{j}
                                error('RectangularRegion.RectangularRegion error, two corners are a match');
                            end
                        end
                end
                tmp_1_unit_vector = obj.corners{2} - obj.corners{1};
                tmp_1_unit_vector = tmp_1_unit_vector.*(1/tmp_1_unit_vector.length());
                tmp_2_unit_vector = obj.corners{3} - obj.corners{2};
                tmp_2_unit_vector = tmp_1_unit_vector.*(1/tmp_2_unit_vector.length());
                tmp_3_unit_vector = obj.corners{4} - obj.corners{3};
                tmp_3_unit_vector = tmp_1_unit_vector.*(1/tmp_3_unit_vector.length());
                orthorgonal_vector = tmp_1_unit_vector*tmp_2_unit_vector;
                % verify that theses corners are coplanar
                if abs(orthorgonal_vector.*tmp_3_unit_vector)>Frame.precision
                    error('RectangularRegion.RectangularRegion error, points are not coplanar');
                end
                % verify that edges are orthorgonal, 
                if abs(tmp1_unit_vector.*tmp2_unit_vector)>Frame.precision || ...
                   abs(tmp2_unit_vector.*tmp3_unit_vector)>Frame.precision
                    error('RectangularRegion.RectangularRegion error, edges do not form as 90degree');
                end
                return;
            elseif length(arg)==3 && isa(arg{1}, 'Frame')
                tf = arg{1};
                axes = arg{2}; pix = arg{3};
                x = axes(1)*pix/2;
                y = axes(2)*pix/2;
                obj.corners{1} = Point(-x,-y,0,tf);
                obj.corners{2} = Point(-x, y,0,tf);
                obj.corners{3} = Point( x, y,0,tf);
                obj.corners{4} = Point( x,-y,0,tf);
                return;
            elseif length(arg)==3 && isa(arg{1}, 'RectangularRegion')
                rec_region = arg{1}; nrml = arg{2}; along_nrml = arg{3};
                if nrml.length()==0
                   error('a null vector has been provided as the normal vector'); 
                end
                nrml_hat = nrml.*(1/nrml.length());
                rec_region_corners = rec_region.getCorners();
                xhat = rec_region_corners{2}-rec_region_corners{1};
                xhat = xhat.*(1/xhat.length());
                yhat = rec_region_corners{4}-rec_region_corners{1};
                yhat = yhat.*(1/yhat.length());
                zhat = xhat*yhat;
                rec_region_center = rec_retgion.getCenter();
                
                tmp = zhat*nrml_hat;
                if tmp.length()<Frame.length()
                    obj = RectangularRegion(rec_region);
                    return;
                end
                if abs(zhat.*nrml_hat)<Frame.precision
                    error('rectangular region can not project region on to plane orthogonal to the region')
                end
                if abs(nrml_hat.*xhat)>Frame.precision && ...
                   abs(nrml_hat.*yhat)>Frame.precision
                   error('projection of this region onto the lane specified by the normal vector provided to this constructor would result in a non-rectangular region');
                end
                half_edge = (rec_region_corners{2}-rec_region_corners{1}).*(1/2);
                tmp = zhat*nrml_hat;
                if abs(tmp.*half_edge)>Frame.precision
                   half_edge = (rec_region_corners{3}-rec_region_corners{2}).*(1/2);
                end
                cos_projection_angle = zhat.*nrml_hat;
                sin_projection_angle = sqrt(1-cos_projection_angle^2);
                projection_vector = Vector();
                if along_nrml
                    projection_vector = nrml_hat.*(half_edge.length()*sin_projection_angle);
                else
                    projection_vector = zhat.*(half_edge.length()*sin_projection_angle/cos_projection_angle);
                end
                for i=1:4
                   if nrml_hat.*(rec_region_corners{i}-rec_region_center)>0
                      rec_region_corners{i} = rec_region_corners{i}-projection_vector; 
                   else
                      rec_region_corners{i} = rec_region_corners{i}+projection_vector; 
                   end
                end
                obj = RectangularRegion(rec_region_corners);
                return;
            elseif length(arg)==2
                rec_region = arg{1}; pix = arg{2};
                if pix<=0
                    error('cannot construct region with dimensions evenly divisible by the provided pix');
                end
                in_corners = rec_region.get_corners();
                tmp = in_corners{2}-in_corners{1};
                length_ = tmp.length();
                if mod(length_, pix) > Frame.precision && ...
                   mod(length_, pix) < (pix-Frame.precision)
                    error('rounding corner error')
                end
                tmp = in_corners{4}-in_corners{1};
                length_ = tmp.length();
                if mod(length_, pix) > Frame.precision && ...
                   mod(length_, pix) < (pix-Frame.precision)
                    error('rounding corner error')
                end
                obj = RectangularRegion(in_corners);
                return;
            end    
        end
        function result = isAligned(obj, rectangularRegion)
        % Determine whether this
        % rectangular region is aligned
        % with rec_region.
        % Aligned means that the axes
        % defined by the edges of the
        % rectangles must match.         
            result = false;
            this_first_edge = obj.corners{2} - obj.corners{1};
            this_second_edge = obj.corners{3} - obj.corners{2};
            rec_region_first_edge = rectangularRegion.corners{2} - rectangularRegion.corners{1}; 
            rec_region_second_edge = rectangularRegion.corners{3} - rectangularRegion.corners{1};
            this_first_edge = this_first_edge.*(1/this_first_edge.length());
            this_second_edge = this_second_edge.*(1/this_second_edge.length());
            rec_region_first_edge = rec_region_first_edge.*(1/rec_region_first_edge.length());
            rec_region_second_edge = rec_region_second_edge.*(1/rec_region_second_edge.length());
            
            tmp1 = this_first_edge*rec_region_first_edge;
            tmp2 = this_second_edge*rec_region_second_edge;
            if tmp1.length()<Frame.precision
               if tmp2.length()<Frame.precision
                   result = true;
                   return;
               else
                   result = false;
                   return;
               end
            elseif abs(this_second_edge.*rec_region_second_edge)<Frame.precision
               if abs(this_first_edge.*rec_region_first_edge)<Frame.precision
                   result = true;
                   return;
               else
                   result = false;
                   return;
               end
            else
               result = false;
               return;
            end
        end
        function result = isContains(obj, rectangularRegion)
        % Determine whether this
        % region contains rec_region.
        % This rectangular_region and rec_region must
        % be aligned 
            status = obj.regionStatus(rectangularRegion);
            if strcmp(status,'match') || strcmp(status,'four corner container')
                result = true;
                return;
            end
            result = false;
        end
        function result = isContained(obj, rectangularRegion)
        % Determine whether this
        % region is contained by rec_region.
        % This rectangular_region and rec_region must
        % be aligned         
            status = obj.regionStatus(rectangularRegion);
            if strcmp(status,'match') || strcmp(status,'four corner containee')
                result = true;
                return;
            end
            result = false;
        end
        function result = isDisjoint(obj, rectangularRegion)
        % Determine whether this
        % region has no overlap with rec_region.
        % This rectangular_region and rec_region must
        % be aligned         
            status = obj.regionStatus(rectangularRegion);
            if strcmp(status,'no overlap') 
                result = true;
                return;
            end
            result = false;
        end
        function result = getCorners(obj)
        % Returns the three_points that 
        % identify this region 
            result = obj.corners;
        end
        function result = getCenter(obj)
        % Returns the center of the region
            result = obj.corners{1} + (obj.corners{3}-obj.corners{1}).*0.5;
        end
        function result = regionUnion(a,b)
        % Return the rectangular_region
        % of smallest size that contains
        % both rectangular regions supplied
        % as arguments.
        % rec_region1 and rec_region2 must
        % be aligned 
            x = a.corners{2} - a.corners{1};
            y = a.corners{4} - a.corners{1};
            tf = Frame(a.getCenter(), x, y, x*y);
            astartpt = a.corners{1};
            xmin = astartpt.x(tf);
            xmax = astartpt.x(tf);
            ymin = astartpt.y(tf);
            ymax = astartpt.y(tf);
            
            for i=1:4
               tmppt1 = a.corners{i};
               tmppt2 = b.corners{i};
               if xmin>tmppt1.x(tf)
                   xmin = tmppt1.x(tf);
               end
               if xmax<tmppt1.x(tf)
                   xmax = tmppt1.x(tf);
               end
               if xmin>tmppt2.x(tf)
                   xmin = tmppt1.x(tf);
               end
               if xmax<tmppt2.x(tf)
                   xmax = tmppt1.x(tf);
               end
               if ymin>tmppt1.y(tf)
                   ymin = tmppt1.y(tf);
               end
               if ymax<tmppt1.y(tf)
                   ymax = tmppt1.y(tf);
               end
               if ymin>tmppt2.y(tf)
                   ymin = tmppt2.y(tf);
               end
               if ymax>tmppt2.y(tf)
                   ymax = tmppt2.y(tf);
               end
            end
            union_corners = cell(4,1);
            union_corners{1} = Point(xmin, ymin, 0, tf);
            union_corners{2} = Point(xmax, ymin, 0, tf);
            union_corners{3} = Point(xmax, ymax, 0, tf);
            union_corners{4} = Point(xmin, ymax, 0, tf);
            result = RectangularRegion(union_corners);
        end
        function result = regionIntersection(rec_region1, rec_region2)
        % Return the rectangular_region
        % of largest size that is contained
        % by both of the rectangular regions 
        % supplied as arguments.
        % rec_region1 and rec_region2 must
        % be aligned 
        % haven't been tested yet
            status = rec_region1.regionStatus(rec_region2);
            if strcmp(status, 'match')
                result = rec_region1;
                return;
            elseif strcmp(status, 'four corner containee')
                result = rec_region1;
                return;
            elseif strcmp(status, 'four corner container')
                result = rec_region2;
                return;
            elseif strcmp(status, 'no overlap')
                error('no overlap between region');
            end
            intersection_corners={};
            if strcmp(status, 'two corner container') || strcmp(status, 'two corner containee')
               container_region = RectangularRegion();
               containee_region = RectangularRegion();
               if strcmp(status, 'two corner containee')
                  container_region = rec_region2;
                  containee_region = rec_region1;
               else
                  container_region = rec_region1;
                  containee_region = rec_region2;
               end
               exterior_corners = cell{1,1};
               %%unfinished
               for i=1:4
                  if pointWithinPolygon(containee_region.corners{i}, container_region.corners)
                     intersection_corners{end+1} = containee_region.corners{i};
                  else
                     exterior_corners{end+1} = containee_region.corners{i}; 
                  end
                  if length(intersecion_corners)~=2
                      error('regionIntersection error- found more interior corners when expecting two');
                  end
                  containee_edge_vector = Vector();
                  tmpvec1 = exterior_corners{1} - intersection_corners{1};
                  tmpvec2 = exterior_corners{1} - intersection_corners{2};
                  if tmpvec1.length()>tmpvec2.length()
                      containee_edge_vector = tmpvec2;
                  else
                      containee_edge_vector = tmpvec1;
                  end
                  unit_containee_edge_vector = containee_edge_vector.*(1/containee_edge_vector.length());
                  max_length = unit_containee_edge_vector.*(container_region.corners{1}-intersection_corners{1});
                  for i=1:4
                     length_ = unit_containee_edge_vector.*(container_region.corners{i}-intersection_corners{i});
                     if length_>max_length
                         max_length = length_;
                     end
                  end
                  intersection_corners{end+1} = intersection_corners{1}+unit_containee_edge_vector.*max_length;
                  intersection_corners{end+1} = intersection_corners{2}+unit_containee_edge_vector.*max_length;
               end
            elseif strcmp(status, 'one corner')
                intersection_corners = cell(4,1);
                index = 0;
                for i=1:4
                    if pointWithinPolygon(rec_region2.corners{i}, rec_region1)
                        intersection_corners{1} = rec_region2.corners{i};
                    end
                    if pointWithinPolygon(rec_region1.corners{i}, rec_region2)
                        intersection_corners{3} = rec_region1.corners{i};
                    end
                end
                min_length = realmax;
                for i=2:4
                    tmp = rec_region1.corners{i}-rec_region1.corners{1};
                    length_ = tmp.length();
                    if length_<min_length
                        index = i;
                        min_length = length_;
                    end
                end
                intersection_unit_vector = (rec_region1.corners{index}-rec_region1.corners{1}).*(1/min_length);
                intersection_edge = intersection_unit_vector.*(intersection_unit_vector.*(intersection_corners{3}-intersection_corners{1}));
                intersection_corners{2} = intersection_corners{1} + intersection_edge;
                intersection_corners{4} = intersection_corners{1} + (intersection_corners{3} - intersection_corners{2});
                
            end
            result = RectangularRegion(intersection_corners);
        end
        function result = eq(a,b) 
            match = false;
            for i=1:4
               match = false;
               for j=1:4
                    if a.corners{i} == b.corners{j}
                       match = true;
                       break;
                    end
               end
            end
            if match==false
                result = false;
                return
            end
            result = true;
        end
        function result = ne(a,b)
            if a==b
                result = false;
                return;
            else
                result = true;
            end
        end
        function display(obj)
            for i=1:4
               obj.corners{i} 
            end
        end
        function plot(obj)
           x = zeros(4,1); y = x; z = x;
           tf = Frame();
           for i=1:4
              pt = obj.corners{i};
              x(i) = pt.x(tf); y(i) = pt.y(tf); z(i) = pt.z(tf);
           end
           if ~ishold()
              hold on; 
           end
           patch(x,y,z);
           if ~ishold()
              hold off;
           end
           grid on;
        end
    end
    
end