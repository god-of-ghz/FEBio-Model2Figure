function [rmax, rmin] = LimitHelper(max, min, val, r)
% helper to compute relevant limits for a window of size r
%% VERSION HISTORY
% CREATED 11/9/2019 BY SS

%% SAFETY AND PREP
assert(max >= min+1);
assert(val >= min);
assert(val <= max);

% compute the limits of a window given the maximum/minimum indices of an
% image as well as the current pixel, and the window size r
% i.e. if we're figuring out the limits of a window of size 10, with a
% current index of 96, but the image maximum is 100, then the window will
% be from 91 (96-10/2) and 100 (since 100 is smaller than 96+10/2)

%% COMPUTE LIMITS
if r == 0           % if the window size is 0, i.e. one pixel
    rmax = val;
    rmin = val;
else
    if max <= round(val+(r/2));     % if we exceed the max, use the max
        rmax = max;
    else
        rmax = round(val+(r/2));    
    end
    
    if min >= round(val-(r/2));     % if we are below the min, use the min
        rmin = min;
    else
        rmin = round(val-(r/2));
    end
end
