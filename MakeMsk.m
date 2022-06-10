function [msk] = MakeMsk(map,type)
% helper function to quickly make a 2D mask

%% VERSION HISTORY
% CREATED 7/7/20 BY SS

%% SAFETY AND PREPARATION
[x y] = size(map);
if x ~= y
    disp('Warning! Square 2D map was expected...')
end

%% FILL IN MASK
if isnan(type)
    msk = NaN(x,y);
    msk(find(~isnan(map))) = 1;
else
    msk = zeros(x,y);
    msk(find(map ~= 0)) = 1;
end