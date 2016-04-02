function [] = RR_val(id)

% neuro(id)
% Executes t-test + Ridge Regression regularization on Janaina's data on the cluster
% id - task id (1 to 240)

% Data parameters
% id = str2double(id);
ns = 16; %Number of subjects for test Leave-One-Subject-Out
nsv = 15; %Number of subjects for validation Leave-One-Subject-Out
step = 84;

% Which threshold
% p = 0.75;
p_mask = 0.5;

% Percentage of features to retain via t-test
perc = 0.025;

% Regularization parameters
nlambdas = 10;
lambdas = logspace(2, 5, nlambdas);

%% Find task indices - splitting jobs by subjects
ks = ceil(id/nsv); %Subject out
temp = mod(id,nsv);
if temp == 0
   temp = nsv;
end
ksv = temp;

%% CREATE TRAIN AND TEST SETS
% Load the data

load(sprintf('../c1_c3_data_mask_p_%g.mat',p_mask));

a = setdiff(1:size(X,1),step*(ks-1)+1:step*ks); %#ok<*NODEF>

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

[m, n] = size(Xtr);

% Select features via t-test
nsel = round(n*perc);

% Compute t and p -values
disp('Computing t-test');
tic
[p, ~, ~] = mattest(Xtr(ytr==1,:)',Xtr(ytr==-1,:)','VarType','equal');
% Sort the p values in ascending order
[~, idx_sorted] = sort(p);
time_ttest = toc
idx = idx_sorted(1:nsel);
Xtr = Xtr(:,idx);
Xva = Xva(:,idx);

alpha   = zeros(nsel,nlambdas);
time    = zeros(nlambdas,1);
yprev   = zeros(size(Xva,1),nlambdas);
err_val = zeros(nlambdas,1);

for klambda = 1:nlambdas
   tic
   disp(datestr(now));
   fprintf('RR: Subject test loo = %d of %d, Subject val loo = %d of %d, Reg par = %d of %d\n',ks,ns,ksv,nsv, klambda,nlambdas);
   lambda = lambdas(klambda);
   alpha(:,klambda) = (Xtr'*Xtr + lambda*eye(nsel))\(Xtr'*ytr);
   time(klambda) = toc;
   fprintf('Elapsed time: %g minutes\n',time(klambda)/60);
   yprev(:,klambda) = sign(Xva*alpha(:,klambda));
   err_val(klambda) = sum(1-yprev(:,klambda).*yva)/(2*size(yva,1));
end

clear Xtr ytr Xts yts Xva yva Li_X klambda means stds temp
disp(datestr(now));
disp('FINISHED!');
fsave = sprintf('RESULTS_VAL/RR_loo_%d_val_%d_p_%g_perc_%1.1f.mat', ks, ksv, p_mask, perc*100);
save(fsave);
% exit