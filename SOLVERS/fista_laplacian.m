function [beta1 t costs] =...
    fista_laplacian(X, y, L, lambda, gamma, tol_fista, maxiter_fista, Li, alpha0)

% Use FISTA to solve the problem
%
% argmin_{beta} 1/(2*m) ||X*beta-Y||^2 + gamma/2*x'*L*x +
% lambda||x||_1
%
% where L is the laplacian of the graph connecting the variables

[m, n] = size(X);

if nargin < 8
    %Lipschitz constant of the gradient of the empirical risk
    Li = eigs(X'*X,1,'LM')/m + gamma*eigs(L,1,'LM');
end
if nargin < 10
    alpha0 = zeros(n,1);
end

% Gradient of empirical risk w.r.t. beta
grad = @(z) X'*(X*z-y)/m + gamma*L*z;
% Empirical Risk
f = @(z) 0.5*sum((X*z-y).^2)/m + gamma/2*z'*L*z;
% Penalty Term
omega = @(z) lambda*sum(abs(z));
% Proxmap of Penalty term
prox = @(z, c) max(abs(z)-lambda*c,0).*sign(z);

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
    
    costs(t) = f(beta1) + omega(beta1);

    % STOPPING CRITERION (RELATIVE DIFFERENCE)
    if t > 1 && abs(costs(t-1)-costs(t))/costs(t-1) < tol_fista
       costs(t+1:end) = [];
       break;
    end
   
    alpha0 = alpha1;
    beta0 = beta1;
    theta0 = theta1;
end