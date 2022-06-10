function [newimg] = SA_Overlay(img, ind)
% a function to quickly overlay plusses on an image, indicating defects

%% VERISON HISTORY
% CREATED 12/11/19 BY SS

%% OVERLAY DEM POINTS
for i = 1:max(size(ind))
    figure, imagesc(img)
end
