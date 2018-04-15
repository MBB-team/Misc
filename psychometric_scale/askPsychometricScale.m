function [ recScale ] = askPsychometricScale(  stuff , displayOption, key, miscOption )
%% This is a generic function to perform a psychometric scale

% Stuff is a structure containing:
    % instruction : the index of instruction image
    % listQuestion : cell object containing question
    % listAnswer : cell object containing possible answers
    % caseN/caseV : index of images for cases
% displayOption
    % win : index of the display window
% key (or key.key)
    % Required fields are up, down and valid
    % key.back is an optionnal key allowing to get back to the previous question

%% For compatibility
if ~isfield(key, 'key')
    responseOption.key=key;
else
    responseOption=key;
end   

if isfield(responseOption.key, 'back')
   isGoBackAllowed = 1;
else
    isGoBackAllowed = 0;
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
catch
miscOption.color.text=[255 255 255];
end

%% Instructions
Screen('DrawTexture',displayOption.win,stuff.instruction, [], displayOption.bound);
Screen(displayOption.win, 'Flip');
waitForKey(responseOption.key.space);
 
%% Perform scale
KbReleaseWait;
[k, timedown, KeyCode, d] = KbCheck;

caseXYD=[1/16*centerX 3/4*centerY, centerY/20];
nQuestion=size(stuff.listQuestion,1);

if any(size(stuff.listAnswer) == 1) % Same answers for all question
    if size(stuff.listAnswer, 1) == 1
        listAnswer = repmat(stuff.listAnswer, nQuestion, 1);
    else
        listAnswer = repmat(stuff.listAnswer', nQuestion, 1);
    end
else
    if size(stuff.listAnswer, 1) == nQuestion
        listAnswer  = stuff.listAnswer;
    else
        listAnswer  = stuff.listAnswer';
    end
end

assert(size(listAnswer,1) == nQuestion, 'Wrong number of answers');
iQ=1;

%% Get maximal number of character per lign
% That's quite stupid but I don't know how to get that info with psychotoolbow...
isMax = 0;
nMaxCharacter = 1;
while isMax == 0
    [~, ~, bounds] =DrawFormattedText(displayOption.win, repmat('o',1, nMaxCharacter), caseXYD(1)+2*caseXYD(3), 1/2*centerY, miscOption.color.text);
    if bounds(3) < displayOption.screenXY(3)
        nMaxCharacter = nMaxCharacter+1;
    else
        isMax = 1;
    end
end

% Screen(displayOption.win, 'Flip');
% pause

while iQ <= nQuestion
    answer = listAnswer(iQ,:);
    answer = answer(~cellfun(@isempty, answer));
    nAnswer = length(answer);
    cQ=Sample(1:nAnswer);
    isCancelQuestion = 0;
    while ((KeyCode(key.valid) == 0));
        Screen('FillRect',displayOption.win,miscOption.color.back, displayOption.screenXY);
        text= [stuff.listQuestion{iQ}];
        [nx, ny]= DrawFormattedText(displayOption.win, double(text), 1/16*centerX, 1/2*centerY, miscOption.color.text, nMaxCharacter);
        %DrawFormattedText(displayOption.win, double(text), 'center', 1/2*centerY, miscOption.color.text);
        
        shift = max( caseXYD(2), ny + 4*caseXYD(3));
        for iA=1:nAnswer
            caseBox = [caseXYD(1), shift , caseXYD(1)+caseXYD(3), shift + caseXYD(3)];
            if iA == cQ
                Screen('DrawTexture',displayOption.win,stuff.caseV, [],  caseBox);
            else
                Screen('DrawTexture',displayOption.win,stuff.caseN, [],  caseBox);
            end
            text = double(answer{iA});
            sx = caseBox(3) + caseXYD(3);
            sy = caseBox(4) - caseXYD(3)/4;
            [nx, ny] =DrawFormattedText(displayOption.win, text, sx,sy,miscOption.color.text, nMaxCharacter);
            shift = ny + 1.5* caseXYD(3);
        end

        if (KeyCode(key.up) == 1)
            cQ=(cQ>1)*(cQ-1)+(cQ==1);
            KbReleaseWait;
        end
        if (KeyCode(key.down) == 1)
            cQ=(cQ<nAnswer)*(cQ+1)+nAnswer*(cQ==nAnswer);
            KbReleaseWait;
        end

        [k, timedown, KeyCode, d] = KbCheck;
        
        if isGoBackAllowed == 1
             if (KeyCode(key.back) == 1)
                 isCancelQuestion = 1;
                 KbReleaseWait;
             end
        end
        Screen(displayOption.win, 'Flip');
    end
    

        
    KbReleaseWait;
    KeyCode=KeyCode*0;
    recScale(iQ)=cQ;
    
    if isGoBackAllowed == 1 & isCancelQuestion  ==1 
        iQ = max(1, iQ-1);
    else
        iQ = iQ+1;
    end
    
    
end



    
end

