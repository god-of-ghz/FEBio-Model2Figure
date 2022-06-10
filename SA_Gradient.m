function [lmap,pts,vectors] = SA_Gradient(img, msk)
% function to compute a gradient map of an image with a mask

%% VERSION HISTORY
% CREATED 12/4/19 BY SS
% MODIFIED 6/24/20 BY SS
%   - now returns map of vectors to indicate gradient direction

%% SAFETY AND PREPARATION
[x y] = size(img);
[a b] = size(msk);

if a ~= x || y ~= b
    error('Image and mask must be of the same size');
end

NaNmsk = msk2NaN(msk);

%% PERFORM GRADIENT
[lmap, amap] = imgradient(img.*NaNmsk);

%% GRAB LIST OF POINTS
pts = [];
for i = 1:x
    for j = 1:y
        if msk(i,j)    % if the mask is valid here
            pts = [pts; [i, j]];    % add that point
        end
    end
end
n_pts = max(size(pts));

%% COMPUTE VECTOR VALUES
vectors = zeros(n_pts,2);
for i = 1:n_pts
    [vectors(i,1), vectors(i,2)] = SA_GradientAngleHelper(amap(pts(i,1),pts(i,2)),lmap(pts(i,1),pts(i,2)));
end