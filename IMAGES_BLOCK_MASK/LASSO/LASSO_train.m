function [] = LASSO_train(ks)

% Executes LASSO training with the regularization parameters found during validation
% on Janaina's data on the cluster
% id - task id

ks      = str2double(ks);
ns      = 16;   % Number of subjects for test Leave-One-Subject-Out
nsv     = 15;   % Number of subjects for validation Leave-One-Subject-Out
step    = 84;   % Number of samples per subject
p       = 0.5;  % Threshold on grey matter mask

% Optimization parameters
tol_fista       = 1e-5;
maxiter_fista   = 1e4;

% Regularization parameters
nlambdas    = 10;
lambdas     = logspace(log10(0.9), log10(1e-5), nlambdas);

% Load validation results
fload = sprintf('RESULTS_VAL/LASSO_loo_errs_%d_%g.mat', ks, p);
load(fload, 'idx_best_regpar_accuracy', 'idx_best_regpar_dist_OC', 'idx_best_regpar_dist_corr');

%% Load grey-matter-thresholded data
load(sprintf('../c1_c3_data_mask_p_%g.mat',p), 'X', 'Y');

%% CREATE TRAIN AND TEST SETS
Xts = X(step*(ks-1)+1:step*ks,:);
yts = Y(step*(ks-1)+1:step*ks,:);

Xtr = X(setdiff(1:size(X,1),step*(ks-1)+1:step*ks),:);
ytr = Y(setdiff(1:size(X,1),step*(ks-1)+1:step*ks),:);

clear X Y;

%% Normalization
means   = mean(Xtr);
stds    = std(Xtr);

Xtr = Xtr - repmat(means,size(Xtr,1),1);
Xtr = Xtr./repmat(stds,size(Xtr,1),1);
Xts = Xts - repmat(means,size(Xts,1),1);
Xts = Xts./repmat(stds,size(Xts,1),1);

m = size(Xtr,1);
n = size(Xtr,2);

%% Loads Lipschitz constant of gradient of empirical risk
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

%% SET REGULARIZATION PARAMETER
lambda_max = max(abs(Xtr'*ytr))/m;

regpar_accuracy     = lambda_max*lambdas(idx_best_regpar_accuracy);
regpar_dist_OC      = lambda_max*lambdas(idx_best_regpar_dist_OC);
regpar_dist_corr    = lambda_max*lambdas(idx_best_regpar_dist_corr);

lambda_2 = 0;

%% RUN FISTA SOLVER FOR ACCURACY-BASED MODEL SELECTION
disp(datestr(now));
fprintf('LASSO: Subject test loo = %d of %d - Accuracy \n',ks,ns)
tic
[alpha_accuracy, iters_accuracy, costs_accuracy] =...
          fista_enet(Xtr, ytr, regpar_accuracy, lambda_2, tol_fista, maxiter_fista, Li_X, zeros(n,1));
time_accuracy       = toc;
yprev_accuracy      = sign(Xts*alpha_accuracy);
err_test_accuracy   = sum(1-yprev_accuracy.*yts)/(2*size(yts,1));

%% RUN FISTA SOLVER FOR OC-BASED MODEL SELECTION
disp(datestr(now));
fprintf('LASSO: Subject test loo = %d of %d - Distance OC\n',ks,ns)
tic
if idx_best_regpar_dist_OC == idx_best_regpar_accuracy
   alpha_dist_OC = alpha_accuracy;
   iters_dist_OC = iters_accuracy;
   costs_dist_OC = costs_accuracy;
   yprev_dist_OC = yprev_accuracy;
   err_test_dist_OC = err_test_accuracy;
else
   [alpha_dist_OC iters_dist_OC costs_dist_OC] =...
             fista_enet(Xtr, ytr, regpar_dist_OC, lambda_2, tol_fista, maxiter_fista, Li_X, zeros(n,1));
   yprev_dist_OC = sign(Xts*alpha_dist_OC);
   err_test_dist_OC = sum(1-yprev_dist_OC.*yts)/(2*size(yts,1));
end
time_dist_OC = toc;

%% RUN FISTA SOLVER FOR CORRELATION-BASED MODEL SELECTION
disp(datestr(now));
fprintf('LASSO: Subject test loo = %d of %d - Distance correlation\n',ks,ns)
tic
if idx_best_regpar_dist_corr == idx_best_regpar_accuracy
   alpha_dist_corr = alpha_accuracy;
   iters_dist_corr = iters_accuracy;
   costs_dist_corr = costs_accuracy;
   yprev_dist_corr = yprev_accuracy;
   err_test_dist_corr = err_test_accuracy;
elseif idx_best_regpar_dist_corr == idx_best_regpar_dist_OC
   alpha_dist_corr = alpha_dist_OC;
   iters_dist_corr = iters_dist_OC;
   costs_dist_corr = costs_dist_OC;
   yprev_dist_corr = yprev_dist_OC;
   err_test_dist_corr = err_test_dist_OC;
else
   [alpha_dist_corr iters_dist_corr costs_dist] =...
             fista_enet(Xtr, ytr, regpar_dist_corr, lambda_2, tol_fista, maxiter_fista, Li_X, zeros(n,1));
   yprev_dist_corr = sign(Xts*alpha_dist_corr);
   err_test_dist_corr = sum(1-yprev_dist_corr.*yts)/(2*size(yts,1));
end
time_dist_corr = toc;

%% CLEAR AND SAVE
clear Xtr ytr Xts yts
disp(datestr(now));
fprintf('FINISHED!\n');
fsave = sprintf('RESULTS_TRAIN/LASSO_loo_%d_p_%g.mat', ks, p);
save(fsave);
exit