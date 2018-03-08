function [a_data,a_epochs] = BP_Artifacts_Visual(data,type,epochs,eyeball,BPcfg)
% BIOPAC data preprocessing toolbox - Visual artifact detection function.
% This function flags the Biopac data as missing if they are visually 
% inspected and found to be artifactual.
% It flags the epochs containing visually detected artifacts as missing and
% additionally it can set the samples of the continuous dataset as NaN. See
% the configuration script for the default options per data type.
% Written by Roeland Heerema (roelandheerema@hotmail.com) in January 2018
% 
% INPUT
%   data: a variable of type double that contains the n datapoints of 
%           one channel. 
%   type: the type of data you're filtering. Enter either of the following strings:
%           'EMG':  electromyography (musculature)
%           'PPG':  pulse oxymetry (heart rate)
%           'EDA':  electrodermal (skin conductance)
%   epochs: an m×2 variable of type double that contains sample numbers of
%           the onsets (first column) and offsets (second column) of each
%           of the m epochs (rows). In case you miss or reject a given
%           trial, enter [NaN NaN] for that trial.
%   eyeball: a k×2 variable of type double that contains sample numbers of
%           the onsets (first column) and offsets (second column) of k
%           periods of visually detected artifactual data
%   BPcfg: the configuration structure that is produced by running
%           BP_Configuration.m. Be sure to enter the correct settings there.
%
% OUTPUT
%   a_data: an 1×n variable of type double with artifacts marked as NaNs.

%% Transpose data if necessary
    %This way there is no confusion: 1 row (channel) × n samples for the
    %continuous dataset.
    if size(data,1)>size(data,2)
        data = data';                               
    end
    
%% How do you want to handle the artifacts?
% Option 1: set the entire epoch as missing (recommended because presumably
%   the effects you're looking for are short-lasting and might not be
%   detectable even if you set a short interval of samples as missing).
% Option 2: set samples of visually detected artifacts as missing (not 
%   recommended because the sudden change from signal to NaN may cause 
%   strange edging effects when you filter.
flagepoch = 0; flagsamples = 0;
switch type
    case 'EDA'
        if BPcfg.artifacts.setepochsmissing.EDA; flagepoch = 1; end
        if BPcfg.artifacts.setsamplesmissing.EDA; flagsamples = 1; end
    case 'PPG'
        if BPcfg.artifacts.setepochsmissing.PPG; flagepoch = 1; end
        if BPcfg.artifacts.setsamplesmissing.PPG; flagsamples = 1; end        
    case 'EMG'
        if BPcfg.artifacts.setepochsmissing.EMG; flagepoch = 1; end
        if BPcfg.artifacts.setsamplesmissing.EMG; flagsamples = 1; end
end
%% Visually detected artifacts
    %Sets sample intervals that are visually spotted as being artifactual
    %to NaNs. Importantly, also set these epochs as NaN.
    if ~isempty(eyeball)
        for i = 1:size(eyeball,1)
            %Quick anticipated fix
                if eyeball(i,1) == 0 
                    eyeball(i,1) = 1;     %Obviously an index can't be zero, but we know you meant time zero ;)
                end
            %Set artifact samples as NaN
                if flagsamples
                    data(eyeball(i,1):eyeball(i,2)) = NaN;
                end
            %Set artifact epochs as NaN
                if flagepoch
                    nanepochs = [epochs(:,1)-eyeball(i,1) epochs(:,2)-eyeball(i,2)];
                    nanepochs = logical((nanepochs(:,1)>=0).*(nanepochs(:,2)<=0));
                    epochs(nanepochs,:) = NaN;
                end
        end
    end
    a_epochs = epochs;    
    a_data = data;
    
disp('Completed marking artifacts in the data.')
end