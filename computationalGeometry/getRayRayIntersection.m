function result = getRayRayIntersection(tp1, tv1, tp2, tv2)
% function type is point = getRayRayIntersection(point, vector, point,
% vector)
% Return the point of intersection between a ray extending from
% o_a in the direction n_a, and a ray extending from o_b in the
% direction n_b.
% 
% WARNING:  this function can return inaccurate results due to 
% numerical roundoff.  Quantifying the limits of validity of this
% function is a work in progress.

    % ensure vectors are not NULL
    if(tv1.length()<Frame.precision || tv2.length()<Frame.precision)
       error('input vector should not be NULL'); 
    end

    % ensure vectors are not parallel
    tmp = tv1*tv2;
    if(tmp.length()*(1/tv1.length()/tv2.length())<Frame.precision)
       error('input vector should not be parallel'); 
    end

    % ensure points are unique
    tv3 = tp1-tp2;
    if(tv3.length()<Frame.precision)
       error('input points should be unique'); 
    end

    % ensure vectors are coplanar
    tmp = tv1*tv2;
    if(abs((tmp.*tv3)/tv1.length()/tv2.length()/tv3.length())>Frame.precision)
       error('input argument is not coplanar');
    end

    % law of sines, using cross products, to get the vector connecting tp1 to the
    % point of intersection.  The direction of the vector is also checked to ensure
    % that we get the right one.
    tmpVec1 = tv2*tv3;
    tmpVec2 = tv1*tv2;
    mag = tv1.*(tmpVec1.length()/tmpVec2.length());
    tmpVec1 = tv2*(tp1+mag-tp2);
    tmpVec2 = tv2*(tp1-mag-tp2);
    if(tmpVec1.length()>tmpVec2.length())
       result = tp1-mag;
       return;
    end
    result = tp1+mag;
end