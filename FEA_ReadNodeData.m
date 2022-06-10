function [node_coor, node_disp] = FEA_ReadNodeData(filename, n_node, n_step)
% function to read in nodal data from .log files

%% VERSION HISTORY
% CREATED 12/16/20 BY SS


%% SAFETY AND PREPARATION
if ~exist(filename, 'file')
    error(['The file: ' filename newline ' does not exist!' newline 'Please check the filename!']);
end

node_coor = zeros(n_node,3);
node_disp = zeros(n_node,3);

%% OPEN FILE AND SKIP TO THE DATA
readfile = fopen(filename,'r');
line = fgetl(readfile);

% skip all the timesteps except the last one
for i = 1:n_step-1
    while ~strcmp(line,'Data Record #1')
        line = fgetl(readfile);
    end
    for i = 1:(n_node+6)*2
        line = fgetl(readfile);
    end
end

%% READ IN THE FIRST HALF OF THE DATA
% find the last time step
while ~strcmp(line,'Data Record #1')
    line = fgetl(readfile);
end
% ensure its the correct one we expect and the file is formatted properly
for i = 1:4
    line = fgetl(readfile);
    if i == 2
        n = str2num(line(8:end));
        assert(n == n_step)
    elseif i == 4
        assert(contains(line,'NODAL COORDINATES'));
    end
end
% start reading in the data
disp('Reading coordinate data...')
for i = 1:n_node
    line = fgetl(readfile);
    temp = str2num(line);
    node_coor(i,:) = temp(2:end);
end
disp('Coordinate data complete!')

%% READ IN THE SECOND HALF OF THE DATA
while ~strcmp(line,'Data Record #2')
    line = fgetl(readfile);
end
% ensure its the correct one we expect and the file is formatted properly
for i = 1:4
    line = fgetl(readfile);
    if i == 2
        n = str2num(line(8:end));
        assert(n == n_step)
    elseif i == 4
        
        assert(contains(line,'NODAL DISPLACEMENTS'));
    end
end
% start reading in the data
disp('Reading displacement data...')
for i = 1:n_node
    line = fgetl(readfile);
    temp = str2num(line);
    node_disp(i,:) = temp(2:end);
end
disp('Displacement data complete!')

%% CLEANUP
fclose(readfile);
