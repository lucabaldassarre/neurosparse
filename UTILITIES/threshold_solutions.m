function alpha = threshold_solutions(alpha)

nlambda = size(alpha,2);
threshold = 1e-4;

for klambda = 1:nlambda
   [a, b] = sort(abs(alpha(:,klambda)));
   c = cumsum(a)/sum(a);
   d = find(c > threshold,1);
   alpha(b(1:d-1),klambda) = 0;
end