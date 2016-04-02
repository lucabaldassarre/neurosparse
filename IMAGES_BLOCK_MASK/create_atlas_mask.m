function create_atlas_mask(p)

fload = sprintf('grey_mask_p_%g.mat',p);
load(fload);

load('../atlas','ordered_atlas');

ordered_atlas = ordered_atlas(idx_features);

R = numel(unique(ordered_atlas));
indeces = cell(R,1);
volume = zeros(R,1);

for r = 1:R
   indeces{r} = find(ordered_atlas == r-1);
   volume(r) = numel(indeces{r});
end

fsave = sprintf('atlas_mask_p_%g.mat',p);
save(fsave,'ordered_atlas','volume','indeces');