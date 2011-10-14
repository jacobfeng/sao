function result = getRayPlaneIntersection(o_a,n_a,o_b,n_b)
% function type
% Point = getRayPlaneIntersection(Point, Vector, Point, Vector)
% Return the point of intersection between a ray extending from
% o_a in the direction n_a and a plane defined by normal n_b and
% origin o_b.
% 
% WARNING:  this function can return inaccurate results due to 
% numerical roundoff.  Quantifying the limits of validity of this
% function is a work in progress.
    if(n_a.length()==0 || ...
       n_b.length()==0)
        error('input has zero length');
    end
    
    % when o_a is in the plane defined by o_b, n_b
    odiff = o_b - o_a;
    if(abs(odiff.*n_b) < Frame.precision)
       result = o_a; 
       return;
    end
    
    %normalized vector, taken note here, since later this property is
    %needed
    na = n_a;
    na = na.*(1/n_a.length());
    nb = n_b;
    nb = nb.*(1/n_b.length());
    
    % ensure nb is directed towards oa (cuts down the number of cases one must consider), in which case, angle should be
    % less than 180 deg, if not, inverse the direction
    if((nb.*odiff)<0)
       nb = nb.*(-1); 
    end
    
    if(abs(na.*nb)<Frame.precision)
        error('plane is parallel to the ray');
    end
    
    % case when the ray is starting from na
    tmpVec1 = na*nb; tmpVec2 = na*odiff;
    if(tmpVec1.length() < Frame.precision &&...
       tmpVec2.length() < Frame.precision)
        result = o_b;
        return;
    end
       
    % normal case, need a projection
    perpendicular_point = o_a - nb.*(odiff.*nb); % node - perpendicular_vector, nb is a unit vector
    % o_a to perpendicular_point vector
    perpendicular_vector = o_a - perpendicular_point;
    % distance from o_a to the intersection point, need to project the
    % perpendicular distance back, therefore /(na.*nb)
    distance = perpendicular_vector.length()/(na.*nb);
    result = o_a+(na.*distance);
end