function result = getAreaOfPolygon(polygon_vertices)
    % input point sequence must be sorted before using
    % function type
    % double = getAreaOfPolygon(cell(Point))
    nvertices = length(polygon_vertices);
    if(nvertices<3)
       error('getAreaOfPolygon() error, number of vertices is less than 3');
    end

    index1 = 2;
    tmpV1 = polygon_vertices{index1}-polygon_vertices{1};
    while(tmpV1.length()<Frame.precision)
       index1 = index1+1;
       tmpV1 = polygon_vertices{index1}-polygon_vertices{1}; 
    end
    index2 = index1+1;
    tmpV2 = polygon_vertices{index2}-polygon_vertices{index1};
    while(tmpV2.length()<Frame.precision)
        index2 = index2+1;
        tmpV2 = polygon_vertices{index2}-polygon_vertices{index1};
    end

    out_of_plane_normal = tmpV1*tmpV2;
    out_of_plane_normal = out_of_plane_normal.*(1/out_of_plane_normal.length());
    polygon_area = 0;
    for i=3:nvertices
       %calculate the two triangle, and sum up for the are of the polygon 
       tmpv1 = polygon_vertices{i-1} - polygon_vertices{1};
       tmpv2 = polygon_vertices{i}   - polygon_vertices{1};
       triangle_area = .5* ((tmpv1*tmpv2).*out_of_plane_normal);
       if triangle_area==inf
          error('getAreaOfPolygon() error, infinite area calculated');
       else
          polygon_area = polygon_area + triangle_area; 
       end
    end
    result = polygon_area;
end