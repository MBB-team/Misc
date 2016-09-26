function [ y ] = interpslide( x, dir )
% simple interpolation of x(t) by x(t-1)
%

if nargin==1
   dir ='backward' ;
end

while sum(isnan(x))>0
    if isequal(dir,'backward')
        x(isnan(x)) = x(find(isnan(x))-1 );
    elseif isequal(dir,'foreward')
        x(isnan(x)) = x(find(isnan(x))+1 );
    end
end 
y = x;
   
end

