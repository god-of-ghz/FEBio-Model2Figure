function [ctime] = AddTime(ctime_old, to_add)
% helper function to quickly add time (in seconds) to the output of 'clock.m'
% note, this function does NOT account for leap years because I'm too lazy

% days per month
dpm = [31 28 31 30 31 30 31 31 30 31 30 31];

ctime = ctime_old;
% go through each level one at a time, adding as much as we can

% years
while to_add >= 3600*24*365
    % special case, just for years
    time_in_years = to_add/(3600*24*365);
    years_to_add = floor(time_in_years);
    leftover = time_in_years - years_to_add;
    
    ctime(1) = ctime(1) + years_to_add;        % directly increment the year
    to_add = leftover*(3600*24*365);  %          % subtract a year's worth of seconds
end
% months, update year as needed
while to_add >= 3600*24*dpm(ctime(2))
    if ctime(2) == 12                           % if we're in december
        to_add = to_add - 3600*24*dpm(12);      % subtract december's worth of time
        ctime(2) = 1;                           % reset to january
        ctime(1) = ctime(1) + 1;                % add a new year
    else
        to_add = to_add - 3600*24*dpm(ctime(2));    % subtract that months' worth of time
        ctime(2) = ctime(2) + 1;                    % increment the month
    end
end
% days, update month as needed
while to_add >= 3600*24
    if ctime(3) == dpm(ctime(2))        % if we're on the last day of a month
        to_add = to_add - 3600*24;      % subtract a day's worth of time
        ctime(3) = 1;                   % reset to day 1
        ctime(2) = ctime(2) + 1;        % add a month (december --> january should have been taken care of already)
    else
        to_add = to_add - 3600*24;      % subtract a day's worth of time
        ctime(3) = ctime(3) + 1;        % add a day
    end
end
% hours, update days as needed
while to_add >= 3600
    if ctime(4) == 23                   % if we're on 11pm...
        to_add = to_add - 3600;         % subtract an hour's worth of time
        ctime(4) = 0;                   % reset to midnight (0 on a 24-hour clock)
        ctime(3) = ctime(3) + 1;        % go to the next day
    else
        to_add = to_add - 3600;         % subtract an hour's worth of time
        ctime(4) = ctime(4) + 1;        % add an hour
    end
end
% minutes, update hours as needed
while to_add >= 60                      % you get the drill...
    if ctime(5) == 59
        to_add = to_add - 60;
        ctime(5) = 0;
        ctime(4) = ctime(4) + 1;
    else
        to_add = to_add - 60;
        ctime(5) = ctime(5) + 1;
    end
end
% seconds, update minutes as needed
while to_add > 1
    if ctime(6) >= 59
        to_add = to_add - 1;
        ctime(6) = ctime(6) - floor(ctime(6));      % go to 0 seconds, but preserve the decimal places
        ctime(5) = ctime(5) + 1;
    else
        to_add = to_add - 1;
        ctime(6) = ctime(6) + 1;
    end
end

% add the milliseconds
ctime(6) = ctime(6) + to_add;

% run through the newly added time, correcting for any errors
for i = 6:-1:1
    % the upper limits of of each value. if a value reaches this point...
    max_vals = [inf 13 dpm(ctime(2))+1 24 60 60];
    % it must be reset to 1 or 0 (or not at all)
    reset = [inf 1 1 0 0 0];
    if ctime(i) >= max_vals(i)
        ctime(i-1) = ctime(i-1) + 1;
        ctime(i) = reset(i);
    end
end
