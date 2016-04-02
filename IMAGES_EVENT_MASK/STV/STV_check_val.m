function missing_jobs = STV_check_val

% Checks which jobs are missing

%id = str2double(id);
ns = 15; %Number of subjects for test Leave-One-Subject-Out
nsv = 14; %Number of subjects for validation Leave-One-Subject-Out

% Regularization parameters
% L1 regularization parameter
% nregpar1 = 10;

% TV regularization parameter
nregpartv = 10;

tol = 1e-5;
p = 0.5;

missing_jobs = [];

for id = 1:2100
   %% Find task indices
   ks = ceil(id/(nsv*nregpartv)); %Subject out
   temp = mod(id,(nsv*nregpartv));
   if temp == 0
      temp = nsv*nregpartv;
   end
   ksv = ceil(temp/nregpartv); %Internal subject out
   regpartv_ind = mod(temp,nregpartv); %TV parameter
   if regpartv_ind == 0
      regpartv_ind = nregpartv;
   end
   fload = sprintf('RESULTS_VAL/STV_loo_%d_val_%d_regpartv_%d_fista_tol_%g_p_%g.mat',ks,ksv,regpartv_ind, tol,p);
   if ~exist(fload,'file')
      missing_jobs = [missing_jobs; id ks ksv regpartv_ind];
   end
end

save('STV_missing_jobs','missing_jobs');