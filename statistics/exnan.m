function [ y ] = exnan( x )
    % exclude NaN from a vector
    
    y = x(~isnan(x));

end

