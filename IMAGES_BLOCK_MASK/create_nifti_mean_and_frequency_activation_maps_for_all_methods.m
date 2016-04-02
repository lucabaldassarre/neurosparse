%% Get gray map structure over which to write results
addpath('NIFTI');
I = load_nii('NIFTI_IMAGES_BLOCK/gray_matter_prior.hdr');
load masked_to_whole_p05;
[Nx, Ny, Nz] = size(I.img);

%%
str_method = {'LASSO','ENET','LAP','SLAP','STV','TV'};

for method = 1:6
   str = str_method{method};
   
   %% Accuracy
   fload = sprintf('%s/RESULTS_TRAIN/%s_results.mat',str,str);
   load(fload,'alpha_tot_accuracy');
   % Mean map
    fsave = sprintf('NIFTI_IMAGES_BLOCK/%s_block_accuracy_mean_map',str);
    I.img = zeros(Nx,Ny,Nz);
   for subject = 1:16
      I.img(masked_to_whole) = I.img(masked_to_whole) + alpha_tot_accuracy(subject,:)';
   end
   I.img = 1/16*I.img;
   I.img = I.img/max(I.img(:));
   save_nii(I, fsave);
   
   % Frequency map
    fsave = sprintf('NIFTI_IMAGES_BLOCK/%s_block_accuracy_frequency_map',str);
    I.img = zeros(Nx,Ny,Nz);
   for subject = 1:16
      I.img(masked_to_whole) = I.img(masked_to_whole) + (alpha_tot_accuracy(subject,:)'~=0);
   end
   I.img = 1/16*I.img;
   save_nii(I, fsave);
   
   %% OC only for sparse methods
   switch method
      case {1,2,4,5} 
         load(fload,'alpha_tot_dist_OC');
         
         % Mean map
         fsave = sprintf('NIFTI_IMAGES_BLOCK/%s_block_dist_OC_mean_map',str);
            I.img = zeros(Nx,Ny,Nz);
         for subject = 1:16
            I.img(masked_to_whole) = I.img(masked_to_whole) + alpha_tot_dist_OC(subject,:)';
         end
         I.img = 1/16*I.img;
         I.img = I.img/max(I.img(:));
         save_nii(I, fsave);
         
         % Frequency map
         fsave = sprintf('NIFTI_IMAGES_BLOCK/%s_block_dist_OC_frequency_map',str);
        I.img = zeros(Nx,Ny,Nz);
         for subject = 1:16
            I.img(masked_to_whole) = I.img(masked_to_whole) + (alpha_tot_dist_OC(subject,:)'~=0);
         end
         I.img = 1/16*I.img;
         save_nii(I, fsave);
   end
   
   %% CORR
   load(fload,'alpha_tot_dist_corr');
   % Mean map
   fsave = sprintf('NIFTI_IMAGES_BLOCK/%s_block_dist_corr_mean_map',str);
  I.img = zeros(Nx,Ny,Nz);
   for subject = 1:16
      I.img(masked_to_whole) = I.img(masked_to_whole) + alpha_tot_dist_corr(subject,:)';
   end
   I.img = 1/16*I.img;
   I.img = I.img/max(I.img(:));
   save_nii(I, fsave);
   
  % Frequency map
   fsave = sprintf('NIFTI_IMAGES_BLOCK/%s_block_dist_corr_frequency_map',str);
  I.img = zeros(Nx,Ny,Nz);
   for subject = 1:16
      I.img(masked_to_whole) = I.img(masked_to_whole) + (alpha_tot_dist_corr(subject,:)'~=0);
   end
   I.img = 1/16*I.img;
   save_nii(I, fsave);
end

%% LS
load('LS/LS_block_mask.mat','alpha');
% Mean map
fsave = sprintf('NIFTI_IMAGES_BLOCK/LS_block_mean_map');
I.img = zeros(Nx,Ny,Nz);
for subject = 1:16
    I.img(masked_to_whole) = I.img(masked_to_whole) + alpha(subject,:)';
end
I.img = 1/16*I.img;
I.img = I.img/max(I.img(:));
save_nii(I, fsave);
% Frequency map
fsave = sprintf('NIFTI_IMAGES_BLOCK/LS_block_frequency_map');
I.img = zeros(Nx,Ny,Nz);
for subject = 1:16
    I.img(masked_to_whole) = I.img(masked_to_whole) + (alpha(subject,:)~=0)';
end
I.img = 1/16*I.img;
save_nii(I, fsave);

%% T-TEST AND LS METHOD at 5%
load('LS/LS_ttest_5_perc_results.mat','alpha_full');
% Mean map
fsave = sprintf('NIFTI_IMAGES_BLOCK/LS_ttest_5_perc_block_mean_map');
I.img = zeros(Nx,Ny,Nz);
for subject = 1:16
    I.img(masked_to_whole) = I.img(masked_to_whole) + alpha_full(:,subject);
end
I.img = 1/16*I.img;
I.img = I.img/max(I.img(:));
save_nii(I, fsave);
% Frequency map
fsave = sprintf('NIFTI_IMAGES_BLOCK/LS_ttest_5_perc_block_frequency_map');
I.img = zeros(Nx,Ny,Nz);
for subject = 1:16
    I.img(masked_to_whole) = I.img(masked_to_whole) + (alpha_full(:,subject)~=0);
end
I.img = 1/16*I.img;
save_nii(I, fsave);

%% T-TEST AND LS METHOD at 10%
load('LS/LS_ttest_10_perc_results.mat','alpha_full');
% Mean map
fsave = sprintf('NIFTI_IMAGES_BLOCK/LS_ttest_10_perc_block_mean_map');
I.img = zeros(Nx,Ny,Nz);
for subject = 1:16
    I.img(masked_to_whole) = I.img(masked_to_whole) + alpha_full(:,subject);
end
I.img = 1/16*I.img;
I.img = I.img/max(I.img(:));
save_nii(I, fsave);
% Frequency map
fsave = sprintf('NIFTI_IMAGES_BLOCK/LS_ttest_10_perc_block_frequency_map');
I.img = zeros(Nx,Ny,Nz);
for subject = 1:16
    I.img(masked_to_whole) = I.img(masked_to_whole) + (alpha_full(:,subject)~=0);
end
I.img = 1/16*I.img;
save_nii(I, fsave);

