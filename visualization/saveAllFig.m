function [ F ] = saveAllFig(fmt)

    if nargin<1
        fmt = 'meta';
    end

    F = findobj('Type','figure');
    for iF = 1:numel(F)
        if isempty(F(iF).Name)
            F(iF).Name = [ 'figure_' num2str(iF) ];
        end
        F(iF).Units =  'centimeters';
        dim = F(iF).Position;
%         F(iF).Position([3,4]) =  [ min(1,dim(3)/dim(4)) min(1,dim(4)/dim(3))];
        F(iF).PaperType = '<custom>';
        size = max(dim([3,4]));
        F(iF).PaperSize = [ size size ];
%         F(iF).PaperUnits = 'normalized';
        F(iF).PaperPosition = [ 0 0 dim([3,4]) ];

        F(iF).Color = 'none';
%         savefig(F(iF),F(iF).Name);
        saveas(F(iF),F(iF).Name,fmt) ;
        F(iF).Color = 'w';

    end

end

