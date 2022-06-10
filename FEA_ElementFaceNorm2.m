function [normal,pl_pts,op_pts,d_sign] = FEA_ElementFaceNorm2(pts)
% helper function, computes the following:
%   - normal vector to each face (defined by 3 points)
%   - the unused point for each face (directly opposite)
%   - the signed distance values for the unused points VS the faces
%   (that last one is needed to see if a point is inside the element or not)
% only works for tet4 and hex8 elements


%% VERSION HISTORY
% CREATED 7/18/20 BY SS
% MODIFIED 12/19/20 BY SS
%   - allows for elements of tet4 and hex8 size
%   - additional elements can easily be added by including more

%% SAFETY AND PREPARATION
n_pts = size(pts,1);
if n_pts ~= 4 && n_pts ~= 8
    error('Only tet4 and hex8 elements are supported!');
end

%% COMBINATIONS OF POINTS TO COMPUTE NORMS
% every face of an element is made of some # of points
% the hard-coded array below uses all the possible combinations of how the
% points make up each face
if n_pts == 4
    % the nodes that make up each face
    % example, for a tet4, face 1 is made up of node 1,2, and 3
    comb = [1 2 3; 1 2 4; 1 3 4; 2 3 4;];
    
    % and a list of the UNUSED point(s) for that face.
    % example, for a tet4, face 1 does NOT use node 4
    unused = [4;3;2;1];
    % nodes per face
    npf = 3;
    % number of faces
    n_face = 4;
elseif n_pts == 8
    % hardcoded for how PreView numbers its nodes
    % Depending on how your mesh is generated, this might differ! It must be manually inspected for every
    comb = [1 2 3 4; 1 2 5 6; 1 4 8 5; 5 6 7 8; 2 6 7 3; 4 3 7 8;];
    unused = [7;8;6;1;4;2];
    npf = 4;
    n_face = 6;
end

%% COMPUTE NORMALS
normal = zeros(n_face,3);   % the normal vectors
pl_pts = zeros(n_face,npf,3);  % the points used in each plane
op_pts = zeros(n_face,3);    % the unused point

for i = 1:n_face
    % grab the points for this face
    cur_pts = zeros(npf,3);
    for j = 1:npf
        cur_pts(j,:) = pts(comb(i,j),:);
        % assign them for the holder
        pl_pts(i,j,:) = cur_pts(j,:);
    end
    % compute normal
    normal(i,:) = cross(cur_pts(2,:)-cur_pts(1,:),cur_pts(2,:)-cur_pts(3,:));
    % get the unused point
    op_pts(i,:) = pts(unused(i),:);
end

%% COMPUTE SIGNED DISTANCES
d_sign = zeros(n_face,1);
for i = 1:n_face
    plane_pt = pts(comb(i,1),:);
    test_pt = op_pts(i,:);
    d_sign(i) = FEA_SignedDistance(normal(i,:),plane_pt,test_pt);
end