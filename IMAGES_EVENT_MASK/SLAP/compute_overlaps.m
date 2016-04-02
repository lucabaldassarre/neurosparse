function [mean_O std_O mean_OC std_OC mean_OE std_OE] = compute_overlaps(support,n)

% support is a cell array containing the support sets of each subject
% n is the total number of voxels

% Number of subjects
ns = numel(support);
% Uncorrected overlap
O = zeros(ns,ns);
% Corrected overlap
OC = zeros(ns,ns);
% Relative overlap
OE = zeros(ns,ns);

for ks1 = 1:ns
   O(ks1,ks1) = 1;
   for ks2 = ks1+1:ns
      % Use the max(.,0) to avoid NaN from dividing by zero
      % O = |I_1 \cap I_2|/max(s1,s2)
      O(ks1,ks2) = max(numel(intersect(support{ks1},support{ks2}))/max(numel(support{ks1}),numel(support{ks2})),0);
      O(ks2,ks1) = O(ks1,ks2);
      E = numel(support{ks1})*numel(support{ks2})/n;
      OC(ks1,ks2) = O(ks1,ks2) - max(E/max(numel(support{ks1}),numel(support{ks2})),0);
      OC(ks2,ks1) = OC(ks1,ks2);
      % OE = |I_1 \cap I_2|/E
      OE(ks1,ks2) = numel(intersect(support{ks1},support{ks2}))/E/n;
      OE(ks2,ks1) = OE(ks1,ks2);
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
dummy = squeeze(OE(:,:));
dummy(1:ns+1:end) = [];
mean_OE = mean(dummy(:));
std_OE = std(dummy(:));