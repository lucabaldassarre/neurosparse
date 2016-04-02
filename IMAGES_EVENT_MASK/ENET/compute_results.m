%Compute LOO prediction errors
ns = 15;
threshold = 0.99;
n = 219727;
% Load atlas
load('../atlas','ordered_atlas');
% Number of regions
R = max(ordered_atlas);

err_class_all = zeros(ns,1);
support = cell(ns,1);
sparsity = zeros(ns,1);
atlas_hist = zeros(ns,R);

%% Collect accuracy, support and sparsity
for ks = 1:ns
   fload = ['RESULTS/ENET_loo_',num2str(ks)];
   load(fload,'alpha','err_val');
   err_class_all(ks) = err_val;
   l1_norm = norm(alpha,1);
   dummy1 = sort(abs(alpha));
   dummy2 = cumsum(dummy1)/l1_norm;
   idx = find(dummy2 > 1-threshold,1);
   threshold_value = dummy1(idx);
   support{ks} = find(alpha > threshold_value);
   sparsity(ks) = numel(support{ks})/numel(alpha);
   % Compute relative frequencies for each region
   for r = 0:R
      atlas_hist(ks,r+1) = sum(abs(alpha(ordered_atlas == r)))/l1_norm;
   end
   clear dummy1 dummy2 idx threshold_value alpha
end

mean_err_class = mean(err_class_all);
std_err_class = std(err_class_all);
mean_sparsity = mean(sparsity);
std_sparsity = std(sparsity);

%% Compute Overlap and Corrected Overlap

O = zeros(ns);
OC = zeros(ns);

for ks1 = 1:ns
   O(ks1,ks1) = 1;
   for ks2 = ks1+1:ns
      O(ks1,ks2) = numel(intersect(support{ks1},support{ks2}))/max(numel(support{ks1}),numel(support{ks2}));
      O(ks2,ks1) = O(ks1,ks2);
      OC(ks1,ks2) = O(ks1,ks2) - numel(support{ks1})*numel(support{ks2})/(n*max(numel(support{ks1}),numel(support{ks2})));
      OC(ks2,ks1) = OC(ks1,ks2);
   end
end
dummy = squeeze(O(:,:));
dummy(1:ns+1:end) = [];
mean_O = mean(dummy(:));
std_O = std(dummy(:));
dummy = squeeze(OC(:,:));
dummy(1:ns+1:end) = [];
mean_OC = mean(dummy(:));
std_OC = std(dummy(:));

clear ks1 ks2 dummy

RST = mean_O./mean_sparsity;

%% Compute Histogram Intersections
HINT = zeros(ns);
cont = 0;
for ks1 = 1:ns
   HINT(ks1,ks1) = 1;
   for ks2 = ks1+1:ns
      cont = cont +1;
      HINT(ks1,ks2) = sum(min(atlas_hist(ks1,:),atlas_hist(ks2,:)));
      HINT(ks2,ks1) = HINT(ks1,ks2);
      dummy_hint(cont) = HINT(ks1,ks2);
   end
end

mean_HINT = mean(dummy_hint);
std_HINT = std(dummy_hint);

clear fname l1_norm r ks ks1 ks2 set dummy atlas_hist_orig cont dummy_hint

%% COMPUTE NORMALIZED HISTOGRAMS AND FULL INTERSECTION
load('../atlas','volume');
atlas_hist_norm = atlas_hist;

atlas_hist_norm = atlas_hist_norm./repmat(volume',ns,1);
HIST_FULL = min(atlas_hist_norm);


% Apply histogram intersection kernel to the normalized histograms
% This measure does not make intuitive sense, since even a perfect overlap
% will not give a value of 1, due to the normalization by the region's
% volume
HIST_FULL_KERNEL = sum(HIST_FULL);

clear volume

%% FIND FIRST 10 REGIONS in NORMALIZED FULL INTERSECTED HISTOGRAMS
N = 10;
[dummy sorted_regions] = sort(HIST_FULL,'descend');
% Translate back to original indeces (0 = CSF)
sorted_regions = sorted_regions - 1;
clear dummy

save('ENET_loo_results');