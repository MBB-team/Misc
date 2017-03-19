%% demo_outlier_detection
clc;clear all;close all;


% simulate data
rt = exp(randn(100,1));

% transform 
log_rt = log(rt);

% display
figure; hold on;
plot(rt,'k');
plot(log_rt,'b');


% outlier detection
alpha=0.05; 
nanReplace=1;
[rt2,idx,outliers] = deleteoutliers(rt,alpha,nanReplace);
plot(rt2,'r');


legend('raw rt','log-rt','rt without outliers');