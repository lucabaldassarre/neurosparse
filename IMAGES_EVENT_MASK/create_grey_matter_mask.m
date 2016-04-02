load grey_prior
load voxel_mask

% p = 0.75;
p = 0.5;
idx = find(grey_prior > p);
[a, idx_features, idx_voxel] = intersect(voxel_mask,idx);

fsave = sprintf('grey_mask_p_%g.mat',p);
save(fsave,'idx_features');

%%
clearvars -except p idx_features
flag = 1;
if flag
   load c1_c3_data_ER
   X = X(:,idx_features);
   fsave = sprintf('c1_c3_data_mask_p_%g.mat',p);
   save(fsave)
end

   
   
