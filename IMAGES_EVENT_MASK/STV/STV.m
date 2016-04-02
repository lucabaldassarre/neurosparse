function [] = STV

% Executes Sparse Total Variation (anysotropic) regularization
% It requires a connection matrix B that encodes the adjacency graph
% between voxels, that is B is m x n, where m is the number of edges and n
% is the number of voxels. B_ji = 1 and B_jk = -1 if voxel i and k are
% next to each other (in one of the 3 dimensions).

% (c) Luca Baldassarre
% luca.baldassarre@epfl.ch
% 05/10/2012

% Load the connection matrix
load('../connection_matrix.mat','B','normBsqr');
C = B;
clear B;
% Load the data
load('data','Xtr','ytr','Xts','yts');
n = size(Xtr,2);

% Optimization parameters
pars.tol = 1e-5;
pars.coeff = 1;
pars.maxiter = 1e4;
pars.inner_maxiter = 1e3;
pars.x0 = zeros(n,1);

%% Normalization

means = mean(Xtr);
stds = std(Xtr);

Xtr = Xtr - repmat(means,size(Xtr,1),1);
Xtr = Xtr./repmat(stds,size(Xtr,1),1);
Xts = Xts - repmat(means,size(Xts,1),1);
Xts = Xts./repmat(stds,size(Xts,1),1);

m = size(Xtr,1);
n = size(Xtr,2);
% Loads Lipschitz constant of gradient of empirical risk
% or computes it if does not exit
fload = '../Li.mat';
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

%% TRAIN FOR ACCURACY
disp('STV: TRAIN FOR ACCURACY');
% set values of regularization parameters
% lambda1 = ;
% lambda2 = ;

% Create proper matrix B for composite $\ell_1$-norm minimization
tic
B = [lambda1*speye(n); lambda2*C];
pars.kappa = Li_X/(lambda1^2 + lambda2^2*normBsqr);
pars.gamma = 1; % Regularization parameters are already included in B

[alpha iters costs prox_iters] =...
       aifobas_complasso_warm(Xtr, ytr, B, 1, pars);
yprev = sign(Xts*alpha);
err_test = sum(1-yprev.*yts)/(2*size(yts,1));
time = toc;

clear Xtr ytr Xts yts
disp('FINISHED!');
save('STV_train');
exit