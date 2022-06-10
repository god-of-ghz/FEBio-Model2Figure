function [new_cell] = cell_add(a, b)
% helper function, add the contents of cell b to cell a

%% VERSION HISTORY
% CREATED 12/10/19 BY SS

%% POOL THE CELLS
new_cell = {[a{:} b{:}]};
