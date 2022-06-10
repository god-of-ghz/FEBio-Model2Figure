% Automatically repair FEBio .feb files that wont run with an alternate version
% This assumes files have been generated by FEA_GenerateSims.m already, and
% have been run at least once

%% SET UP PARAMETERS
model = 'defect_model_';

if strcmp(model,'defect_model_')
    % patient-specific defect model
    n_pts_1 = 1;       % number of simulations to run the first parameter set
    n_pts_2 = 23;       % for the 2nd parameter set
    fac = 1;
    range_E = [0.3:0.1:1.5].*(0.85*fac);
    range_v = [0.3:0.1:1.5].*0.30;
    range_s = [1e-9 1e-8 5e-8 1e-7 5e-7 1e-6 5e-6 1e-5 1e-4 1e-3 1e-2 1e-1 1 10 100 1000 1e4 5e4 1e5 5e5 1e6 5e6 1e7];
    range_s = sort(range_s);
    E_ind = 46;
    v_ind = 47;
    s_ind = 679508;
    root = 'C:\Users\Sameer\OneDrive - Rensselaer Polytechnic Institute\Documents\FEA\Hex_Mesh_Knee_Cartilage\9932809_00mo\smoothed\models - febio\';
    
    % lines to replace only for broken files
    r_ind = 17;
    r_vals = [1 0]; % 2 values to swap between
    % the two halves of the line, the value fits between them when concatenated horizontally
    r_format_1 = ['		<qnmethod>'];
    r_format_2 = ['</qnmethod>'];
end

%% DETERMINE WHICH FILES SHOULD BE CORRECTED
if ~exist('to_use','var')
    to_use = ones(n_pts_1,n_pts_2);
    disp('The variable "to_use" will now be generated.')
    parfor i = 1:n_pts_1
        for j = 1:n_pts_2
            % generate the filename
            path = [root 'E' num2str(round(range_E(i)/fac,2)) '\'];
            filename = [model num2str(round(range_E(i)/fac,2)) 'e6_' num2str(range_s(j)) '.log'];
            target = [path filename];
            
            disp(['Assessing file: ' extract_filename(target)]);
            disp('--------------------------------------------------');
            
            % make sure it exists
            if ~exist(target,'file')
                disp('This file does not exist! Marking it as not run...')
                to_use(i,j) = 0;
                continue;
            end
            
            % determine if that file terminated properly
            [~,~,~,~,~,finish] = FEA_FileOptimizer(target,'log');
            to_use(i,j) = finish;
            
            disp(['---------------------------------------------' newline 'Finished assessing file!']);
        end
    end
    
        disp(newline);
    disp('--------------------------------------------------');
    disp('  F I L E  A S S E S S M E N T  C O M P L E T E!  ');
    disp('--------------------------------------------------');
end

%% RUN THROUGH AND REPAIR THOSE FILES
parfor i = 1:n_pts_1
    for j = 1:n_pts_2
        if ~to_use(i,j)
            % generate the appropriate filename
            path = [root 'E' num2str(round(range_E(i)/fac,2)) '\'];
            filename = [model num2str(round(range_E(i)/fac,2)) 'e6_' num2str(range_s(j)) '.feb'];
            target = [path filename];
            
            % make sure that file exists at all
            if ~exist(target,'file')
                disp('This file to be corrected: ')
                disp(extract_filename(target))
                disp('does not exist! Skipping...')
                continue;
            end
            
            % read in that file
            disp('Reading file: ')
            disp(extract_filename(target))
            base_file = cell(1e7,1);
            file_ind = 1;
            readfile = fopen(target,'r');
            readline = fgetl(readfile);
            while(~strcmp(readline,'</febio_spec>'))
                base_file{file_ind} = readline;
                file_ind = file_ind + 1;
                readline = fgetl(readfile);
            end
            base_file{file_ind} = '</febio_spec>';
            n_lines = file_ind;
            disp('File read!')
            fclose(readfile);
            
            % now fix that line to be the opposite of what it was
            r_line = base_file{r_ind};
            if contains(r_line,num2str(r_vals(1)))
                r_line = [r_format_1 num2str(r_vals(2)) r_format_2];
            elseif contains(r_line,num2str(r_vals(2)))
                r_line = [r_format_1 num2str(r_vals(1)) r_format_2];
            end
            
            % write the file with the corrected line
            disp('Writing file: ');
            disp(filename);
            % start writing the file
            writefile = fopen(target,'w');
            for k = 1:n_lines
                if k == r_ind
                    to_write = r_line;
                else
                    to_write = base_file{k};
                end
                fprintf(writefile,'%s\n',to_write);
            end
            fclose(writefile);
            disp('Finished writing!')
        end
    end
end

%% GENERATE BATCH FILES TO RUN *ONLY* THE MODELS IN NEED OF REPAIR
% write the master file - calls the other batch files per folder
masterfile = ['run_all_repair.bat'];
target = [root masterfile];
writefile = fopen(target,'w');
fprintf(writefile,'%s\n','@echo on');
fprintf(writefile,'%s\n',['cd ' root]);
for i = 1:n_pts_1
    folder = ['E' num2str(round(range_E(i)/fac,2))];
    to_write = ['start "' folder '" /wait cmd /c CALL ' folder '/run_' folder '_repair.bat'];
    fprintf(writefile,'%s\n',to_write);
end
%fprintf(writefile,'%s\n','call run_intact.bat');
fclose(writefile);


% write each of the individual files per folder
for i = 1:n_pts_1
    folder = ['E' num2str(round(range_E(i)/fac,2))];
    subfile = ['run_' folder '_repair.bat'];
    target = [root folder '\' subfile];
    writefile = fopen(target,'w');
    fprintf(writefile,'%s\n','@echo off');
    fprintf(writefile,'%s\n','cd C:\Program Files\FEBio2.9.1\bin');
    for j = 1:n_pts_2
        % write only the needed files
        if ~to_use(i,j)
            to_write = ['FEBio2 -i "' root folder '\' model num2str(round(range_E(i)/fac,2)) 'e6_' num2str(range_s(j)) '.feb"'];
            fprintf(writefile,'%s\n',to_write);
        end
    end
    fclose(writefile);
end