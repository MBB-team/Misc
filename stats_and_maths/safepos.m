function [ y, dydx ] = safepos( x )
% SAFEPOSE is an approximation of max(x,0).
% this function can be used to transform a parameter into positive numbers.

k=20; 
% the greater, the smaller the approximation error.
% For instance, with k=15, the error = 0.0462
% with k=70, the error = 0.0099.
% However, if k is too big, the algorithm might fail to adjust the
% parameters properly.

% main output
y=log(1+exp(k*x))/k;

% first derivative
dydx = exp(k*x)/(exp(k*x) + 1);

if any(isinf(y))
    y(isinf(y))=x(isinf(y));
end
    
end

