load coordenates_mask
% p = 0.75;
p = 0.5;
load(sprintf('grey_mask_p_%g.mat',p));
coordenates_mask = coordenates_mask(idx_features,:);

n = size(coordenates_mask,1);
cont = 0;   
B = sparse(1,1);
start = 0;

% keyboard

tic
for kn = 1:n
   %disp(kn);
   father = kn;
   dummy_abs = sum(abs(repmat(coordenates_mask(father,:),n,1)-coordenates_mask),2);
   dummy = sum(repmat(coordenates_mask(father,:),n,1)-coordenates_mask,2);
   idx_abs = find(dummy_abs == 1);
   idx_rel = find(dummy(idx_abs) == -1);
   idx_children = idx_abs(idx_rel);
   n_children = numel(idx_children);
   for kc = 1:n_children
      B(start+kc,father) = 1;
      B(start+kc,idx_children(kc)) = -1;
   end
   start = size(B,1);
end

B = sparse(B);
normBsqr = eigs(B'*B,1,'LM');
toc
save(sprintf('connection_matrix_p_%g.mat',p),'B','normBsqr');