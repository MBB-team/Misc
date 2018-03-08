function [CP_data] = BP_CropOrPad(data,type,BPcfg)
% BIOPAC data preprocessing toolbox - cropping and padding.
% This function cuts out your window-of-interest specified in the
% configuration script. This is useful when you have trials of unequal
% length. If the trial duration is shorter than the specified time window,
% the data is padded with NaNs.
% Note that this function only takes epoched data.
% 
% INPUT
%   data: an n×1 cell variable of which every cell contains the data of one
%           of the n trials. Only epoched data can be entered.
%   type:  the data type of which you want a specific window; i.e. a string
%           that can have either of the following values: "EDA" (for skin
%           conductance), "PPG" (for oxymetry), or "EMG" (for musculature).
%   BPcfg: the configuration structure that is produced by running
%           BP_Configuration.m. Be sure to enter the correct settings there.
%
% OUTPUT
%   CP_data: cropped or padded data, i.e. a cell of the same format as 
%           "data", with every trial's data now of the same dimensions.
% Written by Roeland Heerema (roelandheerema@hotmail.com) in January 2018

switch type
    case 'EMG'; window = BPcfg.Window.EMG;
    case 'EDA'; window = BPcfg.Window.EDA;
    case 'PPG'; window = BPcfg.Window.PPG;
    otherwise
        window = input('Specify window-of-interest and baseline in seconds from trial onset as [windowOn windowOFF; baselineON baselineOFF]: ');            
end

if ~isempty(window) && prod(size(window) == [2 2])
    WOI = BPcfg.signal.FS * window(1,:);  %Window-of-interest
    if WOI(2) == Inf
        error('No finite window end defined.')
    end
    CP_data = cell(size(data));
    for trial = 1:size(data,1)
        cutdata = data{trial};        
        %Step 1: cut out data before window start
            cutdata = cutdata(WOI(1):end);
        %Step 2: cut out data following window end, or pad
            if length(cutdata) < WOI(2)-WOI(1)  %Pad
                cutdata = [cutdata NaN(1,WOI(2)-WOI(1)-length(cutdata))];
            elseif length(cutdata) > WOI(2)-WOI(1); %Cut out
                cutdata = cutdata(1:WOI(2)-WOI(1));
            end    
        CP_data{trial} = cutdata;
    end
    disp('Data cropped/padded.')
else
    error('The window-of-interest is not set.')
end