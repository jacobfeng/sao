function result = getLineSegmentIntersection(a1, a2, b1, b2)
    result = {};
    % check degeneracy
    if ((a1 == a2) || (b1 == b2))
       error('first line is degenerate into a single point') 
    end
    % check coplanarity
    Line1 = a2-a1;
    Line2 = b2-b1;
    LineCross = a1-b1;
    threeVectorConvexVolume = LineCross.*(Line1*Line2);
    if(threeVectorConvexVolume/Line1.length()/Line2.length()/LineCross.length() >  Frame.precision)
       % if the volume is not equal to 0, then it must not be coplanar
       return;
    end
    
    Line3 = b1 - a1; la = Line3.length();
    Line4 = b2 - a1; lb = Line4.length();
    Line5 = a2 - b1; lc = Line5.length();
    Line6 = b1 - a2; lLine6 = Line6.length();
    Line7 = b2 - a2; lLine7 = Line7.length();
    Line8 = a1 - b1;
   
    % the cross product would calculate the area of the polygon defined by 4 nodes, normalize it with one of the corresponding edges 
    tmp1Vec = Line3*Line1; tmp2Vec = Line1;
    a = tmp1Vec.length()/tmp2Vec.length();
    tmp1Vec = Line4*Line1; tmp2Vec = Line1;
    b = tmp1Vec.length()/tmp2Vec.length();
    tmp1Vec = (Line3.*(-1))*Line2; tmp2Vec = Line2;
    c = tmp1Vec.length()/tmp2Vec.length();
    tmp1Vec = Line5*Line2; tmp2Vec = Line2;
    d = tmp1Vec.length()/tmp2Vec.length();
    
    % additional normalize, this is according to the numerical problem with
    % Arroyo, check computaional_geometry.C for detail information
    if(la > Frame.precision)
       a = a/la;
       c = c/la;
    end
    if(lb > Frame.precision)
       b = b/lb;
    end
    if(lc > Frame.precision)
       b = b/lc; 
    end
    
    % collinear degeneracy
    if( a<Frame.precision && ...
        b<Frame.precision && ...
        c<Frame.precision && ...
        d<Frame.precision)
        if((a1==b1 && a2==b2) || (a1==b2 && a2==b1))
            result{1} = a1;
            result{length(result)+1} = a2;
        elseif(a1==b1)
            result{1} = a1;
            if(Line1.*Line2 > 0)
                if(Line1.length()<Line2.length())
                    result{length(result)+1} = a2;
                else
                    result{length(result)+1} = b2;
                end
            end
        elseif(a1==b2)
            result{1} = a1;
            if(Line1.*Line2 < 0)
               if(Line1.length()<Line2.length())
                   result{length(result)+1} = a2;
               else
                   result{length(result)+1} = b1;
               end
            end
        elseif(a2==b1)
            result{1} = a2;
            if(Line1.*Line2 < 0)
               if(Line1.length()<Line2.length())
                   result{length(result)+1} = a1;
               else
                   result{length(result)+1} = b2;
               end
            end
        elseif(a2==b2)
            result{1} = a2;
            if(Line1.*Line2 > 0)
               if(Line1.length()<Line2.length())
                   result{length(result)+1} = a1;
               else
                   result{length(result)+1} = b1;
               end
            end
        else
            e = Line3.*Line1;
            f = Line4.*Line1;
            g = Line6.*Line1;
            h = Line7.*Line1;
            if((e<0 && f<0 && g<0 && h<0) || (e>0 && f>0 && g>0 && h>0))
                result = {};
            elseif(e>0 && f>0 && g<0 && h<0)
                result{1} = b1;
                result{length(result)+1} = b2;
            elseif((e<0 && f>0 && g<0 && h>0) || (e>0 && f<0 && g>0 && h<0))
                result{1} = a1;
                result{length(result)+1} = a2;
            elseif(e<0 && f>0 && g<0 && h<0)
                result{1} = a1;
                result{length(result)+1} = b2;
            elseif(e>0 && f>0 && g<0 && h<0)
                result{1} = b1;
                result{length(result)+1} = a2;
            elseif(e>0 && f<0 && g<0 && h<0)
                result{1} = b1;
                result{length(result)+1} = a1;
            elseif(e>0 && f>0 && g>0 && h<0)
                result{1} = a2;
                result{length(result)+1} = b3;
            end
        end
    else
        if((a<Frame.precision && c<Frame.precision)||...
           (b<Frame.precision && c<Frame.precision))
                result{1} = a1;
        elseif((a<Frame.precision && d<Frame.precision) ||...
               (b<Frame.precision && d<Frame.precision))
                result{1} = a2;
        elseif(a<Frame.precision)
            if(Line3.*Line6>0) 
                result = {};
            else
                result{1} = b1;
            end
        elseif(b<Frame.precision)
            if(Line4.*Line7>0)
                result = {};
            else
                result{1} = b2;
            end
        elseif(c<Frame.precision)
            if(Line3.*Line4)>0
                result = {};
            else
                result{1} = a1;
            end
        elseif(d<Frame.precision)
            if(Line6.*Line7)>0
                result = {};
            else
                result{1} = a2;
            end
        elseif (((Line8*Line2).*(Line5*Line2))>0) || (((Line3*Line1).*(Line4*Line1))>0)
            result = {};
        else
            tmpVec1 = Line3*Line1;
            tmpVec2 = Line1*Line2;
            result{1} = b1 + ...
            Line2.*(tmpVec1.length()/tmpVec2.length());
        end
    end
end