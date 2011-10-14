function [x_intgrl, y_intgrl] = convexPolygonIntegration(tf, polygon_vertices)
% obsolete

% a reimplementation is needed for this function
% function needed for pyramid wavefront sensor
    x_intgrl = 0;
    y_intgrl = 0;
    nvertices = length(polygon_vertices);
    
    % if the polygon is degenerate, return zero for the integrand values
    if nvertices<=2 
        return;
    end

    slope_b = 0;    slope_c = 0;
    intercept_b = 0;    intercept_c = 0;
    x_a = 0; y_a = 0; x_b = 0; y_n = 0; x_c = 0; y_c = 0;
    last_x_b = 0; last_y_b = 0; last_x_c = 0; last_y_c = 0;
    xmin = 0; ymin = 0; xmax = 0; ymax = 0;
    sign = 0;
    tmp = 0;
    
    index = 1;
    tmpobj = polygon_vertices{1}; % since we are not using handle class
    x_a = tmp.x(tf);
    % find smallest x coordinate
    for i=2:nvertices
       tmpobj = polygon_vertices{i};
       tmp = tmpobj.x(tf);
       if tmp<x_a
          index = i;
          x_a = tmp;
       end
    end
    indexb = index;
    indexc = index;
    loop = true;
    while loop
       indexb = mod((indexb+1-1), nvertices)+1;
       tmpobj = polygon_vertices{indexb};
       x_b = tmpobj.x(tf);
       if (x_b-x_a)>=Frame.precision
          loop = false; 
       end
    end
    loop = true;
    while loop
       indexc = mod((indexc-1+nvertices-1), nvertices)+1; 
       tmpobj = polygon_vertices{indexc};
       x_c = tmpobj.x(tf);
       if (x_c-x_a)>=Frame.precision
          loop = false; 
       end
    end
    
    sign = 1;
    pointc = polygon_vertices{indexc};
    pointb = polygon_vertices{indexb};
    if(pointc.y(tf)>pointb.y(tf))
        sign = -1;
    end
    
    while true
        if indexb == indexc 
           break; 
        end
        pointc = polygon_vertices{indexc};
        pointb = polygon_vertices{indexb};
        y_b = pointb.y(tf);
        lastpointb = polygon_vertices{mod(indexb-1+nvertices-1,nvertices)+1};
        last_x_b = lastpointb.x(tf);
        last_y_b = lastpointb.y(tf);
        
        slope_b =(y_b - last_y_b)/(x_b - last_x_b);
        intercept_b = y_b - slope_b*x_b;
        
        y_c = pointc.y(tf);
        lastpointc = polygon_vertices{mod(indexc+1-1, nvertices)+1};
        last_x_c = lastpointc.x(tf);
        last_y_c = lastpointc.y(tf);
        
        slope_c =(y_c - last_y_c)/(x_c - last_x_c);
        intercept_c = y_c - slope_c*x_c;
        
        %something must be wrong here in the original version, need to
        %check 
        if last_x_b>last_x_c
            xmin = last_x_c; 
        else
            xmin = last_x_b;
        end
        if x_b>x_c
            xmax = x_b;
        else
            xmax = x_c; 
        end
        ymin = y_b;
        ymax = y_c;
        if y_b>y_c
            ymin = y_c; 
        else
            ymax = y_b;
        end        
        x_integrl = x_integral + sign *((slope_b-slope_c)*(xmax^3 - xmin^3)/3+(intercept_b-intercept_c)*(xmax^2-xmin^2)/2); 
        if abs(x_b-x_c)<Frame.precision
            indexb = mod(indexb+1-1, nvertices)+1;
            if(indexb == indexc) 
                break;
            end
            indexc = mod(indexc-1+nvertices-1, nvertices)+1;
        elseif (x_b<x_c)
            indexb = mod(indexb+1-1, nvertices);
        else
            indexc = mod(indexc-1+nvertices-1, nvertices)+1;
        end
    end
    
    index = 1;
    tmpobj = polygon_vertices{1}; % since we are not using handle class
    y_a = tmp.y(tf);
    % find smallest x coordinate
    for i=2:nvertices
       tmpobj = polygon_vertices{i};
       tmp = tmpobj.y(tf);
       if tmp<y_a
          index = i;
          y_a = tmp;
       end
    end
    indexb = index;
    indexc = index;
    loop = true;
    while loop
       indexb = mod((indexb+1-1), nvertices)+1;
       tmpobj = polygon_vertices{indexb};
       y_b = tmpobj.y(tf);
       if (y_b-y_a)>=Frame.precision
          loop = false; 
       end
    end
    loop = true;
    while loop
       indexc = mod((indexc-1+nvertices-1), nvertices)+1; 
       tmpobj = polygon_vertices{indexc};
       y_c = tmpobj.y(tf);
       if (y_c-y_a)>=Frame.precision
          loop = false; 
       end
    end
    
    sign = 1;
    pointc = polygon_vertices{indexc};
    pointb = polygon_vertices{indexb};
    if(pointc.x(tf)>pointb.x(tf))
        sign = -1;
    end
    
    while true
        if indexb == indexc 
           break; 
        end
        pointc = polygon_vertices{indexc};
        pointb = polygon_vertices{indexb};
        x_b = pointb.x(tf);
        lastpointb = polygon_vertices{mod(indexb-1+nvertices-1,nvertices)+1};
        last_x_b = lastpointb.x(tf);
        last_y_b = lastpointb.y(tf);
        
        slope_b =(x_b - last_x_b)/(y_b - last_y_b);
        intercept_b = x_b - slope_b*y_b;
        
        y_c = pointc.y(tf);
        lastpointc = polygon_vertices{mod(indexc+1-1, nvertices)+1};
        last_x_c = lastpointc.x(tf);
        last_y_c = lastpointc.y(tf);
        
        slope_c =(x_c - last_x_c)/(y_c - last_y_c);
        intercept_c = x_c - slope_c*y_c;
        
        %something must be wrong here in the original version, need to
        %check 
        if last_y_b>last_y_c
            ymin = last_y_c; 
        else
            ymin = last_y_b;
        end
        if y_b>y_c
            ymax = y_b;
        else
            ymax = y_c; 
        end
        xmin = x_b;
        xmax = x_c;
        if x_b>x_c
            xmin = x_c; 
        else
            xmax = x_b;
        end        
        y_integrl = y_integral + sign *((slope_b-slope_c)*(ymax^3 - ymin^3)/3+(intercept_b-intercept_c)*(ymax^2-ymin^2)/2); 
        if abs(y_b-y_c)<Frame.precision
            indexb = mod(indexb+1-1, nvertices)+1;
            if(indexb == indexc) 
                break;
            end
            indexc = mod(indexc-1+nvertices-1, nvertices)+1;
        elseif (y_b<y_c)
            indexb = mod(indexb+1-1, nvertices);
        else
            indexc = mod(indexc-1+nvertices-1, nvertices)+1;
        end
    end  
end