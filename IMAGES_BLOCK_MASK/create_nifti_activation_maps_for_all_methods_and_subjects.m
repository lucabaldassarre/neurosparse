%% Get gray map structure over which to write results
addpath('NIFTI');
I = load_nii('NIFTI_IMAGES_BLOCK/gray_matter_prior.hdr');
load masked_to_whole_p05;
[Nx, Ny, Nz] = size(I.img);

%% 'LASSO','ENET','LAP','SLAP','STV','TV'
str_method = {'LASSO','ENET','LAP','SLAP','STV','TV'};

for method = 1:6
   str = str_method{method};
   fload = sprintf('%s/RESULTS_TRAIN/%s_results.mat',str,str);
   % Accuracy
   load(fload,'alpha_tot_accuracy');
   for subject = 1:16
      fsave = sprintf('NIFTI_IMAGES_BLOCK/%s_block_accuracy_subject_%d',str,subject);
      I.img = zeros(Nx,Ny,Nz);
      I.img(masked_to_whole) = abs(alpha_tot_accuracy(subject,:))/max(abs(alpha_tot_accuracy(subject,:)));
      save_nii(I, fsave);
   end
   switch method
      case {1,2,4,5} %OC only for sparse methods
         % OC
         load(fload,'alpha_tot_dist_OC');
         for subject = 1:16
            fsave = sprintf('NIFTI_IMAGES_BLOCK/%s_block_dist_OC_subject_%d',str,subject);
            I.img = zeros(Nx,Ny,Nz);
            I.img(masked_to_whole) = abs(alpha_tot_dist_OC(subject,:))/max(abs(alpha_tot_dist_OC(subject,:)));
            save_nii(I, fsave);
         end
   end
   % CORR
   load(fload,'alpha_tot_dist_corr');
   for subject = 1:16
      fsave = sprintf('NIFTI_IMAGES_BLOCK/%s_block_dist_corr_subject_%d',str,subject);
      I.img = zeros(Nx,Ny,Nz);
      I.img(masked_to_whole) = abs(alpha_tot_dist_corr(subject,:))/max(abs(alpha_tot_dist_corr(subject,:)));
      save_nii(I, fsave);
   end
end

%% LS
fload = 'LS/LS_block_mask.mat';
load(fload,'alpha');
for subject = 1:16
  fsave = sprintf('NIFTI_IMAGES_BLOCK/LS_block_subject_%d',subject);
  I.img = zeros(Nx,Ny,Nz);
  I.img(masked_to_whole) = abs(alpha(subject,:))/max(abs(alpha(subject,:)));
  save_nii(I, fsave);
end

%% T-TEST 5% + LS
fload = 'LS/LS_ttest_5_perc_results.mat';
load(fload,'alpha_full');
for subject = 1:16
  fsave = sprintf('NIFTI_IMAGES_BLOCK/LS_ttest5_block_subject_%d',subject);
  I.img = zeros(Nx,Ny,Nz);
  I.img(masked_to_whole) = abs(alpha_full(:,subject))/max(abs(alpha_full(:,subject)));
  save_nii(I, fsave);
end

%% T-TEST 10% + LS
fload = 'LS/LS_ttest_10_perc_results.mat';
load(fload,'alpha_full');
for subject = 1:16
  fsave = sprintf('NIFTI_IMAGES_BLOCK/LS_ttest10_block_subject_%d',subject);
  I.img = zeros(Nx,Ny,Nz);
  I.img(masked_to_whole) = abs(alpha_full(:,subject))/max(abs(alpha_full(:,subject)));
  save_nii(I, fsave);
end