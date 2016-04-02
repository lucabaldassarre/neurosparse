% Number of subjects
ns = 16;

% Number of examples per subject
step = 84;

% Load data with p-values associated to t-test for each feature
p = 0.5;
load(sprintf('../c1_c3_data_mask_p_%g.mat',p));
% Total number of voxels
n = size(X,2);

alpha = zeros(ns,n);
time = zeros(ns,1);
err_class = zeros(ns,1);

for ks = 1:ns
   %% CREATE TRAIN AND TEST SETS
   fprintf('Subject left out %d of %d\n',ks,ns);

   Xts = X(step*(ks-1)+1:step*ks,:);
   yts = Y(step*(ks-1)+1:step*ks,:);

   Xtr = X(setdiff(1:size(X,1),step*(ks-1)+1:step*ks),:);
   ytr = Y(setdiff(1:size(X,1),step*(ks-1)+1:step*ks),:);

   %% NORMALIZATION
   means = mean(Xtr);
   stds = std(Xtr);

   Xtr = Xtr - repmat(means,size(Xtr,1),1);
   Xtr = Xtr./repmat(stds,size(Xtr,1),1);
   Xts = Xts - repmat(means,size(Xts,1),1);
   Xts = Xts./repmat(stds,size(Xts,1),1);

   %% LEAST SQUARES
   tic
   K = Xtr*Xtr';
   alpha(ks,:) = Xtr'*(K\ytr);   
   time(ks) = toc;
   yprev = sign(Xts*alpha(ks,:)');
   err_class(ks) = sum(1-yprev.*yts)/(2*size(yts,1));

end

%% COMPUTE RESULTS
mean_err_class = mean(err_class);
std_err_class = std(err_class);
corr = corrcoef(alpha');
dummy = corr;
dummy(1:ns+1:end) = [];
mean_corr = mean(dummy(:));
std_corr = std(dummy(:));

clear X Y Xtr ytr Xts yts stds means yprev ks K dummy
save LS_block_mask