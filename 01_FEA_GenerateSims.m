%% FEA PROCESSING SUITE -  STEP 1/4 - GENERATE .FEB FILES
%   ----------------------------------------------------------------------
%   This program is used to automatically generate all the files needed
%   for a set of FEBio simulations, and .bat files to run them in sequence.

%% VERSION HISTORY
% CREATED 12/8/20 BY SS
% MODIFIED 12/16/20 BY SS
%   - generates batch files to run everything
% MODIFIED 4/27/20 BY SS
%   - generalized variable names, improved comments

%% ADD THIS TO YOUR BASE .FEB FILE IN <OUTPUT>, BENEATH <PLOTFILE>
% 		<logfile>
% 			<node_data data="x;y;z" name="NODAL COORDINATES" delim=",	"></node_data>
% 			<node_data data="ux;uy;uz" name = "NODAL DISPLACEMENTS" delim=",	"></node_data>
% 		</logfile>

%% PARAMETERS
% script/caching parameters
cache_path = 'FEA_cached/';
make_file = 1;          % actually generate the files, or just use this to generate a parameter file

file_ext = '.feb';      % file extension, .feb for default
file_end = '</febio_spec>'; % what to expect at the end of the file

% simulation parameters
model = 'simple_model2_';       % which of the following models to run

if strcmp(model,'example_')
    n_pts_1 = 1;       % number of simulations to run the 1st parameter set
    n_pts_2 = 1;       % for the 2nd parameter set
    % ADD THIRD PARAMETER SET HERE IF NEEDED
    
    % setting variable values
    fac = 1;            % factor to multiply var1 by (for convenience)
    base_val = 1;
    range_var1 = [];    % values for variable 1
    range_var2 = [];    % values for variable 2 (varied with variable 1!)   
    range_var3 = [];    % values for variable 3
    
    % setting variable insertion into file. set to 0 if you want to skip it
    var1_ind = [];      % the line to insert each value for variable 1, one per file
    var2_ind = [];      % the line to insert each value for variable 2, one per file
    var3_ind = [];      % the line to insert each value for variable 3, one per file
    
    root = '';          % root folder of where all your models will be stored
elseif strcmp(model,'defect_model_')
    % patient-specific defect model
    n_pts_1 = 13;       % number of simulations to run the first parameter set
    n_pts_2 = 11;       % for the 2nd parameter set
    fac = 1;
    range_var1 = [0.3:0.1:1.5].*(2.0*fac);
    range_var2 = [0.3:0.1:1.5].*0.30;
    range_var3 = [0.001 0.01 0.05 0.1 0.5 1 5 10 50 100 1000];
    %range_s = [1e-9 1e-8 5e-8 1e-7 5e-7 1e-6 5e-6 1e-5 1e-4 1e-3 1e-2 1e-1 1 10 100 1000 1e4 5e4 1e5 5e5 1e6 5e6 1e7];
    %range_s = sort(range_s);
    var1_ind = 46;
    var2_ind = 47;
    var3_ind = 679503;
    root = 'C:\Users\Sameer\OneDrive - Rensselaer Polytechnic Institute\Documents\FEA\Hex_Mesh_Knee_Cartilage\9932809_00mo\smoothed\models - febio\';
elseif strcmp(model,'simple_model_')
    % simple fe model
    n_pts_1 = 13;       % number of simulations to run the first parameter set
    n_pts_2 = 1;       % for the 2nd parameter set
    fac = 1;
    range_var1 = [0.3:0.1:1.5].*(0.85*fac);
    range_var2 = [0.3:0.1:1.5].*0.30;
    range_var3 = [0];
    var1_ind = 56;
    var2_ind = 57;
    var3_ind = 0;  % if you dont want to replce this line, just make the value 0
    root = 'C:\Users\Sameer\OneDrive - Rensselaer Polytechnic Institute\Documents\FEA\Simple Explant\';
elseif strcmp(model,'simple_model2_')
    % second simple fe model
    n_pts_1 = 13;       % number of simulations to run the first parameter set
    n_pts_2 = 1;       % for the 2nd parameter set
    fac = 1;
    range_var1 = [0.3:0.1:1.5].*(0.85*fac);
    range_var2 = [0.3:0.1:1.5].*0.30;
    range_var3 = [0];
    var1_ind = 52;
    var2_ind = 53;
    var3_ind = 0;  % if you dont want to replace this line, just make the value 0
    root = 'C:\Users\Sameer\OneDrive - Rensselaer Polytechnic Institute\Documents\FEA\Simple Explant2\';
end 


%% FILENAMES
febfiles = cell(n_pts_1,n_pts_2);   % holders for the file names
logfiles = cell(n_pts_1,n_pts_2);

%% MAKE DIRECTORIES
% generates directories for each set of simulations. variables 1 and 2 are
% varied together, and each combination has its own folder. variable 3
% makes the files in each folder

