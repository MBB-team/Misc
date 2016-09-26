function [ h,hp,s ] = corrplot( x,y, varargin )
% personalized correlation plot
%
% Nicolas Borderies

%% options
 if nargin<4
     col = 'k';
 else
     col = varargin{1};
 end

 resol = 0.05;
 alpha = 0.4;
 
 
[rho,p] = corr(x,y,'row','pairwise');
stat = fitglm(x,y,'linear');
x2 = [min(x):(resol*range(x)):max(x)]';
[y2,ic] = predict(stat,x2);
[h,hp] = boundedline( x2 , y2 , ic(:,2)-ic(:,1) , 'alpha','transparency',alpha); 
set(h,'Color',col,'LineWidth',2);set(hp,'FaceColor',col);
h.LineStyle = '-'; 
[~,s,h] = errorscat(x,y,y.*0,col);
h.LineStyle = 'none';
                
                
% legending
text(min(x)*1.1,max(y)*0.9,['rho = ' num2str(round(rho,2))]);
text(min(x)*1.1,max(y)*0.8,['p = ' num2str(round(p,10))]);