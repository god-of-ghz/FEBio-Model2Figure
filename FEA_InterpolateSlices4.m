function [img_data, msk, vx_grp, slc_thick, px_size] = FEA_InterpolateSlices4(ele_conn,ele_parts,ele_disp,dim,node_coor,opt,n_slc,soi,im_size,scale,plane,parts)
% script to interpolar 3D elements via nodal connectivity into a series of 2D slices

%% VERSION HISTORY
% CREATED 7/10/20 BY SS
% MODIFIED 7/18/20 BY SS
%   - reworked main loop 'determine which voxels...' to be computed with multiple threads
%   - **THIS REQUIRES PARALLEL COMPUTE TOOLBOX!** 
%   - Minimum hardware: 4 core CPU, 16GB RAM
%   - Recommended hardware: 16+ core CPU, 128GB RAM
%   If you don't have this, just change it to a regular 'for' loop. It's mad slow though...
% MODIFIED 12/18/20 BY SS
%   - allows element sizes beyond tet4
%   - allows merging of masks 
%   - allows choosing of a specific plane
% MODIFIED 1/14/21 BY SS
%   - cleaned up redundant code
%   - modified code to only examine slices of interest
%   - implemented centroid-weighted averaging

%% SAFETY
if max(size(dim)) ~= 3
    error('Check the number of dimensions in "dim" variable!');
end

%% PREPARATION
% the actual rectangular dimensions (x z y) of the model are units in mm
% but the data needs to fit inside an image of the desired size (im_size & scale)
n_ele = sum(opt.n_ele);
ele_size = opt.ele_size;
n_node = opt.n_node;
n_prt = opt.n_prt;

% process only the slices of interest (soi)
% if we don't specify the soi
if isempty(soi)
    % just use all the slices
    soi = 1:n_slc;
end
soi_min = min(soi);
soi_max = max(soi);

% figure out which imaging plane we want to use
% XZ-Y plane - coronal slices (default)
% YZ-X plane - sagittal slices
% XY-Z plane - axial slices
dir_name = ['X';'Y';'Z'];
dir = zeros(1,3);
if isempty(plane) % coronal, X Z, use dim 1 and dim 3
    dir(1) = 1;
    dir(2) = 3;
    dir(3) = 2;
else
    for i = 1:3
        dir(i) = find(dir_name == plane(i));
    end
end

% compute the aspect ratio of the 2D slices 
xratio = dim(dir(1))/max([dim(dir(1)) dim(dir(2))]);   
yratio = dim(dir(2))/max([dim(dir(1)) dim(dir(2))]);

% compute the number of pixels that central region is
x = round(im_size*scale*xratio);
y = round(im_size*scale*yratio);
% compute the effective pixel size (simulated of course)
px_size(1) = dim(dir(1))/x;
px_size(2) = dim(dir(2))/y;

% compute the thickness of each slice
z = n_slc;
slc_thick = dim(dir(3))/n_slc;


%% GRAB RECTANGULAR INDICES FOR EACH ELEMENT'S NODES
ele_coor = zeros(n_ele,ele_size,3);
for i = 1:n_ele             % for each element
    for j = 1:ele_size             % for each node its connected to
        ele_coor(i,j,:) = node_coor(ele_conn(i,j),:);    % grab that node's 3D coordinates in X,Y,Z format
    end
end

%% DETERMINE WHICH VOXELS EACH ELEMENT TOUCHES
% holder for all the elements, and the list of voxels in which they belong
ele_vx = cell(n_ele,1);

disp('Begin parallel element processing!');
tStart = tic;

