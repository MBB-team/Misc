function [beta,L,posterior,out] = nanglm(varargin)
% nanglm - perform a glm analysis with missing data under the VBA scheme
%
% Syntax: function [beta,L,posterior,out] = nanglm(X,y,...)
%
% Inputs:
%    X - design matrix
%    y   - observation vector
%
%    (optional)
%    'verbose' - flag to display text & figure (def=0)
%    'sparsity' - flag to perform sparse GLM regression (def=0)
%    'logit' - flag to perform logistic regression (def=0)

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
X = varargin{1};
y = varargin{2};
sparsity=0;
verbose=0;
logit=0;

% optionnal arguments
if nargin > 2;
    for i=3:nargin
        arg = varargin{i};
        switch arg
            case 'sparsity'
                sparsity = varargin{i+1};
            case 'verbose'
                verbose = varargin{i+1};
            case 'logit'
                logit = varargin{i+1};
        end
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
inG.logit = logit;
dim.n = 0;
dim.n_theta = 0;
dim.n_phi = p+d;
dim.n_t = 1;
dim.p = n;
priors.muPhi = zeros(dim.n_phi,1);
sigma = min([nanstd(y)*ones(1,p).*(nanvar(y)./nanvar(X)) ; 
             nanstd(y)*ones(1,p) ]);
if d>0
    sigma = [sigma , mean(sigma).*ones(1,d)];
end
if sparsity
    sigma = 1e0.*ones(1,dim.n_phi);
end
priors.SigmaPhi = diag(sigma);
options.isYout =  zeros(size(y));
options.isYout(omp) = 1;
y(omp) = 0;

% options
options.priors = priors;
inG.sparsity = sparsity;
inG.smooth = log(2);
options.inG = inG;
options.verbose = verbose;
options.DisplayWin = verbose;
if logit==1
    options.binomial=1;
end

% inversion
[posterior,out] = VBA_NLStateSpaceModel(y,[],[],g_fname,dim,options);

% extract
beta = posterior.muPhi(inG.b);
if sparsity
    beta = sparsify(posterior.muPhi(inG.b),inG.smooth);
end
L = out.F;

% 

end




