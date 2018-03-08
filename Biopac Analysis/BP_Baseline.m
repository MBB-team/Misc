function [BL_data] = BP_Baseline(data,type,BPcfg)
% BIOPAC data preprocessing toolbox - baseline correction.
% This function "corrects" the preprocessed Biopac data, i.e. it prepares
% the data for further analyses by baseline-correcting it. This requires
% you to have set a baseline in the configuration script; if you haven't,
% the function will terminate. The baseline is best set to be a short
% period of time right before the onset of your effect. The average value
% of this period is subtracted from the signal in the window you want to
% retain for later analyses.
% 
% INPUT
%   data: an n×1 cell variable of which every cell contains the data of one
%           of the n trials. Please first preprocess the raw data before 
%           entering it in this function. Only epoched data can be entered.
%   epochs: an m×2 variable of type double that contains sample numbers of
%           the onsets (first column) and offsets (second column) of each
%           of the m epochs (rows). In case you miss or reject a given
%           trial, enter [NaN NaN] for that trial. Missing trials will also
%           be marked as "NaN" in the quantified output.
%   type:  the data type you want to baseline-correct; this is a string
%           that can have either of the following values: "EDA" (for skin
%           conductance), "PPG" (for oxymetry), or "EMG" (for musculature).
%   BPcfg: the configuration structure that is produced by running
%           BP_Configuration.m. Be sure to enter the correct settings there.
%
% OUTPUT
%   Q_data: quantified data, i.e. a cell of the same format as "data", with
%           every trial's data now baseline-corrected.
% Written by Roeland Heerema (roelandheerema@hotmail.com) in January 2018

switch type
    case 'EMG'; window = BPcfg.Window.EMG;
    case 'EDA'; window = BPcfg.Window.EDA;
    case 'PPG'; window = BPcfg.Window.PPG;
end

if ~isempty(window) && prod(size(window) == [2 2])
        
    %Settings
        FS = BPcfg.signal.FS;
        BL_data = cell(length(data),1);     % Output
        baseline = window(2,:);
        if baseline(1) == 0; baseline(1) = 1/FS; end
    %Loop through trials
        for trial = 1:length(data)
            signal = data{trial};
            if ~isempty(signal)
                BL_data{trial} = signal - nanmean(signal(baseline(1)*FS:baseline(2)*FS));                            
            else
                BL_data{trial} = [];
            end
        end
        disp('Baseline-correction done.')
else
    error('The window-of-interest and/or baseline have not been set. No baseline-correction executed.')        
end