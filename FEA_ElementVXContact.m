function [result] = FEA_ElementVXContact(corner_pts,pl_norm,pl_pts,d_sign)
% function that computes if any part of an voxel (as defined by its 8
% corner points) touches or lies inside an element (as defined by 4 normal
% vectors to its faces, the 3 nodes used in each of those 4 planes, and signed distance values
% from those faces to the opposing corner

%% VERSION HISTORY
% CREATED 7/18/20 BY SS
% MODIFIED 12/19/20 BY SS
%   - allows for variable element size

%% SAFETY AND PREPARATION
n_face = size(pl_norm,1);
assert(n_face == size(pl_pts,1));
assert(n_face == size(d_sign,1));

%% COMPUTE
for i = 1:8 % for each corner pt
    for j = 1:n_face   % compare it to the signed distance for each plane
        val = FEA_SignedDistance(pl_norm(j,:),squeeze(pl_pts(j,1,:)),corner_pts(i,:));
        %disp(val)
        % if true, this point is on the wrong side of the plane, therefore out of the element
        if val/d_sign(j) < 0
            break; % unless it works for every plane, it's not a match
        % if we got this far..
        elseif j == n_face
            % its a match. this point fits inside the element, and
            % therefore the element makes contact with this voxel
            result = 1;
            return;
        end
    end
end

result = 0;