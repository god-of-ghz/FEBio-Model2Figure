function [vals] = DivideUp(a, b, varargin)
% helper function to divide A things into B discrete sections of "equal" size

% the 'method' is where you want the smallest sections to be
% the options are:
%   even: large/small sections are evenly distributed (default)
%   begin: small sections are all at the beginning
%   end: small sections are at the end
%   center: small sections are in the middle(ish)
%   edges: small sections are on the sides

if nargin >= 3
    method = varargin{1};
elseif nargin == 2
    method = 'even';
end

% for safety
if b == 0
    b = 1;
end

vals = zeros(b, 1);         % the # of rows each level will pool
base_val = a / b;           % base value

if strcmp(method, 'even')
    for i = 1:b      % round each row up OR down
        if mod(i, 2)    %if its an odd row, round up
            vals(i) = floor(base_val) + 1; 
        else            %if its even, round down
            vals(i) = floor(base_val);
        end
    end
elseif strcmp(method, 'center')
    vals(:) = floor(base_val);
else
    vals(:) = floor(base_val)+1;  
end

% to make SURE we have the right number of rows
while(sum(vals) ~= a)
    if sum(vals) < a           % if we rounded DOWN too much
        [~, ind] = min(vals);       % find the first 'low' row,
        vals(ind) = vals(ind) + 1;  % up its value by 1
    elseif sum(vals) > a       % if we rounded UP too much
        [~, ind] = max(vals);       % find the first 'high' row,
        vals(ind) = vals(ind) - 1;  % down its value by 1
    end
    
    % in case center-focused rounding was specified
    % flipping every time will result in more center-oriented rounding
    if strcmp(method, 'center') || strcmp(method, 'edges')
        vals = flip(vals);
    end
end

% in case rounding was specified to start at the end, reverse it
if strcmp(method, 'end')
    vals = flip(vals);
end

% final check for safety
assert(sum(vals) == a);
assert(max(size(vals)) == b);