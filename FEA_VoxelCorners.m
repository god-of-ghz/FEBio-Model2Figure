function [range, corner_pts] = FEA_VoxelCorners(voxel,dim,vx_dim,dir)
% helper function to compute the range of coordinates for a voxel's corners
% needs the following:
%   - (dim) maximum rectangular dimensions of the model **[X Z Y]**
%   - (vx_dim) number of pixels in each dimension [X Y Z]
% now, only the RANGE is needed since the voxel surfaces are always flat and aligned with cardinal directions

%% VERSION HISTORY
% CREATED 7/12/20 BY SS
% MODIFIED 7/18/20 BY SS
%   - also outputs the coordinates of corners, not just rectangular range
% MODIFIED 12/19/20 BY SS
%   - allows for variable direction slicing (coronal, sagittal, axial, etc)

%% SAFTEY AND PREPARATION
if ~all(voxel <= vx_dim)
    disp(voxel)
    disp(vx_dim)
    error('Voxel must actually fit inside the indicated dimensions...')
end

if ~all(dim > 0)
    error('Dimensions must all be positive values! Be sure appropriate processing has been done first')
end

%% COMPUTE VOXEL WIDTHS
vx_size(1) = 1/vx_dim(1)*dim(dir(1)); % x width   
vx_size(2) = 1/vx_dim(2)*dim(dir(2)); % y width
vx_size(3) = 1/vx_dim(3)*dim(dir(3)); % z width

%% COMPUTE RANGE OF VALUES
range = zeros(3,2);
for i = 1:3
    range(i,1) = vx_size(i)*(voxel(i)-1);   % lower bound
    range(i,2) = vx_size(i)*voxel(i);       % upper bound
end

%% COMPUTE INDICES OF CORNERS
corner_pts = zeros(8,3);
ind = 1;
for i = 1:2
    for j = 1:2
        for k = 1:2
            corner_pts(ind,1) = range(1,i);
            corner_pts(ind,2) = range(2,j);
            corner_pts(ind,3) = range(3,k);
            ind = ind + 1;
        end
    end
end