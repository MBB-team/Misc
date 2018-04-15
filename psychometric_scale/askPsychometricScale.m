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
    % key.back is an optionnal field allowing to get back to the previous question

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

 isGoBackAllowed 
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

caseXYD=[3/8*centerX 3/4*centerY, centerY/20];
nQuestion=size(stuff.listQuestion,1);
nAnswer=size(stuff.listAnswer,1);
changeAnswer = (size(stuff.listAnswer,2)>=2);
iQ=1;

while iQ <= nQuestion
    cQ=Sample(1:nAnswer);
    isCancelQuestion = 0;
    while ((KeyCode(key.valid) == 0));
        Screen('FillRect',displayOption.win,miscOption.color.back, displayOption.screenXY);
        text= [stuff.listQuestion{iQ}];
        DrawFormattedText(displayOption.win, double(text), 1/16*centerX, 1/2*centerY, miscOption.color.text);
        %DrawFormattedText(displayOption.win, double(text), 'center', 1/2*centerY, miscOption.color.text);
        for iA=1:nAnswer
            caseBox = [caseXYD(1), caseXYD(2) + (iA-1)*2*caseXYD(3), caseXYD(1)+caseXYD(3), caseXYD(2)+(1+(iA-1)*2)*caseXYD(3)];
            Screen('DrawTexture',displayOption.win,stuff.caseN, [],  caseBox);
            if changeAnswer
                text = double(stuff.listAnswer{iA,iQ});
            else
                text = double(stuff.listAnswer{iA});
            end
            
            sx = caseBox(3) + caseXYD(3);
            sy = caseBox(4);
            
            DrawFormattedText(displayOption.win, text, sx,sy,miscOption.color.text, 60);
           
        end
        Screen('DrawTexture',displayOption.win,stuff.caseV, [], [caseXYD(1), caseXYD(2)+((cQ-1)*2)*caseXYD(3), caseXYD(1)+caseXYD(3), caseXYD(2)+((cQ-1)*2+1)*caseXYD(3)] );

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

