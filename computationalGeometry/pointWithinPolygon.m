function varargout = pointWithinPolygon(tp, vertices)
% function type
% 1. [bool] = pointWithinPolygon(point, cell(vertices))
% 2. [bool, bool, bool] = pointWithinPolygon(point, cell(vertices))
%     isWithin, isOnEdge, isOnVertex
% the second form is implementing the Arroyo bool
% point_within_polygon(point &, vector &, bool &, bool &)
    x = 0; dy = 0; 
    crossings = 0;
    xflag0 = false; yflag0 = false; yflag1 = false;
    nvertices = length(vertices);
    v1 = Vector(); v2 = Vector();
    if nvertices<3
        error('pointWithinPolygon error, vertices number is less than 3'); 
    end
    % checking input vertices duplication
    for i=1:(nvertices-1)
        for j=(i+1):nvertices
           if vertices{i} == vertices{j}
              error('polintWithinPolygon error(), duplicated vertices');
           end
        end
    end
    % checking for coplanarity
    first  = vertices{2} - vertices{1};
    second = vertices{3} - vertices{1};
    cross = first * second;
    cross = cross.*(1/cross.length());
    for i=4:nvertices
       tmp_unit_vector = vertices{i}-vertices{1};
       tmp_unit_vector = tmp_unit_vector.*(1/tmp_unit_vector.length());
       if abs(cross.*tmp_unit_vector)>Frame.precision   % the same method as: Volume = avec.*(bvec*cvec)
          error('pointWithinPolygon() error, inputs are not coplanar');
       end
    end
    % check wether the point is equal to one of the vertices
    for i=1:nvertices
       if tp==vertices{i} 
           varargout{1} = true;
           varargout{2} = false;
           varargout{3} = true;
           return;
       end
    end
    % ensure tp is coplanar with vertices
    tmp_unit_vector = tp - vertices{1};
    tmp_unit_vector = tmp_unit_vector.*(1/tmp_unit_vector.length());
    if cross.*tmp_unit_vector > Frame.precision
        error('input note is not coplanar with other vertices');
    end
    
    tf = Frame(tp, first, cross*first, cross);
    vertex_one = vertices{nvertices};
    % get test result for above/below Y axis
    % not clear for the principle of the underlying
    dy = vertex_one.y(tf) - tp.y(tf);
    yflag0 = (dy>=0);
    crossings = 0;
    vertex_two = Point();
    for i=1:nvertices
       if mod(i, 2)==0
          vertex_one = vertices{i};
          dy = vertex_one.y(tf) - tp.y(tf);
          yflag0 = (dy>=0);
       else
          vertex_two = vertices{i};
          yflag1 = (vertex_two.y(tf) >= tp.y(tf));
       end
    
    
       v1 = vertex_two - vertex_one;
       v2 = tp - vertex_two;
       cross1 = v1*v2;
       dot1 = v1.*v2;
       if(cross1.length()/v1.length()/v2.length()<Frame.precision)
           if(dot1>0 &&...
           v1.length() > v2.length())
                varargout{1} = true;
                varargout{2} = true;
                varargout{3} = false;
                return;
           end
       end        
       if(yflag0 ~= yflag1)
            xflag0 = vertex_one.x(tf)>=tp.x(tf);
            if(xflag0==(vertex_two.x(tf)>=tp.x(tf)))
                if(xflag0 == true)
                    crossings = crossings+1; 
                end
            else
                tmp = (vertex_one.x(tf) - dy*(vertex_two.x(tf) - vertex_one.x(tf))/(vertex_two.y(tf)-vertex_one.y(tf)))>=tp.x(tf);
                if(tmp==true)
                    crossings = crossings + 1;
                end
            end
       end
    end
    if mod(crossings,2) ==1
        varargout{1} = true;
    else
        varargout{1} = false;
    end
        
    varargout{2} = false;
    varargout{3} = false; 
end