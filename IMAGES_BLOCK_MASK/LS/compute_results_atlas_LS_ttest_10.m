function compute_results_atlas_LS_ttest_10

p = 0.5;

% Load models
load('LS_ttest_10_perc_results.mat','alpha_full','ns');
alpha_full = alpha_full'; %#ok<NODEF>

%% Computes the atlas-based frequency histogram for each LOSO model

% Load atlas
fload = sprintf('../atlas_mask_p_%g.mat',p);
load(fload,'ordered_atlas','volume');
% Regions
regions = unique(ordered_atlas);
R = numel(regions);
atlas_hist = zeros(ns,R);


for ks = 1:ns
   % Compute l1 norm
   l1_norm = norm(alpha_full(ks,:),1);
   % Compute relative frequencies for each region
   for r = 1:R
      region_value = regions(r);
      atlas_hist(ks,r) = sum(abs(alpha_full(ks,ordered_atlas == region_value)))/l1_norm;
   end  
   clear l1_norm   
end

clear ks r region_value

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

clear l1_norm r ks ks1 ks2 set dummy dummy_hint

%% COMPUTE NORMALIZED HISTOGRAMS AND FULL INTERSECTION
% Apply histogram intersection kernel to the normalized histograms
% This measure does not make intuitive sense, since even a perfect overlap
% will not give a value of 1, due to the normalization by the region's
% volume

norm_hist = atlas_hist./repmat(volume',ns,1);
NA = mean(norm_hist);
NI = min(norm_hist);
FNA = sum(NA);
FNI = sum(NI);

clear volume

%% FIND FIRST 10 REGIONS in NORMALIZED FULL INTERSECTED HISTOGRAMS
N = 10;
% Accuracy
[dummy sorted_regions_NI] = sort(NI,'descend');
% Translate back to original indeces (0 = CSF)
sorted_regions_NI = regions(sorted_regions_NI);
[dummy sorted_regions_NA] = sort(NA,'descend');
sorted_regions_NA = regions(sorted_regions_NA);

clear dummy 
clear alpha_full

%% SAVE
save('LS_ttest_10_perc_results_atlas.mat');