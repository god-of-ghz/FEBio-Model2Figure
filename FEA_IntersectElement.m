function [result] =  FEA_IntersectElement(pt1,pt2,range)
% a helper function to determine if a line drawn between the two points intersects a voxels 
% pt1 and pt2 are simple 3D coordinates [X Y Z]
% 'range' is a series of 6 values, minimum and maximum X, Y, and Z
% function returns true if ANY intersection is detected

%% VERSION HISTORY
% CREATED 7/12/20 BY SS

%% SAFETY AND PREPARATION
if max(size(pt1)) ~= 3 || max(size(pt2)) ~= 3
    disp(pt1)
    disp(pt2)
    error('Singular, 3D coordinates are expected!');
end

if size(range,1) ~= 3 || size(range,2) ~= 2
    error('Range is expected to be 6 values, min and max of X,Y,Z!')
end

if max(size(size(range))) ~= 2
    error('Range has more dimensions than expected!')
end

%% PERFORM CALCULATION
% to hold the constants for the 3D line equation
eqs = FEA_Equation3D(pt1,pt2);

ind = [1:3];    % a small helper for determining which comparison to make

for i = 1:3     % for X, Y, and Z
    for j = 1:2     % for the maximum and minimum points
        for k = find(ind ~= i)     % for the comparison to each other dimension (i.e if X, compare with Y and Z. If Y, compare X and Z, etc)
            
            % compute the value at that face (using X, Y or Z to compute the remaining 2 points)
            val = ((range(i,j) - pt1(i))/eqs(i))*eqs(k)+pt1(k);
            
            % if that value lies WITHIN the range, it's a match
            if val >= range(k,1) && val <= range(k,2)
                % this voxel counts, so we're done. don't need to analyze
                % anything else
                result = 1;
                return;
            end
        end
    end
end

%% IF WE'VE GOTTEN THIS FAR, NO INTERSECTIONS WERE FOUND
result = 0;