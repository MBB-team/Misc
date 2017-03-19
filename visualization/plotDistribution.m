function [hb,hs] = plotDistribution(data)

    % data class
    if isequal(class(data),'table')
        x = data{:,:};
        xlabels = data.Properties.VariableNames;
    else
        x = data;
        xlabels = {};
        for i=1:size(x,2)
           xlabels{i} = num2str(i); 
        end
    end
    
    % plots
    hb = boxplot(x,...
        'boxstyle','filled','colors','k',...
        'labels',xlabels,...
        'medianstyle','line',...
        'symbol','',...
        'whisker',1,...
        'widths',0.5);
    
    hs =  plotSpread(x,...
            'distributionColors',[1 1 1]*0.4);
        
    m = findobj('-property','MarkerFaceColor');
    for iM = 1:numel(m)
        m(iM).MarkerSize = 10;
    end


end