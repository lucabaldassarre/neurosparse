%% Load data
load('../RESULTS/results_mask.mat')
addpath('../UTILITIES/');

%% Compare new implementation of Welch's ttest to Matlab's
% Note that Matlab's requires the entire vector, while the new requires
% only mean, sample standard deviation and number of samples for each
% distribution
[h, p, ci, stats] = ttest2(block_all_errors(4,:),block_all_errors(5,:),'Vartype','unequal')

A = block_all_errors([4, 5],:);
A = A';
mu = mean(A);
s  = std(A);
N(1)  = 16;
N(2)  = 16;
[h, p, t, nu] = welchtest(mu, s, N)

%% Compare LASSO accuracy difference between model selection ACC and ACC/OC
modelID = 4;
mu(1)   = block_accuracy(modelID, 1);
s(1)    = block_accuracy(modelID, 2);
N(1)    = 16;

mu(2)   = block_dist_OC(modelID, 2);
s(2)    = block_dist_OC(modelID, 3);
N(2)    = 16;

[h, p, t, nu] = welchtest(mu, s, N)

%% Compare LASSO OC difference between model selection ACC and ACC/OC
modelID = 4;
mu(1)   = block_accuracy(modelID, 9);
s(1)    = block_accuracy(modelID, 10);
N(1)    = 16;

mu(2)   = block_dist_OC(modelID, 10);
s(2)    = block_dist_OC(modelID, 11);
N(2)    = 16;

[h, p, t, nu] = welchtest(mu, s, N)

%% Compare ENET accuracy difference between model selection ACC and ACC/OC
mu(1)   = block_accuracy(5,1);
s(1)    = block_accuracy(5,2);
N(1)    = 16;

mu(2)   = block_dist_OC(5, 2);
s(2)    = block_dist_OC(5, 3);
N(2)    = 16;

[h, p, t, nu] = welchtest(mu, s, N)

%% Compare ENET OC difference between model selection ACC and ACC/OC
mu(1)   = block_accuracy(5, 9);
s(1)    = block_accuracy(5, 10);
N(1)    = 16;

mu(2)   = block_dist_OC(5, 10);
s(2)    = block_dist_OC(5, 11);
N(2)    = 16;

[h, p, t, nu] = welchtest(mu, s, N)

%% Compare STV accuracy difference between model selection ACC and ACC/OC
mu(1)   = block_accuracy(7,1);
s(1)    = block_accuracy(7,2);
N(1)    = 16;

mu(2)   = block_dist_OC(7, 2);
s(2)    = block_dist_OC(7, 3);
N(2)    = 16;

[h, p, t, nu] = welchtest(mu, s, N, 0.01)

%% Compare STV OC difference between model selection ACC and ACC/OC
mu(1)   = block_accuracy(7, 9);
s(1)    = block_accuracy(7, 10);
N(1)    = 16;

mu(2)   = block_dist_OC(7, 10);
s(2)    = block_dist_OC(7, 11);
N(2)    = 16;

[h, p, t, nu] = welchtest(mu, s, N)

%% Compare SLAP accuracy difference between model selection ACC and ACC/OC
modelId = 8;
mu(1)   = block_accuracy(modelId, 1);
s(1)    = block_accuracy(modelId, 2);
N(1)    = 16;

mu(2)   = block_dist_OC(modelId, 2);
s(2)    = block_dist_OC(modelId, 3);
N(2)    = 16;

[h, p, t, nu] = welchtest(mu, s, N, 0.01)

%% Compare SLAP OC difference between model selection ACC and ACC/OC
modelId = 8;
mu(1)   = block_accuracy(modelId, 9);
s(1)    = block_accuracy(modelId, 10);
N(1)    = 16;

mu(2)   = block_dist_OC(modelId, 10);
s(2)    = block_dist_OC(modelId, 11);
N(2)    = 16;

[h, p, t, nu] = welchtest(mu, s, N)

%% Compare LASSO sparsity difference between model selection ACC and ACC/OC
modelId = 4;
mu(1)   = block_accuracy(modelId, 5);
s(1)    = block_accuracy(modelId, 6);
N(1)    = 16;

mu(2)   = block_dist_OC(modelId, 6);
s(2)    = block_dist_OC(modelId, 7);
N(2)    = 16;

[h, p, t, nu] = welchtest(mu, s, N)

%% Compare ENET sparsity difference between model selection ACC and ACC/OC
modelId = 5;
mu(1)   = block_accuracy(modelId, 5);
s(1)    = block_accuracy(modelId, 6);
N(1)    = 16;

mu(2)   = block_dist_OC(modelId, 6);
s(2)    = block_dist_OC(modelId, 7);
N(2)    = 16;

[h, p, t, nu] = welchtest(mu, s, N)

%% Compare STV sparsity difference between model selection ACC and ACC/OC
modelId = 7;
mu(1)   = block_accuracy(modelId, 5);
s(1)    = block_accuracy(modelId, 6);
N(1)    = 16;

mu(2)   = block_dist_OC(modelId, 6);
s(2)    = block_dist_OC(modelId, 7);
N(2)    = 16;

[h, p, t, nu] = welchtest(mu, s, N)

%% Compare SLAP sparsity difference between model selection ACC and ACC/OC
modelId = 8;
mu(1)   = block_accuracy(modelId, 5);
s(1)    = block_accuracy(modelId, 6);
N(1)    = 16;

mu(2)   = block_dist_OC(modelId, 6);
s(2)    = block_dist_OC(modelId, 7);
N(2)    = 16;

[h, p, t, nu] = welchtest(mu, s, N)

%% Compare OC between SLAP and ENET using Acc/OC
mu(1)   = block_dist_OC(8, 10);
s(1)    = block_dist_OC(8, 11);
N(1)    = 16;

mu(2)   = block_dist_OC(5, 10);
s(2)    = block_dist_OC(5, 11);
N(2)    = 16;

[h, p, t, nu] = welchtest(mu, s, N)
% h =
%    1
% p =
%     0.0030