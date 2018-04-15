function [logAnswer] = askQuestion2( questionOption, displayOption, scaleOption, responseOption )
%% This function print a question and allow to answer through a scale / a cursor
% Various display options are provided


    %% Fill empty fields 
    
    responseOption.t0 = GetSecs;
    logAnswer.t0=responseOption.t0;
    if ~isfield(responseOption, 'maxTime')
        responseOption.maxTime = Inf;
        
    end
     
    if ~isfield(responseOption, 'timeBlock')
         responseOption.timeBlock = 0.1;
    end
    
    if ~isfield(questionOption, 'y')
        questionOption.y=0.1;
    end
    
    if ~isfield(scaleOption,'wBound')
    scaleOption.wBound=[0.2 0.8];
    end
    
    if ~isfield(questionOption,'question')
        questionOption.question={''};
    end
    
    if ~isfield(questionOption,'label')
        questionOption.label= cell(1, scaleOption.nBar);
    end
    
    if ~isfield(questionOption, 'labelY')
        questionOption.labelY=0.65;
    end

    if ~isfield(scaleOption, 'color')
        scaleOption.color=[255 255 255];
    end
    
    % Compatibility
   
    if isfield(responseOption, 'key')
        key=responseOption.key;
    else
        key=responseOption;
    end
    
    if ~isfield(displayOption, 'screenXY')
        displayOption.screenXY=Screen(displayOption.win,'Rect');
    end
    
    logAnswer.timePress=[];
    logAnswer.sidePress=[];
    logAnswer.nPress = 0;
    logAnswer.timeFirstPress = NaN;
    logAnswer.RT = NaN;
    logAnswer.finalPosition=NaN;
    
    
    
    %% transform label
    scaleOption.label = cell(1, scaleOption.nBar);
    if length(questionOption.label) == scaleOption.nBar
          scaleOption.label = questionOption.label;
    else
        if isfield(questionOption,'labelX')
            scaleOption.label(questionOption.labelX) = questionOption.label;
        else
            labelX = round(linspace(1, scaleOption.nBar, length(questionOption.label)));
            scaleOption.label(labelX) = questionOption.label;
        end
    end
    
    %% Set Things
    x0 = displayOption.screenXY(1);
    y0 = displayOption.screenXY(2);
    X=displayOption.screenXY(3)-displayOption.screenXY(1);
    Y=displayOption.screenXY(4)-displayOption.screenXY(2);
    
    isAnswer = 0;
    iCurseur = Sample(1:scaleOption.nBar);
    logAnswer.initialPosition=iCurseur;
    
    %% Print question until answer
    
    while (GetSecs < (responseOption.t0 + responseOption.maxTime)) & isAnswer ==0
        
        %% Get input and move cursor
         [k, timePress, KeyCode, d] = KbCheck(-1);
        if (KeyCode(key.left) == 1)
            iCurseur=max(1,iCurseur-1);
            logAnswer.timePress(end+1)=timePress;
            logAnswer.sidePress(end+1)=-1;
            %KbReleaseWait([],logAnswer.timePress(end)+responseOption.timeBlock);
            WaitSecs(responseOption.timeBlock);
        end
        if (KeyCode(key.right) == 1)
            iCurseur=min(scaleOption.nBar,iCurseur+1);
            logAnswer.timePress(end+1)=timePress;
            logAnswer.sidePress(end+1)=1;
            %KbReleaseWait([],logAnswer.timePress(end)+responseOption.timeBlock);
            WaitSecs(responseOption.timeBlock);
        end   
         
        %% Get validation
        
        if (KeyCode(key.valid) == 1)
            isAnswer=1;
            logAnswer.timePress(end+1)=timePress;
            logAnswer.sidePress(end+1)=2;
            logAnswer.nPress = length(logAnswer.sidePress);
            logAnswer.timeFirstPress = logAnswer.timePress(1) - responseOption.t0;
            logAnswer.RT = logAnswer.timePress(end) - responseOption.t0;
            logAnswer.finalPosition=iCurseur;
            KbReleaseWait(-1);
        end
        
        
        %% Get maximal number of character per lign
        % That's quite stupid but I don't know how to get that info with psychotoolbow...
        isMax = 0;
        nMaxCharacter = 1;
        while isMax == 0
             [~, ~, bounds] =DrawFormattedText(displayOption.win, repmat('o',1, nMaxCharacter), 'center', 'center');
             if bounds(3) < displayOption.screenXY(3)
                nMaxCharacter = nMaxCharacter+1;
             else
                isMax = 1;
             end
        end
        
        %% This line should be changed...
        Screen('FillRect',displayOption.win,255 - scaleOption.color, displayOption.screenXY);
        
        %% Print question
        DrawFormattedText(displayOption.win, double(questionOption.question), 'center', y0 + questionOption.y * Y, scaleOption.color, nMaxCharacter);
        
        %% Print scale
        scaleOption.arrow.position=iCurseur;
        scaleOption.labelY = questionOption.labelY;
        displayScale(displayOption.win, displayOption.screenXY, scaleOption);
        Screen(displayOption.win, 'Flip');
    end
    
    logAnswer.currentPosition=iCurseur;
    logAnswer.FinalPercentage=(iCurseur-1) / (scaleOption.nBar-1);
    
    if (GetSecs > (responseOption.t0 + responseOption.maxTime)) & isfield(responseOption, 'tooLateFeedback')
        DrawFormattedText(displayOption.win, responseOption.tooLateFeedback.feedback, 'center', 'center', scaleOption.color);
        vbl=Screen(displayOption.win, 'Flip');
        Screen(displayOption.win, 'Flip', vbl + responseOption.tooLateFeedback.duration);
    end
    
    