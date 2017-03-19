function [ob]  = setFigProper( varargin )

if nargin==0
    s = 18; 
else
    args = varargin;
    nargs = length(args);
end

% otpionnal modifications
for ia = 1:nargs 
    
    % fontsize
    if ismember(args{ia},'FontSize');
        try
            s = args{ia+1};
            ob = findobj('-property','FontSize');
            for iO = 1:numel(ob)
                ob(iO).FontSize = s;
                ob(iO).FontName = 'Arial Narrow';
                ob(iO).FontWeight = 'bold';
                switch class(ob(iO))
                    case {'matlab.graphics.illustration.Legend'}
                        ob(iO).FontSize = s*(0.75);
                    case {'matlab.graphics.axis.Axes'}
                        ob(iO).Title.FontSize = s*(1);
                        ob(iO).XLabel.FontSize = s;
                        ob(iO).YLabel.FontSize = s;
                        ob(iO).FontSize = s*(0.75);
                end
            end
        catch
            warning('argument following FontSize should be a positive scalar');
        end
    end
    
    % linewidth
    if ismember(args{ia},'LineWidth');
        try
            l = args{ia+1};
            ob = findobj('-property','LineWidth');
            for iO = 1:numel(ob)
                ob(iO).LineWidth = l;
            end
        catch
            warning('argument following LineWidth should be a positive scalar');
        end
    end
    
end

        
% constant modifications
ob = findobj('-property','XAxisLocation');
        for iO = 1:numel(ob)
            ob(iO).Color = 'none';
        end
        
ob = findobj('-property','Box');
        for iO = 1:numel(ob)
            ob(iO).Box = 'off';
        end
        
end

