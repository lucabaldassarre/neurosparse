function [] = wrapper_TV_val(id)

id = str2double(id);
algo = 1; %FISTA
tol = 1e-5;
p = 0.5;

TV_val(id, algo, tol, p);
exit