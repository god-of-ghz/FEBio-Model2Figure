function [sign] = FEA_SignedDistance(plane_norm,plane_pt,test_pt)
% helper function to determine the side on which the test pt is from the plane (indicated by a normal vector and a known point on that plane)

%% VERSION HISTORY
% CREATED 7/18/20 BY SS

%% SAFETY AND PREPARATION

% ensure plane is a 1x3 or 3x1 matrix
if size(size(plane_norm),2) ~= 2
    error('Be sure the plane is ONLY a 2D matrix!')
elseif ~xor(size(plane_norm,1) == 3, size(plane_norm,2) == 3)
    error('Matrix must be a 1x3 or 3x1 array!')
end

% ensure plane point and test points are also 1x3 or 3x1 matrices
if size(size(plane_pt),2) ~= 2
    disp(plane_pt)
    error('Be sure the plane point is ONLY a 2D matrix!')
elseif ~xor(size(plane_pt,1) == 3, size(plane_pt,2) == 3)
    error('Plane points must be a 1x3 or 3x1 array!')
end

if size(size(test_pt),2) ~= 2
    error('Be sure the plane point is ONLY a 2D matrix!')
elseif ~xor(size(test_pt,1) == 3, size(test_pt,2) == 3)
    error('Plane points must be a 1x3 or 3x1 array!')
end

[a b] = size(plane_pt);
[x y] = size(test_pt);

% if one of the points has the wrong format, then fix it so they're the same
if a ~= x || b ~= y
    if a == 3
        test_pt = permute(test_pt,[2 1]);
    elseif x == 3
        plane_pt = permute(plane_pt,[2 1]);
    end
end

%% PERFORM CALCULATION
sign = dot((plane_pt - test_pt),plane_norm);

