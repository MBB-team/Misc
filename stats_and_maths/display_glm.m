function display_glm(glm)


% -------- figure definition ----------%
pos0 = get(0,'screenSize');
pos = [0.51*pos0(3),0.05*pos0(4),0.45*pos0(3),0.9*pos0(4)];
handles.hf = figure('color',[1 1 1],'position',pos);

map(1,:) = [1 0 0]; % colormap
for nContrast = 2:32
    map(nContrast,:) = [map(nContrast-1,1), map(nContrast-1,2)+(1/31), map(nContrast-1,3)+(1/31)];
end
for nContrast = 33:64
    map(nContrast,:) = [map(nContrast-1,1)-(1/33), map(nContrast-1,2), map(nContrast-1,3)-(1/33)];
end



% -------- variables definition ----------%
observation = table2array(glm.Variables(:,end));
prediction = glm.Fitted.Response;
linearPredictor = glm.Fitted.LinearPredictor;
predictors = table2array(glm.Variables(:,1:end-1));


% -------- predicted vs observed data ----------%
handles.ha = subplot(3,2,1,'parent',handles.hf,'nextplot','add','visible','on');

switch glm.Distribution.Name
    case 'Binomial'
        hp = plot(handles.ha(1),linearPredictor,observation,'k.');
        mi = min([linearPredictor]);
        ma = max([linearPredictor]);
        logit = @(x) 1./(1+exp(-x));
        fplot(logit,[mi,ma],'r')
        xx = 0.1*(ma-mi)+mi;
        BCA = balanced_accuracy(prediction,observation);
        str = [ ' BCA =',sprintf('%2.3f',BCA)];
        text(xx,0.3,str,'parent',handles.ha(1),'color','r')
        xlabel(handles.ha(1),'predictor')

    otherwise
        hp = plot(handles.ha(1),prediction,observation,'k.');
        mi = min([observation;prediction]);
        ma = max([observation;prediction]);
        plot(handles.ha(1),[mi,ma],[mi,ma],'r')
        xx = 0.1*(ma-mi)+mi;
        str = [ ' adj.R^2=',sprintf('%2.3f',glm.Rsquared.AdjGeneralized)];
        text(xx,xx,str,'parent',handles.ha(1),'color','r')
        xlabel(handles.ha(1),'predicted data')
end
axis(handles.ha(1),'tight')
ylabel(handles.ha(1),'observed data')
grid(handles.ha(1),'on')
title(handles.ha(1),'data alignement')


% -------- regression parameter estimates ----------%
handles.ha(2) = subplot(3,2,2,'parent',handles.hf,'nextplot','add','visible','on');
k = numel(glm.Coefficients.Estimate);
str = cell(k,1);
for j=1:k
    hp = bar(handles.ha(2),j,glm.Coefficients.Estimate(j),'facecolor',0.8*[1 1 1],'BarWidth',0.5);
    str{j} = glm.Formula.TermNames{j,1};
    hp = errorbar(handles.ha(2),j,glm.Coefficients.Estimate(j),glm.Coefficients.SE(j),'r.');
    strp = ['p=',num2str(glm.Coefficients.pValue(j),'%3.3f')];
    text(j-0.5,glm.Coefficients.Estimate(j)+glm.Coefficients.SE(j)+0.05*max(glm.Coefficients.Estimate),strp,'parent',handles.ha(2),'color','r')
end
set(handles.ha(2),'xtick',[1:1:k],'xlim',[0.5,k+0.5],'ygrid','on')
set(handles.ha(2),'xticklabel',str,'xticklabelrotation',45)
xlabel(handles.ha(2),'predictor variables')
title(handles.ha(2),'regression parameter estimates')


% --------  histogram of resiudals ----------%
handles.ha(4) = subplot(3,2,3,'parent',handles.hf,'nextplot','add','visible','on');
plotResiduals(glm);
pd = fitdist(glm.Residuals.Raw,'Normal');
x = min(glm.Residuals.Raw):0.01*(max(glm.Residuals.Raw)-min(glm.Residuals.Raw)):max(glm.Residuals.Raw);
y = pdf(pd,x);
hp = plot(handles.ha(4),x,y,'r');


% --------  resiudals vs predicted data ----------%
handles.ha(6) = subplot(3,2,4,'parent',handles.hf,'nextplot','add','visible','on');
plotResiduals(glm,'fitted');


% --------  parameter correlation matrix ----------%
handles.ha(3) = subplot(3,2,5,'parent',handles.hf,'nextplot','add');
imagesc(cov2corr(glm.CoefficientCovariance),'parent',handles.ha(3))
axis(handles.ha(3),'square')
axis(handles.ha(3),'equal')
axis(handles.ha(3),'tight')
colormap(map);
colorbar('peer',handles.ha(3))
title(handles.ha(3),'parameters'' correlation matrix')
set(handles.ha(3),'clim',[-1,1],'xdir','normal','ydir','reverse','xtick',[1:k],'ytick',[1:k])

% --------  design matrix ----------%
handles.ha(5) = subplot(3,2,6,'parent',handles.hf,'visible','on');
imagesc(predictors,'parent',handles.ha(5))
colormap(map);
colorbar('peer',handles.ha(3))
k = numel(glm.PredictorNames);
set(handles.ha(5),'xtick',[1:1:k],'xlim',[0.5,k+0.5],'xgrid','on','ygrid','off')
xlabel(handles.ha(5),'predictor variables')
ylabel(handles.ha(5),'n° observation')
title(handles.ha(5),'design matrix')


% --------  display summary of glm ----------%
disp(glm);







end