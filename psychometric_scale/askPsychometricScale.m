function [ recScale, orderQuestion ] = askPsychometricScale(  stuff , displayOption, key, miscOption )
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

try
    miscOption.isRandomizeQuestionOrder;
catch
    miscOption.isRandomizeQuestionOrder = 0;
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

if miscOption.isRandomizeQuestionOrder ==1;
    orderQuestion = randperm(nQuestion);
else
    orderQuestion = 1:nQuestion;
end



while iQ <= nQuestion
    
    if miscOption.isRandomizeQuestionOrder ==1;
        currentQ =  orderQuestion(iQ);
    else
        currentQ = iQ;
    end
    
    answer = listAnswer(currentQ,:);
    answer = answer(~cellfun(@isempty, answer));
    nAnswer = length(answer);
    chosenAnswer=Sample(1:nAnswer);
    isCancelQuestion = 0;
    isValidated = 0;
    if displayOption.mouse || displayOption.touch
        displayOption.wait4release;
    end
    
    while ((isValidated == 0))
        Screen('FillRect',displayOption.win,miscOption.color.back, displayOption.screenXY);
        text= [stuff.listQuestion{currentQ}];
        [nx, ny]= DrawFormattedText(displayOption.win, double(text), 1/16*centerX, 1/2*centerY, miscOption.color.text, nMaxCharacter);
        
        if displayOption.mouse || displayOption.touch
            [xMouse,yMouse,buttons] = displayOption.recordResponse(displayOption.win);
        end
        
        shift = max( caseXYD(2), ny + 4*caseXYD(3));
        for iA=1:nAnswer
            caseBox = [caseXYD(1), shift , caseXYD(1)+caseXYD(3), shift + caseXYD(3)];
            
            if displayOption.mouse || displayOption.touch
                if isInsideTheBox([xMouse,yMouse],caseBox) && buttons(1)~=0
                    chosenAnswer = iA;
                    isValidated = 1;
                elseif isValidated==0
                    chosenAnswer = 0; % no pre-selected answer with tactile/mouse version
                end
            end
            
            if iA == chosenAnswer
                Screen('DrawTexture',displayOption.win,stuff.caseV, [],  caseBox);
            else
                Screen('DrawTexture',displayOption.win,stuff.caseN, [],  caseBox);
            end
            text = double(answer{iA});
            sx = caseBox(3) + caseXYD(3);
            sy = caseBox(4) - displayOption.caseYShift*caseXYD(3);
            [nx, ny] =DrawFormattedText(displayOption.win, text, sx,sy,miscOption.color.text, nMaxCharacter);
            shift = ny + 1.5* caseXYD(3);
            
        end

        if ~(displayOption.mouse || displayOption.touch)
            if (KeyCode(key.up) == 1)
                chosenAnswer=(chosenAnswer>1)*(chosenAnswer-1)+(chosenAnswer==1);
                KbReleaseWait;
            end
            if (KeyCode(key.down) == 1)
                chosenAnswer=(chosenAnswer<nAnswer)*(chosenAnswer+1)+nAnswer*(chosenAnswer==nAnswer);
                KbReleaseWait;
            end
            [k, timedown, KeyCode, d] = KbCheck;
            isValidated = KeyCode(key.valid) ;
        else
            [k, timedown, KeyCode, d] = KbCheck;
        end
        
        if isGoBackAllowed == 1
             if (KeyCode(key.back) == 1)
                 isCancelQuestion = 1;
                 KbReleaseWait;
             end
        end
        Screen(displayOption.win, 'Flip');
        if isValidated
            WaitSecs(0.5); % leave time to have feedback on the selected answer
        end
    end
        
    KbReleaseWait;
    KeyCode=KeyCode*0;
    recScale(currentQ)=chosenAnswer;
    
    if isGoBackAllowed == 1 & isCancelQuestion  ==1 
        iQ = max(1, iQ-1);
    else
        iQ = iQ+1;
    end
    
    if iQ == nQuestion +1
        Screen('FillRect',displayOption.win,miscOption.color.back, displayOption.screenXY);
        text= 'Appuyez sur n''importe quelle touche pour continuer.';
        [nx, ny]= DrawFormattedText(displayOption.win, double(text), 'center', 1/2*centerY, miscOption.color.text, nMaxCharacter);
        Screen(displayOption.win, 'Flip');
        while  any(KeyCode) == 0
            [k, timedown, KeyCode, d] = KbCheck;
            if (KeyCode(key.back) == 1)
                iQ = nQuestion;
            end
        end
        KbReleaseWait;
    end
    
end



    
end

