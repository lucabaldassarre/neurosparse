function [] = ENET_val_rerun(id)

% neuro(id)
% Executes ELASTIC NET regularization on Janaina's data on the cluster
% id - task id

% Data parameters
id = str2double(id);
% Retrieve original job id
load ENET_missing_jobs;
id = missing_jobs(id,1);
ns = 15; %Number of subjects for test Leave-One-Subject-Out
nsv = 14; %Number of subjects for validation Leave-One-Subject-Out
step = 36;

% Optimization parameters
tol_fista = 1e-5;
maxiter_fista = 1e4;

%Regularization parameters
nlambda_1 = 10;
% lambda_1s = logspace(log10(0.9), log10(1e-5), nlambda_1);
lambda_1s = logspace(0,-4,nlambda_1);
nlambda_2 = 10;
lambda_2s = logspace(4,-2,nlambda_2);


%% Find task indices - splitting jobs by subjects and lambda_2
ks = ceil(id/(nsv*nlambda_2)); %Subject out
temp = mod(id,(nsv*nlambda_2));
if temp == 0
   temp = nsv*nlambda_2;
end
ksv = ceil(temp/nlambda_2);
klambda_2 = mod(temp,nlambda_2);
if klambda_2 == 0
   klambda_2 = nlambda_2;
end

%%
% Set the value of \lambda_2
lambda_2 = lambda_2s(klambda_2);


%% CREATE TRAIN AND TEST SETS
p = 0.5;
disp(datestr(now));
fprintf('ENET - p = %g - tol = %g - Starting model selection \n', p, tol_fista);
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

% m = size(Xtr,1);
% tic
% Li_X = eigs(Xtr*Xtr',1,'LM')/m;
% time_Li = toc;

alpha = zeros(n,nlambda_1);
t = zeros(nlambda_1,1);
costs = cell(nlambda_1,1);
time = zeros(nlambda_1,1);
yprev = zeros(size(Xva,1),nlambda_1);
err_val = zeros(nlambda_1,1);

% lambda_1_max = max(abs(Xtr'*ytr));
lambda_1_max = 1;

for klambda_1 = 1:nlambda_1
   tic
   disp(datestr(now));
   fprintf('ENET: Subject test loo = %d of %d, Subject val loo = %d of %d, lambda_2 = %d of %d Reg par = %d of %d\n',ks,ns,ksv,nsv,klambda_2, nlambda_2, klambda_1,nlambda_1);
   lambda_1 = lambda_1s(klambda_1)*lambda_1_max;
   if klambda_1 == 1
      [alpha(:,klambda_1) t(klambda_1) costs{klambda_1}] =...
          fista_enet(Xtr, ytr, lambda_1, lambda_2, tol_fista, maxiter_fista, Li_X, zeros(n,1));
   else
      [alpha(:,klambda_1) t(klambda_1) costs{klambda_1}] =...
          fista_enet(Xtr, ytr, lambda_1, lambda_2, tol_fista, maxiter_fista, Li_X, alpha(:,klambda_1-1));
   end
   time(klambda_1) = toc;
    fprintf('Elapsed time: %g minutes\n',time(klambda_1)/60)
   yprev(:,klambda_1) = sign(Xva*alpha(:,klambda_1));
   err_val(klambda_1) = sum(1-yprev(:,klambda_1).*yva)/(2*size(yva,1));
end

clear Xtr ytr Xts yts Xva yva Li_X klambda_1 means stds temp
disp(datestr(now));
disp('FINISHED!');
fsave = sprintf('RESULTS_VAL/ENET_loo_%d_val_%d_regpar2_%d_tol_%g_p_%g.mat', ks, ksv, klambda_2, tol_fista, p);
save(fsave);
exit