function [] = LAP_val(id)

% neuro(id)
% Executes LAPLACIAN regularization on Janaina's data on the cluster
% id - task id

id = str2double(id);
ns = 15; %Number of subjects for test Leave-One-Subject-Out
nsv = 14; %Number of subjects for validation Leave-One-Subject-Out
step = 36;

% Optimization parameters
tol_fista = 1e-5;
maxiter_fista = 1e4;

% Mask threshold
p = 0.5;

lambda = 0; %No L1 regularization term

% Regularization parameters
% Laplacian term
nregpars = 10;
% regpars = logspace(1,-4,nregpars);
regpars = logspace(0.5,-5,nregpars);

%% Find task indices
ks = ceil(id/(nsv)); %Subject out
temp = mod(id,nsv);
if temp == 0
   temp = nsv;
end
ksv = temp;


% Load the connection matrix
load(sprintf('L_p_%g.mat',p),'L','Li_L');
% Load the data
load(sprintf('../c1_c3_data_mask_p_%g.mat',p),'X','Y');
n = size(X,2);


%% CREATE TRAIN AND TEST SETS

fprintf('SLAP - p = %g - tol = %g - Starting model selection \n', p, tol_fista);

%Xts = X(step*(ks-1)+1:step*ks,:);
%yts = Y(step*(ks-1)+1:step*ks,:);

Xtr = X(setdiff(1:size(X,1),step*(ks-1)+1:step*ks),:);
ytr = Y(setdiff(1:size(X,1),step*(ks-1)+1:step*ks),:);

clear X Y

%% CREATE TRAIN AND VALIDATION SETS

Xva = Xtr(step*(ksv-1)+1:step*ksv,:);
yva = ytr(step*(ksv-1)+1:step*ksv,:);

Xtr = Xtr(setdiff(1:size(Xtr,1),step*(ksv-1)+1:step*ksv),:);
ytr = ytr(setdiff(1:size(ytr,1),step*(ksv-1)+1:step*ksv),:);


%% Normalization

means = mean(Xtr);
stds = std(Xtr);

Xtr = Xtr - repmat(means,size(Xtr,1),1);
Xtr = Xtr./repmat(stds,size(Xtr,1),1);
Xva = Xva - repmat(means,size(Xva,1),1);
Xva = Xva./repmat(stds,size(Xva,1),1);

[m n] = size(Xtr);
% Compute Lipschitz constant of gradient of square loss
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

alpha = zeros(n,nregpars);
t = zeros(nregpars,1);
costs = cell(nregpars,1);
time = zeros(nregpars,1);
yprev = zeros(size(Xva,1),nregpars);
err_val = zeros(nregpars,1);

for kregpar = 1:nregpars
   tic
   disp(datestr(now));
   fprintf('SLAP: Subject test loo = %d of %d, Subject val loo = %d of %d, regpar = %d of %d\n',ks,ns,ksv,nsv, kregpar, nregpars);
   regpar = regpars(kregpar);
   % Lipschitz constant of gradient of smooth part
   Li = Li_X + regpar*Li_L;
   if kregpar == 1
      [alpha(:,kregpar) t(kregpar) costs{kregpar}] =...
          fista_laplacian(Xtr, ytr, L, lambda, regpar, tol_fista, maxiter_fista, Li, zeros(n,1));
   else
      [alpha(:,kregpar) t(kregpar) costs{kregpar}] =...
          fista_laplacian(Xtr, ytr, L, lambda, regpar, tol_fista, maxiter_fista, Li, alpha(:,kregpar-1));
   end
   time(kregpar) = toc;
   fprintf('Elapsed time: %g minutes\n',time(kregpar)/60)
   yprev(:,kregpar) = sign(Xva*alpha(:,kregpar));
   err_val(kregpar) = sum(1-yprev(:,kregpar).*yva)/(2*size(yva,1));
end

clear Xtr ytr Xts yts Xva yva L Li Li_L Li_X kregpar means stds temp
disp(datestr(now));
disp('FINISHED!');
fsave = sprintf('RESULTS_VAL/LAP_loo_%d_val_%d_tol_%g_p_%g.mat',ks, ksv, tol_fista, p);
save(fsave);
exit