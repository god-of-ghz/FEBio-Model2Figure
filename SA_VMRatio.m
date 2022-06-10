function lmap = SA_VMRatio(pointmap)
% a function to compute the variance:mean ratio
%% VERSION HISTORY
% CREATED 11/9/2019 BY SS

%% SAFETY AND PREPARATION
if size(size(pointmap),2) ~= 2
    error('Pointmap must be a 2D matrix')
end
[x, y] = size(pointmap);
lmap = NaN(x, y);

%% COMPUTE LACUNARITY (SECOND MOMENT OVER FIRST MOMENT SQUARED)
for i = 1:x
    for j = 1:y
        if ~isempty(pointmap{i,j})              % only bother if the cell has stuff in it
            lvar = std(pointmap{i,j})^2;
            lmean = mean(pointmap{i,j});
            lmap(i,j) = lvar/lmean;             % variance to mean ratio
        end
    end
end