function result = reorder(intersection_vertices, sense_of_rotation)
% function type
% reorder the node in right hand order of the sense o rotation vector
% cell(point) = reorder(cell(point), vector);
% this function only puts points regarding to the first vertices that has different orientation then sense_of_rotation to the front of the queue 
    tmp = Point();
    for i=2:(length(intersection_vertices)-1)
       for j=(i+1):length(intersection_vertices)
          tmpVi1 = intersection_vertices{i} - intersection_vertices{1};
          tmpVj1 = intersection_vertices{j} - intersection_vertices{1};
          cross = tmpVi1*tmpVj1;
          if(cross.*sense_of_rotation <0)
              tmp = intersection_vertices{i};
              intersection_vertices{i} = intersection_vertices{j};
              intersection_vertices{j} = tmp;
          end
       end
    end
    result = intersection_vertices;
end