function [] = SLAP_val(id)

% neuro(id)
% Executes SPARSE LAPLACIAN regularization on Janaina's data on the cluster
% Assesing fewer values for the parameter that balances LAP and L1
% id - task id

id = str2double(id);
ns = 16; %Number of subjects for test Leave-One-Subject-Out
nsv = 15; %Number of subjects for validation Leave-One-Subject-Out
step = 84;

% Regularization parameters
% Laplacian term
ngammas = 10;
gammas = logspace(1,-4,ngammas);
% L1 term
nlambdas = 10;
% lambdas = logspace(log10(4^1), log10(4^-7), nlambdas);
lambdas = logspace(1, -4, nlambdas);

%% Find task indices
ks = ceil(id/(nsv*ngammas)); %Subject out
temp = mod(id,(nsv*ngammas));
if temp == 0
   temp = nsv*ngammas;
end
ksv = ceil(temp/ngammas); %Internal subject out
gamma_ind = mod(temp,ngammas);
if gamma_ind == 0
   gamma_ind = ngammas;
end

gamma = gammas(gamma_ind);

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

alpha = zeros(n,nlambdas);
t = zeros(nlambdas,1);
costs = cell(nlambdas,1);
time = zeros(nlambdas,1);
yprev = zeros(size(Xva,1),nlambdas);
err_val = zeros(nlambdas,1);

for klambda = 1:nlambdas
   tic
   disp(datestr(now));
   fprintf('SLAP: Subject test loo = %d of %d, Subject val loo = %d of %d, gamma = %d of %d Reg par = %d of %d\n',ks,ns,ksv,nsv,gamma_ind, ngammas, klambda, nlambdas);
   lambda = lambdas(klambda);
   % Lipschitz constant of gradient of smooth part
   Li = Li_X + gamma*Li_L;
   if klambda == 1
      [alpha(:,klambda) t(klambda) costs{klambda}] =...
          fista_laplacian(Xtr, ytr, L, lambda, gamma, tol_fista, maxiter_fista, Li, zeros(n,1));
   else
      [alpha(:,klambda) t(klambda) costs{klambda}] =...
          fista_laplacian(Xtr, ytr, L, lambda, gamma, tol_fista, maxiter_fista, Li, alpha(:,klambda-1));
   end
   time(klambda) = toc;
   fprintf('Elapsed time: %g minutes\n',time(klambda)/60)
   yprev(:,klambda) = sign(Xva*alpha(:,klambda));
   err_val(klambda) = sum(1-yprev(:,klambda).*yva)/(2*size(yva,1));
end

clear Xtr ytr Xts yts Xva yva L Li Li_L Li_X klambda means stds temp
disp(datestr(now));
disp('FINISHED!');
fsave = sprintf('RESULTS_VAL/SLAP_loo_%d_val_%d_gamma_%d_tol_%g_p_%g.mat',ks, ksv, gamma_ind, tol_fista, p);
save(fsave);
exit