function [new_vals] = remove_outliers(old_vals, mag_order)
% a helper function to quickly remove outliers from a list of values, based
% on a desired order of magnitude as a threshold

med = median(old_vals,'all','omitnan');
new_vals = old_vals;
% remove the values that are too big
new_vals(find(abs(new_vals) > abs(med)*(10^mag_order))) = [];