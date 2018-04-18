function s = surpriseInfo(x,discretize_flag)
% Compute surpriseInfo s=H(x) of a discrete variable x.
% Input:
%   x: a integer vectors  
%   discretize_flag: flag for discretization of a continuous variable (logical,def=0)
% Output:
%   z: entropy z=H(x)
% Written by Mo Chen (sth4nth@gmail.com).

if nargin<2
    discretize_flag=0;
end

n = numel(x);
if discretize_flag
    [~,u,x] = histcounts(x);
    x=x';
    u=u';
else
    [u,~,x] = unique(x);
end
k = numel(u);
idx = 1:n;
Mx = sparse(idx,x,1,n,k,n);
% Px = nonzeros(mean(Mx,1));
Px = full(mean(Mx,1))';
s = -log2(Px(x));
s(isempty(x)) = NaN ;