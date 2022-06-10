function [val] = SA_RoiVal(map,msk,test,val_type)
% helper function to quick grab the desired stat from an ROI of a map, as specified by the mask

% the test variable is only here to provide changes in special cases

%% VERSION HISTORY
% CREATED 2/18/20 BY SS

%% SAFETY AND PREPARATION
[x1 y1 z1] = size(map);
[x2 y2 z2] = size(msk);

% ensure the maps are the same size
assert(x1 == x2);
assert(y1 == y2);
assert(z1 == z2);

%% PROCESS MAP AS APPROPRIATE
if strcmp(test,'gradient') || strcmp(test,'grad')
    % gradient, need to remove the edges
    [map,msk] = SA_GradientHelper2(map,msk,3,'Method','fast');
else
    % do nothing
end

%% GRAB THE VALUE OF THE MAP IN THE DESIRED ROI
vals_temp = map(find(msk == 1));
vals_temp = remove_outliers(vals_temp,10);  % remove outliers that are 10 orders of magnitude higher than the median
if strcmp(val_type,'mean') || isempty(val_type)
    val = mean(vals_temp,'all','omitnan');
elseif strcmp(val_type,'std') || strcmp(val_type,'stddev') || strcmp(val_type,'std dev') || strcmp(val_type,'standard deviation')
    val = std(vals_temp,'all','omitnan');
elseif strcmp(val_type,'med') || strcmp(val_type,'median')
    val = median(vals_temp,'all','omitnan');
end
