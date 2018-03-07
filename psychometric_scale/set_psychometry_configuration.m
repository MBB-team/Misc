%% set_psychometry_configuration
%  initialize the configuration of motiscan tasks (psychtoolbox)
%       - subject identification
%       - check options
%       - subject folder
%       - screen
%       - keyboard
%       - random number generator
%       - device configuration
%   
%
%% ---------------------------------------------
% Identification
%-----------------------------------------------
nInput = numel(inputList);
if nInput>=1
    if isnumeric(inputList{1})
        subid=inputList{1};
    else
        error(' "subid" should be numeric');
    end
end
if nInput>=2
    if isnumeric(inputList{2}) && round(inputList{2})==inputList{2}
        nsession=inputList{2};
    else
        error(' "nsession" should be an integer number');
    end
end
if exist('subid')~=1
    subid=input('subject identification number? ','s');
end

if exist('nsession')~=1
    nsession=input('session number ?');
end

% Check Options
%-----------------------------------------------
for iarg=1:nInput
   if ischar(inputList{iarg})
       if ismember(inputList{iarg},optionList)
           eval([ inputList{iarg} '= inputList{iarg+1};' ]);
%            eval([ 'subdata.' inputList{iarg} '= inputList{iarg+1};' ]); % future release
       end
   end
end

% Directory Configuration
%-----------------------------------------------
% define script directory
psychodir= fileparts(which('psychometry.m'));
addpath(genpath(psychodir));


% study name
if exist('study.mat','file')==2
    load('study.mat');
else
    studyName = 'MBB_battery';
end

% define group & subject result directory
resultdir=[psychodir '\data'];
if exist(resultdir,'dir')~=7
    mkdir data
end
cd(resultdir);
subdir=[resultdir ['\sub' num2str(subid)]];
if exist(subdir,'dir')~=7
    mkdir(resultdir,['\sub' num2str(subid)]);
end
resultname=strcat(studyName,'_',taskName,'_sub',num2str(subid),'_sess',num2str(nsession));
clck = clock;
time = [num2str(clck(2)) '_' num2str(clck(3)) '_' num2str(clck(1)) '_' num2str(clck(4)) 'h' num2str(clck(5)) 'min' ];
resultname = [resultname '_' time];


% Screen Configuration
%-----------------------------------------------
i_window=0;
[L, H]=Screen('WindowSize',i_window);
x=L/2;
y=H/2;
Screen('Preference', 'SkipSyncTests', 1); %--> or see 'help SyncTrouble'
Screen('Preference', 'ConserveVRAM', 4096);
if fullscreen
    [display.window]=Screen('OpenWindow',i_window,[0 0 0],[]); % full-screen window
else
    nScreen=numel(Screen('Screens'));
    if nScreen>=2
        i_window=2;
        [display.window]=Screen('OpenWindow',i_window,[0 0 0],[]); % testing window
        [L, H]=Screen('WindowSize',i_window);
        x=L/2;
        y=H/2;
    else
        [display.window]=Screen('OpenWindow',i_window,[0 0 0],[0 0 x y]); % testing window
    end
end
Screen('TextSize', display.window, 40);
Screen('TextFont', display.window, 'arial');
HideCursor;
Priority(MaxPriority(display.window));


% Keyboard Configuration
%-----------------------------------------------
[~,~,keycode] = KbCheck;
DisableKeysForKbCheck(find(keycode==1));

KbName('UnifyKeyNames');
key.left = KbName('LeftArrow');
key.right = KbName('RightArrow');
key.up = KbName('UpArrow');
key.down = KbName('DownArrow');
key.space = KbName('Space') ;
key.valid = KbName('Space');
key.escape = KbName('ESCAPE') ;
key.clear = KbName('BackSpace') ;
if exist('laptop')
    if laptop
        key.digit = [48:57];        
    else
        key.digit = [96:105];
    end
end

% Generator reset
%-----------------------------------------------
rand('state',sum(100*clock));
