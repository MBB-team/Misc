function [e] = errorscore(x,dim)
% Standardized error score


% [] is a special case for std and mean, just handle it out here.
if isequal(x,[]), z = []; return; end

flag = 0;
if nargin < 3
    % Figure out which dimension to work along.
    dim = find(size(x) ~= 1, 1);
    if isempty(dim), dim = 1; end
end

% Compute X's mean and sd, and standardize it
mu = nanmean(x,dim);
sigma = nanstd(x,flag,dim);
sigma0 = sigma;
sigma0(sigma0==0) = 1;
e = bsxfun(@minus,x, mu);

