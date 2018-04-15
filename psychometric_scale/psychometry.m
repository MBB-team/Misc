function [] = psychometry(varargin)
%psychometry - execute the psychometric questionnaires to record subject responses
%               (from motiscan battery)
%
%
% Syntax:  psychometry(subid,nsession,'optionName',optionValue)
%
% Inputs:
%    subid - subject identification number (double)
%    nsession - session number (double)
%    options:
%       list - cell array of questionnaire names (size:1 x nlist) ,
%       potential values are :
%           'NORRIS' - Norris scale. normal alertness state
%           'BFI' - Big Five Inventory. normal personality type trait
%           'BIS' - normal affective sensitivity trait
%           'BARATT' - normal impulsivity trait
%           'STARKSTEIN' - pathological apathy state
%           'LAY' -  normal procrastination trait
%           'HAD' - pathological anxiety & depression state (WARNING : under development)
%           'POMS' - Profil of Mood States. normal mood state 
%           'IMI' - Intrinsic Motivation Inventory. normal motivation state
%       fullscreen - display in fullscreen mode(1) or not (0) (logical)
%       random_item - randomize the order of item within questionaires (1)
%                     or not (0)(logical) Warning : does not work / do not use.
%       random_test - randomize the order of questionaires (1)
%                     or not (0)(logical)
% Outputs:
%
% Example: 
%   psychometry(10,2,'list',{'STARKSTEIN','BARATT','LAY'})
%
% Requirements: 
%   Subfunctions:   set_task_configuration.m , 
%   MAT-files: study.mat
%   MATLAB products: MATLAB, Statistics and Machine Learning Toolbox,
%                    Psychtoolbox, psychometric_scale library

%
% See also:
%
% Author: Fabien Vinckier, Nicolas Borderies
% email address: nico.borderies@gmail.com 
% April 2016; Last revision: June 2017

%% Configuration
% -----------------------------------------------
optionList = {'fullscreen','list','random_item','random_test'};
inputList = varargin;
taskName = 'psychometry';
fullscreen=1;
list={'NORRIS',...
      'POMS'};
random_item=0;
random_test=0;
set_psychometry_configuration;

displayOption.win = display.window;
displayOption.bound =Screen('Rect', display.window );
displayOption.screenX=displayOption.bound(3)-displayOption.bound(1);
displayOption.screenY=displayOption.bound(4)-displayOption.bound(2);
displayOption.centerX=displayOption.bound(1)+displayOption.screenX/2;
displayOption.centerY=displayOption.bound(2)+displayOption.screenY/2;
displayOption.monitorFlipInterval=Screen('GetFlipInterval', displayOption.win);
Priority(MaxPriority(displayOption.win)); 
Screen('Preference', 'TextAntiAliasing', 2);
Screen('FillRect',displayOption.win,[0 0 0]); 
Screen('TextSize', displayOption.win , 30); 
Screen('TextFont', displayOption.win, 'Helvetica');

%% Test preparation
% ----------------------------------------------

% Load stimuli
%__________________________________________________________________________

% Load Image
for iList = 1:numel(list)
    test_name = list{iList};
    aga=imread([psychodir filesep  'stuff' filesep 'instructions' test_name '.bmp']);
    listImage.psychometry.(['instruction' test_name ])=Screen('MakeTexture',displayOption.win,aga);
end

aga=imread([psychodir filesep  'stuff' filesep 'arrow3.bmp']);
listImage.psychometry.arrow=Screen('MakeTexture',displayOption.win,aga);
aga=imread([psychodir filesep  'stuff' filesep 'case.bmp']);
listImage.psychometry.case=Screen('MakeTexture',displayOption.win,aga);
aga=imread([psychodir filesep  'stuff' filesep 'caseV.bmp']);
listImage.psychometry.caseV=Screen('MakeTexture',displayOption.win,aga);
 

% Load psychometry stuff
for iList = 1:numel(list)
    test_name = list{iList};
    switch test_name
        case {'POMS','IMI'}
            try
                aga=struct;
                aga.([test_name '_Q' ]) = table2cell(readtable([ test_name '.xlsx'],'Sheet',1,'ReadVariableNames',0));
                aga.([test_name '_R' ]) = table2cell(readtable([ test_name '.xlsx'],'Sheet',2,'ReadVariableNames',0));
            catch
                aga = load ([psychodir filesep 'stuff' filesep test_name '.mat']);
            end
        otherwise
            aga = load ([psychodir filesep 'stuff' filesep test_name '.mat']);
    end
    psychometryStuff.(test_name).listQuestion = aga.([test_name '_Q' ]);
    psychometryStuff.(test_name).listAnswer = aga.([test_name '_R' ]);
