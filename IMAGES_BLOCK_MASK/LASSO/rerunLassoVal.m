%% Set up
ns      = 16; %Number of subjects for test Leave-One-Subject-Out
nsv     = 15; %Number of subjects for validation Leave-One-Subject-Out
nTasks  = 240; 

%% Check what has run
fileList    = dir('RESULTS_VAL\*.mat');
nFiles      = numel(fileList);

runTasksId = zeros(nFiles,1);
for kFile = 1:fileList
    tmp = sscanf(fileList(kFile).name, 'LASSO_loo_%d_val_%d_tol_%g_p_%g.mat');
    ks  = tmp(1);
    ksv = tmp(2);
    id  = nsv*(ks-1) + ksv;
    runTasksId(kFile) = id;
end

%% Re-Run
newTasks = setdiff(1:240, runTasksId);

parfor kTask = newTasks
    LASSO_val(num2str(kTask));
end