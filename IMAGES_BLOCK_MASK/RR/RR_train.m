% function [] = RR_train(ks)

% Executes LASSO training with the regularization parameters found during validation
% on Janaina's data on the cluster
% id - task id

% ks      = str2double(ks);
ns      = 16; %Number of subjects for test Leave-One-Subject-Out
nsv     = 15; %Number of subjects for validation Leave-One-Subject-Out
step    = 84;
p_mask  = 0.5;
perc    = 0.025;

% Regularization parameters
nlambdas = 10;
lambdas = logspace(2, 5, nlambdas);

%%

load(sprintf('../c1_c3_data_mask_p_%g.mat',p_mask),'X','Y');

%%
for ks = 1:16
    
    fload = sprintf('RESULTS_VAL/RR_loo_errs_%d_perc_%1.1f.mat',ks, perc*100);
    load(fload,'idx_best_regpar_accuracy','idx_best_regpar_dist_OC','idx_best_regpar_dist_corr');

    %% CREATE TRAIN AND TEST SETS

    Xts = X(step*(ks-1)+1:step*ks,:); %#ok<*NODEF>
    yts = Y(step*(ks-1)+1:step*ks,:);

    Xtr = X(setdiff(1:size(X,1),step*(ks-1)+1:step*ks),:);
    ytr = Y(setdiff(1:size(X,1),step*(ks-1)+1:step*ks),:);

%     clear X Y;

    %% Normalization

    means = mean(Xtr);
    stds = std(Xtr);

    Xtr = Xtr - repmat(means,size(Xtr,1),1);
    Xtr = Xtr./repmat(stds,size(Xtr,1),1);
    Xts = Xts - repmat(means,size(Xts,1),1);
    Xts = Xts./repmat(stds,size(Xts,1),1);

    m = size(Xtr,1);
    n = size(Xtr,2);
    nsel = round(n*perc);

    % Compute t and p -values
    fsave_p = sprintf('../P_VALUES/p_values_%d_p_%g_perc_%1.1f.mat', ks, p_mask, perc*100);
    tic
    if exist(fsave_p,'file')
        disp('Loading t-test p-values');
        load(fsave_p,'p');
    else
        disp('Computing t-test');
        [p, ~, ~] = mattest(Xtr(ytr==1,:)',Xtr(ytr==-1,:)','VarType','equal');
        save(fsave_p,'p');
    end
    % Sort the p values in ascending order
    [~, idx_sorted] = sort(p);
    time_ttest = toc

    
    idx = idx_sorted(1:nsel);
    Xtr = Xtr(:,idx);
    Xts = Xts(:,idx);

    %% REGULARIZATION PARAMETER

    regpar_accuracy     = lambdas(idx_best_regpar_accuracy);
    regpar_dist_OC      = lambdas(idx_best_regpar_dist_OC);
    regpar_dist_corr    = lambdas(idx_best_regpar_dist_corr);

    %%
    disp(datestr(now));
    fprintf('RR: Subject test loo = %d of %d - Accuracy \n',ks,ns)
    tic
    alpha_accuracy = (Xtr'*Xtr + regpar_accuracy*eye(nsel))\(Xtr'*ytr);
    time_accuracy = toc; %#ok<*NASGU>
    yprev_accuracy = sign(Xts*alpha_accuracy);
    err_test_accuracy = sum(1-yprev_accuracy.*yts)/(2*size(yts,1));

    %%
    disp(datestr(now));
    fprintf('RR: Subject test loo = %d of %d - Distance OC\n',ks,ns)
    tic
    if idx_best_regpar_dist_OC == idx_best_regpar_accuracy
       alpha_dist_OC = alpha_accuracy;
       yprev_dist_OC = yprev_accuracy;
       err_test_dist_OC = err_test_accuracy;
    else
       alpha_dist_OC = (Xtr'*Xtr + regpar_dist_OC*eye(nsel))\(Xtr'*ytr);
       yprev_dist_OC = sign(Xts*alpha_dist_OC);
       err_test_dist_OC = sum(1-yprev_dist_OC.*yts)/(2*size(yts,1));
    end
    time_dist_OC = toc;

    %%
    disp(datestr(now));
    fprintf('RR: Subject test loo = %d of %d - Distance correlation\n',ks,ns)
    tic
    if idx_best_regpar_dist_corr == idx_best_regpar_accuracy
       alpha_dist_corr = alpha_accuracy;
       yprev_dist_corr = yprev_accuracy;
       err_test_dist_corr = err_test_accuracy;
    elseif idx_best_regpar_dist_corr == idx_best_regpar_dist_OC
       alpha_dist_corr = alpha_dist_OC;
       yprev_dist_corr = yprev_dist_OC;
       err_test_dist_corr = err_test_dist_OC;
    else
       alpha_dist_corr = (Xtr'*Xtr + regpar_dist_corr*eye(nsel))\(Xtr'*ytr);
       yprev_dist_corr = sign(Xts*alpha_dist_corr);
       err_test_dist_corr = sum(1-yprev_dist_corr.*yts)/(2*size(yts,1));
    end
    time_dist_corr = toc;


    clear Xtr ytr Xts yts
    disp(datestr(now));
    fprintf('FINISHED!\n');
    fsave = sprintf('RESULTS_TRAIN/RR_loo_%d_p_%g_perc_%1.1f.mat', ks, p_mask, perc*100);
    save(fsave, 'n', 'idx','regpar_accuracy','alpha_accuracy','time_accuracy','yprev_accuracy','err_test_accuracy',...
        'regpar_dist_OC','alpha_dist_OC','time_dist_OC','yprev_dist_OC','err_test_dist_OC',...
        'regpar_dist_corr','alpha_dist_corr','time_dist_corr','yprev_dist_corr','err_test_dist_corr');
end