function [HeartRate,NetEnvelope,PeakLocs] = BP_Quantify_PPG(data,BPcfg)
% BIOPAC data preprocessing toolbox - oxymetry quantification.
% This function produces three time-resolved quantifications of the
% oxymetry (heart beat measures) data from Biopac.
% 
%   data: a 1×n variable of type double that contains the n datapoints of 
%           the one heart rate channel (often called PPG by Biopac). 
%           It is recommended that the data has been preprocessed and that 
%           missing data has been interpolated before entering it here. 
%   BPcfg: the configuration structure that is produced by running
%           BP_Configuration.m. Be sure to enter the correct settings there.
%
% OUTPUT
%   HeartRate: a variable of size 1×n with the time-resolved heart rate
%       (based on distances between detected heart beats; interpolated 
%       between peaks)
%   NetEnvelope: the envelope of the oxymetry signal; interpolated between
%       peaks.
%   PeakLocs: locations of detected peaks. All zeros except at the points
%       of a detected heart beat peak (ones).
% Written by Roeland Heerema (roelandheerema@hotmail.com) in January 2018


%1. Find peak locations
    [PKS,LOCS]= findpeaks(data);   
    PeakLocs = zeros(size(data)); PeakLocs(LOCS) = 1;
 
%2. Make heart rate signal and interpolate
    BPM = LOCS(2:end)-LOCS(1:length(LOCS)-1);   %Durations (in samples) between heart beats
    BPM = 60./(BPM/BPcfg.signal.FS);            %Express in beats per minute
    HeartRate = NaN(size(data));
        HeartRate(LOCS(2:end)) = BPM;
        HeartRate = InterpolatePPG(HeartRate);
    
%3. Interpolate PKS signal (envelope) - respiration proxy
    PosEnvelope = NaN(size(data));
        for i = 1:length(PKS)
            PosEnvelope(LOCS(i)) = PKS(i);
        end    
        PosEnvelope = InterpolatePPG(PosEnvelope);        
    NegEnvelope = NaN(size(data));
        [PKS,LOCS]= findpeaks(-data);   
        for i = 1:length(PKS)
            NegEnvelope(LOCS(i)) = -PKS(i);
        end      
        NegEnvelope = InterpolatePPG(NegEnvelope);                
    NetEnvelope = PosEnvelope-NegEnvelope;    

%4. Visualize time-resolved data
    if BPcfg.quantify.PPG.Visualize
        figure
        subplot(2,1,1); hold on  %Raw signal + detected peaks
            plot(data); plot(PosEnvelope); plot(NegEnvelope)
            title('Raw signal and envelope')
        subplot(2,1,2); hold on
            plot(NetEnvelope); plot(HeartRate/60)
            title('Net envelope and heart rate (per second)')
            legend({'Envelope','BPS'})
    end            

end

%% Subfunction: interpolate heart rate signal
function [i_data] = InterpolatePPG(data)
%This function is a lot faster than the BP_Interpolate one because it is
%especially made to interpolate heart rate data (i.e., relatively very few
%samples are not NaN because they are the detected peaks)

Peaks = find(~isnan(data));
for i = 1:length(Peaks)
    if i == 1   %Boundary condition: start
        if Peaks(1) ~= 1    %First sample is no peak
            data(1:Peaks(1)) = data(Peaks(1));
        end
    elseif i == length(Peaks)   %Boundary condition: end
        if Peaks(i) ~= length(data) %Last sample is no peak
            data(Peaks(i):end) = data(Peaks(i));
        end
    else    %Replace all NaN's between peaks (linear interpolation)
        x = [Peaks(i-1) Peaks(i)];
        v = [data(Peaks(i-1)) data(Peaks(i))];
        xq = Peaks(i-1):Peaks(i);
        data(xq) = interp1(x,v,xq);
    end
end

i_data = data;  %Output

end