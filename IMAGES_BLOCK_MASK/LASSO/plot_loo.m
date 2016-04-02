function plot_loo(ks)

ns = 16;
fload = ['RESULTS_VAL/LASSO_loo_errs_',num2str(ks)];
data = load(fload);
title_str{1} = sprintf('LOO = %d of %d',ks,ns);

% figure, semilogy(data.sparsity')

% title_str{2} = 'SPARSITY vs REGPAR';
% xlabel('REGPAR','FontSize',16)
% ylabel('SPARSITY','FontSize',16)
% set(gca,'FontSize',16);
% xlim([1 10])

figure,
subplot(3,2,[1 3]);
plot(data.mean_O,'LineWidth',2)
hold all
plot(data.mean_OC,'LineWidth',2)
plot(1-data.mean_err_loo,'LineWidth',2)
plot(data.dists,'LineWidth',2)
plot(mean(data.sparsity)/data.n,'LineWidth',2)
%plot(data.mean_OE,'LineWidth',2)
title(title_str,'FontSize',20)
xlabel('REGPAR','FontSize',16)
set(gca,'FontSize',16)
xlim([1 10])
%legend('O','OC','ACCURACY','DISTS','SPARSITY','OE','Location','SouthWest')
legend('O','OC','ACCURACY','DISTS','SPARSITY','Location','SouthWest')

subplot(3,2,2);
semilogx(mean(data.sparsity)/data.n,1-data.mean_err_loo,'LineWidth',2);
title_str{1} = 'ACCURACY vs SPARSITY';
title(title_str,'FontSize',20)
ylabel('ACCURACY','FontSize',16)
xlabel('SPARSITY','FontSize',16)
set(gca,'FontSize',16)

subplot(3,2,4);
plot(data.mean_OC,1-data.mean_err_loo,'LineWidth',2);
title_str{1} = 'ACCURACY vs OC';
title(title_str,'FontSize',20)
ylabel('ACCURACY','FontSize',16)
xlabel('OC','FontSize',16)
set(gca,'FontSize',16)

subplot(3,2,5);
semilogy(mean(data.sparsity)/data.n,data.mean_OE,'LineWidth',2);
title_str{1} = 'OE vs SPARSITY';
title(title_str,'FontSize',20)
ylabel('OE','FontSize',16)
xlabel('SPARSITY','FontSize',16)
set(gca,'FontSize',16)
% xlim([1 10]);

subplot(3,2,6);
plot(mean(data.sparsity)/data.n,data.mean_OC,'LineWidth',2);
title_str{1} = 'OC vs SPARSITY';
title(title_str,'FontSize',20)
xlabel('SPARSITY','FontSize',16)
ylabel('OC','FontSize',16)
set(gca,'FontSize',16)