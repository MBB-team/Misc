function [] = export_my_table( tab )

    writetable(tab,'tab.xlsx','WriteRowNames',1);
    open('tab.xlsx')
    
end