parfor i = 1:n_ele
    % holder for the current element, deciding which voxels it touches (starts empty, obviously)
    ele_tmp = [];
    
    % skip elements that belong to parts we don't care about
    % if its not present in the parts var, just ignore it entirely
    if isempty(find(parts == ele_parts(i)))
        continue;
    end
    
    % holders for the largest possible rectangular dimensions of the element 
    % X [min max]
    % Y [min max]
    % Z [min max]
    range = [inf 0; inf 0; inf 0;];
        
    % just a holder for the voxel coordinates
    vx_temp = zeros(ele_size,3);
    
    % holder for the nodal coordinates of this element [X Y Z]
    ele_pts = zeros(ele_size,3);
    for j = 1:ele_size
        % assign the current variable, reorganizing the X Y Z coordinates
        % into whatever coordinate system we specified above
        ele_pts(j,[dir(1) dir(2) dir(3)]) = ele_coor(i,j,[1 2 3]);
        
        % compute where each node fits inside what voxel (3D coordinates)
        % 1D pixel coordinate/full length * # of pixels, rounded down, +1 
        % (so, rounding up each time)
        nx = floor(ele_pts(j,1)/dim(dir(1))*x)+1;  
        ny = floor(ele_pts(j,2)/dim(dir(2))*y)+1;    
        nz = floor(ele_pts(j,3)/dim(dir(3))*z)+1;
        
        % safety check, to make sure we don't exceed boundaries
        if nx > x
            nx = x;
        end
        if ny > y
            ny = y;
        end
        if nz > z
            nz = z;
        end
        
        vx_temp(j,:) = [nx ny nz];         % add the voxel position for that node
        
        % check min/maxes, adjust range as needed
        for k = 1:3
            range(k,1) = min(vx_temp(j,k),range(k,1));
            range(k,2) = max(vx_temp(j,k),range(k,2));
        end 
    end
    
    % add the voxels (don't worry, the function will automatically take care of repeats)
    ele_tmp = FEA_AddVoxel(ele_tmp,vx_temp);
    
    % if all the nodes of an element fit inside one voxel...
    if size(ele_tmp,1) == 1
        % just add it...
        ele_vx{i} = ele_tmp;
        
        % and move onto the next element
        continue;
    end
    
    % compute the other voxels the element touches with its surfaces
    % compute all possible elements it could touch using the range variable
    test_x = range(1,1):range(1,2);
    test_y = range(2,1):range(2,2);
    test_z = range(3,1):range(3,2);
    
    % check if this element even contacts the soi
    vx_skip = 0;
    % if the soi is the entire range we don't need to do this check...
    if soi_min ~= 1 && soi_max ~= n_slc
        for c = 1:size(test_z,2)
            % check if the current slice touches the soi at all
            if test_z(c) >= soi_min && test_z(c) <= soi_max
                % if it does, we're done here. this element counts
                vx_skip = 0;
                break;
            % but if we reach the end and still fail that check
            elseif c == size(test_z,2)
                % this voxel can be excluded from further analysis
                vx_skip = 1;
            end
        end
    end
    
    % a skip implemented above
    if vx_skip
        continue;
    end
    
    % the voxels to test for contact
    to_test = zeros(size(test_x,2)*size(test_y,2)*size(test_z,2),3);
    ind = 1;
    for a = 1:size(test_x,2)
        for b = 1:size(test_y,2)
            for c = 1:size(test_z,2)
                to_test(ind,:) = [test_x(a) test_y(b) test_z(c)];
                ind = ind + 1;
            end
        end
    end
    
    vx_temp2 = [];
    % grab the important information for the element
    %   - normal vector to each face
    %   - list of points associated with each face (3/4)
    %   - the points NOT used with each face (1/4)
    %   - signed distance value for the unused point to its opposing face
    [pl_norm,pl_pts,~,d_sign] = FEA_ElementFaceNorm2(ele_pts);
    % test every voxel to see if it makes contact with the current element
    for j = 1:size(to_test,1)
        [~, corners] = FEA_VoxelCorners(to_test(j,:),dim,[x y z],dir);
        if FEA_ElementVXContact(corners,pl_norm,pl_pts,d_sign)
            vx_temp2 = [vx_temp2; to_test(j,:)];
        end
    end
    
    % draw lines between each node, test if that line intersects any of the test voxels
    comb = nchoosek(1:ele_size,2);     % each combination of node
    n_comb = size(comb,1);
    for j = 1:n_comb
        for k = 1:size(to_test,1)
            % get the coordinates for the voxel we're testing
            [vx_range,~] = FEA_VoxelCorners(to_test(k,:),dim,[x y z],dir);
            % test if a line drawn between the two points intersects ANY of the faces of the test voxel
            pt1 = ele_pts(comb(j,1),:);
            pt2 = ele_pts(comb(j,2),:);
            
            if FEA_IntersectElement(pt1,pt2,vx_range)
                % if it does, add it to the list of voxels for this element
                vx_temp2 = [vx_temp2; to_test(k,:)];
                %ele_vx = FEA_AddVoxel(ele_vx,to_test(k,:));
            end
        end
    end
    
    % add all those voxels, rechecking for duplicates
    ele_tmp = FEA_AddVoxel(ele_tmp,vx_temp2);
    ele_vx{i} = ele_tmp;
end

tEnd = toc(tStart);
disp(['Time taken: ' num2str(tEnd) ' seconds!']);
disp('Parallel element processing complete!');
%assignin('base','ele_vx',ele_vx);

%% ASSIGN THE VALUES FOR EACH ELEMENT INTO THE VOXEL THEY BELONG
% we used Y X Z format because in matlab, the X and Y axis are flipped
% X, the first dimension, is vertical, and Y, the second, is horizontal
vx_grp = cell(y,x,z);      
msk = false(y,x,z,n_prt);   
for i = 1:n_ele
    for j = 1:size(ele_vx{i},1)
        ind_x = ele_vx{i}(j,1);     % the x value of that voxel
        ind_y = ele_vx{i}(j,2);     % the y value
        ind_z = ele_vx{i}(j,3);     % the z value
        ind_p = ele_parts(i);       % the part # that this element belongs to (used in the mask)
        vx_grp(ind_y,ind_x,ind_z) = cell_add(vx_grp(ind_y,ind_x,ind_z), {i});
        msk(ind_y,ind_x,ind_z,ind_p) = 1;
    end
end

%% GRAB THE VALUES FOR EACH ELEMENT AND AVERAGE THEM FOR THE VOXEL, PER PART
% holder, similar to vx_grp, except now the cells have actual numerical values, instead of the element #
img_data = NaN(y,x,z,3);

% NOTE! Normal i,j,k indices are used here but X AND Y ARE SWAPPED! i = y, and j = x!
parfor i = 1:y
    for j = 1:x
        for k = soi
            % normal averaging, deprecated
%             for d = 1:3
%                 %temp3 = {};
%                 % for each element assigned to this voxel...
%                 n_ele_vx = size(vx_grp{i,j,k},2);
%                 temp3 = zeros(n_ele_vx,1);
%                 for a = 1:n_ele_vx
%                     % get the # of the element we want...
%                     target = vx_grp{i,j,k};
%                     % use that element # to look up the displacement value
%                     temp3(a) = ele_disp(target(a),d);
%                     %temp3 = cell_add(temp3,{ele_disp(target,d)});
%                 end
%                 img_data(i,j,k,d) = mean(temp3);
%             end
            % grab the elements belonging to this voxel
            targets = vx_grp{i,j,k};
            % if we have any elements to process
            if ~isempty(targets)
                [~,vx_corners] = FEA_VoxelCorners([j i k],dim,[x y z],dir);
                % get the centroid-weighted average
                [avg, cw_avg] = FEA_CWA(vx_corners,ele_coor(targets,:,:),ele_disp(targets,:));
                %img_data(i,j,k,:) = avg;       % uncomment this line if you want to use normal averaging, and comment out the next line
                img_data(i,j,k,:) = cw_avg;     
            end
        end
    end
end

