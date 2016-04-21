function [ z] = rangescore(x, dim  )
if nargin<2
   dim = find(size(x) ~= 1, 1);
   if isempty(dim), dim = 1; end
 end  

z = (x)./range(x,dim);

end

