function [epochs] = BP_VisualInspection(data,epochs,BPcfg)
% BIOPAC data preprocessing toolbox - visual inspection function.
% This function shows you the epochs you identified (with their trial
% numbers) and allows you to visually see if you want to keep them. If you
% want to reject them, simply type in their numbers and the epochs will be
% flagged as missing data.
% 
% INPUT
%   data: a 1×n variable of type double that contains the n datapoints of 
%           one channel.
%   epochs: an m×2 variable of type double that contains sample numbers of
%           the onsets (first column) and offsets (second column) of each
%           of the m epochs (rows). In case you miss or reject a given
%           trial, enter [NaN NaN] for that trial.
%   BPcfg: the configuration structure that is produced by running
%           BP_Configuration.m. Be sure to enter the correct settings there.
%
% OUTPUT
%   epochs: the same variable, but with trial timings that you visually     
%           find to be artifactual set as [NaN NaN].
% Written by Roeland Heerema (roelandheerema@hotmail.com) in January 2018


time = (1:length(data))./BPcfg.signal.FS;
onsets = zeros(1,length(data)); 
    onsets(epochs(~isnan(epochs(:,1)),1)) = 1.2*nanmax(data);
offsets = zeros(1,length(data));
    offsets(epochs(~isnan(epochs(:,1)),2)) = 1.2.*nanmax(data);

figure;hold on
%Display trial numbers
    plot(epochs(:,1)./BPcfg.signal.FS,1.25*nanmax(data)*ones(length(epochs),1),'w*')
    ln = findobj('type','line');
    set(ln,'marker','.','markers',14,'markerfa','w') 
    for i=1:length(epochs)
        text(epochs(i,1)./BPcfg.signal.FS,1.25*nanmax(data),num2str(i))
    end
%Display signal and triggers    
    plot(time,data)
    plot(time,offsets,'r')
    plot(time,onsets,'g')
    legend({'','signal','offsets','onsets'})
    xlabel('time (seconds)'); ylabel('Amplitude')
%Reject bad trials
    badtrials = input('Enter the numbers of bad trials, or leave empty if none: ');
    for j = 1:length(badtrials)
        epochs(badtrials(j),:) = NaN(1,2);
    end
    close
end