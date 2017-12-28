function [] = print_my_table(tab)
% function [] = print_my_table(tab)
%   print a table into the current command line in a markdown format

    % conversion
    temptab = varfun(@char,varfun(@string,tab));
    temptab.Properties.VariableNames = tab.Properties.VariableNames ;
    fprintf('\n');
    print_table(temptab,'PrintBorder',true);
    fprintf('\n');


end