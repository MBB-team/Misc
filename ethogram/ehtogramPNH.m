%% ethogramPNH

% identification
    clear all;

%% Session identification
    subid=input('Identifiant du sujet? ( esmeralda, bob)   :','s');
    experimenter=input('Nom de l''experimentateur? (ex: nicolas, sophie, caroline...)   :','s');
    treatment=input('Traitement? (ex: free, placebo, atx, ldopa...) :','s');

% Directory Configuration
%__________________________________________________________________________

% root = 'C:\Users\bastien.blain\Desktop';
% pathway = [root '\ethogram'];
pathway = cd;
cd(pathway);
datadir = [pathway filesep 'data'];

% Screen Configuration
%__________________________________________________________________________

% L=1680;
% H=1050;
[L, H]=Screen('WindowSize',0);
x=L/2;
y=H/2;
Screen('Preference', 'SkipSyncTests', 1); %--> or see 'help SyncTrouble'
scrAll = Screen('Screens');
screenNum = max(scrAll);
[displayOption.win,displayOption.bound]=Screen('OpenWindow',screenNum, [], []);
% [displayOption.win,displayOption.bound]=Screen('OpenWindow',screenNum, [], [5/4*x y/2 7/4*x  3*y/2]);

displayOption.screenX=displayOption.bound(3)-displayOption.bound(1);
displayOption.screenY=displayOption.bound(4)-displayOption.bound(2);
displayOption.centerX=displayOption.bound(1)+displayOption.screenX/2;
displayOption.centerY=displayOption.bound(2)+displayOption.screenY/2;
displayOption.monitorFlipInterval=Screen('GetFlipInterval', displayOption.win);
% HideCursor;
Priority(MaxPriority(displayOption.win));
Screen('Preference', 'TextAntiAliasing', 2);
Screen('FillRect',displayOption.win,[0 0 0]);
Screen('TextSize', displayOption.win , 30);
Screen('TextFont', displayOption.win, 'Helvetica');



% keyboard Configuration
%__________________________________________________________________________

KbName('UnifykeyNames');
key.space = KbName('Space');
key.up = KbName('UpArrow');
key.down = KbName('DownArrow');
key.valid=KbName('Space');
key.left = KbName('LeftArrow');
key.right = KbName('RightArrow');


% Generator reset
%__________________________________________________________________________

rand('state',sum(100*clock));


% Stimuli loading
%__________________________________________________________________________

aga=imread([pathway  filesep 'instructionsETHOGRAM.bmp']);
stuff.instruction=Screen('MakeTexture',displayOption.win,aga);
aga=imread([pathway  filesep 'case.bmp']);
stuff.caseN = Screen('MakeTexture',displayOption.win,aga);
aga=imread([pathway  filesep 'caseV.bmp']);
stuff.caseV = Screen('MakeTexture',displayOption.win,aga);
aga=load([pathway  filesep 'BEHAVIOR_CLASSES.mat']);
stuff.listBehavior = aga.BEHAVIOR_CLASSES;

% data.psychometry.BFI.logResult = askPsychometricScale(stuff , displayOption, key );
% KbReleaseWait;

% For compatibility
%__________________________________________________________________________
if ~isfield(key, 'key')
    responseOption.key=key;
else
    responseOption=key;
end   

displayOption.screenXY=Screen(displayOption.win,'Rect');
centerX=(displayOption.screenXY(3)-displayOption.screenXY(1))/2;
centerY=(displayOption.screenXY(4)-displayOption.screenXY(2))/2;

try
miscOption.color.back;
catch
miscOption.color.back=[0 0 0];
end

try
miscOption.color.text;
miscOption.color.valid;
catch
miscOption.color.text=[255 255 255];
miscOption.color.valid=[255 0 0];
end

%% Initialize variables
freq = 40;
totaltime = (10)*60*40;
% totaltime = (1/12)*60*40;

recordTime = 0;
exit = 0;
it=0;

nBehavior=length(stuff.listBehavior);
behav = cell(nBehavior,1);
for iA=1:nBehavior
    behav{iA} = strrep(stuff.listBehavior{iA},'-','_'  );
    behav{iA} = strrep(behav{iA},' ','_'  );
    ethogram.(behav{iA}) = zeros(1,totaltime);
