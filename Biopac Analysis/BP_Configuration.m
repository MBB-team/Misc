%% BP_Configuration
% -------------------------------------------------------------------------
% BIOPAC data preprocessing toolbox - configuration script.
% This is the configuration script containing all the settings and
% information required to analyze your Biopac data. You will only have to 
% enter a toolbox directory and the sampling rate yourself in order for the 
% preprocessing to run smoothly. For quantification/analysis of the data,
% you can enter divide the experiment up in blocks and specify a
% window-of-interest and baseline within your epochs.
% If you wish, you can also alter the 'Default Settings' section below to 
% adjust the preprocessing steps to your own wishes. Also, you can set here
% if you want to visualize the preprocessing steps.
% Note that this toolbox has been created for the following data types:
%   EDA: electrodermal activity (skin conductance)
%   PPG: photoplethysmogram (obtained from a pulse oximeter for heart rate)
%   EMG: electromyography (musculature, e.g. for facial expressions)
% Written by Roeland Heerema (roelandheerema@hotmail.com) in January 2018

%% Fill this in yourself

%Set a directory
    BPcfg.dir.SPM = 'C:\Users\roeland.heerema\Documents\MATLAB\spm12'; %Your SPM12 folder
%     We use an external toolbox called 'Fieldtrip', so SPM12
%     does not strictly need to be installed - you can leave this field 
%     empty and enter the preprocessing subfolder of fieldtrip directly (if 
%     you have it installed on your computer) under "dir.Fieldtrip" in the 
%     Default Settings section. If you don't have SPM or Fieldtrip
%     installed, get it from http://www.fieldtriptoolbox.org/download.

%Set sampling rate [Hz]       
    BPcfg.signal.FS = 1000; 
     
%Set windows and baselines [s] (only for quantification/analysis)
%     Here we are assuming you have epochs of variable lenghts and by
%     specifying your window-of-interest and your baseline, you can select
%     the samples within an epoch that you want to process (because it
%     contains your signal) and that you want to use as a baseline. If you
%     leave these variables empty, the whole epoch is considered signal
%     (without a baseline-correction). Note that not every data type 
%     requires a baseline. See per-datatype explanations below.
%     Format: [signal_onset signal_offset; baseline_onset baseline_offset].
%     (You can set "Inf" instead of a fixed number, if you want to denote
%     the end of every epoch without specifying a fixed duration).
%     Don't forget: enter values in seconds!
    BPcfg.Window.EDA = [5 16; 2 5];
    BPcfg.Window.EMG = [5 16; 0 0];          
    BPcfg.Window.PPG = [5 16; 0 5];
    
%Divide experiment into blocks (only for standardization)
%     m×n matrix of type double containing all your trial numbers; thereby
%     dividing your experiment in m blocks of n trials per block. Do this 
%     if you want to z-score the data per block (E.g., you may 
%     want to do this if an electrode was re-adjusted during a break 
%     between blocks.) If you rather want to standardize over the whole
%     experiment at once, enter all n trials as a 1×n matrix. 
%     Example: BPcfg.signal.Blocks = [1:15;16:30;31:45;46:60;61:75;76:90];
    BPcfg.signal.Blocks = [1:15;16:30;31:45;46:60;61:75;76:90];     

%% Default Settings

%Directories
    BPcfg.dir.Fieldtrip = [BPcfg.dir.SPM filesep 'external\fieldtrip']; %Fieldtrip directory
        addpath(genpath(BPcfg.dir.Fieldtrip));
%Filtering
    BPcfg.filter.Visualize = 0;                             %Visualize the power spectrum of the original and the filtered data (set to zero for faster analysis)
    BPcfg.filter.BandPass.EMG = [20 BPcfg.signal.FS/2-1];   %Bandpass frequencies in Hz for EMG
    BPcfg.filter.BandPass.EDA = [0.01 0.5];                 %Bandpass frequencies in Hz for EDA (skin conductance measures)
    BPcfg.filter.BandPass.PPG = [0.01 2];                   %Bandpass frequencies in Hz for PPG (heart rate measures)
    BPcfg.filter.LineNoise = 50;                            %Notch filter frequency (here set to European default of 50Hz)   
%Epoching
    BPcfg.epochs.Visualize = 0;                             %Visualize the epochs from the channel's signal, separated by their onsets (set to zero for faster analysis).        
%Artifacts
    %For visually detected artifacts: select if you want to set the samples and/or the entire epoch as missing
    BPcfg.artifacts.setepochsmissing.EDA = 1;               %Presumably, visually detected artifacts affect the entire epoch
    BPcfg.artifacts.setsamplesmissing.EDA = 1;              %Only cutting out a part of the signal will induce strange edging effects of the very-low-pass filter
    BPcfg.artifacts.setepochsmissing.PPG = 1;               %Presumably, visually detected artifacts affect the entire epoch
    BPcfg.artifacts.setsamplesmissing.PPG = 0;              %Only cutting out a part of the signal will induce strange edging effects of the very-low-pass filter
    BPcfg.artifacts.setepochsmissing.EMG = 1;               %Presumably, visually detected artifacts affect the entire epoch
    BPcfg.artifacts.setsamplesmissing.EMG = 0;              %Only cutting out a part of the signal will induce strange edging effects of the very-low-pass filter
    BPcfg.artifacts.Visualize = 0;                          %Visualize the data before and after artefact rejection, and compare the in-trial and out-of-trial power spectra
%Smoothing
    %Select the amount of samples in the boxcar kernel:
    BPcfg.smooth.Kernel.EMG = BPcfg.signal.FS/2;             %boxcar size of 0.5 seconds.
    BPcfg.smooth.Kernel.EDA = BPcfg.signal.FS*3;             %boxcar size of 3 seconds.
    BPcfg.smooth.Kernel.PPG = BPcfg.signal.FS/2;             %boxcar size of 0.5 seconds.
    BPcfg.smooth.Visualize = 0;                              %Visualize the data before and after smoothing;
%Quantification
    BPcfg.quantify.EMG.Stepsize = BPcfg.signal.FS/10;        %Segmentation of the window of interest in steps of this many samples; compute one measure per segment (here set to 100ms).
    BPcfg.quantify.EDA.Visualize = 0;                        %Visualize each trial (in debug mode) with the detected peaks
    BPcfg.quantify.PPG.Visualize = 0;                        %Visualize the entire signal with the detected peaks
