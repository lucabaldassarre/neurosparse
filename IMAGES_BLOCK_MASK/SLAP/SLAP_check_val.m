function missing_jobs = SLAP_check_val

% Find missing model selection jobs for Sparse Laplacian

ns = 16; %Number of subjects for test Leave-One-Subject-Out
nsv = 15; %Number of subjects for validation Leave-One-Subject-Out

% Regularization parameters
% Laplacian term
ngammas = 10;
% L1 term
nlambdas = 10;

p = 0.5;
tol_fista = 1e-5;

missing_jobs = [];

for id = 1:2400
   %% Find task indices
   ks = ceil(id/(nsv*ngammas)); %Subject out
   temp = mod(id,(nsv*ngammas));
   if temp == 0
      temp = nsv*ngammas;
   end
   ksv = ceil(temp/ngammas); %Internal subject out
   gamma_ind = mod(temp,ngammas);
   if gamma_ind == 0
      gamma_ind = ngammas;
   end
   fload = sprintf('RESULTS_VAL/SLAP_loo_%d_val_%d_gamma_%d_tol_%g_p_%g.mat',ks, ksv, gamma_ind, tol_fista, p);
   if ~exist(fload,'file')
      missing_jobs = [missing_jobs; id ks ksv gamma_ind];
   end
end

save('SLAP_missing_jobs','missing_jobs');