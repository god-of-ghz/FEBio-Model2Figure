function [] = SA_QuiverOverlay(map, mask, vectors,scale, reduce)
% a function to overlay arrows onto a given map

%% VERSION HISTORY
% CREATED 6/24/20 BY SS

%% SAFETY AND PREPARATION
[x y] = size(map);
[a b] =  size(vectors);

if a ~= x || b ~= y
    error('Mapped data and vector map must be the same size!');
end





