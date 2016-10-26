function [stat,model] = process_oximeter(oxdata,data,training)
%process_oximeter - extract statistical metrics from continuous oxymetric data
%
% Inputs:
%    oxdata - matrix sorted by the pulse oximeter
%    data   - design matrix of the experiment
%    training - design matrix of the training
%
% Outputs:
%    stat - summary statistics of the analysis
%    model - detailed statistics of the analysis
%
% Example: 
%
% See also: 
%
% Author: Nicolas Borderies
% email: nico.borderies@gmail.com
% August 2016; 

%% setup
% define
    force = [training(:,3) ; data.forcePeak ];
    level = [training(:,2) ; data.incentiveLevel ];
    level = abs(level); 
    rt = [ zeros(size(training(:,3))) ; data.rt];
    
    time = oxdata(:,12);
    beat = oxdata(:,4);
    ppg = oxdata(:,5);
    incentive = oxdata(:,13);
    effort = oxdata(:,14);


% sampling freq
    % f = 1/(mean(time(2:end) - time(1:end-1)));
    f = 60; % Hz


%% 1/ preprocessing ppg
    windowSize = (1)*f/2; % nyquist frequency

% outlier removal   
    % method 1
        % detect
        ppg2 = smooth(ppg,windowSize);
        ppg3 = ppg-ppg2;
        mu = mean(ppg);
        sd = std(ppg);
        criterion = 2*sd;
        outlier = (abs(ppg3)>= criterion);
        % remove
        ppg4 = ppg;
        ppg4(outlier) = NaN;
        % interpolate
        ppg4 = interp1(find(outlier==0),ppg4(outlier==0),[1:numel(ppg4)]','cubic');
    
    % method 2
%      ppg4 = medfilt1(ppg,windowSize);

    % method 3 
%     env = abs(hilbert(ppg,windowSize));


% filtering
    % bandpass 
    order = 6;
    maxVal = 240; maxVal = maxVal/60;
    minVal = 30;  minVal = minVal/60;
    freq = [minVal maxVal]/(f/2);
    [b,a] = butter(order,freq,'bandpass');
    raw = ppg4;
%     ppg4 = filter(b,a,raw);
    ppg4 = filtfilt(b,a,raw);

    % lowpass filter
    maxVal = 30; maxVal = maxVal/60;
    freq =  [maxVal]/(f/2);
    [b,a] = butter(order,freq,'low');
    rr = filtfilt(b,a,raw);

    % spectral analysis
    sa = hilbert(rr);
    rr_phase = unwrap(angle(sa));

    
% quality check 
%     figure; hold on;
%     ind = [1:10000]+0;
%     plot(time(ind),ppg(ind));
%     plot(time(ind),ppg2(ind));
%     plot(time(ind),dppg(ind));
%     plot(time(ind),dppg2(ind));
%     scatter(time(ind),outlier(ind)*100);
%     plot(time(ind),raw(ind));
%     plot(time(ind),ppg4(ind));
%     plot(time(ind),rr_phase(ind)*10);
%     scatter(time(ind),incentive(ind)*10,'filled');


    


%% 2/ heart-rate estimation

% pulse detection
    % 1order deriv
    d1_ppg = diff(ppg4,1);
    d1_ppg = smooth(d1_ppg,5);
    int_ppg = (abs(d1_ppg));
    % 2order deriv
    d2_ppg = diff(ppg4,2);
    d2_ppg = smooth(d2_ppg,5);
    % criterions
    pulseDist = 0.2*f; % sec
    pulseWidth = [ 0.1 2 ]*f;
    % 1. local maximum + artefacts removal
    [max2d,ind_max2d] = findpeaks(ppg4,'MinPeakDistance',pulseDist,'MinPeakWidth',pulseWidth(1),'MaxPeakWidth',pulseWidth(2));
    ind_pos1d = find( abs(d1_ppg) < 0.10*max(d1_ppg) );
    ind_pulse = intersect(ind_max2d,ind_pos1d);
    pulse = zeros(size(ppg4));
    pulse(ind_pulse)=1;
    % 2. pre-extracted by the sensor
%     ind_pulse = find(beat); 

% hr computation
    ppi = nan(size(ppg4));
    ppi(ind_pulse(2:end))= (time(ind_pulse(2:end)) - time(ind_pulse(1:end-1)));
    hr = 1./ppi*60;


% hr preprocessing
    % outlier removal
    maxVal = 240;
    minVal = 30;
    hr( hr<minVal | hr>maxVal ) = NaN;
    
    windowSize = 5; 

    hr2 = nan(size(hr));
%     hr2(~isnan(hr)) = smooth(hr(~isnan(hr)),windowSize);
    hr2(~isnan(hr)) = smooth(hr(~isnan(hr)),'rlowess');
%     hr2(~isnan(hr)) = fit(time(~isnan(hr)),hr(~isnan(hr)),'smoothingspline');
%     curve= fit(time(~isnan(hr)),hr(~isnan(hr)),'smoothingspline');
%      hr2(~isnan(hr)) = feval(curve,time(~isnan(hr)));

    hr3 = hr-hr2;
    mu = nanmean(hr);
    sd = nanstd(hr3);
    criterion = 2*sd;
    outlier = (abs(hr3)>= criterion);
    hr4 = hr;
    hr4(outlier) = NaN;
    hr4 = interp1(time(outlier==0),hr4(outlier==0),time,'cubic');
    first = find(pulse==1,1,'first');
    hr4(1:first) = NaN;
    
% % quality check 
%     figure; hold on;
%     ind = [1:10000];
%     ind = [1:numel(ppg4)];
%     plot(time(ind),ppg4(ind));
%     hold on;
%     plot(time(ind),d1_ppg(ind)*10);
%     plot(time(ind),d2_ppg(ind)*10);
%     scatter(time(ind),pulse(ind)*10);
%     findpeaks(ppg4(ind),time(ind));
%     findpeaks(ppg4(ind),time(ind),'MinPeakDistance',pulseDist/f,'MinPeakWidth',pulseWidth(1)/f,'MaxPeakWidth',pulseWidth(2)/f);
%     scatter(time(ind),beat(ind)*10);
%     scatter(time(ind),hr(ind));
%     plot(time(ind),hr2(ind));

%     scatter(time(ind),incentive(ind));
%     scatter(time(ind),ppi(ind));
%     plot(time(ind),hr4(ind));
%     plot(time(ind),rr_phase(ind)*10);


%% 3/ hr signal alignement

% define
timeLimIncentive = [-0.5 , +4];
timeLimEffort = [-0.5 , +6];
mu = nanmean(hr4);

% response to incentive event
    % event definition
    windowLim = round([timeLimIncentive(1):(1/f):timeLimIncentive(2)]*f);
    flag = (incentive~=0);
    trialNumber = cumsum(flag);
    fir = nan(max(trialNumber),numel(windowLim));
    fir_time = nan(max(trialNumber),numel(windowLim));
    fir_rrphase = nan(max(trialNumber),numel(windowLim));
%     fir_force = nan(max(trialNumber),numel(windowLim));

    %  time bin loop
    for it=1:max(trialNumber)
        % buffer
        ind = find(trialNumber==it+1 | trialNumber==it | trialNumber==it-1);
        if it>1 ; ind = ind(2:end); end
        buffer =  hr4(ind);
        buffer_time = time(ind);
        buffer_phase = rr_phase(ind);
        onset = find(trialNumber(ind)==it,1,'first');
%             onset2 = find(trialNumber(ind)==it & flag2(ind)==1 ,1,'first');
%             buffer_force = (trialNumber(ind)==it & ind>=onset2 );
        prestim = sum(windowLim<0); 
        if it==1 
           onset = onset + prestim;
           buffer = [nan(prestim,1) ; buffer]; 
           buffer_time = [nan(prestim,1) ; buffer_time]; 
           buffer_phase = [nan(prestim,1) ; buffer_phase]; 
%                buffer_force = [nan(prestim,1) ; buffer_force]; 
        end
        % signal
        % without baseline removal
%         fir(it,:) = buffer(onset+windowLim);
        % with baseline removal
        baseline = nanmean(buffer(onset+windowLim(1):onset));
%         baseline = buffer(onset);
%         baseline = nanmean(buffer(onset-15:onset+15));
%         baseline = mu;
        fir(it,:) = buffer(onset+windowLim) - baseline;        
        fir_time(it,:) = buffer_time(onset+windowLim) - buffer_time(onset);
        fir_rrphase(it,:) = buffer_phase(onset+windowLim);        
%         fir_force(it,:) = buffer_force(onset+windowLim);        
    end

    
% response to effort event
    % event definition
    windowLim = round([timeLimEffort(1):(1/f):timeLimEffort(2)]*f);
    flag = (effort~=0);
    trialNumber = cumsum(flag);
    fir2 = nan(max(trialNumber),numel(windowLim));
    fir2_time = nan(max(trialNumber),numel(windowLim));
    fir2_rrphase = nan(max(trialNumber),numel(windowLim));

    % time bin loop
        for it=1:max(trialNumber)
            % buffer
            ind = find(trialNumber==it+1 | trialNumber==it | trialNumber==it-1);
            if it>1 ; ind = ind(2:end); end
            buffer =  hr4(ind);
            buffer_time = time(ind);
            buffer_phase = rr_phase(ind);
            onset = find(trialNumber(ind)==it,1,'first');
            lag = min(0,round(rt(it)*f));
            lag = max(3,lag);
            onset = onset + lag;
            prestim = sum(windowLim<0); 
            if it==1 
               onset = onset + prestim;
               buffer = [nan(prestim,1) ; buffer]; 
               buffer_time = [nan(prestim,1) ; buffer_time]; 
               buffer_phase = [nan(prestim,1) ; buffer_phase]; 
            end
            % signal
            % without baseline removal
%             fir2(it,:) = buffer(onset+windowLim);
            % with baseline removal
            baseline = nanmean(buffer(onset+windowLim(1):onset));
    %         baseline = buffer(onset);
    %         baseline = nanmean(buffer(onset-15:onset+15));
%             baseline = mu;
            fir2(it,:) = buffer(onset+windowLim) - baseline;        
            fir2_time(it,:) = buffer_time(onset+windowLim) - buffer_time(onset);
            fir2_rrphase(it,:) = buffer_phase(onset+windowLim);        
        end
        
% averaging
    % incentive
    mu_fir = nanmean(fir,1);
    sd_fir = sem(fir,1);
    mu_fir_time = nanmean(fir_time,1);
    % effort
    mu_fir2 = nanmean(fir2,1);
    sd_fir2 = sem(fir2,1);
    mu_fir2_time = nanmean(fir2_time,1);
    
% quality check 
%     figure; hold on;
%     plot(time(ind),hr4(ind));
%     scatter(buffer_time,flag(ind)*100);
%     for it=1:size(fir,1)
%         plot(fir_time(it,:),fir(it,:));
%         pause;
%     end
% 
%     [h,hp] = boundedline( mu_fir_time , mu_fir , sd_fir , 'alpha','transparency',0.5); 
%     set(h,'Color','r','LineWidth',2);set(hp,'FaceColor','r');
%     h.LineStyle = '-'; 
%     
%     [h,hp] = boundedline( mu_fir2_time , mu_fir2 , sd_fir2 , 'alpha','transparency',0.5); 
%     set(h,'Color','b','LineWidth',2);set(hp,'FaceColor','b');
%     h.LineStyle = '-'; 
    
%% 4/ statistical models
    
%%% 1. multiple time-independant regressions
% response to cue event
    % define
    beta_cue = nan(size(mu_fir));
    se_cue = nan(size(mu_fir));
    beta_cue_incentive = nan(size(mu_fir));
    se_cue_incentive = nan(size(mu_fir));
    beta_cue_force = nan(size(mu_fir));
    se_cue_force = nan(size(mu_fir));
    rho_cue = nan(size(mu_fir));
    deltaBIC_cue = nan(size(mu_fir));
    % regressors
    x = nanzscore(level);
    x2 = nanzscore(force);
    % orthogonalization
%     [~,~,stat] = glmfit(x,x2,'normal');
%     x2 = stat.resid*0;
    % time loop
    nt = numel(mu_fir);
    for t = 1:nt
        x3 = fir_rrphase(:,t);
        wsize = 60;
        window = [t-wsize/2:t+wsize/2]; 
        window = window(window>0);
        window = window(window<nt);
%         y = fir(:,t);
        y = nanmean(fir(:,window),2);
        
        % muti-linear regression of response
        [beta,~,stat] = glmfit([x,x2,x3],y,'normal');
        beta_cue(t) = beta(1);
        se_cue(t) = stat.se(1);
%         beta_cue_incentive(t) = beta(2);
%         se_cue_incentive(t) = stat.se(2);
%         beta_cue_force(t) = beta(3);
%         se_cue_force(t) = stat.se(3);
%         rho_cue(t) = stat.coeffcorr(2,3);
        
        % mutiple colinear regression of response
        [stat] = fitglm([x,x3],y,'linear');
        beta_cue_incentive(t) = stat.Coefficients.Estimate(2);
        se_cue_incentive(t) = stat.Coefficients.SE(2);
        bic_incentive = stat.ModelCriterion.BIC;
        [stat] = fitglm([x2,x3],y,'linear');
        beta_cue_force(t) = stat.Coefficients.Estimate(2);
        se_cue_force(t) = stat.Coefficients.SE(2);
        bic_force = stat.ModelCriterion.BIC;
        deltaBIC_cue(t) = bic_incentive - bic_force;
        
        % muti-linear regression of response variability
%         y = abs(fir(:,t) - beta_cue(t));
%         [beta,~,stat] = glmfit([x,x3],y,'normal');
%         beta_cue_incentive(t) = beta(2);
%         se_cue_incentive(t) = stat.se(2);
%         [beta,~,stat] = glmfit([x2,x3],y,'normal');
%         beta_cue_force(t) = beta(2);
%         se_cue_force(t) = stat.se(2);
    end


% response to effort event
    % define
    beta_effort = nan(size(mu_fir2));
    se_effort = nan(size(mu_fir2));
    beta_effort_incentive = nan(size(mu_fir2));
    se_effort_incentive = nan(size(mu_fir2));
    beta_effort_force = nan(size(mu_fir2));
    se_effort_force = nan(size(mu_fir2));
    rho_effort = nan(size(mu_fir2));
    deltaBIC_effort = nan(size(mu_fir2));
    % regressors
    x = nanzscore(level);
    x2 = nanzscore(force);
    % orthogonalization
%     [~,~,stat] = glmfit(x2,x,'normal');
%     x = stat.resid*0;
    % time loop
    nt = numel(mu_fir2);
    for t = 1:nt
        x3 = fir2_rrphase(:,t);
        wsize = 60;
        window = [t-wsize/2:t+wsize/2]; 
        window = window(window>0);
        window = window(window<nt);
%         y = fir2(:,t);
        y = nanmean(fir2(:,window),2);
        
        % muti-linear regression of response
        [beta,~,stat] = glmfit([x,x2,x3],y,'normal');
        beta_effort(t) = beta(1);
        se_effort(t) = stat.se(1);
%         beta_effort_incentive(t) = beta(2);
%         se_effort_incentive(t) = stat.se(2);
%         beta_effort_force(t) = beta(3);
%         se_effort_force(t) = stat.se(3);
%         rho_effort(t) = stat.coeffcorr(2,3);
        
        % mutiple colinear regression of response
        [stat] = fitglm([x,x3],y,'linear');
        beta_effort_incentive(t) = stat.Coefficients.Estimate(2);
        se_effort_incentive(t) = stat.Coefficients.SE(2);
        bic_incentive = stat.ModelCriterion.BIC;
        [stat] = fitglm([x2,x3],y,'linear');
        beta_effort_force(t) = stat.Coefficients.Estimate(2);
        se_effort_force(t) = stat.Coefficients.SE(2);
        bic_force = stat.ModelCriterion.BIC;
        deltaBIC_effort(t) = bic_incentive - bic_force;

        % muti-linear regression of response variability
%         y = (fir2(:,t) - beta_effort(t));
%         [beta,~,stat] = glmfit([x,x3],y,'normal');
%         beta_effort_incentive(t) = beta(2);
%         se_effort_incentive(t) = stat.se(2);
%         [beta,~,stat] = glmfit([x2,x3],y,'normal');
%         beta_effort_force(t) = beta(2);
%         se_effort_force(t) = stat.se(2);
    end

%%% quality check 
    figure; hold on;
    % incentive effect
%     [h,hp] = boundedline( mu_fir_time , rho_cue , 0.*se_cue , 'alpha','transparency',0.5); 
    [h,hp] = boundedline( mu_fir_time , beta_cue , se_cue , 'alpha','transparency',0.5); 
    set(h,'Color','k','LineWidth',2);set(hp,'FaceColor','k');
    [h,hp] = boundedline( mu_fir_time , beta_cue_force , se_cue_force , 'alpha','transparency',0.5); 
    set(h,'Color','b','LineWidth',2);set(hp,'FaceColor','b');
    [h,hp] = boundedline( mu_fir_time , beta_cue_incentive , se_cue_incentive , 'alpha','transparency',0.5); 
    set(h,'Color','r','LineWidth',2);set(hp,'FaceColor','r');
    h.LineStyle = '-'; 
%     plot(mu_fir_time,deltaBIC_cue,'k--');
    
    figure; hold on;
    % force effect
%     [h,hp] = boundedline( mu_fir2_time , rho_effort , 0.*se_effort , 'alpha','transparency',0.5); 
    [h,hp] = boundedline( mu_fir2_time , beta_effort , se_effort , 'alpha','transparency',0.5); 
    set(h,'Color','k','LineWidth',2);set(hp,'FaceColor','k');
    [h,hp] = boundedline( mu_fir2_time , beta_effort_incentive , se_effort_incentive , 'alpha','transparency',0.5); 
    set(h,'Color','r','LineWidth',2);set(hp,'FaceColor','r');
    [h,hp] = boundedline( mu_fir2_time , beta_effort_force , se_effort_force , 'alpha','transparency',0.5); 
    set(h,'Color','b','LineWidth',2);set(hp,'FaceColor','b');
    h.LineStyle = '-'; 
%     plot(mu_fir2_time,deltaBIC_effort,'k--');

    
    
%%% 2. principal time-component scores
% response to cue event
    [coeff,score,~,~,explained] = pca(fir,'Centered',0,'NumComponents',1);
    component = score(:,1)*coeff(:,1)';
    % regressors
    x = nanzscore(level);
    x2 = nanzscore(force);
    % orthogonalization
%     [~,~,stat] = glmfit(x2,x,'normal');
%     x = stat.resid;
    x3 = nanmean(fir_rrphase,2);
    y = score(:,1);
    % glm
    [beta,~,stat] = glmfit([x,x2,x3],y,'normal');
    % extract
    beta2_cue_incentive = beta(2);
    beta2_cue_force = beta(3);
    p2_cue_incentive = stat.p(2);
    p2_cue_force = stat.p(3); 
    resid_cue =  stat.resid;
    %
    
    % quality check
%     figure; hold on;
%     ncomponent = 3;
%     for i = 1:ncomponent
%         plot(mu_fir_time,coeff(:,i),'LineWidth',2*ncomponent/i);
%     end

% response to effort event
    [coeff,score,~,~,explained] = pca(fir2,'Centered',0,'NumComponents',1);
    component2 = score(:,1)*coeff(:,1)';
    % regressors
    x = nanzscore(level);
    x2 = nanzscore(force);
    % orthogonalization
%     [~,~,stat] = glmfit(x2,x,'normal');
%     x = stat.resid;
    x3 = nanmean(fir2_rrphase,2);
    y = score(:,1);
    % glm
    [beta,~,stat] = glmfit([x,x2,x3],y,'normal');
    % extract
    beta2_effort_incentive = beta(2);
    beta2_effort_force = beta(3);
    p2_effort_incentive = stat.p(2);
    p2_effort_force = stat.p(3); 
    resid_effort =  stat.resid;
   % quality check
%     figure; hold on;
%     ncomponent = 3;
%     for i = 1:ncomponent
%         plot(mu_fir2_time,coeff(:,i),'LineWidth',2*ncomponent/i);
%     end


% residual correlations
[rho,p] = corr(resid_cue,resid_effort,'row','pairwise');

% quality check 
%     figure; hold on;
%     [h,hp] = boundedline( mu_fir_time , nanmean(component) , sem(component,1) , 'alpha','transparency',0.5); 
%     set(h,'Color','r','LineWidth',2);set(hp,'FaceColor','r');
%     h.LineStyle = '-'; 
%     [h,hp] = boundedline( mu_fir2_time , nanmean(component2) , sem(component2,1) , 'alpha','transparency',0.5); 
%     set(h,'Color','b','LineWidth',2);set(hp,'FaceColor','b');
%     h.LineStyle = '-'; 
%     % condition by incentive
%         nbin = 6;
%         incentive_fir = nan(nbin,numel(mu_fir));
%         for t = 1:numel(mu_fir)
%     %         incentive_fir(:,t) = tools.tapply(fir(:,t),{level},@nanmean,{'continuous'},nbin)';
%             incentive_fir(:,t) = tools.tapply(component(:,t),{level},@nanmean,{'continuous'},nbin)';
%         end
%         figure; hold on;
%         for i = 1:6
%             plot(mu_fir_time,incentive_fir(i,:),'LineWidth',1/1*i,'Color','r');
%         end
%     % condition by force
%         nbin = 3;
%         force_fir = nan(nbin,numel(mu_fir2));
%         for t = 1:numel(mu_fir2)
%     %         force_fir(:,t) = tools.tapply(fir2(:,t),{force},@nanmean,{'continuous'},nbin)';
%             force_fir(:,t) = tools.tapply(component2(:,t),{force},@nanmean,{'continuous'},nbin)';
%         end
%         figure; hold on;
%         for i = 1:nbin
%             plot(mu_fir2_time,force_fir(i,:),'LineWidth',i,'Color','b');
%         end  

    
    
%%% 3. regression of convoluted response


    
    
    
%% 5/ extract statistics

    mu_bpm = nanmean(hr4);
    sigma = nanvar(hr4);
    var_bpm = sigma/mu_bpm;
    
    stat = struct;
    stat.mu_bpm = mu_bpm;
    stat.var_bpm = var_bpm;
    
    % 1.
    [~,imax] = max(beta_cue);
    stat.ox_cue_incentive1 = beta_cue_incentive(imax);
    stat.ox_cue_incentive2 = sum(beta_cue_incentive);
    stat.ox_cue_incentive3 = sum(beta_cue_incentive.*abs(beta_cue))/sum(abs(beta_cue));
    stat.ox_cue_force1 = beta_cue_force(imax);
    stat.ox_cue_force2 = sum(beta_cue_force);
    stat.ox_cue_force3 = sum(beta_cue_force.*abs(beta_cue))/sum(abs(beta_cue));
    [~,imax] = max(beta_effort);
    stat.ox_effort_incentive1 = beta_effort_incentive(imax);
    stat.ox_effort_incentive2 = sum(beta_effort_incentive);
    stat.ox_effort_incentive3 = sum(beta_effort_incentive.*abs(beta_effort))/sum(abs(beta_effort));
    stat.ox_effort_force1 = beta_effort_force(imax);
    stat.ox_effort_force2 = sum(beta_effort_force);
    stat.ox_effort_force3 = sum(beta_effort_force.*abs(beta_effort))/sum(abs(beta_effort));

    % 2.
    stat.ox_cue_incentive4 = beta2_cue_incentive;
    stat.ox_cue_incentive5 = p2_cue_incentive;
    stat.ox_cue_force4 = beta2_cue_force;
    stat.ox_cue_force5 = p2_cue_force;
    stat.ox_effort_incentive4 = beta2_effort_incentive;
    stat.ox_effort_incentive5 = p2_effort_incentive;
    stat.ox_effort_force4 = beta2_effort_force;
    stat.ox_effort_force5 = p2_effort_force;   
    
    stat.ox_cue_effort_rho = rho;   

    
    
    model = struct;
    model.fir_cue = mu_fir;
    model.time_cue = mu_fir_time;
    model.beta_cue = beta_cue;
    model.beta_cue_incentive = beta_cue_incentive;
    model.beta_cue_force = beta_cue_force;
    model.deltaBIC_cue = deltaBIC_cue;
    model.component_cue = component;

    model.fir_effort = mu_fir2;
    model.time_effort = mu_fir2_time;
    model.beta_effort = beta_effort;
    model.beta_effort_incentive = beta_effort_incentive;
    model.beta_effort_force = beta_effort_force;
    model.deltaBIC_effort = deltaBIC_effort;
    model.component_effort = component2;




end
    
