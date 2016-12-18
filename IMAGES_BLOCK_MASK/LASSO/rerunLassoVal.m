%% Set up
addpath('../../UTILITIES/');
addpath('../../SOLVERS/');
ns      = 16; %Number of subjects for test Leave-One-Subject-Out
nsv     = 15; %Number of subjects for validation Leave-One-Subject-Out
nTasks  = 240; 

%% Check what has run
fileList    = dir('RESULTS_VAL\*.mat');
nFiles      = numel(fileList);

runTasksId = zeros(nFiles,1);
for kFile = 1:nFiles
    tmp = sscanf(fileList(kFile).name, 'LASSO_loo_%d_val_%d_tol_%g_p_%g.mat');
    ks  = tmp(1);
    ksv = tmp(2);
    id  = nsv*(ks-1) + ksv;
    runTasksId(kFile) = id;
end

%% Re-Run
newTasks = setdiff(1:240, runTasksId);
numNewTasks = numel(newTasks);

parfor kTask = 1:numNewTasks
    id = num2str(newTasks(kTask));
    LASSO_val(id);
end