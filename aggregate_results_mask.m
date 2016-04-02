m = 10; % Indexes the model
sparse = 0;
block = 1;

if block
   if sparse
      % ACCURACY
      block_accuracy(m,1) = 1-mean_err_loo_accuracy;
      block_accuracy(m,2) = std_err_loo_accuracy;
      block_accuracy(m,3) = mean_corr_accuracy;
      block_accuracy(m,4) = std_corr_accuracy;
      block_accuracy(m,5) = mean_sparsity_accuracy;
      block_accuracy(m,6) = std_sparsity_accuracy;
      block_accuracy(m,7) = mean_O_accuracy;
      block_accuracy(m,8) = std_O_accuracy;
      block_accuracy(m,9) = mean_OC_accuracy;
      block_accuracy(m,10) = std_OC_accuracy;
      block_accuracy(m,11) = RST_accuracy;
      % dist OC
      block_dist_OC(m,1) = norm([1-mean_err_loo_dist_OC mean_OC_dist_OC] - [1 1]);
      block_dist_OC(m,2) = 1-mean_err_loo_dist_OC;
      block_dist_OC(m,3) = std_err_loo_dist_OC;
      block_dist_OC(m,4) = mean_corr_dist_OC;
      block_dist_OC(m,5) = std_corr_dist_OC;
      block_dist_OC(m,6) = mean_sparsity_dist_OC;
      block_dist_OC(m,7) = std_sparsity_dist_OC;
      block_dist_OC(m,8) = mean_O_dist_OC;
      block_dist_OC(m,9) = std_O_dist_OC;
      block_dist_OC(m,10) = mean_OC_dist_OC;
      block_dist_OC(m,11) = std_OC_dist_OC;
      block_dist_OC(m,12) = RST_dist_OC;

      % dist corr
      block_dist_corr(m,1) = norm([1-mean_err_loo_dist_corr mean_corr_dist_corr] - [1 1]);
      block_dist_corr(m,2) = 1-mean_err_loo_dist_corr;
      block_dist_corr(m,3) = std_err_loo_dist_corr;
      block_dist_corr(m,4) = mean_corr_dist_corr;
      block_dist_corr(m,5) = std_corr_dist_corr;
      block_dist_corr(m,6) = mean_sparsity_dist_corr;
      block_dist_corr(m,7) = std_sparsity_dist_corr;
      block_dist_corr(m,8) = mean_O_dist_corr;
      block_dist_corr(m,9) = std_O_dist_corr;
      block_dist_corr(m,10) = mean_OC_dist_corr;
      block_dist_corr(m,11) = std_OC_dist_corr;
      block_dist_corr(m,12) = RST_dist_corr;
   else
      % ACCURACY
      block_accuracy(m,1) = 1-mean_err_loo_accuracy;
      block_accuracy(m,2) = std_err_loo_accuracy;
      block_accuracy(m,3) = mean_corr_accuracy;
      block_accuracy(m,4) = std_corr_accuracy;
      block_accuracy(m,5:end) = NaN;
      % DIST-CORR
      block_dist_corr(m,1) = norm([1-mean_err_loo_dist_corr mean_corr_dist_corr] - [1 1]);
      block_dist_corr(m,2) = 1-mean_err_loo_dist_corr;
      block_dist_corr(m,3) = std_err_loo_dist_corr;
      block_dist_corr(m,4) = mean_corr_dist_corr;
      block_dist_corr(m,5) = std_corr_dist_corr;
      block_dist_corr(m,6:end) = NaN;
      % DIST-OC
      block_dist_OC(m,:) = NaN;
   end
else % EVENT
   if sparse
      % ACCURACY
      event_accuracy(m,1) = 1-mean_err_loo_accuracy;
      event_accuracy(m,2) = std_err_loo_accuracy;
      event_accuracy(m,3) = mean_corr_accuracy;
      event_accuracy(m,4) = std_corr_accuracy;
      event_accuracy(m,5) = mean_sparsity_accuracy;
      event_accuracy(m,6) = std_sparsity_accuracy;
      event_accuracy(m,7) = mean_O_accuracy;
      event_accuracy(m,8) = std_O_accuracy;
      event_accuracy(m,9) = mean_OC_accuracy;
      event_accuracy(m,10) = std_OC_accuracy;
      event_accuracy(m,11) = RST_accuracy;
      % dist OC
      event_dist_OC(m,1) = norm([1-mean_err_loo_dist_OC mean_OC_dist_OC] - [1 1]);
      event_dist_OC(m,2) = 1-mean_err_loo_dist_OC;
      event_dist_OC(m,3) = std_err_loo_dist_OC;
      event_dist_OC(m,4) = mean_corr_dist_OC;
      event_dist_OC(m,5) = std_corr_dist_OC;
      event_dist_OC(m,6) = mean_sparsity_dist_OC;
      event_dist_OC(m,7) = std_sparsity_dist_OC;
      event_dist_OC(m,8) = mean_O_dist_OC;
      event_dist_OC(m,9) = std_O_dist_OC;
      event_dist_OC(m,10) = mean_OC_dist_OC;
      event_dist_OC(m,11) = std_OC_dist_OC;
      event_dist_OC(m,12) = RST_dist_OC;
      % dist corr
      event_dist_corr(m,1) = norm([1-mean_err_loo_dist_corr mean_corr_dist_corr] - [1 1]);
      event_dist_corr(m,2) = 1-mean_err_loo_dist_corr;
      event_dist_corr(m,3) = std_err_loo_dist_corr;
      event_dist_corr(m,4) = mean_corr_dist_corr;
      event_dist_corr(m,5) = std_corr_dist_corr;
      event_dist_corr(m,6) = mean_sparsity_dist_corr;
      event_dist_corr(m,7) = std_sparsity_dist_corr;
      event_dist_corr(m,8) = mean_O_dist_corr;
      event_dist_corr(m,9) = std_O_dist_corr;
      event_dist_corr(m,10) = mean_OC_dist_corr;
      event_dist_corr(m,11) = std_OC_dist_corr;
      event_dist_corr(m,12) = RST_dist_corr;
   else
      % ACCURACY
      event_accuracy(m,1) = 1-mean_err_loo_accuracy;
      event_accuracy(m,2) = std_err_loo_accuracy;
      event_accuracy(m,3) = mean_corr_accuracy;
      event_accuracy(m,4) = std_corr_accuracy;
      event_accuracy(m,5:end) = NaN;
      % DIST-CORR
      event_dist_corr(m,1) = norm([1-mean_err_loo_dist_corr mean_corr_dist_corr] - [1 1]);
      event_dist_corr(m,2) = 1-mean_err_loo_dist_corr;
      event_dist_corr(m,3) = std_err_loo_dist_corr;
      event_dist_corr(m,4) = mean_corr_dist_corr;
      event_dist_corr(m,5) = std_corr_dist_corr;
      event_dist_corr(m,6:end) = NaN;
      % DIST-OC
      event_dist_OC(m,:) = NaN;
   end
end

clearvars -except block_* model event_* labels_*
save results_mask