% safety check
if ~exist(root,'dir')
    error('Root directory does not exist! Try again.');
else
    disp('Making directories...');
    for i = 1:n_pts_1
        % FILE NAMING:
        target = [root 'E' num2str(round(range_var1(i)/fac,2))];
        if ~exist(target,'dir')
            mkdir (target)
        end
    end
end

%% FIND STARTING FILE, BUILD THE BASE FILE TO GENERATE ALL THE OTHERS
% hardcode these to whatever naming scheme you want for your files
% FILE NAMING: starter file is the base, used to generate all other files. must have the lowest value from each variable.
starter = [root model num2str(round(range_var1(1)/fac,2)) 'e6_' num2str(range_var3(1)) file_ext];

% read in that file
disp('Reading base file...')
base_file = cell(1e7,1);
file_ind = 1;
readfile = fopen(starter,'r');
readline = fgetl(readfile);

while(~strcmp(readline,file_end))    % expects an febio .feb file
    base_file{file_ind} = readline;
    file_ind = file_ind + 1;
    readline = fgetl(readfile);
end
base_file{file_ind} = file_end;
n_lines = file_ind;
disp('Base file read!')

%% GENERATE THE NEW FILES, SAVING THE FILENAMES
parfor i = 1:n_pts_1
    for j = 1:n_pts_2
        % VARIABLE LINES: create the lines to insert
        var1_line = ['			<E>' num2str(range_var1(i)) '</E>'];
        var2_line = ['			<v>' num2str(range_var2(i)) '</v>'];
        var3_line = ['			<max_traction>' num2str(range_var3(j)) '</max_traction>'];
        
        % FILE NAMING: create the file, using the same hardcoded naming scheme
        path = [root 'E' num2str(round(range_var1(i)/fac,2)) '\'];  % folder
        filename = [model num2str(round(range_var1(i)/fac,2)) 'e6_' num2str(range_var3(j)) file_ext]; % file name
        target = [path filename];
        
        % note the file name and save it
        febfiles{i,j} = target;
        logfiles{i,j} = [target(1:end-4) '.log'];
        
        % if we want to write the file, do so and replace the relevant
        % lines
        if make_file
            disp('Writing file: ');
            disp(filename);
            % start writing the file
            writefile = fopen(target,'w');
            % intercept the important lines. ADD MORE LINES HERE AS NEEDED!
            for k = 1:n_lines
                if k == var1_ind
                    to_write = var1_line;
                elseif k == var2_ind
                    to_write = var2_line;
                elseif k == var3_ind
                    to_write = var3_line;
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

%% SAVE THE FILENAMES
% saves all the parameters and filenames in a parameter file, in the FEA cache folder
if ~exist('FEA_cached/','dir')
    mkdir ('FEA_cached/');
end
savefile = ['FEA_' model num2str(round(min(range_var1)/fac,2)) '-' num2str(round(max(range_var1)/fac,2)) '_' num2str(min(range_var3)) '-' num2str(max(range_var3))];
savefile = ['FEA_cached/' savefile '.mat'];
% which things should be saved to the parameter files. MODIFY IF MORE VARIABLES ARE NEEDED!
save(savefile,'n_pts_1','n_pts_2','febfiles','logfiles','root','range_var1','range_var2','range_var3');


%% GENERATE BATCH FILES TO RUN THESE MODELS
% only works on windows, and assumes administrator privileges!

% write the master file - calls the other batch files per folder
if make_file
    masterfile = ['run_all.bat'];
    target = [root masterfile];
    writefile = fopen(target,'w');
    fprintf(writefile,'%s\n','@echo on');
    fprintf(writefile,'%s\n',['cd ' root]);
    for i = 1:n_pts_1
        folder = ['E' num2str(round(range_var1(i)/fac,2))];
        to_write = ['start "' folder '" /wait cmd /c CALL ' folder '/run_' folder '.bat'];
        fprintf(writefile,'%s\n',to_write);
    end
    fprintf(writefile,'%s\n','call run_intact.bat');
    fclose(writefile);


    % write each of the individual files per folder
    for i = 1:n_pts_1
        folder = ['E' num2str(round(range_var1(i)/fac,2))];
        subfile = ['run_' folder '.bat'];
        target = [root folder '\' subfile];
        writefile = fopen(target,'w');
        fprintf(writefile,'%s\n','@echo off');
        fprintf(writefile,'%s\n','cd C:\Program Files\FEBio2.9.1\bin');
        for j = 1:n_pts_2
            to_write = ['FEBio2 -i "' root folder '\' model num2str(round(range_var1(i)/fac,2)) 'e6_' num2str(range_var3(j)) '.feb"'];
            fprintf(writefile,'%s\n',to_write);
        end
        fclose(writefile);
    end
end



