function [newlist] = FEA_AddVoxel(list, voxel)
% helper function to conveniently adds UNIQUE voxels to a list of voxels
% this only news NEW voxels. if the voxels are already present in the list,
% they are ignored

%% VERSION HISTORY
% CREATED 7/11/20 BY SS

%% SAFETY AND PREPARATION
% if the input list is empty, we of course add nothing
if isempty(voxel)
    newlist = list;
    return;
end

% voxels are expected to be in the following format
% voxels = n x 3 or n x 2 matrix, where n is the number of voxels to be added
if size(voxel,2) ~= 3 && size(voxel,2) ~= 2
    error('Please ensure voxels/pixels are in 3D/2D respectively!');
end

n_vox = size(voxel,1); % number of voxels to add to the list

%% REMOVE REPEATED VOXELS IN THE LIST TO ADD
% since we only expect to add maybe 3-4 voxels at a time at the MOST,
% checking the new voxels first for repeats is more efficient than
% rechecking the entire list each time (which can have hundreds). 
% skip if there's only 1 voxel to add
if n_vox > 1
    to_add = 1; % initialize the list of voxels to add (their indices in the 'voxel' variable)
    for i = 1:n_vox
        for j = 1:size(to_add,1)
            % if we find it, its a repeat
            if all(voxel(i,:) == voxel(to_add(j),:))
                break;
            % if we're at the end of the list and haven't found any repeats
            elseif j == size(to_add,1)
                to_add = [to_add; i;]; % add it
            end
        end
    end
    
    % process only the unique voxels
    voxel = voxel([to_add(:)],:);
    % re-acquire the size because it might have changed
    n_vox = size(voxel,1);
end


%% RUN THROUGH THE VOXELS, ADDING NEW ONES
% if the original list was empty, just return all the voxels (since we already checked for duplicate inputs)
if isempty(list)
    newlist = voxel;
else
    newlist = list;
    for i = 1:n_vox
        for j = 1:size(list,1)
            % if we find a match with the current voxel
            if all(voxel(i,:) == list(j,:))
                break;  % skip this voxel, don't add it
            % if we reach the end of the list and haven't found a match
            elseif j == size(list,1)    
                % its a new voxel, so add it
                newlist = [newlist; voxel(i,:)];
            end
        end
    end
end