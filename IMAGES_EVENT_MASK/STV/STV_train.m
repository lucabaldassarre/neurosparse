function [] = STV_train(ks)

% neuro(id)
% Executes STV only regularization on Janaina's data on the cluster
% id - task id

ks = str2double(ks);
ns = 15; %Number of subjects for test Leave-One-Subject-Out
step = 36;
p = 0.5;
tol = 1e-5;

% Regularization parameters
% L1 regularization parameter
nregpar1 = 10;
lambda_1s = logspace(1,-4,nregpar1);

% TV regularization parameter
nregpartv = 10;
lambda_2s = logspace(log10(2^-1), log10(2^-10), nregpartv);

fload = sprintf('RESULTS_VAL/STV_loo_errs_%d_%g.mat',ks, p);
load(fload,'idx_*');

%%
% Load the connection matrix
load(sprintf('../connection_matrix_p_%g.mat',p),'B','normBsqr');
C = B;
clear B;
% Load the data
load(sprintf('../c1_c3_data_mask_p_%g.mat',p));
n = size(X,2);

disp(datestr(now));
fprintf('Starting LOO - subject out %d of %02d \n',ks,ns);

% Optimization parameters
pars.tol = tol;
pars.coeff = 1;
pars.maxiter = 1e4;
pars.inner_maxiter = 1e3;
pars.x0 = zeros(n,1);

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

pars.Li = Li_X;
regpar1_max = 1;

%% TRAIN FOR ACCURACY
disp('STV: TRAIN FOR ACCURACY');
lambda1 = lambda_1s(idx_best_lambda_1_accuracy);
lambda2 = lambda_2s(idx_best_lambda_2_accuracy);

lambda1 = lambda1*regpar1_max;
% Create proper matrix B
tic
B = [lambda1*speye(n); lambda2*C];
pars.kappa = Li_X/(lambda1^2 + lambda2^2*normBsqr);
[alpha_accuracy iters_accuracy costs_accuracy prox_iters_accuracy] =...
       aifobas_complasso_warm(Xtr, ytr, B, 1, pars);
yprev_accuracy = sign(Xts*alpha_accuracy);
err_test_accuracy = sum(1-yprev_accuracy.*yts)/(2*size(yts,1));
time_accuracy = toc;

%% TRAIN FOR DIST OC
disp('STV: TRAIN FOR DIST OC');
tic
if (idx_best_lambda_1_dist_OC == idx_best_lambda_1_accuracy) && (idx_best_lambda_1_dist_OC == idx_best_lambda_2_accuracy)
   alpha_dist_OC = alpha_dist_accuracy;
   iters_dist_OC = iters_dist_accuracy;
   costs_dist_OC = costs_dist_accuracy;
   yprev_dist_OC = yprev_dist_accuracy;
   err_test_dist_OC = err_val_dist_accuracy;
else
   lambda1 = lambda_1s(idx_best_lambda_1_dist_OC);
   lambda2 = lambda_2s(idx_best_lambda_2_dist_OC);
   lambda1 = lambda1*regpar1_max;
   % Create proper matrix B
   B = [lambda1*speye(n); lambda2*C];
   pars.kappa = Li_X/(lambda1^2 + lambda2^2*normBsqr);

   [alpha_dist_OC iters_dist_OC costs_dist_OC prox_iters_dist_OC] =...
       aifobas_complasso_warm(Xtr, ytr, B, 1, pars);
   yprev_dist_OC = sign(Xts*alpha_dist_OC);
   err_test_dist_OC = sum(1-yprev_dist_OC.*yts)/(2*size(yts,1));
end
time_dist_OC = toc;

%% TRAIN FOR DIST corr
disp('STV: TRAIN FOR DIST corr');
tic
if (idx_best_lambda_1_dist_corr == idx_best_lambda_1_accuracy) && (idx_best_lambda_1_dist_corr == idx_best_lambda_2_accuracy)
   alpha_dist_corr = alpha_dist_accuracy;
   iters_dist_corr = iters_dist_accuracy;
   costs_dist_corr = costs_dist_accuracy;
   yprev_dist_corr = yprev_dist_accuracy;
   err_val_dist_corr = err_val_dist_accuracy;
elseif (idx_best_lambda_1_dist_corr == idx_best_lambda_1_dist_OC) && (idx_best_lambda_1_dist_corr == idx_best_lambda_2_dist_OC)
   alpha_dist_corr = alpha_dist_dist_OC;
   iters_dist_corr = iters_dist_dist_OC;
   costs_dist_corr = costs_dist_dist_OC;
   yprev_dist_corr = yprev_dist_dist_OC;
   err_test_dist_corr = err_val_dist_dist_OC;
else
   lambda1 = lambda_1s(idx_best_lambda_1_dist_corr);
   lambda2 = lambda_2s(idx_best_lambda_2_dist_corr);
   lambda1 = lambda1*regpar1_max;
   % Create proper matrix B
   B = [lambda1*speye(n); lambda2*C];
   pars.kappa = Li_X/(lambda1^2 + lambda2^2*normBsqr);

   [alpha_dist_corr iters_dist_corr costs_dist_corr prox_iters_dist_corr] =...
       aifobas_complasso_warm(Xtr, ytr, B, 1, pars);
   yprev_dist_corr = sign(Xts*alpha_dist_corr);
   err_test_dist_corr = sum(1-yprev_dist_corr.*yts)/(2*size(yts,1));
end
time_dist_corr = toc;

clear Xtr ytr Xts yts
disp('FINISHED!');
fsave = sprintf('RESULTS_TRAIN/STV_loo_%d_p_%g.mat',ks, p);
save(fsave);
exit