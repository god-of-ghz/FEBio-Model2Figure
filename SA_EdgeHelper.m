function [lmap2, msk] = SA_EdgeHelper(lmap, msk)
% helper function to mitigate effects of edges in the computed heuristic map (lmap)

%% VERSION HISTORY
% CREATED 1/14/20 BY SS

%% SAFETY AND PREP
% SKIPPED SAFTEY BECAUSE I LIVE ON THE EDGE.

%% NORMALIZE THE MASK, JUST IN CASE
msk = double(msk/max(msk(:)));

%% PROCESS IMAGE
temp = lmap.*msk;
lmap2 = temp;
