function [ele_conn, ele_parts, ele_disp, node_coor, node_disp, dim, opt] = FEA_ReadData2(feb_file, log_file, cached, opt)
%function [elements, nodes, dim, ele_parts, n_parts] = FEA_ReadData(ele_file, prt_file, node_cap, ele_cap, saved)
% function to organize ElementData and ElementsPerPart and cache the data

%% VERSION HISTORY
% CREATED 9/14/20 BY SS
% MODIFIED 12/14/20 BY SS
%   - now reads in element connectivity through .feb files
%   - reads in nodal displacements through febio output .log file
%   - computes element displacement through nodal displacements
%   - employs file optimization in the form of an 'opt' struct

%% SAFETY & PREPARATION
cache_path = 'FEA_cached\';

if isempty(cached)   % if we don't specify to use cached data, don't use it.
    clear cached;
    cached.node = 0;
    cached.ele = 0;
end


if isempty(opt)     % if we don't already have a file optimization struct, build it
    clear opt;      % get rid of that shit entirely because matlab is balls stupid
    [opt.n_node, opt.n_step,~,~,~,finish] = FEA_FileOptimizer(log_file,'log');
    [~,~,opt.n_ele,opt.n_prt,opt.ele_size,~] = FEA_FileOptimizer(feb_file,'feb');
else
    if isempty(opt.n_node) || isempty(opt.n_step)
        [opt.n_node, opt.n_step,~,~,~,finish] = FEA_FileOptimizer(log_file,'log');
    end
    if isempty(opt.n_ele) || isempty(opt.n_prt) || isempty(opt.ele_size)
        [~,~,opt.n_ele,opt.n_prt,opt.ele_size,~] = FEA_FileOptimizer(feb_file,'feb');
    end 
end

if exist('finish','var')
    if ~finish
        disp(['This file: ' extract_filename(logfile) newline 'Did not terminate normally! Skipping it...']);
        ele_conn =[];
        ele_parts = [];
        ele_disp = [];
        node_coor = [];
        node_disp = []; 
        return;
    end
end


%% READ NODAL DATA FROM LOG FILE
if ~isempty(log_file)
    if ~exist(log_file, 'file')
        error(['The file: ' log_file newline ' does not exist!' newline 'Please check the filename!']);
    end
    cache_file = extract_filename(log_file);
    cache_file = [cache_path cache_file '_node.mat'];
    if ~cached.node
        [node_coor, node_disp] = FEA_ReadNodeData(log_file,opt.n_node,opt.n_step);
        save(cache_file,'node_coor','node_disp');
    else
        if exist(cache_file,'file')
            disp('Loading from cache!')
            disp(cache_file)
            load(cache_file,'node_coor','node_disp');
        else
            disp('There was no cached file available in:')
            disp(cache_file)
            disp('Reading data from:')
            disp(log_file)
            [node_coor, node_disp] = FEA_ReadNodeData(log_file,opt.n_node,opt.n_step);
            save(cache_file,'node_coor','node_disp');
        end
    end 
end

%% READ ELEMENT CONNECTIVITY FROM FEB FILE
if ~isempty(feb_file)
    if ~exist(feb_file, 'file')
        error(['The file: ' feb_file newline ' does not exist!' newline 'Please check the filename!']);
    end
    cache_file = extract_filename(log_file);
    cache_file = [cache_path cache_file '_ele.mat'];
    if ~cached.ele
        [ele_conn, ele_parts] = FEA_ReadElementData(feb_file,opt.n_ele,opt.n_prt,opt.ele_size);
        save(cache_file,'ele_conn','ele_parts');
    else
        if exist(cache_file,'file')
            disp('Loading from cache!')
            disp(cache_file)
            load(cache_file,'ele_conn','ele_parts')
        else
            disp('There was no cached file available in:')
            disp(cache_file)
            disp('Reading data from:')
            disp(feb_file)
            [ele_conn, ele_parts] = FEA_ReadElementData(feb_file,opt.n_ele,opt.n_prt,opt.ele_size);
            save(cache_file,'ele_conn','ele_parts');
        end
    end
end

%% COMPUTE ELEMENT DISPLACEMENTS
ele_disp = zeros(sum(opt.n_ele),3);
for i = 1:sum(opt.n_ele)
    for j = 1:3
        temp = 0;
        for k = 1:opt.ele_size 
            target_node = ele_conn(i,k);
            temp = temp + node_disp(target_node,j);
        end
        temp = temp/sum(opt.ele_size);
        ele_disp(i,j) = temp;
    end
end

%% COMPUTE DIMENSIONS
dim = NaN(3,2); % 3D, negative to positive
dim(1,1) = min(node_coor(:,1));  % negative X
dim(1,2) = max(node_coor(:,1));  % positive X
dim(2,1) = min(node_coor(:,2));  % negative Y
dim(2,2) = max(node_coor(:,2));  % positive Y
dim(3,1) = min(node_coor(:,3));  % negative Z
dim(3,2) = max(node_coor(:,3));  % positive Z

