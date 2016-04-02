% Regularization parameters
lambda_1s = 10.^(-4:-1:-13);
nlambda_1 = numel(lambda_1s);
lambda_2s = 10.^(4:-1:-2);
nlambda_2 = numel(lambda_2s);

save('lambdas','lambda_1s','nlambda_1','lambda_2s','nlambda_2');