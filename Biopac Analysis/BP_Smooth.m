function [s_data] = BP_Smooth(data,type,BPcfg)
% BIOPAC data preprocessing toolbox - smoothing function.
% This function smooths the signal from a 1D Biopac dataset by taking a
% sliding average.
% 
% INPUT
%   data: a 1×n variable of type double that contains the n datapoints of 
%           one channel. Note that if there are missing samples, the
%           smoothed signal around those samples (1 kernel size before and
%           after) will also be missing, so it's probably better to
%           interpolate missing samples first. Alternatively, set the
%           kernel size to be small.
%   type: the type of data you're filtering. Enter either of the following strings:
%           'EMG':  electromyography (musculature)
%           'PPG':  pulse oxymetry (heart rate)
%           'EDA':  electrodermal (skin conductance)
%   BPcfg: the configuration structure that is produced by running
%           BP_Configuration.m. Be sure to enter the correct settings there.
%
% OUTPUT
%   s_data: the smoothed dataset (in the format 1channel × Nsamples)
% 
% Written by Roeland Heerema (roelandheerema@hotmail.com) in January 2018


%Transpose if necessary (Fieldtrip wants data in the format Nchannels × Nsamples)
    if size(data,1)>size(data,2)
        data = data';                               
    end

switch type
    case 'EMG'
        kernel = BPcfg.smooth.Kernel.EMG;
    case 'EDA'
        kernel = BPcfg.smooth.Kernel.EDA;
    case 'PPG'
        kernel = BPcfg.smooth.Kernel.PPG;
end
s_data = ft_preproc_smooth(data,kernel);

if BPcfg.smooth.Visualize
    close
    figure;hold on
    plot(data);plot(s_data)
    title('Original vs. smoothed data')
    xlabel('Samples')
    ylabel('Signal')
    legend({'Unsmoothed','Smoothed'})
end

disp('Finished smoothing.')

end