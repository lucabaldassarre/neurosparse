function [] = TV_val_ista(id)

time_start = cputime;
% neuro(id)
% Executes TV + l1 regularization on Janaina's data on the cluster
% id - task id

id = str2double(id);
ns = 16; %Number of subjects for test Leave-One-Subject-Out
nsv = 15; %Number of subjects for validation Leave-One-Subject-Out
step = 84;

% TV regularization parameter
%regparstv = 2.^(-1:-1:-10);
% nregpar = 100;
nregpar = 49;
regpars = logspace(log10(2^-1), log10(2^-10), nregpar);


%% Find task indices - splitting jobs by subjects
ks = ceil(id/nsv); %Subject out
temp = mod(id,nsv);
if temp == 0
   temp = nsv;
end
ksv = temp;

% Which threshold
p = 0.75;

% Load the connection matrix
load(sprintf('connection_matrix_p_%g.mat',p),'B','normBsqr');
% Load the data
load(sprintf('../c1_c3_data_mask_p_%g.mat',p));
n = size(X,2);

% Optimization parameters
pars.tol = 1e-8;
pars.coeff = 1;
pars.maxiter = 1e4;
pars.inner_maxiter = 1e3;
% pars.maxiter = 1e2;
% pars.inner_maxiter = 1e2;
pars.rate = 0.3;
pars.x0 = zeros(n,1);
pars.kappa = normBsqr;


%% CREATE TRAIN AND TEST SETS
disp(datestr(now));
fprintf('Starting LOO - subject out %d of %02d \n',ks,ns);

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

% Loads Lipschitz constant of gradient of empirical risk
fload = ['../LIPSCHITZ/Li_loo_',num2str(ks),'_val_',num2str(ksv)];
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
pars.kappa = pars.Li/pars.kappa;

% Initialize variables
alpha = zeros(n,nregpar);
iters = zeros(nregpar,1);
costs = cell(nregpar,1);
prox_iters = cell(nregpar,1);
time = zeros(nregpar,1);
yprev = zeros(size(Xva,1),nregpar);
err_val = zeros(nregpar,1);

for kregpar = 1:nregpar
      disp(datestr(now));
   fprintf('\nSubject test loo = %d of %d, Subject val loo = %d of %d, Reg par TV = %d of %d\n',ks,ns,ksv,nsv,kregpar,nregpar);
   [alpha(:,kregpar) iters(kregpar) costs{kregpar} prox_iters{kregpar}] =...
       ifobas_complasso_warm(Xtr, ytr, B, regpars(kregpar), pars);
    time(kregpar) = toc;
    fprintf('Elapsed time: %g minutes\n',time(kregpar)/60)
    pars.x0 = alpha(:,kregpar);

   yprev(:,kregpar) = sign(Xva*alpha(:,kregpar));
   err_val(kregpar) = sum(1-yprev(:,kregpar).*yva)/(2*size(yva,1));
end

clear Xtr ytr Xts yts Xva yva B kregpar
disp(datestr(now));
disp('FINISHED!');
time_end = cputime;
time_STV = (time_end-time_start)/60;
sprintf('Elapsed Time = %g minutes\n',time_STV);
fsave = sprintf('RESULTS_VAL/TV_loo_%d_val_%d_ista.mat',ks,ksv);
save(fsave);
exit