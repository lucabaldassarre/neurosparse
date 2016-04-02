function [H HN sorted_regions] = l1_histogram_v2(beta, atlas, fig)

%% L1-HISTOGRAM
% v2.0
% 9th September 2012
% (c) Luca Baldassarre
% EPFL STI IEL LIONS
% ELD 243 (Batiment EL)
% Station 11
% CH-1014, Lausanne
% luca.baldassarre@epfl.ch
% baldazen@gmail.com
%
% Atlas-based region histograms.
%
% For each column of beta, l1_histogram(beta, atlas) computes the relative amount of
% the l1_norm that is contained in each region defined by the atlas.
% Atlas is a nx1 vector, where n = size(beta,1), such that atlas(i) is the
% region to which voxel i belongs.
%
% H = l1_histogram(beta, atlas) only computes the standard histogram
%
% [H HN] = l1_histogram(beta, atlas) also computes the normalized
% histogram, where each bin is normalized by the region's volume (i.e. the
% number of voxels it contains).
%
% [H HN sorted_regions] = l1_histogram(beta, atlas) return the list of
% regions, sorted in descending order according to the normalized
% histogram.
% 
% l1_histogram(beta,atlas,fig) also plots the histogram(s) if fig == 1;
%

if nargin < 3
   fig = 0;
end
% Number of voxels
n = size(beta,1);
% Number of vectors
m = size(beta, 2);
% Extract region values and number of regions
regions = unique(atlas);
R = numel(atlas);
% % Initial region index
% r_min = min(atlas);
% % Add an offset to account for matlab indexing (it starts from 1)
% if r_min == 0
%    correction = 1;
% else
%    correction = 0;
% end

H = zeros(R,m);

for km = 1:m
   l1_norm = norm(beta(:,km),1);
   %dummy1 = sort(abs(beta));
   %dummy2 = cumsum(dummy1)/l1_norm;
   %idx = find(dummy2 > 1-threshold,1);
   %threshold_value = dummy1(idx);
   %support{km} = find(beta > threshold_value);
   %sparsity(km) = numel(support{km})/numel(beta);
   % Compute relative frequencies for each region
   for r = 1:R
      H(r,km) = sum(abs(beta(atlas == regions(r),km)))/l1_norm;
   end
end

%% COMPUTE NORMALIZED HISTOGRAMS AND FULL INTERSECTION
if nargout > 1
   % Compute volumes according to atlas
   volume = zeros(R,1);
   for r = 1:R
      volume(r) = sum(atlas == regions(r));
   end
   HN = H./repmat(volume,1,m);
end

%% SORT REGIONS in DECREASING ORDER ACCORDING TO NORMALIZED HISTOGRAM
if nargout > 2
   [dummy sorted_regions] = sort(HN,'descend');
   % Translate back to original indeces (0 = CSF)
   sorted_regions = sorted_regions - correction;
end
%% PLOT HISTOGRAMS
if fig
   figure,
   if nargout > 1
      [AX,H1,H2] = plotyy(regions, H, regions, HN);
      set(AX,'FontSize',16);
      set(H1,'LineWidth',2,'LineStyle','-');
      set(H2,'LineWidth',2,'LineStyle','--');
      set(get(AX(1),'Ylabel'),'String','Standard histogram','FontSize',16);
      set(get(AX(2),'Ylabel'),'String','Normalized histogram','FontSize',16);
      % Create legend
      str_legend = cell(2*m,1);
      for km = 1:m
         str_legend{km} = ['Standard: Map ',num2str(km)];
         str_legend{m+km} = ['Normalized: Map ',num2str(km)];
      end
      legend(str_legend);
      %legend('HISTOGRAM','NORMALIZED HISTOGRAM');
   else
      plot(regions, H, 'LineWidth',2)
      set(gca,'FontSize',16);
      %legend('HISTOGRAM','NORMALIZED HISTOGRAM');
   end
   
   xlabel('Region','FontSize',16);
   title('ATLAS-BASED REGION HISTOGRAM','FontSize',20);
end