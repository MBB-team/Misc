function [ keepH, keepEB, keepL ] = barplot2( mu, phi, color, legLabel,  barOption, ebOption, gcaOption, gcfOption, legendOption, miscOption)

% This is a wrapper that use terrorbar (thanks to Trevor Agus !) to plot barplot in an easier way
% mu are the values you want to plot
% phi are the size of error bars (set to 0 if not provided)
%       If mu is positive then only upper error bar is drawn
%       If mu is negative then only lower error bar is drawn
% color is a N*3 matrix (default colormap from matlab is used)
%       If N = number of bar in a group (e.g. n columns of mu) one color is used for each bar of a group (default)
%       If N = number of group (e.g. n rows of mu), one color is used for each group
%       Else (for example if only one color is provided): colors are duplicated
% legLabel is a n*1 cell of text used to call the legend fonction (usually, n should be the number of differents colors)
% miscOption is a structure with 3 fields
%       ratioWidth (default = 0.1) is the ratio between the inter-bars space and width of a bar (by default width is automatically adjusted but it could also be force in barOption)
%       intergroupWidth (default = 4) distance between groups (expressed as a number of ratioWidth)
%       errorBarWidth is the width of error bar
% Other arguments are any option you want to apply to your graph (for bars,error bars, gca or gcf)
%       Each field name should match the name of the option such that the command "set(gca, field, gcaOption.(field))" could be applied for gcaOption


% Simplest example:
% a=randn(2, 3); b=abs(a/3); barplot(a, b)

% With color and legend
% a=randn(2, 3); b=abs(a/3); barplot(a, b, [1 0 0; 0 1 0; 0 0 1], {'a', 'b', 'c'})


% Example provided by a completely color-blind guy
% barOption.edgeColor= 'b';
% ebOption.Color= [1, 1, 0];
% gcaOption.LineWidth = 4;
% gcfOption.color='g';
% legendOption.Location='southwest';
% miscOption.ratioWidth=0.2;
% miscOption.intergroupWidth=4;
% a=randn(2, 3); b=abs(a/3); [keepH, keepEB, keepL] = barplot2(a, b , rand(4, 3) , {'a', 'b', 'c', 'd'} ,  barOption, ebOption, gcaOption, gcfOption, legendOption, miscOption)


% Bastien's special one
% gcaOption.FontSize = 50;
% legendOption.FontSize = 50;
% miscOption.errorBarWidth = 0.04;
% legendOption.Location='Best';
% a=randn(2, 3); b=abs(a/3); barplot2(a, b, [0 0 1; 1, 0, 0], {'Group 1', 'Group 2'}, [], [], gcaOption, [], legendOption, miscOption);
%  

%% If no error bars, set to zero
try
    assert(~isempty(phi));
catch
    phi=zeros(size(mu));
end

%% bars and error bars should have the same dimension
[nRow, nCol] = size(mu);
assert(all([nRow, nCol] == size(phi)), 'bars and error bars should have the same dimension');
if nRow == 1
    mu=mu';
    phi=phi';
end
[nRow, nCol] = size(mu);

%% Define default options

if ~exist('color', 'var')
    if nCol ==1
        color= colormap(parula(nRow));
    else
        color= colormap(parula(nCol));
    end
elseif isempty(color)
    if nCol ==1
        color= colormap(parula(nRow));
    else
        color= colormap(parula(nCol));
    end
end

[nColor,~]= size(color);
switch nColor
    case numel(mu);
        FaceColor=color;
    case nCol
        FaceColor = repmat(color,nRow, 1);
    case nRow
        for i=1:nRow
            FaceColor((1:nCol) + (i-1) * nCol,:)=repmat(color(i,:), nCol, 1);
        end
    otherwise
        FaceColor = repmat(color, ceil(numel(mu)/nColor), 1);
end

try 
    miscOption.ratioWidth;
catch
    miscOption.ratioWidth = 0.1;
end

try 
    miscOption.intergroupWidth;
catch
    miscOption.intergroupWidth = 4;
end


try 
    miscOption.errorBarWidth;
catch
    miscOption.errorBarWidth = 0;
end


try
    barOption.BarWidth;
catch
    barOption.barWidth = 1/(nCol + (nCol -1 + 2 * miscOption.intergroupWidth) * miscOption.ratioWidth);
end


try
    gcaOption.FontSize;
catch
    gcaOption.FontSize = 20;
end

try
    gcaOption.LineWidth;
catch
    gcaOption.LineWidth = 2;
end

try
    ebOption.LineWidth;
catch
    ebOption.LineWidth = 1;
end

try
    barOption.LineWidth;
catch
    barOption.LineWidth = ebOption.LineWidth;
end

try
    gcfOption.color;
catch
    gcfOption.color = [1, 1, 1];
end

try
    legendOption.FontSize;
catch
    legendOption.FontSize = 20;
end


%figure


%% Compute X value


for i = 1:nRow
    X(i,:) = linspace(i-0.5 + miscOption.intergroupWidth * miscOption.ratioWidth * barOption.barWidth + barOption.barWidth/2  , i + 0.5 - miscOption.intergroupWidth * miscOption.ratioWidth * barOption.barWidth - barOption.barWidth/2, nCol);
end

X=X';X=X(:);
phi=phi';phi=phi(:);
mu=mu';mu=mu(:);

%% Smart definition of error bars (up if positive data, low instead)
dupPhi(1,:) = phi .* (mu>=0);
dupPhi(2,:) = phi .* (mu<0);

lNewColor=[];
%% Plot the bartplot!
for i=1:numel(mu);
    
    % Draw bar
    h = bar(X(i), mu(i));
    hold on
    
    set(h, 'FaceColor', FaceColor(i,:)) % assign color if defined
    
    isNewColor=~any(all(FaceColor(1:(i-1),:)==repmat(FaceColor(i,:), i-1, 1), 2));
    if isNewColor ==1
        lNewColor = [lNewColor, i];
    end
    
    % And  Set options
    if exist('barOption')
        listField= fieldnames(barOption);
        for iField=1:length(listField)
            field= listField{iField};
            set(h, field, barOption.(field))
        end
    end
    keepH(i)=h;
    
    % Draw error bar
    eb=terrorbar(X(i), mu(i), dupPhi(2,i), dupPhi(1,i), miscOption.errorBarWidth);
    
    % Remove the dirty useless horizontal bar 
    if mu(i)>=0
        set(eb(2), 'Visible', 'off');
    else
        set(eb(3), 'Visible', 'off');
    end
        
    
    
    % and Set options
    listField= fieldnames(ebOption);
    for iField=1:length(listField)
        field= listField{iField};
        set(eb, field, ebOption.(field))
    end
    keepEB{i} = eb;
end

% Draw legend if provided
try
    keepL=legend( keepH(lNewColor), legLabel);

    % and Set options
    listField= fieldnames(legendOption);
    for iField=1:length(listField)
        field= listField{iField};
        set(keepL, field, legendOption.(field))
    end
catch
end


% Set general options
hold off
listField= fieldnames(gcaOption);
for iField=1:length(listField)
    field= listField{iField};
    set(gca, field, gcaOption.(field))
end

listField= fieldnames(gcfOption);
for iField=1:length(listField)
    field= listField{iField};
    set(gcf, field, gcfOption.(field))
end

try
    ylim(gcaOption.ylim)
catch
    maxY = max(mu(mu>=0)+phi(mu>=0));
    minY = min(mu(mu<0)-phi(mu<0));
    if isempty(maxY); maxY=0; end
    if isempty(minY); minY=0; end
    ylim(1.2* [minY, maxY]);
end
