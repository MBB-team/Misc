function [fList] = get_flistNames(dir)
% function [fList] = get_flistNames(dir)
% this function provide a cell array of the files and folders content of
% the directory (excluding the '.' and '..')

fList = cellstr(ls(dir));
fList = fList(cellfun(@(s) ~ismember(s,{'.','..'}),fList));


end