end


%% Testing
%-----------------------------------------------

if random_test
    random_list = list(randperm(numel(list)));
else
    random_list = list;
end
data.testList = random_list;

for iList = 1:numel(list)
    test_name = random_list{iList};
    aga.instruction=listImage.psychometry.(['instruction' test_name ]);
    aga.listQuestion=psychometryStuff.(test_name).listQuestion;
    aga.listAnswer=psychometryStuff.(test_name).listAnswer;
    nItems = max([size(aga.listQuestion,1),size(aga.listAnswer,1)]);
    if random_item
        if numel(aga.listQuestion)~=1
            permutation = randperm(numel(aga.listQuestion));
            aga.listQuestion = aga.listQuestion(permutation) ;
        else
            permutation = randperm(size(aga.listAnswer,1));
            aga.listAnswer = aga.listAnswer(permutation,:)  ;
        end
        if size(aga.listQuestion,1)==size(aga.listAnswer,1)
            aga.listAnswer = aga.listAnswer(permutation,:)  ;
        elseif size(aga.listQuestion,1)==size(aga.listAnswer,2)
            aga.listAnswer = aga.listAnswer(:,permutation)  ;
        end
    else
        permutation = [1:nItems];
    end
    data.psychometry.(test_name).permutation = permutation;
    
    switch test_name
        case {'NORRIS','CUSTOM_EVA'} % EVA - response format
            scaleOption.arrow.image=listImage.psychometry.arrow;
            scaleOption.nBar=21;          % For mood and confidence ratings, the scale is divided in nBar possible answers
            scaleOption.arrow.y = -1/8;    % Position of the arrow (in % of screen), the 0 is the position of the scale (should be in dimension option but kept for compatibility)
            scaleOption.arrow.size = 1/50; % SIze of the arrow
            scaleOption.lVisibleBar=[];
            questionOption.y = 0.25;
            scaleOption.y = 0.75;    
            questionOption.labelY=0.8;
            data.psychometry.(test_name).responses = askEVA(aga,questionOption,displayOption, scaleOption, key);
        otherwise % multiple choice - response format
            aga.caseN=listImage.psychometry.case;
            aga.caseV=listImage.psychometry.caseV;
            data.psychometry.(test_name).responses = askPsychometricScale(aga , displayOption, key );
    end
    data.psychometry.(test_name).result =  data.psychometry.(test_name).responses;
    data.psychometry.(test_name).result(permutation) =  data.psychometry.(test_name).responses;
    KbReleaseWait;
end


%% Scoring
%-----------------------------------------------
 
% POMS
if  ismember('POMS',list)
    data.psychometry.POMS.Anxiety = sum(data.psychometry.POMS.result([2 10 16 20 26 27 34 41]) - 1 ) +  sum(5-data.psychometry.POMS.result([22]));
    data.psychometry.POMS.Anger = sum(data.psychometry.POMS.result([3 12 17 24 31 33 39 42 47 52 53 57]) - 1 ) ;
    data.psychometry.POMS.Confusion = sum(data.psychometry.POMS.result([8 28 37 50 59 64]) - 1 ) +  sum(5-data.psychometry.POMS.result([54]));
    data.psychometry.POMS.Depression = sum(data.psychometry.POMS.result([5 9 14 18 21 23 32 35 36 44 45 48 58 61 62]) - 1 );
    data.psychometry.POMS.Fatigue = sum(data.psychometry.POMS.result([4 11 29 40 46 49 65]) - 1 ) ;
    data.psychometry.POMS.Vigor = sum(data.psychometry.POMS.result([7 15 19 38 51 56 60 63]) - 1 ) ;
    data.psychometry.POMS.Interpersonal = sum(data.psychometry.POMS.result([1 6 13 25 30 43 55]) - 1 );
    data.psychometry.POMS.Global = sum([ data.psychometry.POMS.Anxiety, data.psychometry.POMS.Anger, data.psychometry.POMS.Confusion,...
                                         data.psychometry.POMS.Depression, data.psychometry.POMS.Fatigue ]) -  data.psychometry.POMS.Vigor;
end

