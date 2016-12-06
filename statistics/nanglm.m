function [beta,L,posterior,out] = nanglm(X,y,verbose,sparsity)
% nanglm - perform a glm analysis with missing data under the VBA scheme
%
% Inputs:
%    X - design matrix
%    y   - observation vector
%    verbose - flag to display text & figure (def=0)
%
% Outputs:
%    beta  - regression coefficients
%    L - glm log-evidence
%    posterior  - full posterior densities estimates
%    out - full output structure of the model inversion
%
% Example: 
%
% See also: 
%
% Author: Nicolas Borderies
% email: nico.borderies@gmail.com
% November 2016; 

% default arguments
if nargin<4
    sparsity=0;
    if nargin<3
        verbose=0;
    end
end

%  data dimensions
n = size(X,1); % # observations
p = size(X,2); % # regressors
d = numel(find(isnan(X)));  % # missing data in GLM design matrix
tmp = find(isnan(X));  % index of  missing data in GLM design matrix
omp = find(isnan(y));  % index of  missing data in observations
Xmd = X;
Xmd(tmp)=0;

% set up GLM with missing data
g_fname = @g_GLM_md;
inG.X = Xmd;
inG.b = 1:p;
inG.md = p+1:p+d;
inG.xmd = tmp';
dim.n = 0;
dim.n_theta = 0;
dim.n_phi = p+d;
priors.muPhi = zeros(dim.n_phi,1);
priors.SigmaPhi = 1e0*eye(dim.n_phi);
options.isYout =  zeros(size(y));
options.isYout(omp) = 1;
y(omp) = 0;

% options
options.priors = priors;
inG.sparsity = sparsity;
inG.smooth = 0.01;
options.inG = inG;
options.verbose = verbose;
options.DisplayWin = verbose;

% inversion
[posterior,out] = VBA_NLStateSpaceModel(y,[],[],g_fname,dim,options);

% extract
beta = posterior.muPhi(inG.b);
if sparsity
    beta = sparseTransform(posterior.muPhi(inG.b),inG.smooth);
end
L = out.F;


end




