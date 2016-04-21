%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('Preference', 'SkipSyncTests', 1); %--> or see 'help SyncTrouble'

%% Demo for using scales with matlab
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
Screen('CloseAll')

%% Pathway

pathway = 'F:\Nicolas_Sauvegarde\MATLAB\matlab_scales';


cd(pathway)

%% screen & General settings
scrAll = Screen('Screens');
screenNum = max(scrAll);
%[displayOption.win,displayOption.bound]=Screen('OpenWindow',screenNum, [], [0 0 640 480]);
[displayOption.win,displayOption.bound]=Screen('OpenWindow',screenNum, [], []);
displayOption.screenX=displayOption.bound(3)-displayOption.bound(1);
displayOption.screenY=displayOption.bound(4)-displayOption.bound(2);
displayOption.centerX=displayOption.bound(1)+displayOption.screenX/2;
displayOption.centerY=displayOption.bound(2)+displayOption.screenY/2;
displayOption.monitorFlipInterval=Screen('GetFlipInterval', displayOption.win);
%HideCursor;

Priority(MaxPriority(displayOption.win));
Screen('Preference', 'TextAntiAliasing', 2);
Screen('FillRect',displayOption.win,[0 0 0]);
Screen('TextSize', displayOption.win , 30);
Screen('TextFont', displayOption.win, 'Helvetica');
rand('state',sum(100*clock))

%% keyboard settings
KbName('UnifyKeyNames');
Key.space = KbName('Space');
Key.up = KbName('UpArrow');
Key.down = KbName('DownArrow');
Key.valid=KbName('Space');
Key.left = KbName('LeftArrow');
Key.right = KbName('RightArrow');

% Load Image
aga=imread([pathway filesep  'stuff' filesep 'EVA_instructions.bmp']);
listImage.psychometry.instructionEVA=Screen('MakeTexture',displayOption.win,aga);
aga=imread([pathway filesep  'stuff' filesep 'arrow3.bmp']);
listImage.psychometry.arrow=Screen('MakeTexture',displayOption.win,aga);
aga=imread([pathway filesep  'stuff' filesep 'instructionsBFI.bmp']);
listImage.psychometry.instructionBFI=Screen('MakeTexture',displayOption.win,aga);
aga=imread([pathway filesep  'stuff' filesep 'instructionsBIS.bmp']);
listImage.psychometry.instructionBIS=Screen('MakeTexture',displayOption.win,aga);
aga=imread([pathway filesep  'stuff' filesep 'instructionsBARATT.bmp']);
listImage.psychometry.instructionBARATT=Screen('MakeTexture',displayOption.win,aga);
aga=imread([pathway filesep  'stuff' filesep 'instructionsSTARKSTEIN.bmp']);
listImage.psychometry.instructionSTARKSTEIN=Screen('MakeTexture',displayOption.win,aga);
aga=imread([pathway filesep  'stuff' filesep 'instructionsLAY.bmp']);
listImage.psychometry.instructionLAY=Screen('MakeTexture',displayOption.win,aga);

aga=imread([pathway filesep  'stuff' filesep 'case.bmp']);
listImage.psychometry.case=Screen('MakeTexture',displayOption.win,aga);
aga=imread([pathway filesep  'stuff' filesep 'caseV.bmp']);
listImage.psychometry.caseV=Screen('MakeTexture',displayOption.win,aga);
 


% Load psychometry stuff
aga = load ([pathway filesep 'stuff' filesep 't_Norris.mat']);
psychometryStuff.norris=aga.t_Norris;
aga=load([pathway filesep 'stuff' filesep 'BFI_BIS.mat']);
psychometryStuff.BFI.listQuestion=aga.BFI_Q;
psychometryStuff.BFI.listAnswer=aga.BFI_R;
psychometryStuff.BIS.listQuestion=aga.BIS_Q;
psychometryStuff.BIS.listAnswer=aga.BIS_R;
aga = load([pathway filesep 'stuff' filesep 'BARATT.mat']);
psychometryStuff.BARATT.listQuestion=aga.BARATT_Q;
psychometryStuff.BARATT.listAnswer=aga.BARATT_R;
aga = load([pathway filesep 'stuff' filesep 'STARKSTEIN.mat']);
psychometryStuff.STARKSTEIN.listQuestion=aga.STARKSTEIN_Q;
psychometryStuff.STARKSTEIN.listAnswer=aga.STARKSTEIN_R;
aga = load([pathway filesep 'stuff' filesep 'LAY.mat']);
psychometryStuff.LAY.listQuestion=aga.LAY_Q;
psychometryStuff.LAY.listAnswer=aga.LAY_R;


%% EVA Norris
% scaleOption.arrow.image=listImage.psychometry.arrow;
% scaleOption.nBar=21;           % For mood and confidence ratings, the scale is divided in nBar possible answers
% scaleOption.arrow.y = -1/8;    % Position of the arrow (in % of screen), the 0 is the position of the scale (should be in dimension option but kept for compatibility)
% scaleOption.arrow.size = 1/50; % SIze of the arrow
% scaleOption.lVisibleBar=[];
% aga.instruction=listImage.psychometry.instructionEVA;
% aga.listItem=psychometryStuff.norris;
% data.psychometry.norris(1).result=askEVA_Norris(aga, displayOption, scaleOption, Key);
% KbReleaseWait;

