% a script to test a desired method of spatial analysis (SA)

%% VERSION HISTORY
% CREATED 11/9/19 BY SS
% MODIFIED 11/11/19 BY SS
%   - ADDED DEFECT CREATION
% MODIFIED 11/16/19 BY SS
%   - INTEGRATED ALL TEST SCRIPTS HERE

%% DATA LOADING PREPARATION
% scan parameters
to_load = [341];                    % scans to load
s_type = 'prin';                    % principal (prin) vs Green-lagrangian (GL)
dir = 1:3;                            % strain direction (only works on 1 at a time, pick from 1-3 or 1,2,4)
gl_name = ['Exx';'Eyy';'Ezz';'Exy';'Exz';'Eyz';];   % naming for normal strains
clim(1,:) = [0 0.8];
clim(2,:) = [-0.5 0];
clim(3,:) = [0 0.5];
smooth = [10];                      % which smoothing cycle to test (usually do 10 or 15)

%% ANALYSIS PARAMETERS
windows = [2 5 10 15 20 40];                     % window sizes to use
n_scan = size(to_load,2);           % # of scans to load
n_dir = size(dir,2);                % # of strain directions to analyze
n_smooth = size(smooth,2);          % # of smoothing cycles to try
n_win = size(windows,2);            % # of window sizes to use
n_std = 2;                          % # of standard deviations away to consider a defect

%% DEFECT PARAMETERS (DEPRECATED, KIND OF USELESS, BUT DO NOT DELETE)
use_d = 0;                          % to use a defect or not
dloc(1,:) = [124 69];               % pairs of locations to test
%dloc(2,:) = [120 80];
dsize = [10 20 30 40];              % defect sizes
dshape = 'circle';                  % defect shape
dmeth = 'linear';                   % defect method
drange = [0.40 0.60];               % defect range

if use_d
    n_dloc = size(dloc, 1);             % # of locations to use
    n_dsize = size(dsize, 2);           % # of defect sizes to use
else
    n_dloc = 1;
    n_dsize = 1;
end

lpath = 'scans_temp/';  % load path, expects all these scans to have been previously run
spath = 'results_SA/';  % save path

%% METHOD PARAMETERS
%method = 'lacunarity';  % method to test
%method = 'vmratio';     
method = 'moransI';
%method = 'gradient';
%method = 'ripleysK';

edge_corr = 1;                      % correct for edges, or not?

%% PARAMETERS FOR VISUALS
c_loc = 'southoutside';


%% SAFETY
% check all the filenames first, to make sure they check out
to_cancel = 0;
for i = 1:n_scan
    for j = 1:n_smooth
        filename = ['DENSE-' num2str(to_load(i)) '-' num2str(smooth(j)) '.mat'];
        filepath = [lpath filename];
        if ~exist(filepath, 'file')
            disp([filepath ' doesn''t exist.']);
            to_cancel = 1;
        end
    end
end
if to_cancel
    error('Invalid filenames were found, listed above.');
end



%% MAKE DIRECTORIES
for i = 1:n_dsize
    for j = 1:n_dloc
        for k = 1:n_scan
            if use_d
                dfolder = ['defect size ' num2str(dsize(i)) ' - ' num2str(dloc(j,1)) ', ' num2str(dloc(j,2)) '/'];
            else
                dfolder = ['DENSE-' num2str(to_load(k)) '/'];
            end
            %sfolder = ['DENSE-' num2str(to_load(k)) '/'];
            if ~exist([spath dfolder], 'dir')
                mkdir ([spath dfolder])
            end
%             if ~exist([spath dfolder sfolder], 'dir')
%                 mkdir ([spath dfolder sfolder])
%             end
        end
    end
end



