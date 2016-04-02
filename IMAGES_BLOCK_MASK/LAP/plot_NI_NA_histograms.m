function plot_NI_NA_histograms(method)

load(sprintf('RESULTS_TRAIN/%s_results_atlas.mat',method));

%% ACCURACY
figure, 
hold on,
plot(regions,NI_accuracy,'b','LineWidth',2)
plot(regions,NA_accuracy,'r','LineWidth',2)
% title('LASSO: Normalized Intersection (NI) and Normalized Average (NA) for accuracy','FontSize',20)
title('ACCURACY','FontSize',20);
set(gca,'FontSize',16)
xlabel('Region number','FontSize',16);
hold on
plot(sorted_regions_accuracy_min(1:5), zeros(5,1),'bsq','MarkerSize',12);
plot(sorted_regions_accuracy_mean(1:5), zeros(5,1),'r.','MarkerSize',18);
legend('NI','NA','NI: First 5 maxima','NA: First 5 maxima')

%% DIST Corr
figure, 
hold on,
plot(regions,NI_dist_corr,'b','LineWidth',2)
plot(regions,NA_dist_corr,'r','LineWidth',2)
% title('LASSO: Normalized Intersection (NI) and Normalized Average (NA) for dist corr','FontSize',20)
title('DIST CORR','FontSize',20);
set(gca,'FontSize',16)
xlabel('Region number','FontSize',16);
hold on
plot(sorted_regions_dist_corr_min(1:5), zeros(5,1),'bsq','MarkerSize',12);
plot(sorted_regions_dist_corr_mean(1:5), zeros(5,1),'r.','MarkerSize',18);
legend('NI','NA','NI: First 5 maxima','NA: First 5 maxima')

%% DIST OC
figure, 
hold on,
plot(regions,NI_dist_OC,'b','LineWidth',2)
plot(regions,NA_dist_OC,'r','LineWidth',2)
% title('LASSO: Normalized Intersection (NI) and Normalized Average (NA) for dist OC','FontSize',20)
title('DIST OC','FontSize',20);
set(gca,'FontSize',16)
xlabel('Region number','FontSize',16);
hold on
plot(sorted_regions_dist_OC_min(1:5), zeros(5,1),'bsq','MarkerSize',12);
plot(sorted_regions_dist_OC_mean(1:5), zeros(5,1),'r.','MarkerSize',18);
legend('NI','NA','NI: First 5 maxima','NA: First 5 maxima')

%% SAVE


save_figure(1,20,20,sprintf('%s_NI_NA_hist_accuracy',method))
save_figure(2,20,20,sprintf('%s_NI_NA_hist_dist_corr',method))
save_figure(3,20,20,sprintf('%s_NI_NA_hist_dist_OC',method))