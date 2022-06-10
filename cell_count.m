function [count] = cell_count(c_data)
% a function to quickly count up how many entries are in a cell

assert(iscell(c_data));             % make sure its a cell
assert(size(size(c_data), 2) <= 5);    % make sure the whole thing is 2D at most

if isempty(c_data)
    count = 0;
    return;
end

[a, b, c, d, e] = size(c_data);              % grab the size

% initialize the running count
count = 0;

for i = 1:a
    for j = 1:b
        for k = 1:c
            for m = 1:d
                for n = 1:e
                    [x, y, z, w] = size(c_data{i,j,k,m,n});
                    %count = count + max(size(c_data{i,j,k,m,n}));
                    count = count + (x*y*z*w);
                end
            end
        end
    end
end