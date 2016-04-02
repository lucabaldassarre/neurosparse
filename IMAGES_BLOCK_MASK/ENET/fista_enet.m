function [beta1 t costs] =...
    fista_enet(X, y, lambda_1, lambda_2, tol_fista, maxiter_fista, Li, alpha0)

% Use FISTA to solve the problem
%
% argmin_{beta} 1/(2*m) ||X*beta-Y||^2 + lambda_2/2 ||beta||_2^2 + lambda_1 ||beta||_1
%

[m, n] = size(X);

if nargin < 7
    %Lipschitz constant of the gradient of the empirical risk
    Li = eigs(X'*X,1,'LM')/m;
end
% Add contribution due to the \ell_2 norm
Li = Li + lambda_2;

if nargin < 8
    alpha0 = zeros(n,1);
end

% If calling this function multiple time, better to compute this outside
% lambda_1_max = max(abs(X'*y));
% lambda_1 = lambda_1*lambda_1_max;

% Gradient of empirical risk w.r.t. beta
grad = @(z) X'*(X*z-y)/m + lambda_2*z;
% Objective function
V = @(z) 0.5*sum((X*z-y).^2)/m + 0.5*lambda_2*sum(z.^2) + lambda_1*sum(abs(z));
% Proxmap of Penalty term
prox = @(z, c) max(abs(z)-lambda_1*c,0).*sign(z);

%Initializations
beta0 = zeros(n,1);
theta0 = 1;
costs = zeros(maxiter_fista,1);

for t = 1:maxiter_fista
    % GRADIENT STEP
    mu = alpha0 - 1/Li*grad(alpha0);   
    % PROXIMAL STEP
    beta1 = prox(mu,1/Li);
    % UPDATE
    theta1 = (1+sqrt(1+4*theta0^2))/2;
    alpha1 = beta1 + (theta0-1)/theta1*(beta1-beta0);
    
    costs(t) = V(beta1);

    % STOPPING CRITERION (RELATIVE DIFFERENCE)
    if t > 1 && abs(costs(t-1)-costs(t))/costs(t-1) < tol_fista
       costs(t+1:end) = [];
       break;
    end
   
    alpha0 = alpha1;
    beta0 = beta1;
    theta0 = theta1;
end