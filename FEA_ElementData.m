function [ele_final, node_final, dim] = FEA_ElementData(filename, node_cap, ele_cap)
% function to read in zero displacement nodal data from PostView

%% VERSION HISTORY
% CREATED 12/9/19 BY SS
% MODIFIED 12/10/19 BY SS
%   - moved reorganizing functionality to FEA_Organize
% MODIFIED 6/16/20 BY SS
%   - implemented automatic data allocation and resizing
% MODIFIED 6/24/20 BY SS
%   - implemented reading in elements as well as nodes

%% CONVENIENCE, FOR DEBUGGING
if isempty(filename)
   filename = 'C:\Users\Sameer\OneDrive - Rensselaer Polytechnic Institute\Documents\FEA\Idealized Knee\results\intact_xdisp.txt'; 
end

% Define where the nodes of interest end (for speed)
% if unsure or undefined, default is 1 million, will add more as space as needed
alloc = 1000000;

if isempty(node_cap)
    node_cap = alloc;   
    n_node = 0;         % define the actual # of nodes (needed later)
    auto_node = 1;      % bool used to indicate of data is automatically allocated or not
else
    n_node = node_cap;
    auto_node = 0;
end

if isempty(ele_cap)
    ele_cap = alloc;
    n_ele = 0;
    auto_ele = 1;
else
    n_ele = ele_cap;
    auto_ele = 0;
end


%% SAFETY AND PREPARATION
if ~exist(filename, 'file')
    error('File does not exist.');
end

% expected NODAL information
% dim, 3 numbers
%   1 - left right witdth of model (in mm, default 4mm)
%   2 - thickness of model (in mm, default 0.08mm)
%   3 - height of model (in mm, default 2mm)

% pre-allocating a large array of data, for speed
% column 1 = node #
% column 2 = X value (left to right)
% column 3 = Y value (into the screen and out of the screen)
% column 4 = Z value (up down, what we ACTUALLY use for the Y values)
% column 5 = nodal value (varies, depending on the data we're importing)
data_node = zeros(node_cap, 5);

% expected ELEMENT information
% column 1 = element #
% columns 2-5 = nodes involved with that element (assuming tet4)
data_ele = zeros(ele_cap, 6);

line_ind = [];
data_type = [];

%% READ IN DATA
datafile = fopen(filename);
line = fgetl(datafile);
if ~strcmp(line, '*ASCII EXPORT')
    error('File differs from expected input');
end

while ~strcmp(line, '*END')
    line = fgetl(datafile);         % grab the line
    if strcmp(line, '*NODES')
        disp('READING NODE COORDINATES!')
        line_ind = [1 2 3 4];       % hard coded for postview
        data_type = 'node';
        continue;
    elseif strcmp(line, '*ELEMENTS')    % if we find elements...
        disp('READING ELEMENT CONNECTIVITY!')
        line_ind = [1:5];
        data_type = 'ele';
        continue;
    elseif strcmp(line, '*ELEMENT_DATA')
        disp('READING ELEMENT VALUES!')
        line_ind = [1 2];           % hard coded for postview
        data_type = 'ele';
        continue;
    elseif strcmp(line, '*NODAL_DATA')
        disp('READING NODE VALUES!')
        line_ind = [1 2];           % hard coded for postview
        data_type = 'node';
        continue;
    end
    ldata = parse_line(line, line_ind); % parse the line
    
    if ~isempty(ldata)               % if its actually got data...
        if strcmp(data_type,'node')
            % adjust data caps and re-allocate as needed
            if ~auto_node && (ldata(1) > node_cap)   % if we are using a fixed node_cap, ignore it
                continue;
            elseif auto_node && (ldata(1) > node_cap)   % if we're not, re-allocate
                node_cap =  node_cap + alloc;
                disp('Reallocating data!');
                data_node = FEA_Allocation(data_node,alloc,0);
            end
            
            % increment node counter as needed
            if auto_node && data_node(ldata(1),1) == 0   % if data *hasn't* been allocated yet
                n_node =  n_node + 1;                       % increment the counter

                if mod(n_node,5000) == 0
                    to_display = [num2str(n_node) ' nodes read...'];    % inform us every 5k nodes how many nodes there are
                    disp(to_display);
                end
            end

            % assign the data to the correct spot
            if size(ldata, 2) == 4      % and its size 4, it is coordinate data
                data_node(ldata(1), 1:4) = ldata; % assign the whole line
            elseif size(ldata, 2) == 2  % if its size 2, then its displacements
                data_node(ldata(1), 5) = ldata(2); % assign JUST the last value
            end
        elseif strcmp(data_type,'ele')
            
            if ~auto_ele && (ldata(1) > ele_cap)
                continue;
            elseif auto_ele && (ldata(1) > node_cap)
                ele_cap = ele_cap + alloc;
                disp('Reallocating data!');
                data_ele = FEA_Allocation(data_ele,alloc,0);
            end

            % assign the data to the correct spot
            if size(ldata,2) >= 5
                data_ele(ldata(1),1:end-1) = ldata;
                % increment node counter as needed
                if auto_ele && data_ele(ldata(1),1) ~= 0    % if this element *has* been assigned
                    n_ele =  n_ele + 1;                    % increment the counter

                    if mod(n_ele,5000) == 0
                        to_display = [num2str(n_ele) ' elements read...'];    % inform us every 5k nodes how many elements there are
                        disp(to_display);
                    end
                end
            elseif size(ldata,2) == 2
                %if the element we're trying to assign has a value, but no
                %nodal connectivity (i.e. it wasn't assigned earlier
                %because it's not a valid tetrahedral element)...
                %...ignore it
                if data_ele(ldata(1),1) == 0
                    continue;
                else
                    data_ele(ldata(1),end) = ldata(2);
                end
            end
        end
    end
end

%% FIX THE SIZE OF THE DATA, AS NEEDED
if auto_node
    node_final = zeros(n_node, 5);
    node_final(:,:) = data_node(1:n_node,:);
    to_display = [num2str(n_node) ' total nodes read!'];
    disp(to_display)
end

if auto_ele
    ele_final = zeros(n_ele, 6);
    ele_final(:,:) = data_ele(1:n_ele,:);
    to_display = [num2str(n_ele) ' total elements read!'];
    disp(to_display)
end

%% DETERMINE THE RECTANGULAR DIMENSIONS OF THE DATA
dim = NaN(3,2); % 3D, negative to positive
dim(1,1) = min(data_node(:,2));  % negative X
dim(1,2) = max(data_node(:,2));  % positive X
dim(2,1) = min(data_node(:,3));  % negative Y
dim(2,2) = max(data_node(:,3));  % positive Y
dim(3,1) = min(data_node(:,4));  % negative Z
dim(3,2) = max(data_node(:,4));  % positive Z

%% SAVE DATA (for speed later)

