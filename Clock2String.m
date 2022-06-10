function [date_string] = Clock2String(ctime)
% helper function to turn standard 'clock' output into a usable time/date
% example: '12/23/2020 - 9:18 PM'

% format the date into MM/DD/YYYY format
date = [num2str(ctime(2)) '/' num2str(ctime(3)) '/' num2str(ctime(1))];

% compute hour in 12 hour format, with midnight being 12 instead of 0
if ctime(4) > 12    % evening
    hour = num2str(ctime(4) - 12);
    ampm = 'PM';
elseif ctime(4) < 12    % morning
    if ctime(4) == 0
        hour = '12';     % midnight
    else
        hour = num2str(ctime(4));    % regular morning
    end
    ampm = 'AM';
elseif ctime(4) == 12   % noon
    hour = num2str(ctime(4));
    ampm = 'PM'; 
else               
    error('wat')
end

% compute minutes, adding a '0' in front for nice formatting
if ctime(5) < 10
    minute = ['0' num2str(ctime(5))];
else
    minute = num2str(ctime(5));
end

% we are ignoring seconds since normal people don't read time in seconds

% format it all together
date_string = [date ' - ' hour ':' minute ' ' ampm];
