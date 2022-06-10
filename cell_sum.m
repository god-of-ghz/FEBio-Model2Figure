function [total_sum] = cell_sum(c_data)
% a function to quickly sum up cell data
% expects a cell array filled with smaller arrays of doubles

assert(iscell(c_data));             % make sure its a cell
assert(size(size(c_data), 2) == 2);    % make sure the whole thing is 2D

if isempty(c_data)
    total_sum = 0;
    %count = 0;
    return;
end


[x, y] = size(c_data);              % grab the size

% initialize the running sum
run_sum = 0;

for i = 1:x
    for j = 1:y
        assert(size(size(c_data{1}), 2) == 2);       % make sure each cell is 2D
        %count = count + max(size(c_data{i, j}));
        run_sum = run_sum + sum(c_data{i, j});
    end
end

total_sum = run_sum;
