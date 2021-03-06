function [alpha t costs prox_iter] =...
    ifobas_complasso_warm(X, y, B, gamma,pars)

% Solves the problem
%
% argmin_{beta} 1/(2*m) ||X*beta-Y||^2 + gamma*||B*beta||_1
%
% via ISTA (external) and FISTA (internal)

[m, n] = size(X);
BBt = sparse(B*B');

%Lipschitz constant of the gradient of the empirical risk
if isfield(pars,'Li')
   Li = pars.Li;
else
   Li = eigs(X'*X,1,'LM')/m;
end

lambda = 1/Li;

if isfield(pars,'rate')
   rate = pars.rate;
else
   rate = 1;
end
if isfield(pars,'kappa')
%    kappa = pars.kappa/lambda;
   kappa = pars.kappa;
else
   kappa = 1/(eigs(BBt,1,'LM')*lambda);
end
if isfield(pars,'x0')
   alpha = pars.x0;
else
   alpha = zeros(n,1);
end
if isfield(pars,'tol')
   tol = pars.tol;
else
   tol = 1e-9;
end
if isfield(pars,'maxiter')
   maxiter = pars.maxiter;
else
   maxiter = 1e4;
end
if isfield(pars,'inner_maxiter')
   inner_maxiter = pars.inner_maxiter;
else
   inner_maxiter = 1e4;
end


%Gradient of empirical risk w.r.t. beta
grad = @(z) X'*(X*z-y)/m;
%Empirical Risk
f = @(z) 0.5*sum((X*z-y).^2)/m;
%Penalty Term
g = @(z) gamma*norm(B*z,1);
% 
prox_gstar = @(z) z./max(1,abs(z)/gamma);

% Normalization constant for duality gap
if isfield(pars,'dg_NConst')
   dg_NConst = pars.dg_NConst;
else
   coeff = pars.coeff;
%    dg_NConst = coeff*g(-lambda*grad(zeros(n,1)));
   dg_NConst = coeff*2*lambda*g(-lambda*grad(zeros(n,1)));
end

% Inner Fista Step
a = 1;


costs = zeros(maxiter,1);
prox_iter = zeros(maxiter,1);

% Init of inner FISTA
v0 = zeros(size(B,1),1);

for t = 1:maxiter
    % Gradient step
    mu = alpha - lambda*grad(alpha);

    Bmu = sparse(B*mu);
    prox_toll = dg_NConst*(1/(t^rate))^2;
    
   %FISTA initialization
   t0int = 1;
   u0 = v0;
    
    % Proxmap
    for i = 1:inner_maxiter
     % Gradient step
     w = u0 - a*kappa*(lambda*BBt*u0 - Bmu);
     % Projection step
     v = prox_gstar(w);
     
     w = lambda*B'*v;
     x = mu - w;
     
     % FISTA updates
     t1int = 0.5*(1+sqrt(1+4*t0int^2));
     u1 = v + (t0int - 1)/t1int*(v - v0);
     
     t0int = t1int;
     u0 = u1;
     v0 = v;
     
     % Compute duality gap
     gvalue = g(x);
     prox_dg = 2*(sum(w.^2) - sum(w'*mu) + lambda*gvalue);

     cont = i;
     %Stopping criterion
     if prox_dg < prox_toll
         break;
     end
    end
    prox_iter(t) = cont;
    
    % Proxmap
    alpha = x;
    
    costs(t) = f(alpha) + g(alpha);
    
    if (t > 1) && (abs(costs(t-1)-costs(t))/costs(t-1) < tol)
       costs(t+1:end) = [];
       prox_iter(t+1:end) = [];
       break;
    end
   
end