function [ H ] = entropy_shannon( x , binsize, interval )

    % defaults
    if nargin<3
        xmax = max(x); 
        xmin = min(x);
    else
        xmax = interval(2); 
        xmin = interval(1);
    end
    
    if nargin<2
        binsize = 0.1;
    end

    
    % compute
    if ~isnan(xmax)
        p = histcounts(x,[xmin:binsize:xmax],'Normalization','probability');
        lg = log2(p);
        lg(lg==-Inf)=0;
        H = -sum(p.*( lg ));
    else
       H = NaN; 
    end

end

