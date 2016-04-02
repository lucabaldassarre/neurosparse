function [] = SLAP_train(ks)

% neuro(id)
% Executes TV only regularization on Janaina's data on the cluster
% id - task id

ks = str2double(ks);
ns = 16; %Number of subjects for test Leave-One-Subject-Out
step = 84;
p = 0.5;

% Optimization parameters
tol_fista = 1e-5;
maxiter_fista = 1e4;

% Regularization parameters
% Laplacian term
nlambda_2 = 10;
lambda_2s = logspace(1,-4,nlambda_2);
% L1 term
nlambda_1 = 10;
% lambdas = logspace(log10(4^1), log10(4^-7), nlambdas);
lambda_1s = logspace(1, -4, nlambda_1);

fload = sprintf('RESULTS_VAL/SLAP_loo_errs_%d_%g.mat',ks, p);
load(fload,'idx_*');

%%
% Load the connection matrix
load(sprintf('L_p_%g.mat',p),'L','Li_L');
% Load the data
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
disp('SLAP: TRAIN FOR ACCURACY');
lambda_1 = lambda_1s(idx_best_lambda_1_accuracy);
lambda_2 = lambda_2s(idx_best_lambda_2_accuracy);
tic
Li = Li_X + lambda_2*Li_L;
[alpha_accuracy iters_accuracy costs_accuracy] =...
   fista_laplacian(Xtr, ytr, L, lambda_1, lambda_2, tol_fista, maxiter_fista, Li, zeros(n,1));
yprev_accuracy = sign(Xts*alpha_accuracy);
err_test_accuracy = sum(1-yprev_accuracy.*yts)/(2*size(yts,1));
time_accuracy = toc;

%% TRAIN FOR DIST OC
disp('SLAP: TRAIN FOR DIST OC');
tic
if (idx_best_lambda_1_dist_OC == idx_best_lambda_1_accuracy) && (idx_best_lambda_1_dist_OC == idx_best_lambda_2_accuracy)
   alpha_dist_OC = alpha_dist_accuracy;
   iters_dist_OC = iters_dist_accuracy;
   costs_dist_OC = costs_dist_accuracy;
   yprev_dist_OC = yprev_dist_accuracy;
   err_test_dist_OC = err_test_dist_accuracy;
else
   lambda_1 = lambda_1s(idx_best_lambda_1_dist_OC);
   lambda_2 = lambda_2s(idx_best_lambda_2_dist_OC);
   Li = Li_X + lambda_2*Li_L;
   [alpha_dist_OC iters_dist_OC costs_dist_OC] =...
          fista_laplacian(Xtr, ytr, L, lambda_1, lambda_2, tol_fista, maxiter_fista, Li, zeros(n,1));
   yprev_dist_OC = sign(Xts*alpha_dist_OC);
   err_test_dist_OC = sum(1-yprev_dist_OC.*yts)/(2*size(yts,1));
end
time_dist_OC = toc;

%% TRAIN FOR DIST corr
tic
disp('SLAP: TRAIN FOR DIST corr');
if (idx_best_lambda_1_dist_corr == idx_best_lambda_1_accuracy) && (idx_best_lambda_1_dist_corr == idx_best_lambda_2_accuracy)
   alpha_dist_corr = alpha_dist_accuracy;
   iters_dist_corr = iters_dist_accuracy;
   costs_dist_corr = costs_dist_accuracy;
   yprev_dist_corr = yprev_dist_accuracy;
   err_test_dist_corr = err_test_dist_accuracy;
elseif (idx_best_lambda_1_dist_corr == idx_best_lambda_1_dist_OC) && (idx_best_lambda_1_dist_corr == idx_best_lambda_2_dist_OC)
   alpha_dist_corr = alpha_dist_dist_OC;
   iters_dist_corr = iters_dist_dist_OC;
   costs_dist_corr = costs_dist_dist_OC;
   yprev_dist_corr = yprev_dist_dist_OC;
   err_test_dist_corr = err_test_dist_dist_OC;
else
   lambda_1 = lambda_1s(idx_best_lambda_1_dist_corr);
   lambda_2 = lambda_2s(idx_best_lambda_2_dist_corr);
   Li = Li_X + lambda_2*Li_L;
   [alpha_dist_corr iters_dist_corr costs_dist_corr] =...
          fista_laplacian(Xtr, ytr, L, lambda_1, lambda_2, tol_fista, maxiter_fista, Li, zeros(n,1));
   yprev_dist_corr = sign(Xts*alpha_dist_corr);
   err_test_dist_corr = sum(1-yprev_dist_corr.*yts)/(2*size(yts,1));
end
time_dist_corr = toc;

clear Xtr ytr Xts yts
disp('FINISHED!');
fsave = sprintf('RESULTS_TRAIN/SLAP_loo_%d_p_%g.mat',ks, p);
save(fsave);
exit