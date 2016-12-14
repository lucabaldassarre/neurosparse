thresholds = [1e-5, 1e-4, 1e-3, 1e-2, 5e-2];
nT = numel(thresholds);

for kPar = 1:10
    for kT = 1:nT
        a = threshold_solutions(alpha(:,kPar), thresholds(kT));
        sparsityT(kT, kPar) = nnz(a)/numel(a)*100;
    end
    sparsity(kPar) = nnz(alpha(:,kPar))/numel(alpha(:,kPar))*100;
end