function [p_expVar,expVar,ycond] = varpart(y,x)
% varpart - performs a variance partitioning of var[y]
%   conditional to the values of x such as: 
%   var[y] = var[y|x] + var[error[y|x]]
%
% Nicolas Borderies
% March 2017

% conditional E[y|x]
ymean = nanmean(y);
condmean = splitapply(@nanmean,y,x);
predicted = ymean*ones(numel(y),1);
predicted(~isnan(x)) = condmean(x(~isnan(x)));
% conditional residuals 
residual = y - predicted;
% variance decomposition
expVar = nanvar(predicted);
p_expVar = nanvar(predicted)/(nanvar(y));
% projection of y into the null space of x
ycond = residual+ymean;


end