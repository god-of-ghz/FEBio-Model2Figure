% a helper function to start running files at a certain time

% currently set to 2/10/21 at 1pm
% format [YEAR MONTH DAY HOUR MINUTE SECONDS]
% NOTE: hours is in 24 hour format, 0-23
start = [2021 2 13 4 0 0];
delay = 5*60;   % 5 minutes

while ~IsLater(clock,start)
    disp(['Waiting for ' Clock2String(start)]);
    pause(delay);
end
% display  messages
disp('Time is now...');
disp(Clock2String(clock));
disp('Starting now!');

% start scripts
FEA_Strains
FEA_Correlation