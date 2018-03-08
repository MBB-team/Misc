function [e_data] = BP_Epoch(data,epochs,BPcfg)
% BIOPAC data preprocessing toolbox - epoching function.
% This function cuts up the Biopac data and produces a cell containing
% every epoch.
% 
% INPUT
%   data: an 1×n variable of type double that contains the n datapoints of 
%           one channel. It is recommended to first filter the raw data 
%           before entering it in this function.
%   epochs: an m×2 variable of type double that contains sample numbers of
%           the onsets (first column) and offsets (second column) of each
%           of the m epochs (rows). In case you miss or reject a given
%           trial, enter [NaN NaN] for that trial.
%   BPcfg: the configuration structure that is produced by running
%           BP_Configuration.m. Be sure to enter the correct settings there.
%
% OUTPUT
%   e_data: a cell containing all of the epochs. For missing data, the cell
%           rows corresponding to those trials will be empty.
% Written by Roeland Heerema (roelandheerema@hotmail.com) in January 2018


%% Epoching
e_data = cell(size(epochs,1),1);
for trial = 1:size(epochs,1)
    if isnan(epochs(trial,1))
        e_data{trial} = [];
    else
        e_data{trial} = data(epochs(trial,1):epochs(trial,2));
    end
end
disp('The epoched data is now placed in a cell containing all trials.')

%% Visualize the epochs (Note: slow!)
%(Visual inspection may be useful to see if anything is wrong.)
if BPcfg.epochs.Visualize
    
    plotdata = []; borders = []; count = 1;
    for trial = 1:size(epochs,1)
        if ~isnan(epochs(trial,1))        
            borders = [borders;
                count count+epochs(trial,2)-epochs(trial,1)];
                count = count+epochs(trial,2)-epochs(trial,1)+1;
            plotdata = [plotdata e_data{trial}];
        end
    end
    plotonsets = zeros(1,length(plotdata)); plotonsets(borders(:,1))=1.2*max(plotdata);
    
    close
    figure; hold on;
    plot((1:length(plotdata))./BPcfg.signal.FS,plotdata)
    plot((1:length(plotdata))./BPcfg.signal.FS,plotonsets)
    title('Epoched Signal')
    legend({'Trial data','Onsets'})
    ylabel('Signal')
    xlabel('Time [s]')
    
end