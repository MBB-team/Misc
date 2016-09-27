function [stat,model] = process_oximeter(oxdata,data,training)


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


%% 1/ Filter PPG (photoplethysmograph raw signal)

% remove outlier
    % method 1
    windowSize = (1)*f; % filter onto an average of 20bpm (~respiratory rate)
    ppg2 = smooth(ppg,windowSize);
    ppg3 = ppg-ppg2;

    mu = mean(ppg);
    sd = std(ppg);
    criterion = 2*sd;
    outlier = (abs(ppg3)>= criterion);
    ppg4 = ppg;
    ppg4(outlier) = NaN;
    
    ppg4 = interp1(find(outlier==0),ppg4(outlier==0),[1:numel(ppg4)]','cubic');

    % method 2
%     ppg4 = medfilt1(ppg,windowSize);

    % method 3 
%     env = abs(hilbert(ppg,windowSize));


% bandpass filter
    order = 6;
    maxVal = 240; maxVal = maxVal/60;
    minVal = 30;  minVal = minVal/60;
    freq = [minVal maxVal]/f;
    [b,a] = butter(order,freq,'bandpass');
    raw = ppg4;
    ppg4 = filter(b,a,raw);
    ppg4 = filtfilt(b,a,raw);

% lowpass filter
    maxVal = 30; maxVal = maxVal/60;
    freq =  [maxVal]/f;
    [b,a] = butter(order,freq,'low');
    rr = filtfilt(b,a,raw);

% spectral analysis
    sa = hilbert(rr);
    rr_phase = unwrap(angle(sa));

% % quality check 
%     figure; hold on;
%     ind = [1:10000]+0;
% %     plot(time(ind),ppg(ind));
% 
% %     hold on;
% %     plot(time(ind),ppg2(ind));
% %     scatter(time(ind),outlier(ind)*100);
%     plot(time(ind),raw(ind));
%     plot(time(ind),ppg4(ind));
%     plot(time(ind),rr_phase(ind)*10);

    


%% 2/ Compute HR (heart rate) & PPI (pulse-to-pulse interval) signal

% local maxima detection
    % 1order deriv
        d1_ppg = diff(ppg4,1);
        d1_ppg = smooth(d1_ppg,5);
    %     a= 1; b = [-2 -1  1 2];
    %     d1_ppg = filter(b,a,ppg4);
        int_ppg = (abs(d1_ppg));

    % 2order deriv
        d2_ppg = diff(ppg4,2);
        d2_ppg = smooth(d2_ppg,5);
    %     a= 1; b = [-3 -2 -1  1 2 3];
    %     d2_ppg = filtfilt(b,a,d1_ppg);

    % pulse detection
        % pulse criterions
        pulseDist = 0.2*f; % sec
        pulseWidth = [0.1 2]*f;
    
        [max2d,ind_max2d] = findpeaks(ppg4,'MinPeakDistance',pulseDist,'MinPeakWidth',pulseWidth(1),'MaxPeakWidth',pulseWidth(2));
%         [max2d,ind_max2d] = findpeaks(ppg4,'MinPeakDistance',pulseDist);

        ind_pos1d = find( abs(d1_ppg) < 0.10*max(d1_ppg) );
        % ind_pulse = ind_max2d;
        ind_pulse = intersect(ind_max2d,ind_pos1d);

        pulse = zeros(size(ppg4));
        pulse(ind_pulse)=1;

% ppi computation
    ppi = nan(size(ppg4));
    ppi(ind_pulse(2:end))= (time(ind_pulse(2:end)) - time(ind_pulse(1:end-1)));
    hr = 1./ppi*60;

% ppi filtering
    maxVal = 240;
    minVal = 30;
    hr( hr<minVal | hr>maxVal ) = NaN;
    
    windowSize = 5; % filter onto an average of 20bpm (~respiratory rate)
    hr2 = nan(size(hr));
    hr2(~isnan(hr)) = smooth(hr(~isnan(hr)),windowSize);
    hr3 = hr-hr2;
    
    mu = nanmean(hr);
    sd = nanstd(hr);
    criterion = 2*sd;
    outlier = (abs(hr3)>= criterion);
    hr4 = hr;
    hr4(outlier) = NaN;
    
    hr4 = interp1(find(outlier==0),hr4(outlier==0),[1:numel(hr4)]','cubic');
    first = find(pulse==1,1,'first');
    hr4(1:first) = NaN;
    
% % quality check 
%     figure; hold on;
%     ind = [1:10000]+0;
%     plot(time(ind),ppg4(ind));
%     hold on;
%     plot(time(ind),d1_ppg(ind)*10);
%     plot(time(ind),d2_ppg(ind)*10);
%     scatter(time(ind),pulse(ind)*10);
%     findpeaks(ppg4(ind),time(ind));
%     findpeaks(ppg4(ind),time(ind),'MinPeakDistance',pulseDist/f,'MinPeakWidth',pulseWidth(1)/f,'MaxPeakWidth',pulseWidth(2)/f);
%     scatter(time(ind),beat(ind)*10);
%     scatter(time(ind),hr(ind));
%     plot(time(ind),hr4(ind));
%     plot(time(ind),rr_phase(ind)*10);


%% 3/ Compute FIR model (Finite Impulse Respone functions) 

timeLimIncentive = [-0.5 , +4];
timeLimEffort = [-0.5 , +6];
mu = nanmean(hr4);

% response to incentive
    % event definition
    windowLim = round([timeLimIncentive(1):(1/f):timeLimIncentive(2)]*f);
    flag = (incentive~=0);
    flag2 = (effort~=0);
    trialNumber = cumsum(flag);
    fir = nan(max(trialNumber),numel(windowLim));
    fir_time = nan(max(trialNumber),numel(windowLim));
    fir_rrphase = nan(max(trialNumber),numel(windowLim));
%     fir_force = nan(max(trialNumber),numel(windowLim));

    % time bin loop
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
    %             fir(it,:) = buffer(onset+windowLim);
                % with baseline removal
    %             baseline = nanmean(buffer(onset+windowLim(1):onset));
    %               baseline = buffer(onset);
%                   baseline = nanmean(buffer(onset-15:onset+15));
                  baseline = mu;

            fir(it,:) = buffer(onset+windowLim) - baseline;        
            fir_time(it,:) = buffer_time(onset+windowLim) - buffer_time(onset);
            fir_rrphase(it,:) = buffer_phase(onset+windowLim);        
%             fir_force(it,:) = buffer_force(onset+windowLim);        
        end

    
% response to effort
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
    %             fir(it,:) = buffer(onset+windowLim);
                % with baseline removal
    %             baseline = nanmean(buffer(onset+windowLim(1):onset));
    %               baseline = buffer(onset);
%                   baseline = nanmean(buffer(onset-15:onset+15));
                  baseline = mu;

            fir2(it,:) = buffer(onset+windowLim) - baseline;        
            fir2_time(it,:) = buffer_time(onset+windowLim) - buffer_time(onset);
            fir2_rrphase(it,:) = buffer_phase(onset+windowLim);        

        end
        
% average response
    % incentive
    mu_fir = nanmean(fir,1);
    sd_fir = sem(fir,1);
    mu_fir_time = nanmean(fir_time,1);

    % effort
    mu_fir2 = nanmean(fir2,1);
    sd_fir2 = sem(fir2,1);
    mu_fir2_time = nanmean(fir2_time,1);
    
    
% fit incentive
    incentive_beta = nan(size(mu_fir));
    incentive_se = nan(size(mu_fir));
    x = nanzscore(level);
    x2 = nanzscore(force);
    [~,~,stat] = glmfit(x2,x,'normal');
    x = stat.resid;
    
    for t = 1:numel(mu_fir)
%         x4 = fir_force(:,t).*x2;
        x3 = fir_rrphase(:,t);
        y = fir(:,t);
        [beta,~,stat] = glmfit([x,x2,x3],y,'normal');
        incentive_beta(t) = beta(2);
        incentive_se(t) = stat.se(2);
        mu_fir(t) = beta(1);
        sd_fir(t) = stat.se(1);
    end

% fit force
    force_beta = nan(size(mu_fir2));
    force_se = nan(size(mu_fir2));
    x = nanzscore(force);
    x3 = nanzscore(level);

    for t = 1:numel(mu_fir2)
        x2 = fir2_rrphase(:,t);
        y = fir2(:,t);
        [beta,~,stat] = glmfit([x,x2,x3],y,'normal');
        force_beta(t) = beta(2);
        force_se(t) = stat.se(2);
        mu_fir2(t) = beta(1);
        sd_fir2(t) = stat.se(1);
    end
    
    
% pca

    % incentive fir
    [coeff,score,~,~,explained] = pca(fir,'Centered',0);
    component = score(:,1)*coeff(:,1)';
    x = nanzscore(level);
    x2 = nanzscore(force);
%     [~,~,stat] = glmfit(x,x2,'normal');
%     x2 = stat.resid;
    x3 = nanmean(fir_rrphase,2);
    y = score(:,1);
    [beta,~,stat] = glmfit([x,x2,x3],y,'normal');
    
    k_incentive = beta(2);
    k_respiration = beta(4);
    R2_incentive = explained(1);
    
%         % quality check
%         figure; hold on;
%         ncomponent = 3;
%         for i = 1:ncomponent
%             plot(mu_fir_time,coeff(:,i),'LineWidth',ncomponent/i);
%         end

    % force fir
    [coeff2,score2,~,~,explained2] = pca(fir2,'Centered',0);
    component2 = score2(:,1)*coeff2(:,1)';
    x = nanzscore(force);
    x2 = nanzscore(level);
    [~,~,stat] = glmfit(x,x2,'normal');
    x2 = stat.resid;
    x3 = nanmean(fir2_rrphase,2);
    y = score2(:,1);
    [beta2,~,stat2] = glmfit([x,x2,x3],y,'normal');
    
    k_effort = beta2(2);
    R2_effort = explained2(1);
    
%         % quality check
%         figure; hold on;
%         ncomponent = 3;
%         for i = 1:ncomponent
%             plot(mu_fir2_time,coeff2(:,i),'LineWidth',ncomponent/i);
%         end
    
    
% quality check 
%     figure; hold on;
% %     plot(time(ind),hr4(ind));
% %     scatter(buffer_time,flag(ind)*100);
% 
% %     [h,hp] = boundedline( mu_fir_time , mu_fir , sd_fir , 'alpha','transparency',0.5); 
%     [h,hp] = boundedline( mu_fir_time , nanmean(component) , sem(component,1) , 'alpha','transparency',0.5); 
% 
%     set(h,'Color','r','LineWidth',2);set(hp,'FaceColor','r');
%     h.LineStyle = '-'; 
%     
% %     [h,hp] = boundedline( mu_fir2_time , mu_fir2 , sd_fir2 , 'alpha','transparency',0.5); 
%     [h,hp] = boundedline( mu_fir2_time , nanmean(component2) , sem(component2,1) , 'alpha','transparency',0.5); 
% 
%     set(h,'Color','b','LineWidth',2);set(hp,'FaceColor','b');
%     h.LineStyle = '-'; 
    

%% 4/ time dependant regressions

% orthogonalization
    y = nanzscore(level);
    x = force;
    [~,~,stat] = glmfit(x,y,'normal');
    level2 = stat.resid;

% average by incentive
%     incentive_fir = nan(6,numel(mu_fir));
%     for t = 1:numel(mu_fir)
%         incentive_fir(:,t) = tools.tapply(fir(:,t),{level},@nanmean)';
%     end
    
    nbin = 3;
    incentive_fir = nan(nbin,numel(mu_fir));
    for t = 1:numel(mu_fir)
        incentive_fir(:,t) = tools.tapply(fir(:,t),{level2},@nanmean,{'continuous'},nbin)';
%         incentive_fir(:,t) = tools.tapply(component(:,t),{level2},@nanmean,{'continuous'},nbin)';
    end

% average by force
    nbin = 3;
    force_fir = nan(nbin,numel(mu_fir2));
    for t = 1:numel(mu_fir2)
        force_fir(:,t) = tools.tapply(fir2(:,t),{force},@nanmean,{'continuous'},nbin)';
%         force_fir(:,t) = tools.tapply(component2(:,t),{force},@nanmean,{'continuous'},nbin)';
    end

% % quality check 
%     figure; hold on;
%     hold on;
%     for i = 1:6
%         plot(mu_fir_time,incentive_fir(i,:),'LineWidth',1/1*i,'Color','r');
%     end
%     for i = 1:nbin
%         plot(mu_fir_time,incentive_fir(i,:),'LineWidth',1/1*i,'Color','r');
%     end
%     for i = 1:nbin
%         plot(mu_fir2_time,force_fir(i,:),'LineWidth',i,'Color','b');
%     end  
    
    
% % fit incentive
%     incentive_beta = nan(size(mu_fir));
%     incentive_se = nan(size(mu_fir));
%     for t = 1:numel(mu_fir)
%         x = nanzscore(level);
%         y = fir(:,t);
%         [beta,~,stat] = glmfit(x,y,'normal');
%         incentive_beta(t) = beta(2);
%         incentive_se(t) = stat.se(2);
%     end
% 
% % fit force
%     force_beta = nan(size(mu_fir2));
%     force_se = nan(size(mu_fir2));
%     for t = 1:numel(mu_fir2)
%         x = nanzscore(force);
%         y = fir2(:,t);
%         [beta,~,stat] = glmfit(x,y,'normal');
%         force_beta(t) = beta(2);
%         force_se(t) = stat.se(2);
%     end
    
% % % quality check 
%     figure; hold on;
%     hold on;
%     
%     % incentive effect
%     [h,hp] = boundedline( mu_fir_time , incentive_beta , incentive_se , 'alpha','transparency',0.5); 
%     set(h,'Color','r','LineWidth',2);set(hp,'FaceColor','r');
%     h.LineStyle = '-'; 
%     
%     % force effect
%     [h,hp] = boundedline( mu_fir2_time , force_beta , force_se , 'alpha','transparency',0.5); 
%     set(h,'Color','b','LineWidth',2);set(hp,'FaceColor','b');
%     h.LineStyle = '-'; 
    
%% 5/ regression of convoluted FIR response

% % orthogonalization
%     x = nanzscore(level);
%     y = force;
%     [~,~,stat] = glmfit(x,y,'normal');
%     level = nanzscore(level);
%     force = stat.resid;
%     
% % incentive
%     boxcarTime = round(0.5*60);
%     flag = (incentive~=0);
%     trialNumber = cumsum(flag);
%     incentive_boxcar = zeros(size(flag));
%     boxcar = zeros(size(flag));
%     for i = 1:max(trialNumber)
%         ind = (ismember(trialNumber,i));
%         incentive_boxcar( ind ) = [ level(i)*ones(boxcarTime,1) ; zeros(sum(ind)-boxcarTime,1) ] ;
%         boxcar( ind )           = [ ones(boxcarTime,1) ; zeros(sum(ind)-boxcarTime,1) ] ;
%     end
%     
%     windowLim = round([timeLimIncentive(1):(1/f):timeLimIncentive(2)]*f);
%     onset = find(windowLim==0);
%     incentive_conv = conv(mu_fir(onset:end),incentive_boxcar);
%     incentive_conv = incentive_conv(1:numel(flag));
%     fir_conv = conv(mu_fir(onset:end),boxcar);
%     fir_conv = fir_conv(1:numel(flag));
%     
% % effort
%     boxcarTime = round(1*60);
%     flag = (effort~=0);
%     trialNumber = cumsum(flag);
%     force_boxcar = zeros(size(flag));
%     boxcar = zeros(size(flag));
%     for i = 1:max(trialNumber)
%         ind = (ismember(trialNumber,i));
%         force_boxcar( ind ) = [force(i)*ones(boxcarTime,1) ; zeros(sum(ind)-boxcarTime,1) ] ;
%         boxcar( ind )       = [ ones(boxcarTime,1) ; zeros(sum(ind)-boxcarTime,1) ] ;
%     end
%     
%     windowLim = round([timeLimEffort(1):(1/f):timeLimEffort(2)]*f);
%     onset = find(windowLim==0);
%     force_conv = conv(mu_fir2(onset:end),force_boxcar);
%     force_conv = force_conv(1:numel(flag));
%     fir2_conv = conv(mu_fir2(onset:end),boxcar);
%     fir2_conv = fir2_conv(1:numel(flag));
% 
% % fit
%     fir_conv = fir_conv./var(fir_conv);
%     fir2_conv = fir2_conv./var(fir2_conv);
%     x = [ fir_conv , fir2_conv , nanzscore(incentive_conv) , nanzscore(force_conv) ];
%     y = nanzscore(hr4);
%     [beta,~,stat] = glmfit(x,y,'normal');
%     k_incentive = beta(4);
%     k_effort = beta(5);
%     
%     y = (hr4);
%     [~,~,stat] = glmfit(x,y,'normal');
%     sigma = nanvar(stat.resid);
%     


    mu_bpm = nanmean(hr4);
    sigma = nanvar(hr4);
    var_bpm = sigma/mu_bpm;
    
    
% quality check 
%     figure; hold on;
% %     hold on;
%     ind = [1:70000]+0;
% %     hold on;
% %     plot(time(ind),incentive_boxcar(ind));
%     subplot(3,1,1);
%     plot(time(ind),incentive_boxcar(ind),'r');
%     plot(time(ind),incentive_conv(ind),'r--');
%     plot(time(ind),fir_conv(ind),'r');
% 
%     subplot(3,1,2);
%     plot(time(ind),force_boxcar(ind),'b');
%     plot(time(ind),force_conv(ind),'b--');
%     plot(time(ind),fir2_conv(ind),'b');
% 
%     subplot(3,1,3);
%     plot(time(ind),hr4(ind),'k');
    
%% 6/ save

    stat = struct;
    stat.mu_bpm = mu_bpm;
    stat.var_bpm = var_bpm;
    stat.ox_incentive = k_incentive;
    stat.ox_effort = k_effort;
    stat.ox_respiration = k_respiration;

    model = struct;
    model.fir_incentive = mu_fir;
    model.time_incentive = mu_fir_time;
    model.beta_incentive = incentive_beta;
    model.component_incentive = component;
    model.R2_incentive = R2_incentive;

    model.fir_effort = mu_fir2;
    model.time_effort = mu_fir2_time;
    model.beta_effort = force_beta;
    model.component_effort = component2;
    model.R2_effort = R2_effort;




end
    
