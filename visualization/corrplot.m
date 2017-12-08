function [ h,hp,s ] = corrplot( x,y, varargin )
% personalized correlation plot
%
% Nicolas Borderies

% check options
optionList = {'color','ctype'};
defaultList = { 'k', 'Spearman'};
[col,ctype] = check_options(varargin,optionList,defaultList);

 
 resol = 0.05;
 alpha = 0.4;
 
 
[rho,p] = corr(x,y,'row','pairwise','type',ctype);
stat = fitglm(x,y,'linear');
x2 = [min(x):(resol*range(x)):max(x)]';
[y2,ic] = predict(stat,x2);
[h,hp] = boundedline( x2 , y2 , ic(:,2)-ic(:,1) , 'alpha','transparency',alpha); 

% [b,stat] = robustfit(x,y);
% x2 = [min(x):(resol*range(x)):max(x)]';
% y2 = b(1) + b(2)*x2;
% ic = stat.se(1) + stat.se(2)*abs(x2);
% [h,hp] = boundedline( x2 , y2 , ic , 'alpha','transparency',alpha); 

set(h,'Color',col,'LineWidth',2);set(hp,'FaceColor',col);
h.LineStyle = '-'; 
[~,s,h] = errorscat(x,y,y.*0,col);
h.LineStyle = 'none';
                
                
% legending
text(nanmin(x)*1.1,nanmax(y)*0.9,['rho = ' num2str(round(rho,2))]);
text(nanmin(x)*1.1,nanmax(y)*0.8,['p = ' num2str(round(p,10))]);