% BFI
if  ismember('BFI',list)
    data.psychometry.BFI.OCEAN(1)=(sum(data.psychometry.BFI.result([5 10 15 20 25 30 40 44]))+ sum(6-data.psychometry.BFI.result([35 41])))/10;
    data.psychometry.BFI.OCEAN(2)=(sum(data.psychometry.BFI.result([3 13 28 33 38]))+ sum(6-data.psychometry.BFI.result([8 18 23 43])))/9;
    data.psychometry.BFI.OCEAN(3)=(sum(data.psychometry.BFI.result([1 11 16 26 36]))+ sum(6-data.psychometry.BFI.result([6 21 31])))/8;
    data.psychometry.BFI.OCEAN(4)=(sum(data.psychometry.BFI.result([7 17 22 32 42]))+ sum(6-data.psychometry.BFI.result([2 12 27 37 45])))/10;
    data.psychometry.BFI.OCEAN(5)=(sum(data.psychometry.BFI.result([4 14 19 29 39]))+ sum(6-data.psychometry.BFI.result([9 24 34])))/8;
end

% BIS
if  ismember('BIS',list)
    data.psychometry.BIS.BAS_drive=sum(5-data.psychometry.BIS.result([3 9 12 21]));
    data.psychometry.BIS.BAS_funSeeking= sum(5-data.psychometry.BIS.result([5 10 15 20]));
    data.psychometry.BIS.BAS_rewardResponsiveness= sum(5-data.psychometry.BIS.result([4 7 14 18 23]));
    data.psychometry.BIS.BIS= sum(5-data.psychometry.BIS.result([8 13 16 19 24]))+sum(data.psychometry.BIS.result([2 22])); % BIS
    data.psychometry.BIS.normalized.BAS_drive=data.psychometry.BIS.BAS_drive/4;
    data.psychometry.BIS.normalized.BAS_funSeeking=data.psychometry.BIS.BAS_funSeeking/4;
    data.psychometry.BIS.normalized.BAS_rewardResponsiveness=data.psychometry.BIS.BAS_rewardResponsiveness/5;
    data.psychometry.BIS.normalized.BIS=data.psychometry.BIS.BIS/7;
end

% BARATT
if  ismember('BARATT',list)
    data.psychometry.BARATT.total = sum(data.psychometry.BARATT.result);
    data.psychometry.BARATT.BARATT_motor = sum(data.psychometry.BARATT.result([2 3 4 16 17 19 21 22 23 25 30]));
    data.psychometry.BARATT.BARATT_cognitive = sum(data.psychometry.BARATT.result([5 6 9 11 20 24 26 28]));
    data.psychometry.BARATT.BARATT_planification = sum(data.psychometry.BARATT.result([1 7 8 10 12 13 14 15 18 27 29]));
end

% STARKSTEIN
if  ismember('STARKSTEIN',list)
    data.psychometry.STARKSTEIN.total = sum(4-data.psychometry.STARKSTEIN.result([1:8])) + sum(data.psychometry.STARKSTEIN.result([9:14])-1);
end

% LAY
if  ismember('LAY',list)
    data.psychometry.LAY.total = sum(data.psychometry.LAY.result([1 2 5 7 9 10 12 16 17 19])) + sum(6-data.psychometry.LAY.result([3 4 6 8 11 13 14 15 18 20]));
end

% HAD
if  ismember('HAD',list)
    data.psychometry.HAD.total = sum(data.psychometry.HAD.result);
    data.psychometry.HAD.anxietyScore = sum(data.psychometry.HAD.result([1:7]));
    data.psychometry.HAD.depressionScore = sum(data.psychometry.HAD.result([8:14]));
end

% IMI
if  ismember('IMI',list)
    data.psychometry.IMI.total = sum(data.psychometry.IMI.result([1 3:8 10 12 13 15:18 20 22])) +  sum(8-data.psychometry.IMI.result([2 9 11 14 19 21]));
    data.psychometry.IMI.Interest = sum(data.psychometry.IMI.result([1 5 8 10 17 20])) +  sum(8-data.psychometry.IMI.result([14])) ;
    data.psychometry.IMI.SelfCompetence = sum(data.psychometry.IMI.result([4 7 12 16 22]))  ;
    data.psychometry.IMI.SelfDetermination = sum(data.psychometry.IMI.result([3 15])) +  sum(8-data.psychometry.IMI.result([11 19 21])) ;
    data.psychometry.IMI.Pressure = sum(data.psychometry.IMI.result([6 13 18])) +  sum(8-data.psychometry.IMI.result([2 9])) ;
end



%% Save data
%__________________________________________________________________________

Screen('CloseAll');


cd(subdir);
psychometry = data.psychometry;
save(resultname,'subid','nsession','psychometry');
cd(psychodir);

clc;

end

