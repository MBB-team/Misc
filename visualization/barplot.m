function [ b,e ] = barplot( x,y,z, varargin )
% personalized errorbar
%
% Nicolas Borderies

%% options
 if nargin<4
     col = [1 1 1]*0.7;
 else
     col = varargin{1};
 end
 
 alpha = 0.5;

 %% plots
   hold on;
   b = bar( x,y,'FaceColor',col,'EdgeColor',col,'LineWidth',1);
   e = errbar( x,y,z ,'Color',alpha*col,'LineWidth',2);
  
 

end

