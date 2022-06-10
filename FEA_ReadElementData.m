function [ele_conn, ele_parts] = FEA_ReadElementData(filename, n_ele, n_prt, ele_size)
% function to read the element data from the .feb file

%% VERSION HISTORY
% CREATED 12/16/20 BY SS

%% SAFETY AND PREPARATION
if ~exist(filename, 'file')
    error(['The file: ' filename newline ' does not exist!' newline 'Please check the filename!']);
end

total_ele = sum(n_ele);

if isempty(n_ele) && isempty(n_prt)
    opt = 0;
else
    opt = 1;
end

if opt
    ele_conn = zeros(total_ele,ele_size);
    ele_parts = zeros(total_ele,1);
else
    alloc = 10e6;
    ele_conn = zeros(alloc,13);
    ele_parts = zeros(alloc,13);
end

%% START READING IN THE ELEMENTS, ONE PART AT A TIME
readfile = fopen(filename,'r');
line = fgetl(readfile);

% find the elements section
while ~contains(line,'Elements')
    line = fgetl(readfile);
end
disp('Elements section found!')

% repeat until all the parts are found
if opt
    for i = 1:n_prt
        % make SURE we're at the start of an actual elements section
        disp('Finding relevant elements...');
        while ~contains(line,'Elements type')
            line = fgetl(readfile);
        end
        ind = strfind(line,'Elements type');
        ele_type = line(ind+15:ind+18);
        % make sure its only a part with elements we care about, keep searching
        % until we find such a part
        while ~strcmp(ele_type,'tet4') && ~strcmp(ele_type,'hex8')
            while ~strcmp(line,'		</Elements>')
                line = fgetl(readfile);
            end
            ind = strfind(line,'Elements type');
            if isempty(ind)
                error('No elements of tet4 or hex8 shape were found!')
            end
            ele_type = line(ind+15:ind+18);
        end
        
        disp(['Found! Reading elements for part #' num2str(i) '...']);
        for j = 1:n_ele(i)
            line = fgetl(readfile);
            [data, ~] = FEA_ParseFebLine(line);
            ele_ind = j+sum(n_ele(1:i-1));
            ele_conn(ele_ind,:) = data(2:end);
            ele_parts(ele_ind) = i;
        end
        disp(['Finished reading in ' num2str(n_ele(i)) ' elements!']);
    end
    disp(['Finished reading ' num2str(sum(n_ele)) ' elements across ' num2str(n_prt) ' parts!']);
    fclose(readfile);
else
    % to add later...
end