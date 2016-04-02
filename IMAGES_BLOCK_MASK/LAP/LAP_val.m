function [] = LAP_val(id)

% neuro(id)
% Executes LAPLACIAN regularization on Janaina's data on the cluster
% id - task id

id = str2double(id);
ns = 16; %Number of subjects for test Leave-One-Subject-Out
nsv = 15; %Number of subjects for validation Leave-One-Subject-Out
step = 84;

lambda = 0; %No L1 regularization term

% Regularization parameters
% Laplacian term
ngammas = 10;
gammas = logspace(4,-5,ngammas);

%% Find task indices
ks = ceil(id/(nsv)); %Subject out
temp = mod(id,nsv);
if temp == 0
   temp = nsv;
end
ksv = temp;

% Optimization parameters

tol_fista = 1e-5;
maxiter_fista = 1e4;

% Mask threshold
p = 0.5;
% Load the connection matrix
load(sprintf('L_p_%g.mat',p),'L','Li_L');
% Load the data
load(sprintf('../c1_c3_data_mask_p_%g.mat',p),'X','Y');
n = size(X,2);


%% CREATE TRAIN AND TEST SETS

fprintf('LAP - p = %g - tol = %g - Starting model selection \n', p, tol_fista);

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

alpha = zeros(n,ngammas);
t = zeros(ngammas,1);
costs = cell(ngammas,1);
time = zeros(ngammas,1);
yprev = zeros(size(Xva,1),ngammas);
err_val = zeros(ngammas,1);

for kgamma = 1:ngammas
   tic
   gamma = gammas(kgamma);
   disp(datestr(now));
   fprintf('LAP: Subject test loo = %d of %d, Subject val loo = %d of %d, gamma = %d of %d\n',ks,ns,ksv,nsv, kgamma, ngammas);
   % Lipschitz constant of gradient of smooth part
   Li = Li_X + gamma*Li_L;
   if kgamma == 1
      [alpha(:,kgamma) t(kgamma) costs{kgamma}] =...
          fista_laplacian(Xtr, ytr, L, lambda, gamma, tol_fista, maxiter_fista, Li, zeros(n,1));
   else
      [alpha(:,kgamma) t(kgamma) costs{kgamma}] =...
          fista_laplacian(Xtr, ytr, L, lambda, gamma, tol_fista, maxiter_fista, Li, alpha(:,kgamma-1));
   end
   time(kgamma) = toc;
   fprintf('Elapsed time: %g minutes\n',time(kgamma)/60);
   yprev(:,kgamma) = sign(Xva*alpha(:,kgamma));
   err_val(kgamma) = sum(1-yprev(:,kgamma).*yva)/(2*size(yva,1));
end

clear Xtr ytr Xts yts Xva yva L Li Li_L Li_X kgamma means stds temp
disp(datestr(now));
disp('FINISHED!');
fsave = sprintf('RESULTS_VAL/LAP_loo_%d_val_%d_tol_%g_p_%g.mat',ks, ksv, tol_fista, p);
save(fsave);
exit