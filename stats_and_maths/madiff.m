function [ y ] = madiff( x , flag )
% mean absolute difference

if nargin<2
    flag=0;
end

n = numel(x);
x2 = zeros(1,n^2);

for i=1:n
    for j=1:n
        x2(j+n*(i-1)) = abs(x(i)-x(j));
    end
end

if flag
    y = sum(x2)./((n-1)*sum(x));
else
    y = mean(x2);
%     y = median(x2);
end


end

