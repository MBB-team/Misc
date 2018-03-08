function [i_data] = BP_Interpolate(data)
% BIOPAC data preprocessing toolbox - linear interpolation
% This function replaces missing data (NaNs) by linearly interpolated 
% values. If the first (or last) samples of the signal are artefacts, the 
% nearest non-artefactual sample values are adopted.
% 
% INPUT
%   data: a 1×n variable of type double that contains the n datapoints of 
%           one channel. Artefactual data samples must have been marked as
%           NaN before entering them here.
%
% OUTPUT
%   i_data: the data without missing samples.
% Written by Roeland Heerema (roelandheerema@hotmail.com) in January 2018


jumpsize = 10000;
%Loop through the data and, once a NaN is found, look for the previous and
%the next non-NaN data points. Set jumpsize high if you have a lot of data
%and not many artefacts for faster looping.
i = 1;
while i <= length(data)
    if i < length(data)-jumpsize && sum(isnan(data(i):data(i+jumpsize)))==0       %For faster looping
        i = i+jumpsize;
    else
        if isnan(data(i))
            if i == 1 %Boundary condition: NaN at start of the experiment   
                next = find(~isnan(data),1,'first');
                data(1:next) = data(next);  %Set to the first non-artefactual value.            
            else %NaN after experiment has started
                previous = i-1;
                    if isnan(data(previous))
                        previous = find(~isnan(data(1:i)),1,'last');
                        disp('Algorithm is wrong.')
                    end
                next = i+find(~isnan(data(i:end)),1,'first')-1;
                    if isempty(next)    %Boundary condition: NaNs until the end of the experiment
                        data(i:end) = data(previous);
                        break
                    else    %Interpolate within experiment
                        samples = previous:next; samples = samples(samples ~= previous & samples ~= next);
                        data(samples) = interp1([previous next],data([previous next]),samples);
                    end
            end
            i = next;
        else
            i = i+1;
        end
    end
end

i_data = data;
disp('Completed linear interpolation of missing samples.')

end