% Number of subjects
ns = 15;

% Number of examples per subject
step = 36;

% Load data with p-values associated to t-test for each feature
p = 0.5;
load(sprintf('../c1_c3_data_mask_p_%g.mat',p),'X','Y');
% Total number of voxels
n = size(X,2);

% Selected features correspond to
perc = 0.05;
nsel = round(n*perc);

alpha = cell(ns,1);
time = zeros(ns,1);
err_class = zeros(ns,1);
idx_n = cell(ns,1);

%% 10% features experiment

for ks = 1:ns
   %% CREATE TRAIN AND TEST SETS
   fprintf('Subject left out %d of %d\n',ks,ns);

   Xts = X(step*(ks-1)+1:step*ks,:);
   yts = Y(step*(ks-1)+1:step*ks,:);

   Xtr = X(setdiff(1:size(X,1),step*(ks-1)+1:step*ks),:);
   ytr = Y(setdiff(1:size(X,1),step*(ks-1)+1:step*ks),:);

   %% NORMALIZATION
   disp('Normalization');
   means = mean(Xtr);
   stds = std(Xtr);

   Xtr = Xtr - repmat(means,size(Xtr,1),1);
   Xtr = Xtr./repmat(stds,size(Xtr,1),1);
   Xts = Xts - repmat(means,size(Xts,1),1);
   Xts = Xts./repmat(stds,size(Xts,1),1);
   
   %% COMPUTE T-TEST on TRAINING SET ONLY
   % Compute t and p -values
   disp('Computing t-test');
   [p, t, df] = mattest(Xtr(ytr==1,:)',Xtr(ytr==-1,:)','VarType','equal');
   % Sort the p values in ascending order
   [dummy idx_sorted] = sort(p);
   idx{ks} = idx_sorted(1:nsel);
   Xtr = Xtr(:,idx{ks});
   Xts = Xts(:,idx{ks});

   %% LEAST SQUARES
   disp('Computing LS solution');
   tic
   K = Xtr*Xtr';
   alpha{ks} = Xtr'*(K\ytr);   
   time(ks) = toc;
   yprev = sign(Xts*alpha{ks});
   err_class(ks) = sum(1-yprev.*yts)/(2*size(yts,1));

end

clear X Y Xtr ytr Xts yts stds means yprev ks ans K dummy idx_sorted p df t
save LS_ttest_5_perc_proper