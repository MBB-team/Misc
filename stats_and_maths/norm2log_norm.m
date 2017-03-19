function [ mu_out,sigma_out] = norm2log_norm(mu_in,sigma_in,direction)
% ANALYTICAL TRANSFORMATION OF 1RST AND 2ND ORDER MOMENTS of a normal law
% into a log-normal law 
%

%INPUTS/OUTPUTS:
%   _ " mu " are means and "sigma" are standard
%   deviations
%
%   - if direction == 'direct' (default option)
%         inputs:  X_in follows a normal law (ie. X_in ~ N(mu_in,sigma_in) )
%         outputs: X_out follows a log-normal law (ie. X_out ~ logN(mu_out,sigma_out) )
%                  with X_out = exp(X_in)
% 
% 
%   - elseif direction == 'reverse'
%         inputs:  X_in follows a log-normal law (ie. X_in ~ logN(mu_in,sigma_in) )
%         outputs: X_out follows a normal law (ie. X_out ~ N(mu_out,sigma_out) )
%                  with X_out = log(X_in)

% arguments %
if nargin < 2
	error('Must have at least the first two arguments');
elseif nargin == 2
    direction = 'direct';
end

%  transformation %
if strcmp('direct',direction)
    mu_out = exp(mu_in+((sigma_in)^2/2));
    sigma_out = sqrt((exp((sigma_in)^2)-1)*exp(2*mu_in+(sigma_in)^2));
    
elseif strcmp('reverse',direction)
    mu_out = log(mu_in/sqrt(((sigma_in/mu_in)^2)+1));
    sigma_out = sqrt(log(((sigma_in/mu_in)^2)+1)); 
end

end
