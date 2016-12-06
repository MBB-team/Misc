function[fillhandle,msg]=jbfill(xpoints,upper,lower,middle,color,edge,add,transparency)
%USAGE: [fillhandle,msg]=jbfill(xpoints,upper,lower,color,edge,add,transparency)
%This function will fill a region with a color between the two vectors provided
%using the Matlab fill command.
%
%fillhandle is the returned handle to the filled region in the plot.
%xpoints= The horizontal data points (ie frequencies). Note length(Upper)
%         must equal Length(lower)and must equal length(xpoints)!
%upper = the upper curve values (data can be less than lower)
%lower = the lower curve values (data can be more than upper)
% middle = the curve to trace between upper and lower (can be mean for ex.)
%color = the color of the filled area and of the middle curve
%edge  = the color around the edge of the filled area
%add   = a flag to add to the current plot or make a new one.
%transparency is a value ranging from 1 for opaque to 0 for invisible for
%the filled color only.
%
%John A. Bockstege November 2006;
%Example:
%     a=rand(1,20);%Vector of random data
%     b=a+2*rand(1,20);%2nd vector of data points;
%     x=1:20;%horizontal vector
%     [ph,msg]=jbfill(x,a,b,rand(1,3),rand(1,3),0,rand(1,1))
%     grid on
%     legend('Datr')
%
% NICOLAS CLAIRIS and JULES BROCHARD EDIT (8/11/16): all the NaN values are removed from the
% "upper" points, the "lower" points and the corresponding "xpoint" index
%
if nargin<8;transparency=.5;end %default is to have a transparency of .5
if nargin<7;add=1;end     %default is to add to current plot
if nargin<6;edge='k';end  %dfault edge color is black
if nargin<5;color='b';end %default color is blue

upper_valid = ~isnan(upper);
lower_valid = ~isnan(lower);

if any(~upper_valid) || any(~lower_valid)
    warning('Function jbfill.m: NaN values were detected in the variable ''upper'' or ''lower'', they have been removed for display.')
end

if length(upper)==length(lower) && length(lower)==length(xpoints) %&& any(upper_valid ~= lower_valid)
    msg='';
    filled=[upper(upper_valid),fliplr(lower(lower_valid))];
    xpointsfill=[xpoints(upper_valid),fliplr(xpoints(lower_valid))];
    if add
        hold on
    end
    fillhandle=fill(xpointsfill,filled,color);%plot the data
    set(fillhandle,'EdgeColor',edge,'FaceAlpha',transparency,'EdgeAlpha',transparency);%set edge color
    if add
        hold off
    end
else
    msg='Error: Must use the same number of points in each vector';
end

if nargin >= 4
    hold on;
    plot(xpoints,middle,color)
end
