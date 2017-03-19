function [t] = mergetable(t1,t2)
% vertical concatenation of 2 tables by variable matching even if the two
% tables doesn't the same variables (need >= commonVar )

    t1colmissing = setdiff(t2.Properties.VariableNames, t1.Properties.VariableNames);
    n1colmissing = [];
    for i = 1:numel(t1colmissing)
        var = t1colmissing{i};
        n1colmissing(i) = size(t2.(var),2);
    end
    
    t2colmissing = setdiff(t1.Properties.VariableNames, t2.Properties.VariableNames);
    n2colmissing = [];
    for i = 1:numel(t2colmissing)
        var = t2colmissing{i};
        n2colmissing(i) = size(t1.(var),2);
    end
    
    t1 = [t1 array2table(nan(height(t1), numel(t1colmissing)), 'VariableNames', t1colmissing)];
    t2 = [t2 array2table(nan(height(t2), numel(t2colmissing)), 'VariableNames', t2colmissing)];
    for i = 1:numel(t1colmissing)
        if iscategorical(t2.(t1colmissing{i}))
            t1.(t1colmissing{i}) = categorical(nan(height(t1), n1colmissing(i)));
        elseif iscell(t2.(t1colmissing{i}))
            t1.(t1colmissing{i}) = num2cell(nan(height(t1), n1colmissing(i)));
        else
            t1.(t1colmissing{i}) = nan(height(t1), n1colmissing(i));
        end
        
    end
    for i = 1:numel(t2colmissing)
        if iscategorical(t1.(t2colmissing{i}))
            t2.(t2colmissing{i}) = categorical(nan(height(t2), n2colmissing(i)));
        elseif iscell(t1.(t2colmissing{i}))
            t2.(t2colmissing{i}) = num2cell(nan(height(t2), n2colmissing(i)));
        else
            t2.(t2colmissing{i}) = nan(height(t2), n2colmissing(i));
        end
    end

    t = [t1; t2];

end
