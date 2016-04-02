function [] = wrapper_TV_val_rerun(id)

id = str2double(id);
load TV_missing_jobs;
id = missing_jobs(id,1);
algo = 1; %FISTA
tol = 1e-5;
p = 0.5;

TV_val(id, algo, tol, p);
exit