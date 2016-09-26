function [ e,s,l ] = errorscat( x,y,z, varargin )
% personalized errorbar
%
% Nicolas Borderies

%% options
 if nargin<4
     col = 'k';
 else
     col = varargin{1};
 end

 %% plots
   hold on;
   e = errbar( x,y,z ,'Color',col,'LineWidth',2);
   s = scatter( x,y,'MarkerFaceColor',col,'MarkerEdgeColor',col,'LineWidth',1);
   l = plot( x,y,'Color',col,'LineWidth',1);
            
 

end