%% BFI
% aga.caseN=listImage.psychometry.case;
% aga.caseV=listImage.psychometry.caseV;
% aga.instruction=listImage.psychometry.instructionBFI;
% aga.listQuestion=psychometryStuff.BFI.listQuestion;
% aga.listAnswer=psychometryStuff.BFI.listAnswer;
% data.psychometry.BFI.logResult = askPsychometricScale(aga , displayOption, Key );
% data.psychometry.BFI.OCEAN(1)=(sum(data.psychometry.BFI.logResult([5 10 15 20 25 30 40 44]))+ sum(6-data.psychometry.BFI.logResult([35 41])))/10;
% data.psychometry.BFI.OCEAN(2)=(sum(data.psychometry.BFI.logResult([3 13 28 33 38]))+ sum(6-data.psychometry.BFI.logResult([8 18 23 43])))/9;
% data.psychometry.BFI.OCEAN(3)=(sum(data.psychometry.BFI.logResult([1 11 16 26 36]))+ sum(6-data.psychometry.BFI.logResult([6 21 31])))/8;
% data.psychometry.BFI.OCEAN(4)=(sum(data.psychometry.BFI.logResult([7 17 22 32 42]))+ sum(6-data.psychometry.BFI.logResult([2 12 27 37 45])))/10;
% data.psychometry.BFI.OCEAN(5)=(sum(data.psychometry.BFI.logResult([4 14 19 29 39]))+ sum(6-data.psychometry.BFI.logResult([9 24 34])))/8;
% KbReleaseWait;

%% BIS
% aga.caseN=listImage.psychometry.case;
% aga.caseV=listImage.psychometry.caseV;
% aga.instruction=listImage.psychometry.instructionBIS;
% aga.listQuestion=psychometryStuff.BIS.listQuestion;
% aga.listAnswer=psychometryStuff.BIS.listAnswer;
% data.psychometry.BISBAS.result = askPsychometricScale(aga , displayOption, Key );
% data.psychometry.BISBAS.BAS_drive=sum(5-data.psychometry.BISBAS.result([3 9 12 21]));
% data.psychometry.BISBAS.BAS_funSeeking= sum(5-data.psychometry.BISBAS.result([5 10 15 20]));
% data.psychometry.BISBAS.BAS_rewardResponsiveness= sum(5-data.psychometry.BISBAS.result([4 7 14 18 23]));
% data.psychometry.BISBAS.BIS= sum(5-data.psychometry.BISBAS.result([8 13 16 19 24]))+sum(data.psychometry.BISBAS.result([2 22])); % BIS
% data.psychometry.BISBAS.normalized.BAS_drive=data.psychometry.BISBAS.BAS_drive/4;
% data.psychometry.BISBAS.normalized.BAS_funSeeking=data.psychometry.BISBAS.BAS_funSeeking/4;
% 
% data.psychometry.BISBAS.normalized.BAS_rewardResponsiveness=data.psychometry.BISBAS.BAS_rewardResponsiveness/5;
% data.psychometry.BISBAS.normalized.BIS=data.psychometry.BISBAS.BIS/7;
% KbReleaseWait;

%% BARATT
% aga.caseN=listImage.psychometry.case;
% aga.caseV=listImage.psychometry.caseV;
% aga.instruction=listImage.psychometry.instructionBARATT;
% aga.listQuestion=psychometryStuff.BARATT.listQuestion;
% aga.listAnswer=psychometryStuff.BARATT.listAnswer;
% data.psychometry.BARATT.result = askPsychometricScale(aga , displayOption, Key );
% data.psychometry.BARATT.total = sum(data.psychometry.BARATT.result);
% data.psychometry.BARATT.BARATT_motor = sum(data.psychometry.BARATT.result([2 3 4 16 17 19 21 22 23 25 30]));
% data.psychometry.BARATT.BARATT_cognitive = sum(data.psychometry.BARATT.result([5 6 9 11 20 24 26 28]));
% data.psychometry.BARATT.BARATT_planification = sum(data.psychometry.BARATT.result([1 7 8 10 12 13 14 15 18 27 29]));
% KbReleaseWait;

%% STARKSTEIN
% aga.caseN=listImage.psychometry.case;
% aga.caseV=listImage.psychometry.caseV;
% aga.instruction=listImage.psychometry.instructionSTARKSTEIN;
% aga.listQuestion=psychometryStuff.STARKSTEIN.listQuestion;
% aga.listAnswer=psychometryStuff.STARKSTEIN.listAnswer;
% data.psychometry.STARKSTEIN.result = askPsychometricScale(aga , displayOption, Key );
% data.psychometry.STARKSTEIN.total = sum(4-data.psychometry.STARKSTEIN.result([1:8])) + sum(data.psychometry.STARKSTEIN.result([9:14])-1);
% KbReleaseWait;

%% LAY
aga.caseN=listImage.psychometry.case;
aga.caseV=listImage.psychometry.caseV;
aga.instruction=listImage.psychometry.instructionLAY; 
aga.listQuestion=psychometryStuff.LAY.listQuestion;
aga.listAnswer=psychometryStuff.LAY.listAnswer;
data.psychometry.LAY.result = askPsychometricScale(aga , displayOption, Key );
data.psychometry.LAY.total = sum(data.psychometry.LAY.result([1 2 5 7 9 10 12 16 17 19])) + sum(6-data.psychometry.LAY.result([3 4 6 8 11 13 14 15 18 20]));
KbReleaseWait;

Screen('CloseAll')