function [] = LASSO_val_MATLAB(id)

% neuro(id)
% Executes LASSO regularization on Janaina's data on the cluster
% id - task id

% Data parameters
id = str2double(id);
ns = 16; %Number of subjects for test Leave-One-Subject-Out
nsv = 15; %Number of subjects for validation Leave-One-Subject-Out
step = 84;

% Optimization parameters
tol_fista = 1e-9;
maxiter_fista = 1e4;

% Which threshold
p = 0.75;

%Load regularization parameters
load lambdas_lasso

%% Find task indices - splitting jobs by subjects
ks = ceil(id/nsv); %Subject out
temp = mod(id,nsv);
if temp == 0
   temp = nsv;
end
ksv = temp;

%% CREATE TRAIN AND TEST SETS
% Load the data

load(sprintf('../c1_c3_data_mask_p_%g.mat',p));

%Xts = X(step*(ks-1)+1:step*ks,:);
%yts = Y(step*(ks-1)+1:step*ks,:);

a = setdiff(1:size(X,1),step*(ks-1)+1:step*ks);

Xtr = X(a(setdiff(1:size(X,1)-step,step*(ksv-1)+1:step*ksv)),:);
ytr = Y(a(setdiff(1:size(X,1)-step,step*(ksv-1)+1:step*ksv)),:);

Xva = X(a(step*(ksv-1)+1:step*ksv),:);
yva = Y(a(step*(ksv-1)+1:step*ksv),:);

clear X Y a;

%% Normalization

means = mean(Xtr);
stds = std(Xtr);

Xtr = Xtr - repmat(means,size(Xtr,1),1);
Xtr = Xtr./repmat(stds,size(Xtr,1),1);
Xva = Xva - repmat(means,size(Xva,1),1);
Xva = Xva./repmat(stds,size(Xva,1),1);

n = size(Xtr,2);

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


alpha = zeros(n,nlambdas);
t = zeros(nlambdas,1);
costs = cell(nlambdas,1);
time = zeros(nlambdas,1);
yprev = zeros(size(Xva,1),nlambdas);
err_val = zeros(nlambdas,1);

lambda_max = max(abs(Xtr'*ytr))/m; %See Osborne et al.,On the LASSO and its Dual, 1999, where they don't have the 1/m term in front of the empirical risk
% Use fista for Elastic Net with l_2 par = 0
lambda_2 = 0;

lambdas = lambdas*lambda_max;
disp(datestr(now));
fprintf('LASSO: Subject test loo = %d of %d, Subject val loo = %d of %d, MATLAB function\n',ks,ns,ksv,nsv);

tic
[alpha, FitInfo] = lasso(Xtr, ytr, 'Lambda', lambdas, 'RelTol',1e-9);
time_lasso_matlab = toc;

for klambda = 1:nlambdas
   yprev(:,klambda) = sign(Xva*alpha(:,klambda));
   err_val(klambda) = sum(1-yprev(:,klambda).*yva)/(2*size(yva,1));
end

clear Xtr ytr Xts yts Xva yva Li_X klambda means stds temp
fsave = sprintf('RESULTS_VAL/LASSO_loo_%d_val_%d_MATLAB',ks,ksv);
save(fsave);
exit