function [] = export_my_table( tab , filename )

    % defaults
    if nargin<2
        filename = 'tab.xlsx';
    end

    writetable(tab,filename,'WriteRowNames',1);
%     open(filename);
    winopen(filename);
    
end

