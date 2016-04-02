function [] = LAP_train(ks)

% Executes LASSO training with the regularization parameters found during validation
% on Janaina's data on the cluster
% id - task id

ks = str2double(ks);
ns = 16; %Number of subjects for test Leave-One-Subject-Out
step = 84;
p = 0.5;

% Optimization parameters
tol_fista = 1e-5;
maxiter_fista = 1e4;

% Regularization parameters
lambda = 0; %No L1 regularization term
% Laplacian term
ngammas = 10;
gammas = logspace(4,-5,ngammas);

fload = sprintf('RESULTS_VAL/LAP_loo_errs_%d_%g.mat', ks, p);
load(fload,'idx_best_regpar_accuracy','idx_best_regpar_dist_corr');

% REGULARIZATION PARAMETER

regpar_accuracy = gammas(idx_best_regpar_accuracy);
regpar_dist_corr = gammas(idx_best_regpar_dist_corr);

%%
% Load the connection matrix
load(sprintf('L_p_%g.mat',p),'L','Li_L');
% Load the data
load(sprintf('../c1_c3_data_mask_p_%g.mat',p),'X','Y');

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

%% ACCURACY
disp(datestr(now));
fprintf('LAP: Subject test loo = %d of %d - Accuracy \n',ks,ns)
tic
Li = Li_X + regpar_accuracy*Li_L;
[alpha_accuracy iters_accuracy costs_accuracy] =...
   fista_laplacian(Xtr, ytr, L, lambda, regpar_accuracy, tol_fista, maxiter_fista, Li, zeros(n,1));
time_accuracy = toc;
yprev_accuracy = sign(Xts*alpha_accuracy);
err_test_accuracy = sum(1-yprev_accuracy.*yts)/(2*size(yts,1));


%% DIST CORR
disp(datestr(now));
fprintf('LAP: Subject test loo = %d of %d - Distance correlation\n',ks,ns)
tic
if idx_best_regpar_dist_corr == idx_best_regpar_accuracy
   alpha_dist_corr = alpha_accuracy;
   iters_dist_corr = iters_accuracy;
   costs_dist_corr = costs_accuracy;
   yprev_dist_corr = yprev_accuracy;
   err_test_dist_corr = err_test_accuracy;
% elseif idx_best_regpar_dist_corr == idx_best_regpar_dist_OC
%    alpha_dist_corr = alpha_dist_OC;
%    iters_dist_corr = iters_dist_OC;
%    costs_dist_corr = costs_dist_OC;
%    yprev_dist_corr = yprev_dist_OC;
%    err_test_dist_corr = err_test_dist_OC;
else
   Li = Li_X + regpar_dist_corr*Li_L;
   [alpha_dist_corr iters_dist_corr costs_dist] =...
             fista_laplacian(Xtr, ytr, L, lambda, regpar_dist_corr, tol_fista, maxiter_fista, Li, zeros(n,1));
   yprev_dist_corr = sign(Xts*alpha_dist_corr);
   err_test_dist_corr = sum(1-yprev_dist_corr.*yts)/(2*size(yts,1));
end
time_dist_corr = toc;

%% FINISH

clear Xtr ytr Xts yts
disp(datestr(now));
fprintf('FINISHED!\n');
fsave = sprintf('RESULTS_TRAIN/LAP_loo_%d_p_%g.mat', ks, p);
save(fsave);
exit