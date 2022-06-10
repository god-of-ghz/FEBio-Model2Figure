function [fixed] = clean_nan(img)
% helper function to turn NaN into zeros

[x, y, z] = size(img);
fixed = img;

for i = 1:x
    for j = 1:y
        for k = 1:z
            if isnan(img(i,j,k))
                fixed(i,j,k) = 0;
            end
        end
    end
end