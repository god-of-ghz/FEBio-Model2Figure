function [filename] = extract_filename(path)
% helper function to quickly return JUST the filename of a full path
% ex: 'C:\Users\Public\example.txt' returns 'example'

% find all OS path delimiters
ind = find(path == '\');
if isempty(ind)
    ind = find(path == '/');
end
% take the very last one
ind = ind(end);
% extract the 'example.txt' part
filename = path(ind+1:end);
% get rid of the extension
ind = find(filename == '.');
if isempty(ind)
    return;
end
ind = ind(end);
filename = filename(1:ind-1);
