function [ z] = rangescore(x, dim  )
%  Z = NANZSCORE(X) return a zscored X even if there are some NaN!
if nargin<2
   dim = find(size(x) ~= 1, 1);
   if isempty(dim), dim = 1; end
end  

r = repmat(range(x,dim),size(x,1),1);
 
z = (x)./r;

end

