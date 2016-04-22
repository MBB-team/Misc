function [ std_error_mean ] = sem(normal_sample,dim)
%sem: standard error of the mean (for sample following a normal law)
%     input : - sample observed saved into a vector
%             - dimension of the vector indicating index of observation

% default argument
if nargin == 1
    dim = find(size(normal_sample) == max(size(normal_sample)),1,'first' );
end

std_error_mean = nanstd(normal_sample,0,dim)/sqrt(size(normal_sample,dim));


end

