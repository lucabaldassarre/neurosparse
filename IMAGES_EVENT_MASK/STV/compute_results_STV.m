function [] = compute_results_STV

ns = 15;
p = 0.5;

% Get data
for kloo = 1:ns
%    fload = sprintf('RESULTS_TRAIN/STV_loo_%d_p_%g.mat', kloo, p);
   fload = sprintf('RESULTS_TRAIN/STV_loo_%d_%g.mat', kloo, p);
   load(fload,'err_test_accuracy','alpha_accuracy','err_test_dist_OC','alpha_dist_OC','err_test_dist_corr','alpha_dist_corr');
   
   % ACCURACY
   % Get thresholded solution
   n = size(alpha_accuracy,1);
   alpha_t = threshold_solutions(alpha_accuracy);
   alpha_tot_accuracy(kloo,:) = alpha_t;
   support_accuracy{kloo} = find(alpha_t);
   sparsity_accuracy(kloo) = numel(support_accuracy{kloo})/n;
   err_loo_accuracy(kloo) = err_test_accuracy;
   
   % DIST OC
   % Get thresholded solution
   alpha_t = threshold_solutions(alpha_dist_OC);
   alpha_tot_dist_OC(kloo,:) = alpha_t;
   support_dist_OC{kloo} = find(alpha_t);
   sparsity_dist_OC(kloo) = numel(support_dist_OC{kloo})/n;
   err_loo_dist_OC(kloo) = err_test_dist_OC;
   
   % DIST corr
   % Get thresholded solution
   alpha_t = threshold_solutions(alpha_dist_corr);
   alpha_tot_dist_corr(kloo,:) = alpha_t;
   support_dist_corr{kloo} = find(alpha_t);
   sparsity_dist_corr(kloo) = numel(support_dist_corr{kloo})/n;
   err_loo_dist_corr(kloo) = err_test_dist_corr;
   
end

% Mean and std of sparsities
mean_sparsity_accuracy = mean(sparsity_accuracy);
std_sparsity_accuracy = std(sparsity_accuracy);
mean_sparsity_dist_OC = mean(sparsity_dist_OC);
std_sparsity_dist_OC = std(sparsity_dist_OC);
mean_sparsity_dist_corr = mean(sparsity_dist_corr);
std_sparsity_dist_corr = std(sparsity_dist_corr);

% Compute overlaps
[mean_O_accuracy std_O_accuracy mean_OC_accuracy std_OC_accuracy mean_OE_accuracy std_OE_accuracy] = compute_overlaps(support_accuracy,n);
[mean_O_dist_OC std_O_dist_OC mean_OC_dist_OC std_OC_dist_OC mean_OE_dist_OC std_OE_dist_OC] = compute_overlaps(support_dist_OC,n);
[mean_O_dist_corr std_O_dist_corr mean_OC_dist_corr std_OC_dist_corr mean_OE_dist_corr std_OE_dist_corr] = compute_overlaps(support_dist_corr,n);

% Compute correlations
corr_accuracy = corrcoef(alpha_tot_accuracy');
dummy = corr_accuracy;
dummy(1:ns+1:end) = [];
mean_corr_accuracy = mean(dummy(:));
std_corr_accuracy = std(dummy(:));

corr_dist_OC = corrcoef(alpha_tot_dist_OC');
dummy = corr_dist_OC;
dummy(1:ns+1:end) = [];
mean_corr_dist_OC = mean(dummy(:));
std_corr_dist_OC = std(dummy(:));

corr_dist_corr = corrcoef(alpha_tot_dist_corr');
dummy = corr_dist_corr;
dummy(1:ns+1:end) = [];
mean_corr_dist_corr = mean(dummy(:));
std_corr_dist_corr = std(dummy(:));

% Compute test errors
mean_err_loo_accuracy = mean(err_loo_accuracy);
std_err_loo_accuracy = std(err_loo_accuracy);
mean_err_loo_dist_OC = mean(err_loo_dist_OC);
std_err_loo_dist_OC = std(err_loo_dist_OC);
mean_err_loo_dist_corr = mean(err_loo_dist_corr);
std_err_loo_dist_corr = std(err_loo_dist_corr);

% RST
RST_accuracy = mean_O_accuracy/mean_sparsity_accuracy;
RST_dist_OC = mean_O_dist_OC/mean_sparsity_dist_OC;
RST_dist_corr = mean_O_dist_corr/mean_sparsity_dist_corr;

clear kloo fload alpha_t err_test_dist_OC err_test_dist_corr err_test_accuracy alpha_accuracy alpha_dist_OC alpha_dist_corr
fsave = 'RESULTS_TRAIN/STV_results';
[1-mean_err_loo_accuracy std_err_loo_accuracy; mean_corr_accuracy std_corr_accuracy; mean_sparsity_accuracy std_sparsity_accuracy; mean_O_accuracy std_O_accuracy; mean_OC_accuracy std_OC_accuracy; 0 RST_accuracy/100]*100
[1-mean_err_loo_dist_OC std_err_loo_dist_OC; mean_corr_dist_OC std_corr_dist_OC; mean_sparsity_dist_OC std_sparsity_dist_OC; mean_O_dist_OC std_O_dist_OC; mean_OC_dist_OC std_OC_dist_OC; 0 RST_dist_OC/100]*100
[1-mean_err_loo_dist_corr std_err_loo_dist_corr; mean_corr_dist_corr std_corr_dist_corr; mean_sparsity_dist_corr std_sparsity_dist_corr; mean_O_dist_corr std_O_dist_corr; mean_OC_dist_corr std_OC_dist_corr; 0 RST_dist_corr/100]*100
save(fsave);