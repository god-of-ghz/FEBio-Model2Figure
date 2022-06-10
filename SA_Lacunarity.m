function lmap = SA_Lacunarity(pointmap)
% a function to compute the lacunarity, given a pointmap
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
            moment1 = mean(pointmap{i,j});      % compute 1st moment (ordinary mean)
            moment2 = sum(pointmap{i,j}.^2)/size(pointmap{i,j},2);    % compute 2nd moment (each term is squared before being added up)
            lmap(i,j) = moment2/(moment1^2);
        end
    end
end

