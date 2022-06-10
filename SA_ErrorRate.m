function [sen, spec, type1, type2] = SA_ErrorRate(def_pts, msk)
% computes type 1 (false positive) and type 2 (false negative) error rates for a given list of indices of defect points

%% VERSION HISTORY
% CREATED 1/14/20 BY SS

%% SAFETY AND PREPARATION
% fuck it, going raw for now
sen = 0;        % accuracy/sensitivity
spec = 0;       % specificity, how often it correctly says no this isn't an edge
type1 = 0;
type2 = 0;

def_count = size(def_pts,1);
px_count = max(size(find(msk > 0)));
total_count = length(msk)^2;

goodID = 0;
badID = 0;

for i = 1:def_count
    x = def_pts(i,1);
    y = def_pts(i,2);
    if msk(y,x)
        goodID = goodID+1;
    else
        badID = badID+1;
    end
end

%% COMPUTE ERRORS
sen = goodID/px_count;
spec = (total_count-badID-px_count)/(total_count-px_count);
type1 = 1-spec;
type2 = 1-sen;