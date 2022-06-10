function [n_node,n_step,n_ele,n_prt,ele_size,finish] = FEA_FileOptimizer(filename, filetype)
% function to read through and optimize reading of a files to save time

%% VERSION HISTORY
% CREATED 12/14/20 BY SS

%% SAFETY AND PREPARATION
if ~exist(filename, 'file')
    disp(['The file: ' filename 10 ' does not exist!' newline 'Please check the filename!']);
    n_node = [];
    n_step = [];
    n_ele = [];
    n_prt = [];
    ele_size = [];
    finish = 0;
    return;
end

if isempty(filetype)
    filetype = 'log';
elseif ~strcmp(filetype,'feb') && ~strcmp(filetype,'log')
    error('Unsupported filetype!');
end

n_node = [];
n_step = [];
n_ele = [];
n_prt = [];
ele_size = [];
finish = 0;

%% READ THROUGH FILE, OPTIMIZING INTENDED PARAMETERS
if strcmp(filetype,'log')
    n_node = 0;
    readfile = fopen(filename,'r');
    line = fgetl(readfile);
    % find the first data record
    while ~strcmp(line,'Data Record #1')
        line = fgetl(readfile);
        if strcmp(line,' E R R O R   T E R M I N A T I O N')
            finish = 0;
            return;
        elseif feof(readfile)
            finish = 0;
            return;
        end
    end
    % find when the data record ends (i.e. the number of nodes + 6 extra lines)
    while ~strcmp(line,'Data Record #2')
        n_node = n_node + 1;
        line = fgetl(readfile);
        
        % safety check
        if feof(readfile)
            finish = 0;
            return;
        end 
    end
    for i = 1:n_node
        line = fgetl(readfile);
    end
    
    n_step = 1;
    while (contains(line,'AUTO STEPPER:') || contains(line, 'beginning time step')) && ~feof(readfile)
        while ~strcmp(line,'Data Record #1')
            % safety check
            if feof(readfile)
                finish = 0;
                return;
            end 
            line = fgetl(readfile);
        end
        for i = 1:n_node*2
            line = fgetl(readfile);
        end
        n_step = n_step + 1;
        
        % safety check
        if feof(readfile)
            finish = 0;
            return;
        end
    end
    
    while ~feof(readfile)
        line = fgetl(readfile);
        if strcmp(line, ' N O R M A L   T E R M I N A T I O N')
            finish = 1;
        end
    end 
    
    n_node = n_node - 6;
    fclose(readfile);
elseif strcmp(filetype,'feb')
    n_ele = [];
    n_ele_temp = 0;
    n_prt = 0;
    ele_types = [];
    
    readfile = fopen(filename,'r');
    line = fgetl(readfile);
    %disp('File open!')
    %disp('Finding elements section...')
    while ~contains(line,'Elements')
        line = fgetl(readfile);
    end
    while ~strcmp(line,'</febio_spec>')
        ind = strfind(line,'Elements type');
        if ~isempty(ind)
            %disp('Element found!')
            ele_type = line(ind+15:ind+18);
            % ADD MORE ELEMENTS TO SUPPORT HERE
            if strcmp(ele_type,'tet4') || strcmp(ele_type,'hex8')
                ele_types = [ele_types; ele_type];
                %disp(['Element type: ' ele_type])
                % need to actually start reading the data to get a proper count of elements
                line = fgetl(readfile);
                n_prt = n_prt + 1;
                n_ele_temp = 0;
                while ~strcmp(line,'		</Elements>')
                    n_ele_temp = n_ele_temp + 1;
                    line = fgetl(readfile);
                end
                n_ele = [n_ele; n_ele_temp;];
            else
                while ~strcmp(line,'		</Elements>')
                    line = fgetl(readfile);
                end
            end
        end
        line = fgetl(readfile);
    end
    
    ele_type = mode(ele_types);
    ele_size = str2num(ele_type(end));
    if isempty(ele_size)
        disp('There was an error when automatically inferring element size!')
    end
    
    fclose(readfile);
end