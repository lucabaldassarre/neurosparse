function [] = compute_val_correlations_prova

p = 0.5;
ns = 16;
nsv = 15;
n = 122128;
tol_fista = 1e-5;

nregpar = 10;

% Get data
for ks = 1:ns
   
   alpha_tot = zeros(nsv,n,nregpar);
   alpha_tot_t = zeros(nsv,n,nregpar);
   correlations = zeros(nregpar, nsv, nsv);
   correlations_t = zeros(nregpar, nsv, nsv);
   mean_correlations = zeros(nregpar,1);
   std_correlations = zeros(nregpar,1);
   mean_correlations_t = zeros(nregpar,1);
   std_correlations_t = zeros(nregpar,1);
   
   for ksv = 1:nsv
      fload = sprintf('RESULTS_VAL/LASSO_loo_%d_val_%d_tol_%g_p_%g.mat', ks, ksv, tol_fista, p);
      load(fload,'err_val','alpha');
      alpha_tot(ksv,:,:) = alpha;
      alpha_tot_t(ksv,:,:) = threshold_solutions(alpha);
      
      clear alpha err_val
   end

   % Compute overlaps
   for kreg = 1:nregpar
      correlations(kreg,:,:) = corrcoef(squeeze(alpha_tot(:,:,kreg)'));
      correlations_t(kreg,:,:) = corrcoef(squeeze(alpha_tot_t(:,:,kreg)'));
      dummy = squeeze(correlations(kreg,:,:));
      dummy(1:nsv+1:end) = [];
      mean_correlations(kreg) = mean(dummy(:));
      std_correlations(kreg) = std(dummy(:));
      
      dummy = squeeze(correlations_t(kreg,:,:));
      dummy(1:nsv+1:end) = [];
      mean_correlations_t(kreg) = mean(dummy(:));
      std_correlations_t(kreg) = std(dummy(:));
   end
   
   clear dummy alpha_tot alpha_tot_t
   
   keyboard
   
   fsave = ['RESULTS_VAL/LASSO_loo_errs_',num2str(ks)];
   save(fsave,'-append');

end

exit