function [y]  = nancumsum(x)

    ind = find(~isnan(x));
    xx = cumsum(x(~isnan(x)));
    y = nan(size(x));
    y(ind) = xx;

end