%% PERFORM ANALYSIS
% repeat for every...
% i - defect sizse
% j - defect location
% k - scan
% m - smoothing cycles
% n - window size
for i = 1:n_dsize           
    for j = 1:n_dloc
        for k = 1:n_scan
            % name the defect folder
            if use_d
                dfolder = ['defect size ' num2str(dsize(i)) ' - ' num2str(dloc(j,1)) ', ' num2str(dloc(j,2)) '/'];
            else
                dfolder = ['DENSE-' num2str(to_load(k)) '/'];
            end
            
            % clear vars from previous scans in case the image size changes
            strainP = [];
            strain = [];
            strainD = [];
            msk = [];
            dataset = [];
            emsk = [];
            gmsk = [];
            for d = 1:n_dir
                % check that the current direction is valid
                if strcmp(s_type, 'prin')
                    if (dir(d) > 3 || dir(d) <= 0)
                        error('Incorrect strain direction for principal strain: ');
                    end
                elseif strcmp(s_type, 'GL') || strcmp(s_type, 'gl')
                    if (dir(d) > 6 || dir(d) <= 0)
                        error('Incorrect strain direction for green-lagrangian strains');
                    end
                else
                    error('Incorrect strain direction type, please use "prin" or "GL"');
                end
                for m = 1:n_smooth
                    [strainP,msk,strain,~] = DENSELoad(to_load(k),smooth(m));   % grab the strain data
                    
                    % assign and display data 
                    if strcmp(s_type, 'prin')
                        dataset = strainP;
                        dir_name = ['EP' num2str(dir(d))];
                    elseif strcmp(s_type, 'GL') || strcmp(s_type, 'gl')
                        dataset = strain;
                        dir_name = gl_name(dir(d),:);
                    end
                    ftitle = ['DENSE-' num2str(to_load(k)) '-' num2str(smooth(m)) '-' dir_name];
                    figure, imagesc(dataset(:,:,dir(d))), axis equal off, colorbar(c_loc), title(ftitle), caxis(clim(dir(d),:));
                    saveas(gcf, [spath dfolder ftitle], 'png');

                    % create defect, if needed
                    if use_d
                        strainD = SA_Defect(dataset(:,:,dir(d)),msk,dshape,dloc(j,:),dsize(i),dmeth,drange);
                        ftitle = ['DENSE-' num2str(to_load(k)) '-' num2str(smooth(m)) '-EP' num2str(dir(d)) '-Defect Size ' num2str(dsize(i))];
                        figure, imagesc(strainD), axis equal off, colorbar(c_loc), title(ftitle), caxis(clim(dir(d),:));
                        saveas(gcf, [spath dfolder ftitle], 'png');
                    else
                        strainD = dataset(:,:,dir(d));
                    end
                    
                    % load edge correction masks, as needed
                    if edge_corr
                        emsk = double(imread([spath dfolder 'emsk.tif']));
                        gmsk = double(imread([spath dfolder 'gmsk.tif']));
                    end

                    % analyze
                    for n = 1:n_win
                        % use the relevant method, correcting for edges for that method as needed
                        if strcmp(method, 'lacunarity')
                            pointmap = SA_WindowAnalysis(strainD,msk,windows(n));
                            lmap = SA_Lacunarity(pointmap);
                            if edge_corr
                                [lmap, ~] = SA_EdgeHelper(lmap,emsk);
                            end
                        elseif strcmp(method, 'vmratio')
                            pointmap = SA_WindowAnalysis(strainD,msk,windows(n));
                            lmap = SA_VMRatio(pointmap);
                            if edge_corr
                                [lmap, ~] = SA_EdgeHelper(lmap,emsk);
                            end
                        elseif strcmp(method, 'moransI')
                            win = [];   % moran's uses altered window sizes, must be odd
                            if mod(windows(n),2) == 0 && windows(n) > 0
                                windows(n) = windows(n) - 1;
                            end
                            win = ones(windows(n), windows(n));
                            
                            lmap = SA_MoransI(strainD, win, 'true');
                            if edge_corr
                                [lmap, ~] = SA_EdgeHelper(lmap,emsk);
                            end   
                        elseif strcmp(method, 'gradient') 
                            [lmap, ~] = SA_Gradient(strainD,msk);
                            % gradient uses a slightly different edge correction
                        else
                            error([method ' has not been implemented.']);
                        end
                        
                        
                        % display the heuristic
                        ftitle = [dir_name '-' num2str(smooth(m)) ' cycles-' method '-size-' num2str(windows(n)) '-heuristic'];
                        figure, imagesc(lmap), axis equal off, title(ftitle), colorbar(c_loc);
                        saveas(gcf, [spath dfolder ftitle], 'png');

                        % identify the defect points, altering the mask as needed
                        ftitle = [dir_name '-' num2str(smooth(m)) ' cycles-' method '-size-' num2str(windows(n)) '-defects'];
                        if edge_corr
                            if strcmp(method, 'gradient')
                                mask = msk;
                            else
                                mask = emsk;
                            end
                        else
                            mask = msk;
                        end
                        def_pts = SA_Identify(lmap, mask, n_std);
                        
                        
                        % clean up the edge points (GRADIENT ONLY)
                        if strcmp(method, 'gradient')
                            def_pts = SA_GradientHelper(def_pts, gmsk);
                        end
                        
                        % display the original data, and overlay the defect points
                        figure, imagesc(strainD), axis equal off, colorbar(c_loc), title(ftitle), caxis(clim(dir(d),:));
                        hold on
                        if ~isempty(def_pts)
                            plot(def_pts(:,2), def_pts(:,1), 'r+', 'MarkerSize', 10, 'LineWidth', 2);
                        end
                        saveas(gcf, [spath dfolder ftitle], 'png');
                        hold off
                        
                    end
                end
            end
        end
    end
end



