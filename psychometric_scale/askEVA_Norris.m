function [ norris ] = askEVA_Norris( stuff , displayOption, scaleOption, key )

%% This function launch EVA Norris 

% Stuff is a structure containing:
    % instruction : the index of instruction image
    % listItem : a cell with one lign per pair of items
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

if ~isfield(displayOption, 'screenXY')
displayOption.screenXY=Screen(displayOption.win,'Rect');
end

if ~isfield(scaleOption.arrow, 'y')
    scaleOption.arrow.y = -1/10; % position of the arrow, relative to the scale (expressed in proportion of screen height)
end


% Instructions EVA Norris
Screen('DrawTexture',displayOption.win,stuff.instruction, [], displayOption.bound);
Screen(displayOption.win, 'Flip');
waitForKey(responseOption.key.space);

% Perform EVA norris
questionOption.question='En ce moment, je me sens';
    
for iQuestion = 1:length(stuff.listItem);
    questionOption.label=stuff.listItem(iQuestion,:);
    norris(iQuestion)=askQuestion(questionOption, displayOption, scaleOption, responseOption);
end


end

