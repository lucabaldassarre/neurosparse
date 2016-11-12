% See aggregate_results_mask.m for understanding the metrics used
load results_mask.mat

model2 = model;
model2{2} = 'TTEST10';
model2{3} = 'TTEST5';

sorted = 1;
error_bars = 0;

figure,
subplot(1,3,1);
if ~error_bars
   if ~sorted
      h = barh(block_accuracy(end:-1:1,1));
      set(gca,'YTickLabel',model2(end:-1:1),'FontSize',16);
      ch = get(h,'Children');
      fvd = get(ch,'Faces');
      fvcd = get(ch,'FaceVertexCData');
      % Set colors for each bar
      [accuracys, iaccuracys] = sort(block_accuracy(end:-1:1,1));
      for i = 1:9
         row = iaccuracys(i);
         fvcd(fvd(row,:)) = i;
      end
      set(ch,'FaceVertexCData',fvcd)
      xlim([0.75 0.9]);
   elseif sorted
      [accuracys, iaccuracys] = sort(block_accuracy(:,1));
      h = barh(block_accuracy(iaccuracys,1));
      set(gca,'YTickLabel',model2(iaccuracys),'FontSize',16);
%       ch = get(h,'Children');
%       fvd = get(ch,'Faces');
%       fvcd = get(ch,'FaceVertexCData');
%       % Set colors for each bar
%       for i = 1:numel(model)
%          fvcd(fvd(i,:)) = i;
%       end
%       set(ch,'FaceVertexCData',fvcd)
      xlim([0.75 0.9]);
   end
else
   [accuracys, iaccuracys] = sort(median(1-block_all_errors,2));
   boxplot(1-block_all_errors(iaccuracys,:)','orientation','horizontal');
   set(gca,'YTick',1:10);
   set(gca,'YTickLabel',model2(iaccuracys),'FontSize',16);
end
xlabel('mean Accuracy','FontSize',16);
title('BLOCK - Accuracy','FontSize',20);
set(gca, 'XGrid','on');

%% DIST-OC
list_dist_OC = [4 5 7 8];
markersize = 10;

subplot(1,3,2),
hold all
plot(block_dist_OC(list_dist_OC(1),10), block_dist_OC(list_dist_OC(1),2),'b^','MarkerSize', markersize,'MarkerFaceColor','b');
plot(block_dist_OC(list_dist_OC(2),10), block_dist_OC(list_dist_OC(2),2),'go','MarkerSize', markersize,'MarkerFaceColor','g');
plot(block_dist_OC(list_dist_OC(3),10), block_dist_OC(list_dist_OC(3),2),'rsq','MarkerSize', markersize,'MarkerFaceColor','r');
plot(block_dist_OC(list_dist_OC(4),10), block_dist_OC(list_dist_OC(4),2),'kd','MarkerSize', markersize,'MarkerFaceColor','k');
if error_bars
   % Add uncertainty lines
   colors = {'b','g','r','k'};
   for km = 1:4
      plot([block_dist_OC(list_dist_OC(km),10) - block_dist_OC(list_dist_OC(km),5); block_dist_OC(list_dist_OC(km),10) + block_dist_OC(list_dist_OC(km),5)],...
         [block_dist_OC(list_dist_OC(km),2); block_dist_OC(list_dist_OC(km),2)],colors{km});
      plot([block_dist_OC(list_dist_OC(km),10); block_dist_OC(list_dist_OC(km),10)], ...
         [block_dist_OC(list_dist_OC(km),2)- block_dist_OC(list_dist_OC(km),3); block_dist_OC(list_dist_OC(km),2) + block_dist_OC(list_dist_OC(km),3)],colors{km});
   end
end
legend('LASSO','ENET','STV','SLAP','Location','NorthWest');
set(gca,'FontSize',16);
xlabel('mean OC','FontSize',16);
ylabel('mean Accuracy','FontSize',16);
ylim([0.8, 0.85]);
title('BLOCK - dist OC','FontSize',20);
if ~error_bars
   xlim([0.5 0.85]);
   ylim([0.8 0.85]);
else
   xlim([0.35 0.85]);
end
grid on


%% DIST-CORR
list_dist_corr = [4 5 6 7 8 9 10];
markersize = 10;

subplot(1,3,3),
hold all
plot(block_dist_corr(list_dist_corr(1),4), block_dist_corr(list_dist_corr(1),2),'b^','MarkerSize', markersize,'MarkerFaceColor','b');
plot(block_dist_corr(list_dist_corr(2),4), block_dist_corr(list_dist_corr(2),2),'go','MarkerSize', markersize,'MarkerFaceColor','g');
plot(block_dist_corr(list_dist_corr(3),4), block_dist_corr(list_dist_corr(3),2),'yv','MarkerSize', markersize,'MarkerFaceColor','y');
plot(block_dist_corr(list_dist_corr(4),4), block_dist_corr(list_dist_corr(4),2),'rsq','MarkerSize', markersize,'MarkerFaceColor','r');
plot(block_dist_corr(list_dist_corr(5),4), block_dist_corr(list_dist_corr(5),2),'kd','MarkerSize', markersize,'MarkerFaceColor','k');
plot(block_dist_corr(list_dist_corr(6),4), block_dist_corr(list_dist_corr(6),2),'m>','MarkerSize', markersize,'MarkerFaceColor','m');
plot(block_dist_corr(list_dist_corr(7),4), block_dist_corr(list_dist_corr(7),2),'k>','MarkerSize', markersize,'MarkerFaceColor','k');
if error_bars
   % Add uncertainty lines
   colors = {'b','g','y','r','k','m','k'};
   for km = [1:6, 10]
      plot([block_dist_corr(list_dist_corr(km),4) - block_dist_corr(list_dist_corr(km),5); block_dist_corr(list_dist_corr(km),4) + block_dist_corr(list_dist_corr(km),5)],...
         [block_dist_corr(list_dist_corr(km),2); block_dist_corr(list_dist_corr(km),2)],colors{km});
      plot([block_dist_corr(list_dist_corr(km),4); block_dist_corr(list_dist_corr(km),4)], ...
         [block_dist_corr(list_dist_corr(km),2)- block_dist_corr(list_dist_corr(km),3); block_dist_corr(list_dist_corr(km),2) + block_dist_corr(list_dist_corr(km),3)],colors{km});
   end
end
legend('LASSO','ENET','TV','STV','SLAP','LAP','RR','Location','NorthWest');
set(gca,'FontSize',16);
xlabel('mean correlation','FontSize',16);
ylabel('mean Accuracy','FontSize',16);
title('BLOCK - dist corr','FontSize',20);
ylim([0.825, 0.88]);
if ~error_bars
   xlim([0.8 1]);
else
   xlim([0.75 1]);
end
grid on

%% SAVE
if error_bars
   fname = 'results_block_err_bar';
else
   fname = 'results_block';
end
save_figure(1,40,20,fname);
clearvars -except block_* model event_* labels_*