function [result] = ProcessF(F,operator)
% helper function to process a deformation tensor with the desired operators

%% VERSION HISTORY
% CREATED 7/6/20 BY SS

%% PREP
x = size(F,1);
y = size(F,2);
if size(F,3) ~= 3 || size(F,4) ~= 3
    error('Deformation tensor components expected in 3rd and 4th dimension, as 3x3 matrix!')
end

result = zeros(x, y);
if x ~= y
    error('Deformation tensor must be processed into square shape!')
end

%% PERFORM OPERATION
for i = 1:x
    for j = 1:y
        result(i,j) = MatrixOperator(squeeze(F(i,j,:,:)),operator);
    end
end
