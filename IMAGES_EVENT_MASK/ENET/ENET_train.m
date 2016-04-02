function [] = ENET_train(ks)

% neuro(id)
% Executes TV only regularization on Janaina's data on the cluster
% id - task id

ks = str2double(ks);
ns = 15; %Number of subjects for test Leave-One-Subject-Out
step = 36;
p = 0.5;

% Optimization parameters
tol_fista = 1e-5;
maxiter_fista = 1e4;

%Regularization parameters
nlambda_1 = 10;
% lambda_1s = logspace(log10(0.9), log10(1e-5), nlambda_1);
lambda_1s = logspace(-0.5,-3.5,nlambda_1);
nlambda_2 = 10;
lambda_2s = logspace(4,-2,nlambda_2);

fload = sprintf('RESULTS_VAL/ENET_loo_errs_%d_%g.mat',ks, p);
load(fload,'idx_*');

%%
load(sprintf('../c1_c3_data_mask_p_%g.mat',p),'X','Y');

disp(datestr(now));
fprintf('Starting LOO - subject out %d of %02d \n',ks,ns);

%% CREATE TRAIN AND TEST SETS

Xts = X(step*(ks-1)+1:step*ks,:);
yts = Y(step*(ks-1)+1:step*ks,:);

Xtr = X(setdiff(1:size(X,1),step*(ks-1)+1:step*ks),:);
ytr = Y(setdiff(1:size(X,1),step*(ks-1)+1:step*ks),:);

clear X Y;

%% Normalization

means = mean(Xtr);
stds = std(Xtr);

Xtr = Xtr - repmat(means,size(Xtr,1),1);
Xtr = Xtr./repmat(stds,size(Xtr,1),1);
Xts = Xts - repmat(means,size(Xts,1),1);
Xts = Xts./repmat(stds,size(Xts,1),1);

m = size(Xtr,1);
n = size(Xtr,2);
% Loads Lipschitz constant of gradient of empirical risk
% or computes it if does not exit
fload = sprintf('../LIPSCHITZ/Li_loo_%d_p_%g.mat',ks, p);
if exist(fload,'file')
   load(fload,'Li_X');
else
   m = size(Xtr,1);
   tic
   Li_X = eigs(Xtr*Xtr',1,'LM')/m;
   time_Li = toc;
   save(fload,'Li_X','time_Li');
end

%% TRAIN FOR ACCURACY
lambda_1 = lambda_1s(idx_best_lambda_1_accuracy);
lambda_2 = lambda_2s(idx_best_lambda_2_accuracy);
tic
[alpha_accuracy iters_accuracy costs_accuracy] =...
          fista_enet(Xtr, ytr, lambda_1, lambda_2, tol_fista, maxiter_fista, Li_X, zeros(n,1));
yprev_accuracy = sign(Xts*alpha_accuracy);
err_test_accuracy = sum(1-yprev_accuracy.*yts)/(2*size(yts,1));
time_accuracy = toc;

%% TRAIN FOR DIST OC
tic
if (idx_best_lambda_1_dist_OC == idx_best_lambda_1_accuracy) && (idx_best_lambda_1_dist_OC == idx_best_lambda_2_accuracy)
   alpha_dist_OC = alpha_accuracy;
   iters_dist_OC = iters_accuracy;
   costs_dist_OC = costs_accuracy;
   yprev_dist_OC = yprev_accuracy;
   err_test_dist_OC = err_test_accuracy;
else
   lambda_1 = lambda_1s(idx_best_lambda_1_dist_OC);
   lambda_2 = lambda_2s(idx_best_lambda_2_dist_OC);
   [alpha_dist_OC iters_dist_OC costs_dist_OC] =...
          fista_enet(Xtr, ytr, lambda_1, lambda_2, tol_fista, maxiter_fista, Li_X, zeros(n,1));
   yprev_dist_OC = sign(Xts*alpha_dist_OC);
   err_test_dist_OC = sum(1-yprev_dist_OC.*yts)/(2*size(yts,1));
end
time_dist_OC = toc;

%% TRAIN FOR DIST corr
tic
if (idx_best_lambda_1_dist_corr == idx_best_lambda_1_accuracy) && (idx_best_lambda_1_dist_corr == idx_best_lambda_2_accuracy)
   alpha_dist_corr = alpha_accuracy;
   iters_dist_corr = iters_accuracy;
   costs_dist_corr = costs_accuracy;
   yprev_dist_corr = yprev_accuracy;
   err_test_dist_corr = err_test_accuracy;
elseif (idx_best_lambda_1_dist_corr == idx_best_lambda_1_dist_OC) && (idx_best_lambda_1_dist_corr == idx_best_lambda_2_dist_OC)
   alpha_dist_corr = alpha_dist_dist_OC;
   iters_dist_corr = iters_dist_dist_OC;
   costs_dist_corr = costs_dist_dist_OC;
   yprev_dist_corr = yprev_dist_dist_OC;
   err_test_dist_corr = err_test_dist_dist_OC;
else
   lambda_1 = lambda_1s(idx_best_lambda_1_dist_corr);
   lambda_2 = lambda_2s(idx_best_lambda_2_dist_corr);
   [alpha_dist_corr iters_dist_corr costs_dist_corr] =...
          fista_enet(Xtr, ytr, lambda_1, lambda_2, tol_fista, maxiter_fista, Li_X, zeros(n,1));
   yprev_dist_corr = sign(Xts*alpha_dist_corr);
   err_test_dist_corr = sum(1-yprev_dist_corr.*yts)/(2*size(yts,1));
end
time_dist_corr = toc;

clear Xtr ytr Xts yts
% fsave = sprintf('RESULTS_TRAIN/ENET_loo_%d_p_%g.mat',ks, p);
fsave = sprintf('RESULTS_TRAIN/ENET_loo_%d_%g.mat',ks, p);
save(fsave);
% exit