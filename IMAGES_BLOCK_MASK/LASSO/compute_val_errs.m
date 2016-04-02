function [] = compute_val_errs

p = 0.5;
ns = 16;
nsv = 15;
n = 122128;
tol_fista = 1e-5;

nregpar = 10;

% Get data
for ks = 1:ns
   
   alpha_tot = zeros(nsv,n,nregpar);
   correlations = zeros(nregpar, nsv, nsv);
   mean_corr = zeros(nregpar,1);
   std_corr = zeros(nregpar,1);
   
   mean_O = zeros(nregpar,1);
   mean_OC = zeros(nregpar,1);
   mean_OE = zeros(nregpar,1);
   std_O = zeros(nregpar,1);
   std_OC = zeros(nregpar,1);
   std_OE = zeros(nregpar,1);
   
   err_loo = zeros(nsv,nregpar);
   sparsity = zeros(nsv,nregpar);
   support = cell(nsv,nregpar);
   
   for ksv = 1:nsv
      fload = sprintf('RESULTS_VAL/LASSO_loo_%d_val_%d_tol_%g_p_%g.mat', ks, ksv, tol_fista, p);
      load(fload,'err_val','alpha');
      alpha_tot(ksv,:,:) = alpha;
      % Get thresholded solution
      alpha_t = threshold_solutions(alpha);
      % alpha_tot(ksv,:,:) = alpha_t;
      for kreg = 1:nregpar
         support{ksv,kreg} = find(alpha_t(:,kreg));
         sparsity(ksv,kreg) = numel(support{ksv,kreg});
      end
      err_loo(ksv,:) = err_val;
      clear err_val alpha alpha_t
   end

   % Compute overlaps and correlation
   for kreg = 1:nregpar
      [mean_O(kreg) std_O(kreg) mean_OC(kreg) std_OC(kreg) mean_OE(kreg) std_OE(kreg)] = compute_overlaps(support(:,kreg),n);
      
      correlations(kreg,:,:) = corrcoef(squeeze(alpha_tot(:,:,kreg)'));
      dummy = squeeze(correlations(kreg,:,:));
      dummy(1:nsv+1:end) = [];
      mean_corr(kreg) = mean(dummy(:));
      std_corr(kreg) = std(dummy(:));
   end
   
   mean_err_loo = mean(err_loo)';
   [min_mean_err_loo idx_best_regpar_accuracy] = min(mean_err_loo);

   % Find distances to [1 1] in the plane [mean_OC, 1-mean_err_loo]
   dists_OC = sum(([mean_OC 1-mean_err_loo] - repmat([1 1],nregpar,1)).^2,2);
   [min_dist_OC idx_best_regpar_dist_OC] = min(dists_OC);
   
   % Find distances to [1 1] in the plane [mean_corr, 1-mean_err_loo]
   dists_corr = sum(([mean_corr 1-mean_err_loo] - repmat([1 1],nregpar,1)).^2,2);
   [min_dist_corr idx_best_regpar_dist_corr] = min(dists_corr);
   
   clear dummy alpha_tot
   
   fsave = sprintf('RESULTS_VAL/LASSO_loo_errs_%d_%g.mat',ks, p);
   save(fsave);

end

exit