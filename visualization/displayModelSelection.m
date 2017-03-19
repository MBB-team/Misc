function  f = displayModelSelection( LL , f, ax , option )

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

LL = LL - min(LL);
k = numel(LL);
for j=1:k
    beta = LL(j);
    hp = bar(j,beta,'facecolor',0.7*[1 1 1],'BarWidth',0.5,'EdgeColor','none');
    str{j} = num2str(j);
    dF = max(LL)-max(LL(LL~=max(LL)));
    pV = 1./(1+exp(dF)) ;
    if option.pValue==1 && beta==max(LL);
        strp = ['pMax = ',num2str(pV,'%3.3f')];
        text(j-0.5,beta+sign(beta)*(0.05*max(LL )),strp,'parent',ax,'color','r');
        hp.FaceColor = 'r';
    end
    
end
plot([0:k+1],(max(LL)-3).*ones(1,k+2),'r');

set(ax,'xtick',[1:1:k],'xlim',[0.5,k+0.5],'ygrid','on');
set(ax,'ticklength',[0 0.5]);
set(ax,'xticklabel',str,'xticklabelrotation',0);
set(ax,'ylim',[min(LL) max(LL)*1.2 ]);
xlabel(ax,'model space');
ylabel(ax,'log[p(y|m)]');
title(ax,'model selection');

end

