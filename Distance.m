function d = Distance(varargin)
% helper function to quickly compute scalar distances between pairs of points

% expects values in one of the following formats 
%   x1, y1, z1, x2, y2, z2
%   [x1,y1,z1] & [x2, y2, z2];


%% VERSION HISTORY
% CREATED 11/9/2019 BY SS
% MODIFIED 4/29/2021 BY SS
%   - allows for 3D points
%   - allows additional formats of points
%   - allows for multiple sets of points at once

%% CALCULATE DISTANCE
if nargin == 2
    %              point2          point1
    d = sqrt(sum((varargin{2} - varargin{1}).^2));
elseif nargin == 4
    %            x2           x1                y2          y1
    d = sqrt((varargin{3}-varargin{1}).^2 + (varargin{4}-varargin{2}).^2);
elseif nargin == 6
    %            x2           x1                y2          y1                  z2           z1
    d = sqrt((varargin{4}-varargin{1}).^2 + (varargin{5}-varargin{2}).^2 + (varargin{6}-varargin{3}).^2);
else
    error('Incorrect number of input values!');
end

