function [lim] = expand_limits(data,exp_factor)
% helper function to create expanded limits based on a data set
data_max = max(data,[],'omitnan');
data_min = min(data,[],'omitnan');
data_range = data_max - data_min;

lim = zeros(1,2);
lim(1) = data_min - data_range*exp_factor;
lim(2) = data_max + data_range*exp_factor;

return;