function [ result, orderQuestion ] = askEVA( stuff ,questionOption, displayOption, scaleOption, key, miscOption )

%% This function launch EVA scales 

% Stuff is a structure containing:
    % instruction : the index of instruction image
    % listAnswer : a cell with one lign per pair of items
% displayOption
    % win : index of the display window
% key (or key.key)
    % Required fields are left, right and valid
% scaleOption
    % arrow.image : index of the image for arrow
    % nBar : actual n of bars of the index
    % lVisibleBar : vector of visible bars (between 0 & 1)
    
% compatibility
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


if ~isfield(scaleOption.arrow, 'y')
    scaleOption.arrow.y = -1/10; % position of the arrow, relative to the scale (expressed in proportion of screen height)
end

if ~isfield(displayOption, 'screenXY')
    displayOption.screenXY=Screen(displayOption.win,'Rect');
end

try
    miscOption.isRandomizeQuestionOrder;
catch
    miscOption.isRandomizeQuestionOrder = 0;
end


% Instructions 
Screen('DrawTexture',displayOption.win,stuff.instruction, [], displayOption.bound);
Screen(displayOption.win, 'Flip');
waitForKey(responseOption.key.space);

ShowCursor();

if size(stuff.listAnswer, 1) == 1
    stuff.listAnswer = repmat(stuff.listAnswer, length(stuff.listQuestion), 1);
end

nQuestion = length(stuff.listQuestion);
if miscOption.isRandomizeQuestionOrder ==1;
    orderQuestion = randperm(nQuestion);
else
    orderQuestion = 1:nQuestion;
end


% Perform EVA 
iQuestion = 1;
while iQuestion <= nQuestion
    
    if miscOption.isRandomizeQuestionOrder ==1;
        currentQuestion =  orderQuestion(iQuestion);
    else
        currentQuestion = iQuestion;
    end
    
    
    
    questionOption.question = stuff.listQuestion{currentQuestion};
    questionOption.label=stuff.listAnswer(currentQuestion,:);
    result(currentQuestion)=askQuestion(questionOption, displayOption, scaleOption, responseOption);
    
    if result(currentQuestion).isCancelQuestion ==1
        iQuestion = max(1, iQuestion -1);
    else
        iQuestion = iQuestion +1;
    end
end


end

