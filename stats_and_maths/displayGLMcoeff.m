function  f = displayGLMcoeff( glm , f, ax , option )

% default
if nargin<2
f = figure; hold on;
% f.Units = 'normalized';
% f.Position = [0.25 0.25 0.75 0.5];
end
if nargin<3
ax = gca;
end
if nargin<4
    option.pValue=1;
end

thr = [0.1 0.05 0.01 0.001];

k = numel(glm.Coefficients.Estimate);
str = cell(k,1);
for j=1:k
    beta = glm.Coefficients.Estimate(j);
    std = glm.Coefficients.SE(j) ;
    hp = bar(j,beta,'facecolor',0.7*[1 1 1],'BarWidth',0.5,'EdgeColor','none');
    str{j} = glm.Formula.TermNames{j,1};
    hp = errbar(j,beta,std,'r','LineWidth',1.5);
    pV = glm.Coefficients.pValue(j);
    if option.pValue==1
        strp = ['p=',num2str(pV,'%3.3f')];
        text(j-0.5,beta+sign(beta)*(std+0.05*max(glm.Coefficients.Estimate)),strp,'parent',ax,'color','r');
    end
    if pV<=thr(1)
        if pV<=thr(2)
            if pV<=thr(3)
                if pV<=thr(4)
                    text(j,beta+sign(beta)*(std+0.15*max(glm.Coefficients.Estimate)),'***','parent',ax,'color','r',...
                    'fontsize',14,'horizontalalignment','center');
                else
                     text(j,beta+sign(beta)*(std+0.15*max(glm.Coefficients.Estimate)),'**','parent',ax,'color','r',...
                    'fontsize',14,'horizontalalignment','center');
                end
            else
                 text(j,beta+sign(beta)*(std+0.15*max(glm.Coefficients.Estimate)),'*','parent',ax,'color','r',...
                'fontsize',14,'horizontalalignment','center');
            end
        else
             text(j,beta+sign(beta)*(std+0.15*max(glm.Coefficients.Estimate)),'.','parent',ax,'color','r',...
             'fontsize',24,'horizontalalignment','center');
        end
    end
end

set(ax,'xtick',[1:1:k],'xlim',[0.5,k+0.5],'ygrid','on');
set(ax,'ticklength',[0 0.5]);
set(ax,'xticklabel',str,'xticklabelrotation',45);
% set(ax,'ylim',[ min(glm.Coefficients.Estimate)-abs(min(glm.Coefficients.Estimate))*(0.5),...
%                  max(glm.Coefficients.Estimate)+abs(max(glm.Coefficients.Estimate))*(0.5)]);
xlabel(ax,'predictor variables');
title(ax,'regression parameter estimates');

end

