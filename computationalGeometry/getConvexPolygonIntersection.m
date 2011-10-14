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

function result = getConvexPolygonIntersection(first_vertices, second_vertices)
% function type
% array(point) = getConvexPolygonIntersection(cell(point), cell(point));
% This function returns the vertices chain of a convex polygon formed
% from the intersection of two convex polygons, each specified by
% their vertices.  The first_polygon_vertices and
% second_polygon_vertices must each contain at least three unique
% three_points, no three of which may be collinear.  The vertices
% of each polygon must be ordered in the same sense of rotation.
% If either of these conditions are violated, this function throws
% an error.
% 
% WARNING:  this function can return inaccurate results due to 
% numerical roundoff.  Quantifying the limits of validity of this
% function is a work in progress.
% note the two surfaces needs to have same orientation (right hand law)
    intersection_vertices = {};
    nfirst_vertices = length(first_vertices);
    nsecond_vertices = length(second_vertices);
    same_orientation = true;

    % checking number of input
    if nfirst_vertices<3 ||...
       nsecond_vertices<3
        error('getConvexPolygonIntersection() error, input vertices listed are shorter than 3 points');
    end
    
    % a vector to use in assessing the polygon sense of rotation
    sense_of_rotation = (first_vertices{2} - first_vertices{1}) * (first_vertices{3} - first_vertices{1});
    sense_of_rotation2 = (second_vertices{2} - second_vertices{1}) * (second_vertices{3} - second_vertices{1});
    if sense_of_rotation.*sense_of_rotation2 <=0
       if sense_of_rotation.length()<Frame.precision
           error('getConvexPolygonIntersection() error first three vertices of first polygon are collinear'); 
       elseif sense_of_rotation2.length()<Frame.precision
           error('getConvexPolygonIntersection() error first three vertices of second polygon are collinear');
       else
           error('getConvexPolygonIntersection() error, polygons are oriented with the oposite sense of rotation');
       end       
    end
    
    % normalization 
    sense_of_rotation = sense_of_rotation.*(1/sense_of_rotation.length());
    vertex_on_vertex = false; vertex_on_edge = false; skip_vertex = false;
    first_counter = 1; second_counter = 1;
    edge_cross_product = 0;
    while (first_counter <= nfirst_vertices || second_counter <= nsecond_vertices) && ...
          (first_counter <= 2*nfirst_vertices) && ...
          (second_counter <= 2*nsecond_vertices)
        first_vertex_in_left_halfplane_of_second_segment = false;
        second_vertex_in_left_halfplane_of_first_segment = false;
        pt1pg1 = first_vertices{mod(first_counter, nfirst_vertices)+1};
        pt2pg1 = first_vertices{mod(first_counter-1, nfirst_vertices)+1};
        pt1pg2 = second_vertices{mod(second_counter, nsecond_vertices)+1};
        pt2pg2 = second_vertices{mod(second_counter-1, nsecond_vertices)+1};
        edge_cross_product = ((pt1pg1 - pt2pg1) ...
                             *(pt1pg2 - pt2pg2))...
                             .*sense_of_rotation;
        if (((pt1pg1 - pt2pg2) ...
           * (pt1pg2 - pt2pg2)) ...
           .* sense_of_rotation) < Frame.precision
            first_vertex_in_left_halfplane_of_second_segment = true;
        else
            first_vertex_in_left_halfplane_of_second_segment = false;
        end
        if (((pt1pg2 - pt2pg1) ...
           * (pt1pg1 - pt2pg1)) ...
           .* sense_of_rotation) < Frame.precision
            second_vertex_in_left_halfplane_of_first_segment = true;
        else
            second_vertex_in_left_halfplane_of_first_segment = false;
        end      
        if abs(edge_cross_product)>Frame.precision
            segment_intersection_points = getLineSegmentIntersection(pt2pg1, pt1pg1, pt2pg2, pt1pg2);
            if length(segment_intersection_points)==1
            % We never count the head or tail end of a line segment as an
            % intersection vertex, as they will be identified by the point
            % within polygon tests below
               if (segment_intersection_points{1} ~= pt2pg1) &&...
                  (segment_intersection_points{1} ~= pt1pg1) &&...
                  (segment_intersection_points{1} ~= pt2pg2) &&...
                  (segment_intersection_points{1} ~= pt1pg2)
                    % Here we return if we've come full circle
                    if ~isempty(intersection_vertices) && ...
                       segment_intersection_points{1} == intersection_vertices{1}
                        result = num2cell(reorder(intersection_vertices, sense_of_rotation));
                        return;
                    end
                    % here we add the segment intersection point ot the
                    % list of intersection vertices
                    intersection_vertices{length(intersection_vertices)+1} = segment_intersection_points{1};
               end
            end     
        end
        
        if edge_cross_product>=0
            if second_vertex_in_left_halfplane_of_first_segment
                [tmp, vertex_on_vertex, vertex_on_edge] = pointWithinPolygon(pt1pg1, second_vertices);
                if tmp
                    skip_vertex = false;
                    if vertex_on_vertex
                        for ci = 1:length(intersection_vertices)
                            if intersection_vertices{ci} == pt1pg1
                                skip_vertex = true;
                            end
                        end
                    end
                    if ~skip_vertex
                       if ~isempty(intersection_vertices) && ...
                          intersection_vertices{1} == first_vertices{mod(first_counter, n_first_vertices)+1}
                            result = num2cell(reorder(intersection_vertices, sense_of_rotation));
                            return;
                            
                       end
                       intersection_vertices{length(intersection_vertices)+1} = pt1pg1;
                    end         
                end
                first_counter = first_counter+1;
            else
                [tmp, vertex_on_vertex, vertex_on_edge] = pointWithinPolygon(second_vertices{mod(second_counter , nsecond_vertices)+1},...
                                                       first_vertices);
                if tmp
                    skip_vertex = false;
                    if vertex_on_vertex
                        for ci = 1:length(intersection_vertices)
                            if intersection_vertices{ci} == pt1pg2
                                skip_vertex = true;
                            end
                        end
                    end
                    if ~skip_vertex
                       if ~isempty(intersection_vertices) && ...
                          intersection_vertices{1} == second_vertices{mod(second_counter, n_second_vertices)+1}
                            result = num2cell(reorder(intersection_vertices, sense_of_rotation));
                            return;
                            
                       end
                       intersection_vertices{length(intersection_vertices)+1} = pt1pg2;
                    end         
                end
                second_counter = second_counter+1;
            end
        else
            if first_vertex_in_left_halfplane_of_second_segment
                [tmp, vertex_on_vertex, vertex_on_edge] = pointWithinPolygon(pt1pg2,...
                                                       first_vertices);
                if tmp
                    skip_vertex = false;
                    if vertex_on_vertex
                        for ci = 1:length(intersection_vertices)
                            if intersection_vertices{ci} == pt1pg2
                                skip_vertex = true;
                            end
                        end
                    end
                    if ~skip_vertex
                       if ~isempty(intersection_vertices) && ...
                          intersection_vertices{1} == pt1pg2
                            result = num2cell(reorder(intersection_vertices, sense_of_rotation));
                            return;
                            
                       end
                       intersection_vertices{length(intersection_vertices)+1} = pt1pg2;
                    end         
                end
                second_counter = second_counter+1;
            else
                [tmp, vertex_on_vertex, vertex_on_edge] = pointWithinPolygon(pt1pg1,...
                                                       second_vertices);
                if tmp
                    skip_vertex = false;
                    if vertex_on_vertex
                        for ci = 1:length(intersection_vertices)
                            if intersection_vertices{ci} == pt1pg1
                                skip_vertex = true;
                            end
                        end
                    end
                    if ~skip_vertex
                       %  Here we return if we've come full circle 
                       if length(intersection_vertices)> 0 && ...
                          intersection_vertices{1} == first_vertices{mod(first_counter, n_first_vertices)+1}
                            result = num2cell(reorder(intersection_vertices, sense_of_rotation));
                            return;
                            
                       end
                       %  Here we add this vertex to the list
                       intersection_vertices{length(intersection_vertices)+1} = pt1pg1;
                    end         
                end
                first_counter = first_counter+1;
            end            
        end 
    end
    result = num2cell(reorder(intersection_vertices, sense_of_rotation)); 
end