end
ethogram.time = nan(1,totaltime);


%% Instructions
Screen('DrawTexture',displayOption.win,stuff.instruction, [], displayOption.bound);
Screen(displayOption.win, 'Flip');
% waitForKey(responseOption.key.space);
KbWait;
[t0] = Screen(displayOption.win, 'Flip');

%% Perform ethogram

% display
caseXYD=[3/8*centerX 2/8*centerY, centerY/15];
nBehavior=length(stuff.listBehavior);
% cQ = Sample(1:nBehavior);
cQ = 8;
cB = cQ;
recordtime = t0;

while exit==0
    
    it = it+1;
    [k, timedown, keyCode, d] = KbCheck;

%     while ((keyCode(key.valid) == 0));
        Screen('FillRect',displayOption.win,miscOption.color.back, displayOption.screenXY);
        for iA=1:nBehavior
            Screen('DrawTexture',displayOption.win,stuff.caseN, [], [caseXYD(1), caseXYD(2) + (iA-1)*2*caseXYD(3), caseXYD(1)+caseXYD(3), caseXYD(2)+(1+(iA-1)*2)*caseXYD(3)] );
            textBox=[caseXYD(1)+2*caseXYD(3), caseXYD(2)+(1/2+(iA-1)*2)*caseXYD(3)-20, displayOption.screenXY(3), caseXYD(2)+(1/2+(iA-1)*2)*caseXYD(3)+20];
            DrawFormattedText(displayOption.win, stuff.listBehavior{iA}, caseXYD(1)+2*caseXYD(3), 'center',miscOption.color.text, 60 , [], [], 2 , [],textBox );
        end
       for iA=cB
            textBox=[caseXYD(1)+2*caseXYD(3), caseXYD(2)+(1/2+(iA-1)*2)*caseXYD(3)-20, displayOption.screenXY(3), caseXYD(2)+(1/2+(iA-1)*2)*caseXYD(3)+20];
            DrawFormattedText(displayOption.win, stuff.listBehavior{iA}, caseXYD(1)+2*caseXYD(3), 'center',miscOption.color.valid, 60 , [], [], 2 , [],textBox );
       end
       min = floor((recordtime - t0)/60);
       sec =floor((recordtime - t0)- min*60);
       timestring = [num2str(min) ' min.' num2str(sec) 's.'];
       timeBox = [6/4*centerX 1/8*centerY, 8/4*centerX , 2/8*centerY];
       DrawFormattedText(displayOption.win, timestring , 'center', 'center',miscOption.color.valid, 60 , [], [], 2 , [],timeBox );

        Screen('DrawTexture',displayOption.win,stuff.caseV, [], [caseXYD(1), caseXYD(2)+((cQ-1)*2)*caseXYD(3), caseXYD(1)+caseXYD(3), caseXYD(2)+((cQ-1)*2+1)*caseXYD(3)] );

        
    % check response
        if (keyCode(key.up) == 1)
            cQ=(cQ>1)*(cQ-1)+(cQ==1);
            KbReleaseWait;
        end
        if (keyCode(key.down) == 1)
            cQ=(cQ<nBehavior)*(cQ+1)+nBehavior*(cQ==nBehavior);
            KbReleaseWait;
        end
        if (keyCode(key.valid) == 1)
           cB = cQ;
        end
        [k, timedown, keyCode, d] = KbCheck;
        WaitSecs(1/freq);
        [recordtime] = Screen(displayOption.win, 'Flip');
%     end

    % record behavior
    ethogram.(behav{cB})(it) = 1;
    ethogram.time(it) = recordtime - t0;
    
    

    
    % stop recording
    if ethogram.time(it) > (totaltime/freq)
        exit=1;
    end
    
end


% KbReleaseWait; 
keyCode=keyCode*0;

%% Terminates
sca;

% save
     taskClock = clock;
     taskTime = [ num2str(taskClock(2)) '_' num2str(taskClock(3)) '_' num2str(taskClock(1)) '__' num2str(taskClock(4)) 'h' num2str(taskClock(5)) 'min'  ];
     resultname=strcat(['ethogram_',subid,'_',taskTime]);
     cd(datadir);
     save(resultname,'ethogram','subid','experimenter','treatment');


