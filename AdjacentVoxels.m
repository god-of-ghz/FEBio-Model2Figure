function [results] = AdjacentVoxels(voxels)
% helper function, input a series of voxels, check to see if any of them
% are not adjacent to at least one other voxel

%% VERSION HISTORY
% CREATED 7/11/20

%% PREPARATION
n_vox = size(voxels, 1);

% if there's only one voxel, then its fine
if n_vox == 1
    results = 1;
    return;
end

comb = nchoosek(1:n_vox,2);
n_comb = size(comb,1);
results = zeros(n_vox,1);

%% CHECK EACH VOXEL
% 'yes' means that voxel is  directly adjacent to at least one other voxel
% 'adjacent' means directly next to, meaning at least 2/3 coordinates are
% the same!
for i = 1:n
    match = 0;
    
end
