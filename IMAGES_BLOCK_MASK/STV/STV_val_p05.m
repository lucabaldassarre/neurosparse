function [] = STV_val_p05(id)

id = str2double(id);
algo = 1; %FISTA with accuracy rate 1
tol = 1e-5;
p = 0.5;

STV_val(id,algo,tol,p);
exit