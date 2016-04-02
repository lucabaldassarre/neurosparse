function missing_jobs = ENET_check_val

% Checks which jobs are missing

%id = str2double(id);
ns = 16; %Number of subjects for test Leave-One-Subject-Out
nsv = 15; %Number of subjects for validation Leave-One-Subject-Out

%Regularization parameters
nlambda_1 = 10;
nlambda_2 = 10;

tol_fista = 1e-5;
p = 0.5;

missing_jobs = [];

for id = 1:2400
	%% Find task indices - splitting jobs by subjects and lambda_2
	ks = ceil(id/(nsv*nlambda_2)); %Subject out
	temp = mod(id,(nsv*nlambda_2));
	if temp == 0
		temp = nsv*nlambda_2;
	end
	ksv = ceil(temp/nlambda_2);
	klambda_2 = mod(temp,nlambda_2);
	if klambda_2 == 0
		klambda_2 = nlambda_2;
	end
   fload = sprintf('RESULTS_VAL/ENET_loo_%d_val_%d_regpar2_%d_tol_%g_p_%g.mat', ks, ksv, klambda_2, tol_fista, p);
   if ~exist(fload,'file')
      missing_jobs = [missing_jobs; id ks ksv klambda_2]
   end
end

disp('FINISHED!');
save('ENET_missing_jobs','missing_jobs');



