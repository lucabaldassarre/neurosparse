model2 = model;
model2{2} = 'TTEST10';
model2{3} = 'TTEST5';

sorted = 1;
error_bars = 1;
figure,
subplot(1,3,1);
if ~error_bars
   if ~sorted
      h = barh(event_accuracy(end:-1:1,1));
      set(gca,'YTickLabel',model2(end:-1:1),'FontSize',16);
      ch = get(h,'Children');
      fvd = get(ch,'Faces');
      fvcd = get(ch,'FaceVertexCData');
      % Set colors for each bar
      [accuracys iaccuracys] = sort(event_accuracy(end:-1:1,1));
      for i = 1:9
         row = iaccuracys(i);
         fvcd(fvd(row,:)) = i;
      end
      set(ch,'FaceVertexCData',fvcd);
      xlim([0.65 0.85]);
   elseif sorted
      [accuracys iaccuracys] = sort(event_accuracy(:,1));
      h = barh(event_accuracy(iaccuracys,1));
      set(gca,'YTickLabel',model2(iaccuracys),'FontSize',16);
      ch = get(h,'Children');
      fvd = get(ch,'Faces');
      fvcd = get(ch,'FaceVertexCData');
      % Set colors for each bar
      for i = 1:9
         fvcd(fvd(i,:)) = i;
      end
      set(ch,'FaceVertexCData',fvcd);
      xlim([0.65 0.85]);
   end
else
   [accuracys iaccuracys] = sort(median(1-event_all_errors,2));
   boxplot(1-event_all_errors(iaccuracys,:)','orientation','horizontal');
   set(gca,'YTick',1:10);
   set(gca,'YTickLabel',model2(iaccuracys),'FontSize',16);
end
xlabel('mean Accuracy','FontSize',16);
title('EVENT - Accuracy','FontSize',20);

%% DIST-OC
list_dist_OC = [4 5 7 8];

subplot(1,3,2),
hold all
plot(event_dist_OC(list_dist_OC(1),10), event_dist_OC(list_dist_OC(1),2),'b^','MarkerSize',8,'MarkerFaceColor','b');
plot(event_dist_OC(list_dist_OC(2),10), event_dist_OC(list_dist_OC(2),2),'go','MarkerSize',8,'MarkerFaceColor','g');
plot(event_dist_OC(list_dist_OC(3),10), event_dist_OC(list_dist_OC(3),2),'rsq','MarkerSize',8,'MarkerFaceColor','r');
plot(event_dist_OC(list_dist_OC(4),10), event_dist_OC(list_dist_OC(4),2),'kd','MarkerSize',8,'MarkerFaceColor','k');
if error_bars
   % Add uncertainty lines
   colors = {'b','g','r','k'};
   for km = 1:4
      plot([event_dist_OC(list_dist_OC(km),10) - event_dist_OC(list_dist_OC(km),5); event_dist_OC(list_dist_OC(km),10) + event_dist_OC(list_dist_OC(km),5)],...
         [event_dist_OC(list_dist_OC(km),2); event_dist_OC(list_dist_OC(km),2)],colors{km});
      plot([event_dist_OC(list_dist_OC(km),10); event_dist_OC(list_dist_OC(km),10)], ...
         [event_dist_OC(list_dist_OC(km),2)- event_dist_OC(list_dist_OC(km),3); event_dist_OC(list_dist_OC(km),2) + event_dist_OC(list_dist_OC(km),3)],colors{km});
   end
end
legend('LASSO','ENET','STV','SLAP','Location','NorthWest');
set(gca,'FontSize',16);
xlabel('mean OC','FontSize',16);
ylabel('mean Accuracy','FontSize',16);
title('EVENT - dist OC','FontSize',20);
if ~error_bars
   xlim([0.5 0.8]);
   ylim([0.762 0.78]);
else
   xlim([0.48 0.8]);
end

%% DIST-CORR
list_dist_corr = [4 5 6 7 8 9];

subplot(1,3,3),
hold all
plot(event_dist_corr(list_dist_corr(1),4), event_dist_corr(list_dist_corr(1),2),'b^','MarkerSize',8,'MarkerFaceColor','b');
plot(event_dist_corr(list_dist_corr(2),4), event_dist_corr(list_dist_corr(2),2),'go','MarkerSize',8,'MarkerFaceColor','g');
plot(event_dist_corr(list_dist_corr(3),4), event_dist_corr(list_dist_corr(3),2),'yv','MarkerSize',8,'MarkerFaceColor','y');
plot(event_dist_corr(list_dist_corr(4),4), event_dist_corr(list_dist_corr(4),2),'rsq','MarkerSize',8,'MarkerFaceColor','r');
plot(event_dist_corr(list_dist_corr(5),4), event_dist_corr(list_dist_corr(5),2),'kd','MarkerSize',8,'MarkerFaceColor','k');
plot(event_dist_corr(list_dist_corr(6),4), event_dist_corr(list_dist_corr(6),2),'m>','MarkerSize',8,'MarkerFaceColor','m');
if error_bars
   % Add uncertainty lines
   colors = {'b','g','y','r','k','m'};
   for km = 1:6
      plot([event_dist_corr(list_dist_corr(km),4) - event_dist_corr(list_dist_corr(km),5); event_dist_corr(list_dist_corr(km),4) + event_dist_corr(list_dist_corr(km),5)],...
         [event_dist_corr(list_dist_corr(km),2); event_dist_corr(list_dist_corr(km),2)],colors{km});
      plot([event_dist_corr(list_dist_corr(km),4); event_dist_corr(list_dist_corr(km),4)], ...
         [event_dist_corr(list_dist_corr(km),2)- event_dist_corr(list_dist_corr(km),3); event_dist_corr(list_dist_corr(km),2) + event_dist_corr(list_dist_corr(km),3)],colors{km});
   end
end
legend('LASSO','ENET','TV','STV','SLAP','LAP','Location','NorthWest');
set(gca,'FontSize',16);
xlabel('mean correlation','FontSize',16);
ylabel('mean Accuracy','FontSize',16);
title('EVENT - dist corr','FontSize',20);
if ~error_bars
   xlim([0.8 0.95]);
   ylim([0.76 0.82]);
else
   xlim([0.8 0.96]);
end
%% SAVE
if error_bars
   fname = 'results_event_err_bar';
else
   fname = 'results_event';
end
save_figure(1,40,20,fname);
clearvars -except block_* model event_* labels*