%Compute LOO prediction errors

load('LS_ttest_5_perc_proper');
ns = 16;
% Do not threshold, since the t-test does not involve optimization
% approximations
% threshold = 0.9999;
threshold = 1e-4;
n = 122128;

% CORRELATION

alpha_full = zeros(n,ns);
for ks = 1:ns
   alpha_full(idx{ks},ks) = alpha{ks};
end
corr = corrcoef(alpha_full);
dummy = corr;
dummy(1:ns+1:end) = [];
mean_corr = mean(dummy(:));
std_corr = std(dummy(:));

% clear alpha_full


% support_5 = idx_n10;
support_5 = idx;
sparsity_5 = round(n/20)*ones(ns,1)/n;
support_5_thresh = cell(ns,1);
sparsity_5_thresh = zeros(ns,1);

for ks = 1:ns
   % 5% removed
   dummy1 = sort(abs(alpha{ks}));
   dummy2 = cumsum(dummy1)/sum(abs(alpha{ks}));
   idx_temp = find(dummy2 > threshold,1);
   threshold_value = dummy1(idx_temp);
   support_5_thresh{ks} = idx{ks}(alpha{ks} > threshold_value);
   sparsity_5_thresh(ks) = numel(support_5_thresh{ks})/n;
   
   % 5% removed
   clear dummy1 dummy2 idx_temp threshold_value
end

mean_err_class_5 = mean(err_class);
std_err_class_5 = std(err_class);
mean_sparsity_5 = mean(sparsity_5);
std_sparsity_5 = std(sparsity_5);
mean_sparsity_5_thresh = mean(sparsity_5_thresh);
std_sparsity_5_thresh = std(sparsity_5_thresh);

%%
O_5 = zeros(ks);
O_5_thresh = zeros(ks);

cont = 0;
for ks1 = 1:ns
   O_5(ks1,ks1) = 1;
   O_5_thresh(ks1,ks1) = 1;
   for ks2 = ks1+1:ns    
      cont = cont +1;
      %Uncorrected
      O_5(ks1,ks2) = numel(intersect(support_5{ks1},support_5{ks2}))./max(numel(support_5{ks1}),numel(support_5{ks2}));
      O_5(ks2,ks1) = O_5(ks1,ks2);
      dummy10(cont) = O_5(ks1,ks2);
      %Corrected
      OC_5(ks1,ks2) = O_5(ks1,ks2) - numel(support_5{ks1})*numel(support_5{ks2})/(n*max(numel(support_5{ks1}),numel(support_5{ks2})));
      OC_5(ks2,ks1) = OC_5(ks1,ks2);
      dummyC10(cont) = OC_5(ks1,ks2);
            
      %Uncorrected
      O_5_thresh(ks1,ks2) = numel(intersect(support_5_thresh{ks1},support_5_thresh{ks2}))./max(numel(support_5_thresh{ks1}),numel(support_5_thresh{ks2}));
      O_5_thresh(ks2,ks1) = O_5_thresh(ks1,ks2);
      dummy10_thresh(cont) = O_5_thresh(ks1,ks2);
      %Corrected
      OC_5_thresh(ks1,ks2) = O_5_thresh(ks1,ks2) - numel(support_5_thresh{ks1})*numel(support_5_thresh{ks2})/(n*max(numel(support_5_thresh{ks1}),numel(support_5_thresh{ks2})));
      OC_5_thresh(ks2,ks1) = OC_5_thresh(ks1,ks2);
      dummyC10_thresh(cont) = OC_5_thresh(ks1,ks2);
   end
end

mean_O_5 = mean(dummy10);
std_O_5 = std(dummy10);
mean_O_5_thresh = mean(dummy10_thresh);
std_O_5_thresh = std(dummy10_thresh);
%Corrected
mean_OC_5 = mean(dummyC10);
std_OC_5 = std(dummyC10);
mean_OC_5_thresh = mean(dummyC10_thresh);
std_OC_5_thresh = std(dummyC10_thresh);

RST = mean_O_5/mean_sparsity_5;
RST_thresh = mean_O_5_thresh/mean_sparsity_5_thresh;

clear dummy10 dummy5 cont ks ks1 ks2
% %% Computes the atlas-based frequency histogram for each LOSO model
% 
% % Number of subjects
% ns = 15;
% % Number of voxels
% n = 219727;
% % Load atlas
% load('../atlas','ordered_atlas');
% % Number of regions
% R = max(ordered_atlas);
% atlas_hist_5 = zeros(ns,R);
% 
% for ks = 1:ns
%    % 10% removed
%    alpha = alpha10{ks};
%    % Compute l1 norm
%    l1_norm = norm(alpha,1);
%    % Compute relative frequencies for each region
%    for r = 0:R
%       [set indeces_idx ~] = intersect(idx_n10{ks},find(ordered_atlas == r));
%       atlas_hist_5(ks,r+1) = sum(abs(alpha(indeces_idx)))/l1_norm;
%    end
%    
%    clear alpha set idx indeces_idx l1_norm
% end
% 
% clear ks r
% 
% %% Compute K-L divergence between each pair of frequency histograms
% atlas_hist_orig_5 = atlas_hist_5;
% atlas_hist_5 = max(atlas_hist_5,eps);
% KL_div_5 = zeros(ns);
% 
% for ks1 = 1:ns
%    for ks2 = setdiff(1:ns,ks1)
%       KL_div_5(ks1,ks2) = atlas_hist_5(ks1,:)*log(atlas_hist_5(ks1,:)./atlas_hist_5(ks2,:))';
%    end
% end
% 
% set = setdiff(1:ns^2,[1:17:ns^2]);
% mean_KL_div_5 = mean(KL_div_5(set));
% std_KL_div_5 = std(KL_div_5(set));
% 
% atlas_hist_5 = atlas_hist_orig_5;
% clear atlas_hist_orig_5
% %% Compute Histogram Intersections
% HINT_5 = zeros(ns);
% cont = 0;
% for ks1 = 1:ns
%    HINT_5(ks1,ks1) = 1;
%    for ks2 = ks1+1:ns
%       cont = cont +1;
%       HINT_5(ks1,ks2) = sum(min(atlas_hist_5(ks1,:),atlas_hist_5(ks2,:)));
%       HINT_5(ks2,ks1) = HINT_5(ks1,ks2);
%       dummy_hint_5(cont) = HINT_5(ks1,ks2);
%    end
% end
% 
% mean_HINT_5 = mean(dummy_hint_5);
% std_HINT_5 = std(dummy_hint_5);
% 
% clear fname l1_norm r ks ks1 ks2 set dummy dummy_hint_5 cont
% 
% %% COMPUTE NORMALIZED HISTOGRAMS AND FULL INTERSECTION
% load('../atlas','volume');
% 
% atlas_hist_norm_5 = atlas_hist_5./repmat(volume',ns,1);
% HIST_FULL_5 = min(atlas_hist_norm_5);
% 
% % Apply histogram intersection kernel to the normalized histograms
% % This measure does not make intuitive sense, since even a perfect overlap
% % will not give a value of 1, due to the normalization by the region's
% % volume
% HIST_FULL_KERNEL_5 = sum(HIST_FULL_5);
% 
% clear volume
% 
% %% FIND FIRST 10 REGIONS in NORMALIZED FULL INTERSECTED HISTOGRAMS
% N = 10;
% [dummy sorted_regions_5] = sort(HIST_FULL_5,'descend');
% % Translate back to original indeces (0 = CSF)
% sorted_regions_5 = sorted_regions_5 - 1;
% clear dummy

clear alpha idx dummy*
save LS_ttest_5_perc_results