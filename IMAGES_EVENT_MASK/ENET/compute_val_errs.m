% Find best regularization parameters for ENET

% Number of subjects for external LOSO-CV
ns = 15;
% Number of subjects for internal LOSO-CV
nsv = 14;

%Regularization parameters
nlambda_1 = 10;
nlambda_2 = 10;
n = 122128;
tol_fista = 1e-5;
p = 0.5;

for ks = 1:ns % External LOO
   
   err_loo = zeros(nsv,nlambda_2,nlambda_1);
   support = cell(nsv, nlambda_1, nlambda_2);
   
   for ksv = 1:nsv % Internal LOO
      for klambda_2 = 1:nlambda_2
			fload = sprintf('RESULTS_VAL/ENET_loo_%d_val_%d_regpar2_%d_tol_%g_p_%g.mat', ks, ksv, klambda_2, tol_fista, p);
         load(fload,'err_val','alpha');
         alpha_tot(ksv,:,:,klambda_2) = alpha;
			% Get thresholded solution
			alpha_t = threshold_solutions(alpha);
			for klambda_1 = 1:nlambda_1
				support{ksv,klambda_2, klambda_1} = find(alpha_t(:,klambda_1));
			end
         err_loo(ksv,klambda_2,:) = err_val;
         clear err_val alpha alpha_t
      end
   end
   % Compute overlaps and correlations
   for klambda_2 = 1:nlambda_2
		for klambda_1 = 1:nlambda_1
			[mean_O(klambda_2, klambda_1) std_O(klambda_2, klambda_1) mean_OC(klambda_2, klambda_1) std_OC(klambda_2, klambda_1) mean_OE(klambda_2, klambda_1) std_E(klambda_1, klambda_2)] = compute_overlaps(squeeze(support(:,klambda_2, klambda_1)),n);
         
         correlations(klambda_2,klambda_1,:,:) = corrcoef(squeeze(alpha_tot(:,:,klambda_1,klambda_2)'));
         dummy = squeeze(correlations(klambda_2,klambda_1,:,:));
         dummy(1:nsv+1:end) = [];
         mean_corr(klambda_2, klambda_1) = mean(dummy(:));
         std_corr(klambda_2, klambda_1) = std(dummy(:));
		end
   end
	
	% Find best regpars according to accuracy
   mean_err_loo = squeeze(mean(err_loo,1));
   [min_mean_err_loo idx_best_pars_accuracy] = min(mean_err_loo(:));
   [idx_best_lambda_2_accuracy, idx_best_lambda_1_accuracy] = ind2sub(size(mean_err_loo),idx_best_pars_accuracy);
   
   % Find best regpars according to balance between accuracy and stability
   for klambda_2 = 1:nlambda_2
   	dists_OC(klambda_2,:) = sum(([mean_OC(klambda_2,:)' 1-mean_err_loo(klambda_2,:)'] - repmat([1 1],nlambda_1,1)).^2,2);
      dists_corr(klambda_2,:) = sum(([mean_corr(klambda_2,:)' 1-mean_err_loo(klambda_2,:)'] - repmat([1 1],nlambda_1,1)).^2,2);
   end
   
	[min_dist_OC idx_best_pars_dist_OC] = min(dists_OC(:));
   [idx_best_lambda_2_dist_OC, idx_best_lambda_1_dist_OC] = ind2sub(size(dists_OC),idx_best_pars_dist_OC);
   
   [min_dist_corr idx_best_pars_dist_corr] = min(dists_corr(:));
   [idx_best_lambda_2_dist_corr, idx_best_lambda_1_dist_corr] = ind2sub(size(dists_corr),idx_best_pars_dist_corr);
   
   clear alpha_tot
   
   fsave = sprintf('RESULTS_VAL/ENET_loo_errs_%d_%g.mat',ks, p);
   clear klambda_2 klambda_1
   save(fsave);
   
end

disp('FINISHED!');

exit