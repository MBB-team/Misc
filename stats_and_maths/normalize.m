function y = normalize(x,type)
% this function normalize a vector x with a specified method in the 
% type argument
%
% Inputs:
%    x - input vector
%    type - 'mean','variance','zscore','range','max' 

%
% Outputs:
%   y - output vector
%
% Nicolas Borderies
% March 2017

switch type
    case 'mean'
        y = x - nanmean(x);
    case 'variance'
        y = x./nanvar(x);
    case 'zscore'
        y = nanzscore(x);
    case 'range'
        y = x./range(x);
    case 'max'
        y = x./nanmax(x);
end

end