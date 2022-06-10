function [data_shift, dim_range] = FEA_DataShift(data_raw, dim)
% function to shift the nodal coordinates to positive values, starting at 0,0,0;
%% VERSION HISTORY
% CREATED 6/16/20 BY SS
% MODIFIED 7/12/20 BY SS
%   - made inputting data optional
% MODIFIED 12/18/20
%   - made it so the input data detects if its 4 OR 3 columns

% determine the shift needed for each axis
diff = zeros(1,3);
dim_range = zeros(1,3);
for i = 1:3
    diff(i) = 0 - dim(i,1);
    dim_range(i) = dim(i,2) - dim(i,1);
end

% peform the shift needed on each axis
if ~isempty(data_raw)
    data_shift = data_raw;
    % columnar index shift to allow input data to be in 4 OR 3 col format
    n_col = size(data_raw,2);
    shift = n_col-3;
    for i = 1:3
        data_shift(:,i+shift) = data_shift(:,i+shift)+diff(i);
    end
else
    data_shift = [];
end

