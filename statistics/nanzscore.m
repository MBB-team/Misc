function [ z] = nanzscore(x, dim  )
%  Z = NANZSCORE(X) return a zscored X even if there are some NaN!
if nargin<2
   dim = find(size(x) ~= 1, 1);
   if isempty(dim), dim = 1; end
 end  

z = (x - nanmean(x))/nanstd(x, [], dim);

end

