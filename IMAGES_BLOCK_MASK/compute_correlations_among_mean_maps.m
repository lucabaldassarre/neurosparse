%% Get gray map mask
load DATA/masked_to_whole_p05;

%%
str_method  = {'LASSO','ENET','LAP','SLAP','TV','STV'};
n_methods   = 6;
N           = 122128;
alpha_mean_accuracy     = zeros(n_methods, N);
alpha_mean_dist_OC      = zeros(n_methods, N);
alpha_mean_dist_corr    = zeros(n_methods, N);

%% Accuracy
for method = 1:6
   str = str_method{method};
   fload = sprintf('%s/RESULTS_TRAIN/%s_results.mat',str,str);
   load(fload,'alpha_tot_accuracy');
   % Compute Mean Activations
   alpha_mean_accuracy(method,:) = mean(alpha_tot_accuracy);
end
clear alpha_tot_accuracy

%% OC only for sparse methods
for method = [1,2,4,6]
    str = str_method{method};
    fload = sprintf('%s/RESULTS_TRAIN/%s_results.mat',str,str);
    load(fload,'alpha_tot_dist_OC');
    % Compute Mean Activations
    alpha_mean_dist_OC(method,:) = mean(alpha_tot_dist_OC);      
end

clear alpha_tot_dist_OC
   
%% CORR
for method = 1:6
    str = str_method{method};
    fload = sprintf('%s/RESULTS_TRAIN/%s_results.mat',str,str);
    load(fload,'alpha_tot_dist_corr');
    % Compute Mean Activations
    alpha_mean_dist_corr(method,:) = mean(alpha_tot_dist_corr);      
end

clear alpha_tot_dist_corr fload str method

%% T-TEST AND LS METHOD at 5%
load('LS/LS_ttest_5_perc_results.mat','alpha_full');
% Compute Mean Activations
alpha_mean_ttest(1,:) = mean(alpha_full,2);      

%% T-TEST AND LS METHOD at 10%
load('LS/LS_ttest_10_perc_results.mat','alpha_full');
% Compute Mean Activations
alpha_mean_ttest(2,:) = mean(alpha_full,2);
clear alpha_full

%% COMPUTE CORRELATIONS AMONG MEAN MAPS
% ACCURACY
corr_accuracy = corrcoef([alpha_mean_accuracy; alpha_mean_ttest]');
% DIST OC
corr_dist_OC = corrcoef([alpha_mean_dist_oc; alpha_mean_ttest]');
% DIST corr
corr_dist_corr = corrcoef([alpha_mean_dist_corr; alpha_mean_ttest]');

%%
save correlation_among_mean_maps