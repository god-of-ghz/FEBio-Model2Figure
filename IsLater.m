function [is_later] = IsLater(time_now,target_time)
% helper function to tell if the time_now is later than the target time
% time is in the following format
% [year month day hour minute seconds]
assert(size(time_now,1) == 1);
assert(size(target_time,1) == 1);
assert(size(time_now,2) == 6);
assert(size(target_time,2) == 6);

is_later = false;
for t = 1:6
    if time_now(t) > target_time(t)
        is_later = true;
        return;
    elseif time_now(t) < target_time(t)
        is_later = false;
        return;
    elseif time_now(t) == target_time(t)
        % do nothing, continue
    end
end