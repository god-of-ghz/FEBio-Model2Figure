function defect_map = SA_Defect(strain, msk, shape, loc, r, dist, range)
% a function to create a defect in strain data
%% VERSION CONTROL
% CREATED 11/10/19 BY SS

%% INSTRUCTIONS TO USE
% SHAPE 
%   CIRCLE
%   LINE
%   SQUARE
% LOCATION
%   PERCENT OF OF X AND Y DIMENSION
% SIZE
%   DIAMETER OF CIRCLE
%   WIDTH OF LINE
%   LENGTH & WIDTH OF SQUARE
% DISTRIBUTION
%   LINEAR FROM ONE % TO ANOTHER %
%   ALL ONE %
%   RANDOM % IN A RANGE
% RANGE
%   LOW TO HIGH STRAIN (OR JUST 1, AS NEEDED)

%% SAFETY AND PREPARATION
if size(size(strain),2) ~= 2
    error('Input strain MUST be a 2D matrix');
end
if size(strain,2) ~= size(msk,2)
    error('Input strain and mask must be the same size, a 2D matrix.');
end

[x, y] = size(strain);

% if ~isstring(shape)
%     error('Input shape must be a string!');
% end
% if ~isa(loc, 'numeric')
%     error('Input location must be a number!');
% end
% if size(loc, 2) ~= 2
%     error('Input location must be TWO numbers!');
% end
% if ~isa(size, 'numeric')
%     error('Size must be a number!');
% end
% if ~isstring(dist)
%     error('Distribution must be a string!');
% end
% if ~isa(range, 'numeric')
%     error('Strain range must be 1-2 numbers!');
% end
defect_map = strain;

%% PREPARE THE DEFECT DATA
if strcmp(shape, 'circle') || strcmp(shape, 'c')
    defect = zeros(r, r);       % declare the smaller matrix holding the defect
    c = round(r/2);              % center point, also the radius
    for i = 1:r
        for j = 1:r
            d = Distance(i,j,c,c);  % distance to the center
            if d > c                % if its too far to make a 'circle', skip this part
                continue
            end
            if strcmp(dist, 'linear')
                scale = 1-d/c;    % scaling value from 100% (furthest from center) to 0% (the center)
                val = ((range(2) - range(1))*scale) + range(1);
                defect(i,j) = val;  % assign the scaled strain value to that spot
            else
                error('only coded for linear atm');
            end
        end
    end
end

% for debugging only
%figure, imagesc(defect), colorbar, title('defect shape, for inspection');

%% DETERMINE THE BOUNDING BOX FOR THE STRAIN DATA
% skipped for now, loc will be manually input XY coordinates

%% LAY THE DEFECT DATA OVER THE STRAIN DATA
% determine x range for the defect area
xbegin = loc(1)-c;
xend = xbegin+r;
xrange = xbegin:1:xend-1;       

% determine y range for the defect area
ybegin = loc(2)-c;
yend = ybegin+r;
yrange = ybegin:1:yend-1;

%assignin('base', 'xrange', xrange);
%assignin('base', 'yrange', yrange);

for i = xrange
    for j = yrange
        if msk(i,j)     % if the mask in this spot is valid
            if defect(i-xbegin+1,j-ybegin+1) ~= 0 % and if the defect map is valid in that spot
                defect_map(i,j) = defect(i-xbegin+1,j-ybegin+1);    % assign the defect map's value to the original strain map
            end
        end
    end
end

