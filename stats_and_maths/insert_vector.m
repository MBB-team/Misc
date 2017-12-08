
function [a2] = insert_vector(a,value,position)
% function [a2] = insert_vector(a,value,position)
% this function insert an scalar element into any position within a vector.
%
% inputs:
%   - a : original vector
%   - value : scalar to be inserted
%   - position: index of the position preceding the inserted element ( integer between 0 & numel(a) )

    a2 = [a , value ];
    ind_a2 = [ 1:numel(a) , position+0.5 ];
    [~,ind_a2] = sort(ind_a2);
    a2 = a2(ind_a2);
    
end


