function [new_data] = FEA_Allocation(old_data, alloc, format)
% helper function to quickly rearrange and reallocate data
%% VERSION HISTORY
% CREATED 6/16/20 BY SS

%% SAFETY
if max(size(size(old_data))) > 3
    disp('Data is handled only up to 3 dimensions!')
end

if iscell(old_data)
    error('Cells are unsupported!');
end

%% PREPADATAION
[x,y,z] = size(old_data);               % grab the size of the old data

[old_size, ind] = max(size(old_data));  % the largest dimension is the one to be increased
new_size = old_size + alloc;            % increase that dimension, and re-assign it

%% RE-ALLOCATE THE DATA
% check if NaN format or just zeroes
if isnan(format)
    if ind == 1
        new_data = NaN(new_size,y,z);           % create the new array, with the increased size
        new_data(1:x,:,:) = old_data(:,:,:);    % reassign the old data to the new array
    elseif ind == 2
        new_data = NaN(x,new_size,z);
        new_data(:,1:y,:) = old_data(:,:,:);
    elseif ind == 3
        new_data = NaN(x,y,new_size);
        new_data(:,:,1:z) = old_data(:,:,:);
    else
        error('There was a problem in finding the dimension to re-allocate the data');
    end
else
    if ind == 1
        new_data = zeros(new_size,y,z);
        new_data(1:x,:,:) = old_data(:,:,:);
    elseif ind == 2
        new_data = zeros(x,new_size,z);
        new_data(:,1:y,:) = old_data(:,:,:);
    elseif ind == 3
        new_data = zeros(x,y,new_size);
        new_data(:,:,1:z) = old_data(:,:,:);
    else
        error('There was a problem in finding the dimension to re-allocate the data');
    end
end

