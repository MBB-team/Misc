function [scaleDim, xBar] = displayScale( wPtr,screenXY, scaleOption )

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

%% Plot main line
Screen('DrawLine',wPtr,scaleOption.color,scaleDim(1),scaleDim(2), scaleDim(3), scaleDim(4), scaleOption.e);
scaleDim(2)= scaleDim(2)-scaleOption.h*Y;
scaleDim(4)= scaleDim(4)+scaleOption.h*Y;
scaleDim(5)=scaleDim(3)-scaleDim(1);

%% Plot bars & labels
for iBar = 1:scaleOption.nBar
    xBar(iBar)= scaleDim(1) + scaleDim(5) * (iBar-1)/ (scaleOption.nBar-1);
    if isVisibleBar(iBar) == 1
        Screen('DrawLine',wPtr,scaleOption.color,xBar(iBar),scaleDim(2),xBar(iBar),scaleDim(4), scaleOption.e);
    end
    textBox = [xBar(iBar)-X, screenXY(2) + Y * scaleOption.labelY  - Y,  xBar(iBar)+X, screenXY(2) + Y * scaleOption.labelY + Y];
    DrawFormattedText(wPtr, double(scaleOption.label{iBar}), 'center', 'center', scaleOption.color, [], [], [], [], [],textBox);
end

%% Plot arrow

if scaleOption.arrow.visible ==1
    if ~isfield(scaleOption.arrow, 'size')
        scaleOption.arrow.size = 1/20;
    end
    [scaleOption.arrow.X,scaleOption.arrow.Y] = RectSize(Screen('Rect',scaleOption.arrow.image));
    sizeRatio = scaleOption.arrow.Y/scaleOption.arrow.X;
    scaleOption.arrow.X=X*scaleOption.arrow.size;
    scaleOption.arrow.Y=scaleOption.arrow.X*sizeRatio;
    xArrow= scaleDim(1) + scaleDim(5) * (scaleOption.arrow.position-1)/ (scaleOption.nBar-1);
    arrowBox= [xArrow-scaleOption.arrow.X/2,  scaleDim(4) + scaleOption.arrow.y * Y, xArrow+scaleOption.arrow.X/2,  scaleDim(4) + scaleOption.arrow.y * Y+scaleOption.arrow.Y];
    Screen('DrawTexture',wPtr,scaleOption.arrow.image, [], arrowBox);
end
