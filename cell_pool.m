function [pooled] = cell_pool(c_old, c_new)
% helper function to quickly pool the actual data WITHIN each cell for an array of cells
% the old and new cells to pool must be the exact same size (singleton dimensions excepted)
% the data WITHIN the cells does not have to be the same size (which is why
% cells are being used)

%% SAFETY & PREPARATION
c_old = squeeze(c_old);                 % remove singleton dimensions
c_new = squeeze(c_new);             
assert(max(size(size(c_old))) <= 4);    % ensure we have no more than 4 dimensions

[x y z w] = size(c_old);              
[a b c d] = size(c_new);
assert(x == a && y == b && z == c && w == d);     % ensure they are the same size

pooled = cell(x, y, z, w);

%% POOL DATA
for i = 1:x
    for j = 1:y
        for k = 1:z
            for m = 1:w
                pooled(i,j,k,m) = {[c_old{i,j,k,m} c_new{i,j,k,m}]};
            end
        end
    end
end

