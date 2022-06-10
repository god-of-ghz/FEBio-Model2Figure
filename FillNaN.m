function [nanmap] = FillNaN(map,msk)
% a helper function, fills in all the values in the map not covered by the mask with NaN

nanmap = map;
nanmap(find(msk ~= 1)) = NaN;