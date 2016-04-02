function compute_results_atlas(method,p)

switch lower(method)
   case {'lasso','enet','slap','stv'}
      flag_dist_OC = 1;
   case {'lap','tv'}
      flag_dist_OC = 0;
end

% Load models
fload = sprintf('RESULTS_TRAIN/%s_results.mat',method);
load(fload,'alpha_tot_*','ns');


%% Computes the atlas-based frequency histogram for each LOSO model

% Load atlas
fload = sprintf('../atlas_mask_p_%g.mat',p);
load(fload,'ordered_atlas','volume');
% Regions
regions = unique(ordered_atlas);
R = numel(regions);
atlas_hist_accuracy = zeros(ns,R);
atlas_hist_dist_corr = zeros(ns,R);
if flag_dist_OC
   atlas_hist_dist_OC = zeros(ns,R);
end

for ks = 1:ns
   % Models selected for Accuracy
   % Compute l1 norm
   l1_norm = norm(alpha_tot_accuracy(ks,:),1);
   % Compute relative frequencies for each region
   for r = 1:R
      region_value = regions(r);
      atlas_hist_accuracy(ks,r) = sum(abs(alpha_tot_accuracy(ks,ordered_atlas == region_value)))/l1_norm;
   end  
   clear l1_norm
   
   % Models selected for distance to (1,1) in Accuracy-Correlation
   % Compute l1 norm
   l1_norm = norm(alpha_tot_dist_corr(ks,:),1);
   % Compute relative frequencies for each region
   for r = 1:R
      region_value = regions(r);
      atlas_hist_dist_corr(ks,r) = sum(abs(alpha_tot_dist_corr(ks,ordered_atlas == region_value)))/l1_norm;
   end  
   clear l1_norm
   
   if flag_dist_OC
      % Models selected for distance to (1,1) in Accuracy-OC
      % Compute l1 norm
      l1_norm = norm(alpha_tot_dist_OC(ks,:),1);
      % Compute relative frequencies for each region
      for r = 1:R
         region_value = regions(r);
         atlas_hist_dist_OC(ks,r) = sum(abs(alpha_tot_dist_OC(ks,ordered_atlas == region_value)))/l1_norm;
      end  
      clear l1_norm
   end
   
end

clear ks r region_value

%% Compute Histogram Intersections
HINT_accuracy = zeros(ns);
HINT_dist_corr = zeros(ns);
if flag_dist_OC
   HINT_dist_OC = zeros(ns);
end


% Accuracy
cont = 0;
for ks1 = 1:ns
   HINT_accuracy(ks1,ks1) = 1;
   for ks2 = ks1+1:ns
      cont = cont +1;
      HINT_accuracy(ks1,ks2) = sum(min(atlas_hist_accuracy(ks1,:),atlas_hist_accuracy(ks2,:)));
      HINT_accuracy(ks2,ks1) = HINT_accuracy(ks1,ks2);
      dummy_hint(cont) = HINT_accuracy(ks1,ks2);
   end
end
mean_HINT_accuracy = mean(dummy_hint);
std_HINT_accuracy = std(dummy_hint);

% Dist_corr
cont = 0;
for ks1 = 1:ns
   HINT_dist_corr(ks1,ks1) = 1;
   for ks2 = ks1+1:ns
      cont = cont +1;
      HINT_dist_corr(ks1,ks2) = sum(min(atlas_hist_dist_corr(ks1,:),atlas_hist_dist_corr(ks2,:)));
      HINT_dist_corr(ks2,ks1) = HINT_dist_corr(ks1,ks2);
      dummy_hint(cont) = HINT_dist_corr(ks1,ks2);
   end
end
mean_HINT_dist_corr = mean(dummy_hint);
std_HINT_dist_corr = std(dummy_hint);

if flag_dist_OC
   % Dist_OC
   cont = 0;
   for ks1 = 1:ns
      HINT_dist_OC(ks1,ks1) = 1;
      for ks2 = ks1+1:ns
         cont = cont +1;
         HINT_dist_OC(ks1,ks2) = sum(min(atlas_hist_dist_OC(ks1,:),atlas_hist_dist_OC(ks2,:)));
         HINT_dist_OC(ks2,ks1) = HINT_dist_OC(ks1,ks2);
         dummy_hint(cont) = HINT_dist_OC(ks1,ks2);
      end
   end
   mean_HINT_dist_OC = mean(dummy_hint);
   std_HINT_dist_OC = std(dummy_hint);
end

clear l1_norm r ks ks1 ks2 set dummy dummy_hint

%% COMPUTE NORMALIZED HISTOGRAMS AND FULL INTERSECTION
% Apply histogram intersection kernel to the normalized histograms
% This measure does not make intuitive sense, since even a perfect overlap
% will not give a value of 1, due to the normalization by the region's
% volume

% Accuracy
norm_hist_accuracy = atlas_hist_accuracy./repmat(volume',ns,1);
NA_accuracy = mean(norm_hist_accuracy);
NI_accuracy = min(norm_hist_accuracy);
FNI_accuracy = sum(NI_accuracy);
FNA_accuracy = sum(NA_accuracy);

% Dist-corr
norm_hist_dist_corr = atlas_hist_dist_corr./repmat(volume',ns,1);
NA_dist_corr = mean(norm_hist_dist_corr);
NI_dist_corr = min(norm_hist_dist_corr);
FNI_dist_corr = sum(NI_dist_corr);
FNA_dist_corr = sum(NA_dist_corr);

if flag_dist_OC
   % Dist-OC
   norm_hist_dist_OC = atlas_hist_dist_OC./repmat(volume',ns,1);
   NA_dist_OC = mean(norm_hist_dist_OC);
   NI_dist_OC = min(norm_hist_dist_OC);
   FNI_dist_OC = sum(NI_dist_OC);
   FNA_dist_OC = sum(NA_dist_OC);
end

clear volume

%% FIND FIRST 10 REGIONS in NORMALIZED FULL INTERSECTED HISTOGRAMS
N = 10;
% Accuracy
[dummy sorted_regions_accuracy_min] = sort(NI_accuracy,'descend');
% Translate back to original indeces (0 = CSF)
sorted_regions_accuracy_min = regions(sorted_regions_accuracy_min);
[dummy sorted_regions_accuracy_mean] = sort(NA_accuracy,'descend');
sorted_regions_accuracy_mean = regions(sorted_regions_accuracy_mean);

% Dist-corr
[dummy sorted_regions_dist_corr_min] = sort(NI_dist_corr,'descend');
% Translate back to original indeces (0 = CSF)
sorted_regions_dist_corr_min = regions(sorted_regions_dist_corr_min);
[dummy sorted_regions_dist_corr_mean] = sort(NA_dist_corr,'descend');
sorted_regions_dist_corr_mean = regions(sorted_regions_dist_corr_mean);

if flag_dist_OC
   % Dist-OC
   [dummy sorted_regions_dist_OC_min] = sort(NI_dist_OC,'descend');
   % Translate back to original indeces (0 = CSF)
   sorted_regions_dist_OC_min = regions(sorted_regions_dist_OC_min);
   [dummy sorted_regions_dist_OC_mean] = sort(NA_dist_OC,'descend');
   sorted_regions_dist_OC_mean = regions(sorted_regions_dist_OC_mean);
end

clear dummy 
clear alpha_tot_*

%% SAVE
fsave = sprintf('RESULTS_TRAIN/%s_results_atlas.mat',method);
save(fsave);