function [ b ] = myboxplot( x,y, varargin )
% personalized errorbar
%
% Nicolas Borderies

%% options
 if nargin<3
     col = [1 1 1]*0.5;
 else
     col = varargin{1};
 end
 

 %% plots
   hold on;
   boxplot(y,...
                'boxstyle','outline','colors',col,...
                'medianstyle','line',...
                'symbol','',...
                'whisker',1,...
                'widths',0.5,...
                'positions',x);
 
  b = findobj('Tag','Box','-and','Color',col);
  b = b(end);


end

