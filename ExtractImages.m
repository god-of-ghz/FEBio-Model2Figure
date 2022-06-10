% Automatically extract all images from a scan or set of scans
%% VERSION HISTORY
% CREATED 4/11/2019 BY SS
% MODIFIED 5/15/2019 BY SS
%   - ADDED NEW SAVE LOCATIONS

%% SCAN NAMES
scan_name{1} = ';


%% SKIP
skip = [];     % skip these folders for whatever reason

%% SAVE LOCATIONS
save_dense = 1;             % save the images in the DENSE/slices folder
save_shared = 0;            % save the images in the shared experiments folder

%% DIRECTORY PREPARATION

%all computers
folderpath = 'C:\Users\Sameer\OneDrive - Rensselaer Polytechnic Institute\Documents\MRI Data\MRIScanData\';

num_scans = max(size(scan_name));
scan_list = cell(1, num_scans);


%populate each scan's scan list
for i = 1:num_scans
    scan_ind = 1;
    path = [folderpath scan_name{i} '\' num2str(scan_ind)];
    while(exist(path, 'dir'))
        %disp(scan_ind)
        scan_list{i} = [scan_list{i}; scan_ind;];
        scan_ind = scan_ind + 1;
        
        % if this one's marked to be skipped, iterate to the next one
        while(find(skip == scan_ind))
            scan_ind = scan_ind + 1;
        end
        
        path = [folderpath scan_name{i} '\' num2str(scan_ind)];
    end
end

%make directories
for i = 1:num_scans
    folder = ['slices/' scan_name{i}];
    if ~exist(folder, 'dir')
        mkdir (folder)
    end
end

%% READ IN DATA
% for each scan set
for i = 1:num_scans
    current_scans = scan_list{i};               % grab that set's scan list
    num_current = max(size(current_scans));     % determine # of scans
    folder = ['slices\' scan_name{i}];          % get the folder
    for j = 1:num_current % if we're meant to skip this scan, skip it
        if find(skip == current_scans(j))
            continue
        end
        
        path = [folderpath scan_name{i} '\' num2str(current_scans(j))];      % determine the path to read
        [pars, ~] = GETMRIPARAM([folderpath scan_name{i} '\'], current_scans(j));    % get the method (for naming)
        method = pars.method;
        subject = pars.subject;
        
        % get rid of the annoying bruker formatting
        % turns '<BRUKER:denseFISP>' to just 'denseFISP'
        method = method(find(method == ':')+1:end-1); 
        % ignore b0 maps
        if strcmp(method, 'FieldMap')
            continue;
        end
        
        % check if it actually exists
        filepath = [path '\pdata\1\2dseq'];
        if ~exist(filepath, 'file')
            continue;
        end
        
        % write images
        img = ReadISAData(filepath);         % read in the data
        imN = img./max(img(:));                             % normalize
        [~, ~, z] = size(imN);
        for k = 1:z                                         % title and write all slices
            i_title = [num2str(current_scans(j)) ' - ' method ' - ' num2str(k) '.tif'];
            if save_dense
                ftitle = [folder '\' i_title];
                imwrite(imN(:,:,k), ftitle);
            end
            if save_shared
                if ~exist([targpath exp_path subject '\'], 'dir')
                    mkdir ([targpath exp_path subject '\'])
                end
                ftitle = [targpath exp_path subject '\' i_title];
                imwrite(imN(:,:,k), ftitle);
            end
        end
    end
end

