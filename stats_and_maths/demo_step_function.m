

k=3;
beta=1e3;
sig = @(x) 1./(1+exp(-beta.*x));
dsig = @(x) sig(x).*(1-sig(x));
% step = @(x) sum(sig(x-[1:k]),2);
dstep = @(x) sum(sum(dsig(x-[1:k])),2);

step = @(x) (cos(x.*2*pi)+1).*x/2;
% step = @(x) (cos(x.*2*pi)+1)./2;

figure;hold on;
fplot(step);
% fplot(dstep);

figure; hold on;
x=randn(1e6,1)*1e1;
x2=step(x);
histogram(x,[-10:0.1:10]);
histogram(x2,[-10:0.1:10]);
xlim([-5 5])