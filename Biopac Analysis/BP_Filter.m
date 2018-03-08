function [f_data] = BP_Filter(data,type,BPcfg)
% BIOPAC data preprocessing toolbox - filtering script.
% This function filters Biopac data and optionally shows the signal's spectrum.
% 
% INPUT
%   data: an n×1 or 1×n variable of type double that contains the n 
%           datapoints of one channel. This is the raw data that comes from 
%           the Biopac dataset.
%   BPcfg: the configuration structure that is produced by running
%           BP_Configuration.m. Be sure to enter the correct settings there.
%   type: the type of data you're filtering. Enter either of the following strings:
%           'EMG':  electromyography (musculature)
%           'PPG':  pulse oxymetry (heart rate)
%           'EDA':  electrodermal (skin conductance)
%
% OUTPUT
%   f_data: the filtered dataset (in the format 1channel × Nsamples)
% Written by Roeland Heerema (roelandheerema@hotmail.com) in January 2018


%% Settings
    FS = BPcfg.signal.FS;                       %Sampling rate
    LineNoise = BPcfg.filter.LineNoise;         %Stopband filter
    %Select bandpass filter (depending on data type)
        switch type                                 
            case 'EMG'
                BandPass = BPcfg.filter.BandPass.EMG;
            case 'PPG'
                BandPass = BPcfg.filter.BandPass.PPG;
            case 'EDA'
                BandPass = BPcfg.filter.BandPass.EDA;
        end    
    %Transpose if necessary (Fieldtrip wants data in the format Nchannels × Nsamples)
        if size(data,1)>size(data,2)
            data = data';                               
        end

%% Apply filters
    switch type
        case 'EMG'
            [f_data] = ft_preproc_bandpassfilter(data, FS, BandPass);
            [f_data] = ft_preproc_dftfilter(f_data, FS, LineNoise);
            disp('Completed bandpass and line noise filtering.')
            
        case {'EDA','PPG'}
            %Iterative process for very low-frequency signals described here:
            %https://allsignalprocessing.com/very-low-frequency-filtering/
            f_FS = BPcfg.signal.FS;     %Sampling frequency of the filtered signal (will be downsampled)            
            factor = 10;                %Downsampling factor            
            iterations = 2;             %How many iterations
            f_data = data;
            for loop = 1:iterations
                %Lowpass filter
                    Flp = factor^(iterations+1-loop); %Lowpass frequency
                    [f_data] = ft_preproc_lowpassfilter(f_data,f_FS,Flp);     
                %Downsample
                    f_data = f_data(1:factor:length(f_data));
                    f_FS = f_FS/factor;
            end
            
            [f_data] = ft_preproc_bandpassfilter(f_data,f_FS,BandPass);
                %Interpolate up to original sampling frequency
                f_data = interp1(1:length(f_data),f_data,1:1/(factor^iterations):length(f_data));
                f_data = [f_data zeros(1,length(data)-length(f_data))];     %Pad with zeros towards the end
            disp('Completed low-frequency bandpass filtering procedure.')                  
            
    end

%% Visualizations (Note: slow!)
if BPcfg.filter.Visualize
    
%Compute power spectral density
    FFTdata = fft(data,length(data));                       %Fast Fourier Transform
    FFTfiltered = fft(f_data,length(f_data));
    PSDdata = FFTdata.*conj(FFTdata)./length(data);         %Power Spectral Density
    PSDfiltered = FFTfiltered.*conj(FFTfiltered)./length(f_data);         
        %PSD is a measurement of the energy at various frequencies, using
        %the complex conugate (CONJ). Note: symmetric about the middle.
    freq = FS/length(data).*(0:length(data)/2); %Frequencies
    
%     close
    figure
    subplot(1,2,1)  %Original vs. filtered signal
        hold on
        plot((1:length(data))/FS,data)
        plot((1:length(f_data))/FS,f_data)    
        title('Original vs. filtered signal')
        xlabel('Time [s]')
        legend({'Raw data','Filtered data'})
    subplot(1,2,2)  %Power spectral density
        semilogx(freq,PSDdata(1:length(freq))); hold on
        semilogx(freq,PSDfiltered(1:length(freq))); hold off
    %     fig = gca;
    %     rectangle('Position',[BandPass(1) 0 BandPass(2) fig.YLim(2)],'EdgeColor','k')       %Bandpass filter
    %     rectangle('Position',[LineNoise-2 0 log(LineNoise) fig.YLim(2)],'EdgeColor','k')    %Notch filter
        title('Power Spectral Density')
        xlabel('Frequency [Hz]')
        ylabel('Power')
        legend({'Raw data','Filtered data'})
    
end
end