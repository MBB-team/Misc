function [s_data] = BP_Standardize(data,BPcfg)
% BIOPAC data preprocessing toolbox - standardization.
% This function standardizes continuous physiological signals in one of two 
% ways:
%   1. Per block, if you specified them; or
%   2. Across all trials.
% Option (1) is useful if you suspect there are great differences in the
% signal-to-noise ratio between blocks, and if the experimental conditions
% are comparable between blocks. See the configuration script for how to
% define the blocks.
% The data you enter has to be epoched and it is assumed that your entire
% epoch has to be included in the standardization. Trials of different
% durations are allowed.
% 
% INPUT
%   data:  a n×1 cell variable of which every cell contains the data of
%           one trial; i.e. when data has been epoched. In this case, data
%           from rejected trials are discarded in the standardization
%           procedure.
%   BPcfg: the configuration structure that is produced by running
%           BP_Configuration.m. Be sure to enter the correct settings there.
%
% OUTPUT
%   s_data: the standardized dataset (format n×1 trials; like "data" input)
% Written by Roeland Heerema (roelandheerema@hotmail.com) in January 2018

%Settings
    Blocks = BPcfg.signal.Blocks;
        if isempty(Blocks)
            Blocks = 1:length(epochs);
        end
        s_data = cell(size(data));  %output
%Loop through blocks
    for block = 1:size(Blocks,1)
        %Collect trial signal only
            trial_signal = []; borders = []; count = 1;
                for trial = Blocks(block,:)
                    if ~isempty(data{trial})       
                        trial_signal = [trial_signal data{trial}];
                        borders(trial,:) = [count count+length(data{trial})-1];
                        count = count+length(data{trial});          
                    else                    %Missing trial
                        borders(trial,:) = NaN(1,2);
                    end
                end
        %Standardize signal from trials
            if sum(isnan(trial_signal))==0  %No missing data
                z_trial_signal = zscore(trial_signal);
            else %Missing data
                z_trial_signal = z_missing(trial_signal);
            end            
        %Put the z-scored data back into the 1D signal
            for trial = Blocks(block,:)
                if ~isempty(data{trial})
                    s_data{trial} = z_trial_signal(borders(trial,1):borders(trial,2));     
                end
            end
    end    
    disp('Data has been standardized.')
end

%% Auxiliary function: standardize a signal with missing samples
function [st_data] = z_missing(data)
    z_data = zscore(data(~isnan(data)));
    count = 1;
    for samples = 1:length(data)
        if ~isnan(data(samples))
            data(samples) = z_data(count);
            count = count+1;
        end
    end
    st_data = data;
end