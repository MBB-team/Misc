function [beta,stat] = VBA_logit(x,y,Xnames,c)


% define input & output
if isequal(class(x),'table')
    predictor = x;
    x = predictor(:,1:end-1)';
    y = predictor(:,end)';
    Xnames = predictor.Properties.VariableNames(1:end-1);
end

% function
g_fname = @g_logit;

% priors
nphi = size(x,1) + 1;
priors.muPhi = zeros(nphi,1);         % prior mean on observation params
priors.SigmaPhi = 1e0*eye(nphi); % prior covariance on observation params
% priors.a_sigma = 1;             % Jeffrey's prior
% priors.b_sigma = 1;             % Jeffrey's prior
options.priors = priors;        % include priors in options structure

% dimensions
dim = struct('n',0,... % number of hidden states
    'n_theta',0 ,...   % number of evolution parameters
    'n_phi',nphi,...     % number of observation parameters
    'p',1,...          % output (data) dimension
    'n_t',size(y,2));   % number of time samples or trials
options.dim             = dim;

% options
if ~isempty(find(isnan(x)))
    options.isYout          =  zeros(size(y,1),size(y,2));   % data exclusion
    options.isYout(isnan(x))          =  1;  x(isnan(x)) = 0;
end
options.DisplayWin      = 1;
options.verbose         = 1;
% options.extended=1;
% options.sources(1).type = 1;    % binomial data
% options.sources(1).out = 1;    
options.binomial = 1;    % binomial data
options.kernelSize = 0; 

% Call inversion routine
[posterior,out] = VBA_NLStateSpaceModel(y,x,[],g_fname,dim,options);

% extract
    beta = array2table([posterior.muPhi';diag(posterior.SigmaPhi)' ; ones(1,numel(posterior.muPhi)) ],...
                        'VariableNames',[{'x0'} ; Xnames]',...
                        'RowNames',{'mu','std','p'});

    % reduced model
    for i = 1:numel(posterior.muPhi)
        priors2.muPhi = zeros(nphi,1);         % prior mean on observation params
        priors2.SigmaPhi = 1e0*eye(nphi); % prior covariance on observation params
        priors2.SigmaPhi(i,i) = 0;
        [F2,~] = VBA_SavageDickey(posterior,options.priors,out.F,dim,priors2);
        dF = out.F - F2 ;
        beta{3,i} = 1./(1+exp(dF));
    end
    
   
    stat = struct;
    stat.logE = out.F;
    dF = out.F - out.diagnostics.LLH0 ;
    stat.p = 1./(1+exp(dF));
    stat.BCA = out.fit.acc;
    stat.yy = out.suffStat.gx;
    stat.corrBeta = cov2corr(posterior.SigmaPhi);
    
     % contrast
    if nargin>3
        stat.contrast = array2table([ c , zeros(size(c,1),1) ],...
                        'VariableNames',[{'x0'} ; Xnames ;{'logE'}]');
        stat.contrast.logE(1) = stat.logE;
        
        for i = 1:size(c,1)
            priors2.muPhi = zeros(nphi,1);         % prior mean on observation params
            priors2.SigmaPhi = 1e0*eye(nphi); % prior covariance on observation params
            priors2.SigmaPhi(i,i) = 0;
            [F2,~] = VBA_SavageDickey(posterior,options.priors,out.F,dim,priors2);
            stat.contrast.logE(i) = F2;
        end
    end

    % figure
     f = displayLogit( beta ) ;
     if nargin>3
        f = displayModelSelection( stat.contrast.logE );
     end

end
