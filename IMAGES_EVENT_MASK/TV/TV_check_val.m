function missing_jobs = TV_check_val

ns = 15; %Number of subjects for test Leave-One-Subject-Out
nsv = 14; %Number of subjects for validation Leave-One-Subject-Out


% TV regularization parameter
%nregpar = 10;
pars.tol = 1e-5;
p = 0.5;

missing_jobs = [];

for id = 1:ns*nsv
	%% Find task indices - splitting jobs by subjects
	ks = ceil(id/nsv); %Subject out
	temp = mod(id,nsv);
	if temp == 0
		temp = nsv;
	end
	ksv = temp;
	fload = sprintf('RESULTS_VAL/TV_loo_%d_val_%d_fista_tol_%g_p_%g.mat', ks, ksv, pars.tol, p);
   if ~exist(fload,'file')
      missing_jobs = [missing_jobs; id ks ksv];
   end
end

disp('FINISHED!');
save('TV_missing_jobs','missing_jobs');
exit