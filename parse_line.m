function [data] = parse_line(raw_data, data_ind)
% helper function to read in data from ascii delineated lines

%% VERSION HISTORY
% CREATED 12/9/2019 BY SS

%% SAFETY AND PREPARATION
if isempty(raw_data)
    error('line cannot be empty');
end

data = [];

% data ind is an array of the individual values we want from the line
% so if we have a line like: "34000, 0.2074191, 0.04, 2.361449"
% the 1st value would be 34000
% the 2nd is 0.2074191
% the 3rd is 0.04
% the 4th is 2.361449
% data_ind to grab ALL the data would be [1 2 3 4], [1:4], or even [:]
% if we want JUST #2, data_ind would just be 2
%% PARSE LINE
temp = str2num(raw_data);

% if the length of the line and the indexes we want to read from that data
% don't match, something is wrong, and we should ignore this line.
% also ignore it if the indexes are too large for the line of data
if size(data_ind,2) ~= size(temp,2)
    return;
end
if max(data_ind) > size(temp,2)
    return;
end

%% GRAB RELEVANT DATA
data = temp(data_ind);
