function [] = STV_val(id, algo, tol, p)

% Run model selection on fMRI data using Sparse Total Variation algorithm
% INPUT
% id       - Task id: selects the data split to use for train and for validation
%                   We use two nested loops of Leave-One-Subject
%                   Cross-Validaiton
% algo   - 1 selects FISTA, 0 selects ISTA (usually slower)
% tol     - Tolerance for stopping the optimization algorithm |V(k+1) -
%             V(k)|/V(k) < tol, where V is the objective function to be minimized
% p       - probability threshold for selecting gray matter voxels from a
%            probabilistic gray matter mask
%
% OUTPUT
% is written on a file


time_start = cputime;
% neuro(id)
% Executes TV + l1 regularization on Janaina's data on the cluster
% id - task id

%id = str2double(id);
ns = 16; %Number of subjects for test Leave-One-Subject-Out
nsv = 15; %Number of subjects for validation Leave-One-Subject-Out
step = 84;

% Regularization parameters
% L1 regularization parameter
% regpars1 = [0.9,0.5,0.1,0.05,0.01,0.005,1.0e-03,5.0e-04,1.0e-04,1.0e-05];
% nregpar1 = numel(regpars1);

nregpar1 = 10;
% regpars1 = logspace(log10(0.9), log10(1e-5), nregpar1);
regpars1 = logspace(0,-4,nregpar1);

% TV regularization parameter
% regparstv = 2.^(-1:-1:-10);
% nregpartv = numel(regparstv);

nregpartv = 10;
regparstv = logspace(log10(2^-1), log10(2^-10), nregpartv);

%% Find task indices
ks = ceil(id/(nsv*nregpartv)); %Subject out
temp = mod(id,(nsv*nregpartv));
if temp == 0
   temp = nsv*nregpartv;
end
ksv = ceil(temp/nregpartv); %Internal subject out
regpartv_ind = mod(temp,nregpartv); %TV parameter
if regpartv_ind == 0
   regpartv_ind = nregpartv;
end

% Load the connection matrix
load(sprintf('../connection_matrix_p_%g.mat',p),'B','normBsqr');
C = B;
clear B;
% Load the data
load(sprintf('../c1_c3_data_mask_p_%g.mat',p));
n = size(X,2);

% Optimization parameters
pars.tol = tol;
% pars.tol = 1e-8;
pars.coeff = 1;
pars.maxiter = 1e4;
pars.inner_maxiter = 1e3;
pars.x0 = zeros(n,1);

% Define filename for saving
if algo % FISTA
   pars.rate = 1;
   % Save file
   fsave = sprintf('RESULTS_VAL/STV_loo_%d_val_%d_regpartv_%d_fista_tol_%g_p_%g.mat',ks,ksv,regpartv_ind, pars.tol,p);
else
   pars.rate = 0.3;
   % Save file
   fsave = sprintf('RESULTS_VAL/STV_loo_%d_val_%d_regpartv_%d_ista_tol_%g_p_%g.mat',ks,ksv,regpartv_ind, pars.tol,p);
end

%% CREATE TRAIN AND TEST SETS

disp(datestr(now));
fprintf('STV - p = %g - tol = %g - Starting model selection \n', p, pars.tol);

Xtr = X(setdiff(1:size(X,1),step*(ks-1)+1:step*ks),:);
ytr = Y(setdiff(1:size(X,1),step*(ks-1)+1:step*ks),:);

%% CREATE TRAIN AND VALIDATION SETS

Xva = Xtr(step*(ksv-1)+1:step*ksv,:);
yva = ytr(step*(ksv-1)+1:step*ksv,:);

Xtr = Xtr(setdiff(1:size(Xtr,1),step*(ksv-1)+1:step*ksv),:);
ytr = ytr(setdiff(1:size(ytr,1),step*(ksv-1)+1:step*ksv),:);

clear X Y;
%% Normalization

means = mean(Xtr);
stds = std(Xtr);

Xtr = Xtr - repmat(means,size(Xtr,1),1);
Xtr = Xtr./repmat(stds,size(Xtr,1),1);
Xva = Xva - repmat(means,size(Xva,1),1);
Xva = Xva./repmat(stds,size(Xva,1),1);

m = size(Xtr,1);

% Loads Lipschitz constant of gradient of empirical risk if it exists
% otherwise computes it
fload = sprintf('../LIPSCHITZ/Li_loo_%d_val_%d_p_%g.mat',ks, ksv, p);
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

% Initialize variables
alpha = zeros(n,nregpar1);
iters = zeros(nregpar1,1);
costs = cell(nregpar1,1);
prox_iters = cell(nregpar1,1);
time = zeros(nregpar1,1);
yprev = zeros(size(Xva,1),nregpar1);
err_val = zeros(nregpar1,1);

% Maximum l1 regpar
% regpar1_max = max(abs(Xtr'*ytr))/m; 
regpar1_max = 1; 

for kregpar1 = 1:nregpar1
   tic
   regpar1 = regpars1(kregpar1)*regpar1_max;
   % Create proper matrix B
   B = [regpar1*speye(n); regparstv(regpartv_ind)*C];
   pars.kappa = Li_X/(regpar1^2 + regparstv(regpartv_ind)^2*normBsqr);
   
   disp(datestr(now));
   fprintf('Subject test loo = %d of %d, Subject val loo = %d of %d, Reg par TV = %d of %d, Reg par l1 = %d of %d\n',ks,ns,ksv,nsv,regpartv_ind, nregpartv, kregpar1,nregpar1);
   if algo
      [alpha(:,kregpar1) iters(kregpar1) costs{kregpar1} prox_iters{kregpar1}] =...
       aifobas_complasso_warm(Xtr, ytr, B, 1, pars);
   else
      [alpha(:,kregpar1) iters(kregpar1) costs{kregpar1} prox_iters{kregpar1}] =...
       ifobas_complasso_warm(Xtr, ytr, B, 1, pars);
   end
    time(kregpar1) = toc;
    fprintf('Elapsed time: %g minutes\n',time(kregpar1)/60)
    pars.x0 = alpha(:,kregpar1);

   yprev(:,kregpar1) = sign(Xva*alpha(:,kregpar1));
   err_val(kregpar1) = sum(1-yprev(:,kregpar1).*yva)/(2*size(yva,1));
end

clear Xtr ytr Xts yts Xva yva B C kregpar1
disp(datestr(now));
disp('FINISHED!');
time_end = cputime;
time_STV = (time_end-time_start)/60;
sprintf('Elapsed Time = %g minutes\n',time_STV);
save(fsave);
% exit