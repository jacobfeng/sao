classdef OrthonormalTransformation < Transformation
   methods
       function obj = OrthonormalTransformation(varargin)
            obj = obj@Transformation(varargin{:});
       end  
       function result = inverse(obj)
            tmp = inverse@Transformation(obj);
            result = OrthonormalTransformation(tmp);
       end
       function result = transform(obj, in)
       % the inv_tf included here is the legacy of Arroyo... will be changed in total in near future    
       % function types,
       % 1. point = obj.transform(point)
       % 2. vector = obj.transform(vector)
       % 3. frame = obj.transform(frame)
            inv_tf = obj.inverse(); %although it would return a Transformation class, it doesn't infect the result much, since all the transformation class only differs in the transformation matrix
            if isa(in, 'Frame')
               tmpx = in.x(); tmpy = in.y(); tmpz = in.z();
               zp = in.getzp();
               tmpzp = transform@Transformation(inv_tf,zp);
               tmpx = transform@Transformation(inv_tf,tmpx);
               tmpy = transform@Transformation(inv_tf,tmpy);
               tmpz = transform@Transformation(inv_tf,tmpz);
               result = Frame(tmpzp, tmpx, tmpy, tmpz);
            elseif isa(in, 'Point') || isa(in, 'Vector');
               result = transform@Transformation(inv_tf,in);
            end
       end
       
   end
end