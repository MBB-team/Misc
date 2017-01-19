% fMRI_rec_all_TTL: records all the TTL received during an fMRI task. Input
% each part where it should be in your specific fMRI setting
%
% written by Nicolas Clairis - 2016

%% BEGINNING OF YOUR PTB SCRIPT

% subject identification number and session identification number
subject_number = 1;
subid = num2str(subject_number); % subject number as a string
session = 1;
sessionname = num2str(session);   % run number as a string   

% KbQueue records every time an fMRI trigger is received.
% Note that KbCheck or KbWait commands will not be impacted by the fact
% that KbQueue only checks for 
keysOfInterest = zeros(1,256); % all keys of the keyboard
trigger = 53; %% TTL in keyboard touch 5 in my case
keysOfInterest(trigger) = 1;
KbQueueCreate(0,keysOfInterest); % checks TTL only
KbQueueStart; % starts checking



%% YOUR TASK



%% END OF YOUR PTB SCRIPT
% extract all the TTLs recorded inside KbQueue
TTL = [];
while KbEventAvail
    [event, n] = KbEventGet;
    TTL = [TTL; event.Time];
end
KbQueueStop;
KbQueueRelease;
% save all TTL in the results file
save(['TTL_sub',subid,'_sess',sessionname,'.mat'],'TTL');