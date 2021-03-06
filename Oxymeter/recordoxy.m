function [oxdata,onset] = recordoxy(oxdata,option,onset,value)
% recordoxy- template function for real-time oxymeter recording & event tagging,
%            to insert and adapt to your task script
%            it must be located into a while loop to update the recording
%            at each iteration. 
%
% ex: 
%     recordDuration = 2; 
%     onset=0; feedback = +1;
%     startTime = GetSecs;
%     while GetSecs< startTime + recordDuration
%         [oxdata,onset] = recordoxy(oxdata,'feedback',onset,feedback)
%     end
%
% Nicolas Borderies- March 2017

% continuous oxymeter acquisition
ret = ReadOxymeter('livedata');

if ~isempty(ret)
    % event marking
    % column 1 : options onset, valence value
    % column 2 : choice onset, correct value
    % column 3 : feedback onset, outcome value
    event = zeros(size(ret,1),3); 

    % update onset
    if nargin>2
        onset = onset+1;
        switch option
            case 'options'
                event(find(onset==1),1) = value;   
            case 'choice'
                event(find(onset==1),2) = value;   
            case 'feedback'
                event(find(onset==1),3) = value;   
        end
    end
    oxdata=[oxdata;[ret,event]] ;
end


end