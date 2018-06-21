function [scaleBox, scaleDim, xBar] = displayScaleTactile( wPtr,screenXY, scaleOption, rating , target )

%% Fill empty fields
if ~isfield(scaleOption, 'color')
    scaleOption.color = [255 255 255];
end

if ~isfield(scaleOption,'wBound')
    scaleOption.wBound=[0.2 0.8];
end

if ~isfield(scaleOption,'labelY')
    scaleOption.labelY=.65;
end


if ~isfield(scaleOption,'y') % position of the scale
    scaleOption.y=0.5;
end

if ~isfield(scaleOption,'e') % Width of the scale
    scaleOption.e=2;
end

if ~isfield(scaleOption,'h')
    scaleOption.h= 1/40;
end

try 
    scaleOption.arrow.y;
catch
    scaleOption.arrow.y = 2*scaleOption.h;
end


isVisibleBar = zeros(1, scaleOption.nBar);
if isfield(scaleOption,'lVisibleBar')
    isVisibleBar(scaleOption.lVisibleBar) = 1;
else
    if isfield(scaleOption,'label')
        isVisibleBar(~cellfun(@isempty,scaleOption.label))=1;
    else
        isVisibleBar(1, scaleOption.nBar) = 1;
    end
end


if isfield(scaleOption,'arrow')
    scaleOption.arrow.visible = 1;
else
    scaleOption.arrow.visible = 0;
end


%% Compute dim

X=screenXY(3)-screenXY(1);
Y=screenXY(4)-screenXY(2);
x0 = screenXY(1);
y0 = screenXY(2);

scaleDim=[...
    x0+scaleOption.wBound(1)*X,...
    y0+scaleOption.y*Y,...
    x0+scaleOption.wBound(2)*X,...
    y0+scaleOption.y*Y];

scaleDim(5)=scaleDim(3)-scaleDim(1);

%% Display discrete response fields
wBox = scaleDim(5) / (scaleOption.nBar);

if isfield(scaleOption, 'graphicScale');
    hBox = (scaleDim(5) * scaleOption.graphicScale.ratio)/2;
else
    hBox = wBox/2;
end
scaleBox= [scaleDim(1) scaleDim(2)-hBox scaleDim(3) scaleDim(2)+hBox];

if isfield(scaleOption.graphicScale, 'texture');
    Screen('DrawTexture',wPtr,scaleOption.graphicScale.texture, [], scaleBox);
else  
    for iBox = 1:scaleOption.nBar
        box = [scaleDim(1)+(iBox-1)*wBox scaleDim(2)-hBox scaleDim(1)+(iBox)*wBox scaleDim(2)+hBox];
        if isVisibleBar(iBox) == 1
            Screen('FrameRect', wPtr,scaleOption.color, box, scaleOption.e);
        else
            Screen('DrawLine', wPtr,scaleOption.color,box(1), mean([box(2),box(4)]), box(3),  mean([box(2),box(4)]) ,scaleOption.e);
        end
        xBar = (box(3) + box(1))/2;
        textBox = [xBar-X, screenXY(2) + Y * scaleOption.labelY  - Y,  xBar+X, screenXY(2) + Y * scaleOption.labelY + Y];
        DrawFormattedText(wPtr, double(scaleOption.label{iBox}), 'center', 'center', scaleOption.color, [], [], [], [], [],textBox);
    end
end

%% Display confirmed response
if ~isempty(rating)
    iRating = sum(rating >= (linspace(0, 101, scaleOption.nBar+1)));
    box = [scaleDim(1)+(iRating-1)*wBox scaleDim(2)-hBox scaleDim(1)+(iRating)*wBox scaleDim(2)+hBox];
    xCrossLine = [scaleDim(1)+rating/100*wBox*scaleOption.nBar];
    if any(isVisibleBar) == 1
        Screen('FillRect', wPtr,[0 255 0], box);
    else
        Screen('DrawLine', wPtr,[0 255 0],xCrossLine, box(2), xCrossLine, box(4) ,scaleOption.e);
    end
end

%% display target
if nargin>4
   targetsize = wBox;
   iTarget = round(target*(ngrad-1)/100) + 1;
   box = [scaleDim(1)+(iTarget-1)*wBox scaleDim(2)-hBox scaleDim(1)+(iTarget)*wBox scaleDim(2)+hBox];
   Screen('FrameRect', wPtr,[0 255 0], box, scaleOption.e);
   Screen('DrawLine',  wPtr,[0 255 0], box(1)-targetsize, scaleDim(2),  box(1), scaleDim(2),scaleOption.e);
   Screen('DrawLine',  wPtr,[0 255 0], box(3), scaleDim(2),  box(3)+targetsize, scaleDim(2),scaleOption.e);
   Screen('DrawLine',  wPtr,[0 255 0], (box(1)+box(3))/2, box(2)-targetsize,  (box(1)+box(3))/2, box(2),scaleOption.e);
   Screen('DrawLine',  wPtr,[0 255 0], (box(1)+box(3))/2, box(4),  (box(1)+box(3))/2, box(4)+targetsize,scaleOption.e);
end

scaleBox= [scaleDim(1) scaleDim(2)-hBox scaleDim(3) scaleDim(2)+hBox];
