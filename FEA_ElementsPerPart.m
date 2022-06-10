function [ele_parts, n_parts] = FEA_ElementsPerPart(filename)
% a helper script to grab the list of elements associated with each part
%% VERSION HISTORY
% CREATED 8/20/20 BY SS

%% SAFETY AND PREPARATION
if ~exist(filename, 'file')
    error('That file does not exist! Please check the filename!');
end

%% PREPARE DATA HOLDERS
n_parts = 0;
alloc = 1000000;
ele_parts = zeros(alloc,1);
ele_read = 0; % an indicator if an element is being read

%% OPEN THE FILE
datafile = fopen(filename);
line = fgetl(datafile);
line = fgetl(datafile);     % yes, this line is repeated for a reason
if ~strcmp(line, '<febio_spec version="2.5">')
    disp('Warning! FEBio spec 2.5 expected!');
elseif size(line,2) > 20
    if ~strcmp(line(1:20), '<febio_spec version=')
        error('This file is not formatted correctly! Expected FEBio format!')
    end
end 

%% READ IN DATA
while ~strcmp(line,'</febio_spec>')
    line = fgetl(datafile);
    %disp(line)
    if size(line,2) > 35
        if strcmp(line(1:23),'		<Elements type="tet4"') && ele_read == 0
            n_parts = n_parts + 1;
            ele_read = 1;
            
            to_disp = ['Reading elements for part #: ' num2str(n_parts)];
            disp(to_disp);
            continue
        end
    elseif size(line,2) < 15
        if strcmp(line,'		</Elements>')
            to_disp = ['Done reading elements for part #: ' num2str(n_parts)];
            disp(to_disp);
            ele_read = 0;
            continue
        end
    end
    
    if ele_read == 1
        if strcmp(line(1:13),'			<elem id="')
            % expected format: <elem id="ele_id"> node1, node2, node3, node4</elem>
            id_ind = find(line == '"');     % find the quotes
            ele_id = str2num(line(id_ind(1)+1:id_ind(2)-1));    % element ID is between the first 2 quotes
            
            % reallocate if necessary
            if ele_id > size(ele_parts,1)
                ele_parts = FEA_Allocation(ele_parts,alloc,0);
            end
            
            % assign the current part to that element index value
            ele_parts(ele_id) = n_parts;
            
            if mod(ele_id,5000) == 0
                to_disp = [num2str(ele_id) ' elements read!'];
                disp(to_disp)
            end
        end
    end
end

%% CLEANUP
% return only the values used from the start to the last element read (the largest)
ele_parts = ele_parts(1:ele_id);