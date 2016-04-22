function [ k, timedown, KeyCode, d ] = waitForKey( key )
% Dummy function: wait for a specific key
KbReleaseWait();
[k, timedown, KeyCode, d] = KbCheck;
while all((KeyCode(key) == 0));
        [k, timedown, KeyCode, d] = KbCheck;
end
KbReleaseWait();
end

