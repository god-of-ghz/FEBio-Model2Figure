function [indices] = cell_find(A, B)
% helper function to quickly find a variable B within a CELL array A and return all indices where it was found

%% VERSION HISTORY
% CREATED 6/28/19 BY SS

%% PREPARATION & SAFETY
if size(size(A),2) > 6
    error('Cell array size too large, unsupported at this time.')
end
if ~iscell(A)
    error('Please enter a CELL array for A.')
end
[a, b, c, d, e, f] = size(A);
indices = [];
    
    
%% SEARCH FOR VARIABLE
for i = 1:a
    for j = 1:b
        for k = 1:c
            for m = 1:d
                for n = 1:e
                    for o = 1:f
                        if isa(B, 'numeric')
                            if A{i,j,k,m,n,o} == B
                                indices = [indices, sub2ind(size(A),i,j,k,m,n,o)];
                            end
                        elseif ischar(B)
                            if strcmp(A{i,j,k,m,n,o}, B)
                                indices = [indices, sub2ind(size(A),i,j,k,m,n,o)];
                            end
                        elseif iscell(B)
                            if isequal(A{i,j,k,m,n,o},B{1})
                                indices = [indices, sub2ind(size(A),i,j,k,m,n,o)];
                            end
                        else
                            error('Unsupported data type for B- please search only for numbers, char arrays or cells');
                        end
                    end
                end
            end
        end
    end
end

%% RETURN 0 IF EMPTY
if isempty(indices)
    indices = 0;
end
            