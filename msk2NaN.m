function [NaNmsk] = msk2NaN(msk)
% helper function to quickly convert a mask with zeroes to NaN

%% VERSION HISTORY
% CREATED 12/4/19 BY SS

%% SAFETY AND PREPARATION
[x y] = size(msk);
NaNmsk = NaN(x, y);

%% CONVERT MASK
NaNmsk(find(msk)) = 1;