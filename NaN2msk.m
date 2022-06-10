function [msk] = NaN2msk(NaNmsk)
% helper function to quickly convert a mask with NaN to zeroes

%% VERSION HISTORY
% CREATED BY 12/4/19 BY SS
% FIXED 12/10/19 BY SS

%% SAFETY AND PREPARATION
[x y] = size(NaNmsk);
msk = zeros(x, y);

%% CONVERT MASK
for i = 1:x
    for j = 1:y
        if ~isnan(NaNmsk(i,j))
            msk(i,j) = 1;
        end
    end
end