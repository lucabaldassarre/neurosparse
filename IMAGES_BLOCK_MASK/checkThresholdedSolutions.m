addpath('../UTILITIES/');
thresholds  = [1e-5, 1e-4, 1e-3, 1e-2, 5e-2];
nT          = numel(thresholds);
nPars       = 10;

sparsity = zeros(nT+1, nPars);

for kPar = 1:nPars
    for kT = 1:nT
        a = threshold_solutions(alpha(:,kPar), thresholds(kT));
        sparsity(kT+1, kPar) = nnz(a)/numel(a)*100;
    end
    sparsity(1, kPar) = nnz(alpha(:,kPar))/numel(alpha(:,kPar))*100;
end