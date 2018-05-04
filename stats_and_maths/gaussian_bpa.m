function [muPost,sigmaPost] = gaussian_bpa(muList,sigmaList,mu_0,sigma_0)
%  function [groupMu,groupSigma] = gaussian_bpa(muList,sigmaList,mu_0,sigma_0)
%
% This function perform bayesian parameter averaging for k parameters under a
% multivariate gaussian law. The posterior mean & covariances are
% computed with the n-list of iid. mean & covariances likelihood (ie.
% for bayesian integration over subjects, sessions,etc... ) & the prior mean &
% covariance (if provided, otherwise it uses the non-informative limit).
%
% inputs
%   - muList: parameters means, cell array (1xn) of mean vector (kx1)
%   - sigmaList: parameters covariance matrix, cell array (1xn) of covariance matrix (kxk)
% options
%   - mu_0: prior means (vector kx1)
%   - sigma_0: prior covariance matrix (matrix kxk) 
% outputs
%   - muPost: posterior means (vector kx1)
%   - sigmaPost: posterior covariance matrix (matrix kxk) 
%
%
% ref: A. Gelman et al. (1995) Bayesian Data Analysis. Chapman and Hall.
% author: Nicolas Borderies
% date: May 2018

% dimensions
n=numel(muList);
k=numel(muList{1});

% priors
if nargin<3
    
    % non-informative limit
    lambdaPost = zeros(k);
    muPost = zeros(k,1);
    
else
    
    % prior integration
    lambda_0 = inv(sigma_0);
    lambdaPost = -(n-1)*lambda_0;
    muPost = lambdaPost*mu_0;
    
end

% precision computation
lambdaList = cellfun(@inv , sigmaList,'UniformOutput',0);

% iteration
for iN=1:n
    lambdaPost = lambdaPost + lambdaList{iN};
    muPost = muPost + lambdaList{iN}*muList{iN};
end
    
% posterior estimates
sigmaPost = inv(lambdaPost);
muPost = sigmaPost*muPost;

end