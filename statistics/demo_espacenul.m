% Demo espace nul

% define reg1
reg1= repmat(1:10, 1, 20)';
figure;plot(reg1, 'linewidth', 2)
set(gca, 'XTick', []);
set(gca, 'YTick', []);

% define reg2
reg2= 10 * reg1 + (1:length(reg1))' + randn(length(reg1), 1);
figure;plot(reg2, 'linewidth', 2, 'color', 'red')
set(gca, 'XTick', []);
set(gca, 'YTick', []);
corr(reg1, reg2)


% orthogonolize using glmfit
a= glmfit(reg1, reg2)
reg3 = reg2 - a(2) * reg1;
figure;plot(reg3, 'linewidth', 2, 'color', 'green')
set(gca, 'XTick', []);
set(gca, 'YTick', []);
corr(reg1, reg3)
reg1' * reg2

% orthogonolize using spm_orth

aga= spm_orth([reg1, reg2]);
reg4 = aga(:,end);
figure;plot(reg4, 'linewidth', 2, 'color', 'cyan')
set(gca, 'XTick', []);
set(gca, 'YTick', []);
corr(reg1, reg4)
reg1' * reg4
cov(spm_orth(aga))
 
% orthogonolize using spm_orth... but 0-mean reg1 !
aga= spm_orth([reg1-mean(reg1), reg2]);
reg5 = aga(:,end);
figure;plot(reg5, 'linewidth', 2, 'color', [1 0.7 0])
set(gca, 'XTick', []);
set(gca, 'YTick', []);
corr(reg1, reg5)
reg1' * reg5
cov(spm_orth(aga))


% or put a constant as the first regressor !
aga= spm_orth([ones(size(reg1)) reg1, reg2]);
reg6 = aga(:,end);
figure;plot(reg6, 'linewidth', 2, 'color', [1 1 0])
set(gca, 'XTick', []);
set(gca, 'YTick', []);
corr(reg1, reg6)
reg1' * reg6
cov(spm_orth(aga))






