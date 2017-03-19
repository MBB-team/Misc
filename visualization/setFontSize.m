function [ob]  = setFontSize( s )


ob = findobj('-property','FontSize');
        for iO = 1:numel(ob)
            ob(iO).FontSize = s;
            ob(iO).FontName = 'Arial Narrow';
            ob(iO).FontWeight = 'bold';
            try
                ob(iO).Title.FontSize = s;
                ob(iO).XLabel.FontSize = s;
                ob(iO).YLabel.FontSize = s;
            end
        end
        
ob = findobj('-property','XAxisLocation');
        for iO = 1:numel(ob)
            ob(iO).Color = 'none';

        end
        
ob = findobj('-property','Box');
        for iO = 1:numel(ob)
            ob(iO).Box = 'off';
        end
ob = findobj('-property','LineWidth');
        for iO = 1:numel(ob)
            ob(iO).LineWidth = 2;
        end
        
end

