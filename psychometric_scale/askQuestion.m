function [logAnswer] = askQuestion( questionOption, displayOption, scaleOption, responseOption )
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
        questionOption.label={'', ''};
    end
    
    if ~isfield(questionOption, 'labelY')
        questionOption.labelY=0.65;
    end

    if isfield(questionOption, 'labelScale')
        scaleOption.label=questionOption.labelScale;
    end
    
    if ~isfield(questionOption, 'labelX')
        questionOption.labelX=scaleOption.wBound;
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
    
    
    
    %% Set Things
    x0 = displayOption.screenXY(1);
    y0 = displayOption.screenXY(2);
    X=displayOption.screenXY(3)-displayOption.screenXY(1);
    Y=displayOption.screenXY(4)-displayOption.screenXY(2);
    
    isAnswer = 0;
    iCurseur = round(((scaleOption.nBar-1)/4))+randi(1+round((scaleOption.nBar-1)/2));
    logAnswer.initialPosition=iCurseur/scaleOption.nBar;
    
    %% Print question until answer
    
    while (GetSecs < (responseOption.t0 + responseOption.maxTime)) & isAnswer ==0
        
        %% Get input and move cursor
         [k, timePress, KeyCode, d] = KbCheck(-1);
        if (KeyCode(key.left) == 1)
            iCurseur=max(0,iCurseur-1);
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
            logAnswer.finalPosition=iCurseur/scaleOption.nBar;
            KbReleaseWait(-1);
        end
        
        

        %% Print question & labels
        DrawFormattedText(displayOption.win, questionOption.question, 'center', y0 + questionOption.y * Y, scaleOption.color);
        labelBox=[x0 + questionOption.labelX(1)*X-X, y0 + questionOption.labelY * Y - Y, x0 + questionOption.labelX(1)*X+X, y0 + questionOption.labelY * Y + Y];
        DrawFormattedText(displayOption.win, questionOption.label{1}, 'center', 'center', scaleOption.color,[],[],[],[],[],labelBox );
        labelBox=[x0 + questionOption.labelX(2)*X-X, y0 + questionOption.labelY * Y - Y, x0 + questionOption.labelX(2)*X+X, y0 + questionOption.labelY * Y + Y];
        DrawFormattedText(displayOption.win, questionOption.label{2}, 'center', 'center', scaleOption.color,[],[],[],[],[],labelBox );
        
        
        %% Print scale
        scaleOption.arrow.position=iCurseur/scaleOption.nBar;
        displayScale(displayOption.win, displayOption.screenXY, scaleOption);
        Screen(displayOption.win, 'Flip');
    end
    
    logAnswer.currentPosition=iCurseur/scaleOption.nBar;
    
    if (GetSecs > (responseOption.t0 + responseOption.maxTime)) & isfield(responseOption, 'tooLateFeedback')
        DrawFormattedText(displayOption.win, responseOption.tooLateFeedback.feedback, 'center', 'center', scaleOption.color);
        vbl=Screen(displayOption.win, 'Flip');
        Screen(displayOption.win, 'Flip', vbl + responseOption.tooLateFeedback.duration);
    end
    
    