function [h, p, t, nu] = welchtest(mu, s, N, significance)

if nargin < 4
    significance = 0.05;
end

nuu = N - 1;

t = mu(1) - mu(2);
t = t / sqrt( s(1)^2/N(1) + s(2)^2/N(2) );

nu = (s(1)^2/N(1) + s(2)^2/N(2))^2;
nu = floor(nu / ( s(1)^4/(N(1)^2*nuu(1)) + s(2)^4/(N(2)^2*nuu(2)) ));

p = 2*tcdf(abs(t), nu, 'upper');

h = p < significance;



