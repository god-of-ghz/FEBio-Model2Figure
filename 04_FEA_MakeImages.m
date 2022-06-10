%% FEA PROCESSING SUITE - STEP 4/4 - GENERATE FIGURES
%   ----------------------------------------------------------------------
%   This program is used to generate figures based on the analysis results.
%   It can crop/zoom in on interesting features, and automatically apply
%   labels to the figures based on the parameters, as well as visualize
%   correlations.

%% VERSION HISTORY
% CREATED 2/17/21 BY SS
% MODIFIED 4/26/20 BY SS
%   - cleaned up code, generalized variable names

%% FIGURE PARAMETER SETUP
% actually generate the figures from the data directly, or just show the figures we've already generated
% useful to turn off if you're tweaking simple things like fonts or colors
to_run = 1;

% figure parameters, for aesthetics
fontname = 'Arial';
% the smallest font, used in minor labels
fontsize1 = 12;
% the default font size, used for most things, including figure title, colorbar, etc
fontsize2 = 16;
% the largest font size, used for large labels
fontsize3 = 24;

% render window sizes- choose based on your monitor and how much data you
% want to display
render1 = [0 40 1300 950];
%render1 = [0 40 2560 950];
render2 = [0 40 900 1200];

% the main figure names, just used for titles
fig_names = {'Interpolated Displacements';...
    'Noisy Displacements';...
    'Smoothed Displacements';...
    'Smoothed Displacements - Stiffness Ratio';...
    'Smoothed Displacements - Adhesion Strength';...
    'Parameter Set 1 - Strains';...
    'Parameter Set 2 - Strains';...
    'Parameter Set 1 - Spatial Analysis';...
    'Parameter Set 2 - Spatial Analysis';...
    'Parts';...
    'ROIs for Analysis';...
    'Correlation Curves';...
    'Example Process on Representative Slice'};

% for displaying/saving images
% figure list
% 1 - interpolated disps
% 2 - noisy disps
% 3 - smoothed disps
% 4 - smoothed disps, all slices, e range
% 5 - smoothed disps, all slices, s range
% 6 - var1-range strains
% 7 - var3-range strains
% 8 - var1-range SA
% 9 - var3-range SA
% 10 - masks, all parts
% 11 - masks, all rois for analysis
% 12 - correlation curves
% 13 - interpolation --> noise --> smoothing process

% make the figure you want to show or save as 1, leave as 0 to turn it off
          %1 2 3 4 5 6 7 8 9 10 11 12 13
to_show = [1 0 0 1 0 1 0 0 0 0  0  0  1];
%to_show = ones(1,13);  % easy comment/uncomment to turn them all on or off
to_save = [0 0 0 0 0 0 0 0 0 0  0  0  0];
%to_save = zeros(1,13);  % easy comment/uncomment to turn them all on or off

% choosing how much data to display
n_disp = 2;         % default is 2, X and Y disps
n_strain = 3;       % default is 3, E1,E2 and max shear strains

% names of the strains
s_name = {'EP1';'EP2';'Max Shear'};

% colormap
red = [255 0 0];
yellow = [255 255 0];
green = [0 255 0];
blue = [0 0 255];
black = [0 0 0];
white = [1 1 1];
nancolor = black;
cmap = [];
cmap(:,:,1) = [nancolor; custom_colormap(green, red, 256)];
cmap(:,:,2) = [nancolor; custom_colormap(blue, green, 256)];
cmap(:,:,3) = [nancolor; custom_colormap(green, red, 256)];

%% MODEL PARAMETER SETUP
if strcmp(model,'simple')
    % shape of the grid layout. 1 = slices, 2 = parameter range
    % first position is the vertical tiling, 2nd is the horizontal;
    % this isn't quiiiite working right, so leave it as [1 2] for now
    g_shape = [1 2];    
    
    rep_var1 = [1 8 13];   % representative slices for parameter set 1 (a range)
    def_var1 = 8;          % the default slice for parameter set 1 (a single value)
    rep_var3 = 1;          % representative slices for the second parameter set 2 (a range)
    def_var3 = 1;          % default slice for parameter set 2 (a single value)
    rep_soi = 1;           % representative slice
    viz_soi = 1;           % which slice to actually *show* on certain figures
    n_soi2 = 1;            % number of slices to actually show
    poi_1 = 10:im_size;    % pixels of interest in the x direction, to help zoom in
    poi_2 = 1:im_size;     % pixels of interest in the y direction, to help zoom in
    
    % the percentage of the points to keep (to make a dotted line)
    line_factor = 1;       % scale of 0 to 1 to the % of all points to keep. 1 = 100%, 0 = no points at all (no dotted line)
    main_roi = 4;          % which ROI you want to highlight
    
    % colors & line shape for the the outlines
    % see https://www.mathworks.com/help/matlab/ref/plot.html#btzitot_sep_mw_3a76f056-2882-44d7-8e73-c695c0c54ca8
    % for color info
    outline_strain(:,1) = {'k.';'w.';'k.'};     
    outline_strain(:,2) = {'k.';'w.';'k.'};
    
    % color limits for strains, displacements, and spatial analysis techniques
    clim_disp = [0 0.5; -1.5 0];
    clim_strain = [0 0.25; -0.50 0.05; 0 0.18];
    clim_SA(1,:,:) = [clim_strain(1,:);0 0.05;2 3;-100 1000;0 0.25;];
    clim_SA(2,:,:) = [clim_strain(2,:);-0.1 0;2 4;-100 1000;0 0.5;];
    clim_SA(3,:,:) = [clim_strain(3,:);0 0.03;2 3;-100 1000;0 0.20;];
    
    % offset values used for labels, x and y
    lab_x_offset = -15;
    lab_y_offset = 0;
    
    % the sub-figure names
    sub_figs = {{'Transverse';'Axial'};...
    {'Transverse';'Axial'};...
    {'Transverse';'Axial'};...
    {'Transverse';'Axial'};...
    {'Transverse';'Axial'};...
    {'EP1';'EP2';'Max Shear'};...
    {'EP1';'EP2';'Max Shear'};...
    {'Strain';'VMR';'Lacunarity';'Moran''s I';'Gradient'};...
    {'Strain';'VMR';'Lacunarity';'Moran''s I';'Gradient'};...
    {''};...
    {'ROI 1';'ROI 2'};
    {'Mean Strain';'VMR';'Lacunarity';'Moran''s I';'Gradient'};...
    {'Interpolated';'Noisy';'Smoothed';}};
elseif strcmp(model,'simple2')
    % shape of the grid layout. 1 = slices, 2 = parameter range
    % first position is the vertical tiling, 2nd is the horizontal;
    g_shape = [1 2];    
    
    rep_var1 = [1 8 13];      % representative slices for material stiffness
    def_var1 = 8;          % the default slice
    rep_var3 = 1;
    def_var3 = 1;      
    rep_soi = 1;
    viz_soi = 1;
    n_soi2 = 1;
    poi_1 = 38:im_size-40;    % pixels of interest, to help zoom in
    poi_2 = 10:im_size-10;
    % the percentage of the points to keep (to make a dotted line)
    line_factor = 1;
    main_roi = 4;
    % colors for the outlines
    outline_strain(:,1) = {'k.';'w.';'k.'};
    outline_strain(:,2) = {'k.';'w.';'k.'};
    
    clim_disp = [-0.5 0.5; -1.0 0];
    clim_strain = [0 0.25; -0.5 0.05; 0 0.18];
    %clim_SA = zeros(n_strain,n_test,2);
    clim_SA(1,:,:) = [clim_strain(1,:);0 0.05;2 3;-100 2000;0 0.25;];
    clim_SA(2,:,:) = [clim_strain(2,:);-0.05 0;2 4;-100 2000;0 0.5;];
    clim_SA(3,:,:) = [clim_strain(3,:);0 0.03;2 3;-100 2000;0 0.20;];
    
    
    lab_x_offset = 3;
    lab_y_offset = 0;
    
    sub_figs = {{'Transverse';'Axial'};...
    {'Transverse';'Axial'};...
    {'Transverse';'Axial'};...
    {'Transverse';'Axial'};...
    {'Transverse';'Axial'};...
    {'EP1';'EP2';'Max Shear'};...
    {'EP1';'EP2';'Max Shear'};...
    {'Strain';'VMR';'Lacunarity';'Moran''s I';'Gradient'};...
    {'Strain';'VMR';'Lacunarity';'Moran''s I';'Gradient'};...
    {''};...
    {'ROI 1';'ROI 2'};
    {'Strain';'VMR';'Lacunarity';'Moran''s I';'Gradient'};...
    {'Interpolated';'Noisy';'Smoothed';}};
elseif strcmp(model,'simple3')
    % shape of the grid layout. 1 = slices, 2 = parameter range
    % first position is the vertical tiling, 2nd is the horizontal;
    g_shape = [1 2];    
    
    rep_var1 = [1 8 13];      % representative slices for material stiffness
    def_var1 = 8;          % the default slice
    rep_var3 = 1;
    def_var3 = 1;      
    rep_soi = 1;
    viz_soi = 1;
    n_soi2 = 1;
    poi_1 = 38:im_size-40;    % pixels of interest, to help zoom in
    poi_2 = 10:im_size-10;
    % the percentage of the points to keep (to make a dotted line)
    line_factor = 1;
    main_roi = 4;
    % colors for the outlines
    outline_strain(:,1) = {'k.';'w.';'k.'};
    outline_strain(:,2) = {'k.';'w.';'k.'};
    
    clim_disp = [-0.5 0.5; -1.5 0];
    clim_strain = [0 0.25; -0.5 0.05; 0 0.18];
    %clim_SA = zeros(n_strain,n_test,2);
    clim_SA(1,:,:) = [clim_strain(1,:);0 0.05;2 3;-100 2000;0 0.25;];
    clim_SA(2,:,:) = [clim_strain(2,:);-0.05 0;2 4;-100 2000;0 0.5;];
    clim_SA(3,:,:) = [clim_strain(3,:);0 0.03;2 3;-100 2000;0 0.20;];
    
    
    lab_x_offset = 3;
    lab_y_offset = 0;
    
    sub_figs = {{'Transverse';'Axial'};...
    {'Transverse';'Axial'};...
    {'Transverse';'Axial'};...
    {'Transverse';'Axial'};...
    {'Transverse';'Axial'};...
    {'EP1';'EP2';'Max Shear'};...
    {'EP1';'EP2';'Max Shear'};...
    {'Strain';'VMR';'Lacunarity';'Moran''s I';'Gradient'};...
    {'Strain';'VMR';'Lacunarity';'Moran''s I';'Gradient'};...
    {''};...
    {'ROI 1';'ROI 2'};
    {'Strain';'VMR';'Lacunarity';'Moran''s I';'Gradient'};...
    {'Interpolated';'Noisy';'Smoothed';}};
elseif contains(model,'defect') && strcmp(plane,'ZYX') && scale == 2.0
    % shape of the grid layout. 1 = slices, 2 = parameter range
    % first position is the vertical tiling, 2nd is the horizontal;
    g_shape = [1 2];    
    
    rep_var1 = [1 8 13];   % representative slices for material stiffness
    def_var1 = 8;          % the default slice
    rep_var3 = [1 8 11];
    def_var3 = 8;
    rep_soi = 5; % middle slice
    viz_soi = 4:6;
    n_soi2 = size(viz_soi,2);
    poi_1 = 150:220;
    poi_2 = 25:220;
    line_factor = 0.33;
    main_roi = 1;
    outline_strain(:,1) = {'k.';'k.';'k.'};
    outline_strain(:,2) = {'k.';'k.';'k.'};
    
    clim_disp = [ -0.25 0.1; -0.08 0.05];
    %clim_strain = [-0.02 0.10; -0.10 -0.02; -0.02 0.04];
    clim_strain = [-0.1 0.1; -0.1 0.1; -0.05 0.05];
    clim_SA(1,:,:) = [clim_strain(1,:);0 0.05;3 4;-5e3 2e4;0-0.01 0.15;];
    clim_SA(2,:,:) = [clim_strain(2,:);-0.03 0.01;3 4;-5e3 2e4;-0.01 0.15;];
    clim_SA(3,:,:) = [clim_strain(3,:);-0.005 0.025;3 4;1e3 2e4;0 0.08;];
    
    lab_x_offset = 15;
    lab_y_offset = 0;
    
    sub_figs = {{'Axial';'Transverse'};...
    {'Axial';'Transverse'};...
    {'Axial';'Transverse'};...
    {'Axial';'Transverse'};...
    {'Axial';'Transverse'};...
    {'EP1';'EP2';'Max Shear'};...
    {'EP1';'EP2';'Max Shear'};...
    {'Strain Map';'VMR';'Lacunarity';'Moran''s I';'Gradient'};...
    {'Strain Map';'VMR';'Lacunarity';'Moran''s I';'Gradient'};...
    {'Single Mask'};...
    {'ROI 1';'ROI 2'};
    {'Mean Strain';'VMR';'Lacunarity';'Moran''s I';'Gradient'};...
    {'Interpolated';'Noisy';'Smoothed';}};
else
    disp('??????');
    return;
end

% if we're re-running, clear the figures and stuff
if to_run
    %close all;
    fig = {};
end

n_rep_var1 = size(rep_var1,2);
n_rep_var3 = size(rep_var3,2);


%% ALTER TILING PATTERN
% somewhat broken, don't use
if ~exist('g_shape','var')
    g_shape = [1 2];
end
shape_vars = {'n_soi', 'n_rep_var1';'n_soi', 'n_rep_var3'};
grid_shape = zeros(2,2);
for gs1 = 1:2
    for gs2 = 1:2
        command = ['grid_shape(gs1,gs2) = ' shape_vars{gs1,g_shape(gs2)} ';'];
        eval(command);
    end
end

%% PIXELS OF INTEREST
size_poi_1 = size(poi_1,2);
size_poi_2 = size(poi_2,2);

%% FIGURE LABELS
def_var1_label = {};
def_var3_label = {};
rep_var1_label = {};
rep_var3_label = {};

def_var1_label = {'100%'};
def_var3_label = {'100%'};
for label = 1:n_rep_var1
    rep_var1_label{label} = [num2str(100*range_var1(rep_var1(label))/range_var1(def_var1)) '%';];
end
for label = 1:n_rep_var3
    rep_var3_label{label} = [num2str(range_var3(rep_var3(label))) ' MPa'];
end
if use_intact
    def_var1_label{end+1} = 'Intact';
    def_var3_label{end+1} = 'Intact';
    rep_var1_label{end+1} = 'Intact';
    rep_var3_label{end+1} = 'Intact';
end

%% SET UP DIRECTORIES
savepath = [cache_path model ' - ' plane '\'];
if ~exist(savepath,'dir')
    mkdir (savepath);
end

%% CREATE TILED IMAGES
if to_run
    %% INTERPOLATED DISPLACMENTS
    disp(['Tiling: ' fig_names{1} '...'])
    temp_disp = [];
    temp_msk = [];
    for d = 1:n_disp
        temp_msk = sum(msk(poi_1,poi_2,rep_soi,:,def_var1,def_var3),4);
        temp_disp = disps(poi_1,poi_2,soi(rep_soi),dir(d),def_var1,def_var3);
        temp_disp = FillNaN(temp_disp,temp_msk);
        if use_intact
            tile1 = imtile(permute(temp_disp,[1 2 4 3 5 6]));
            temp_i_msk = sum(i_msk(poi_1,poi_2,rep_soi,:),4);
            temp_i_disp = i_disp(poi_1,poi_2,soi(rep_soi),dir(d));
            temp_i_disp = FillNaN(temp_i_disp,temp_i_msk);
            tile2 = imtile(permute(temp_i_disp,[1 2 4 3 5 6]));
            fig{1}(:,:,d) = [tile1 tile2];
            
            tile1 = [];
            tile2 = [];
            temp_i_msk = [];
            temp_i_disp = [];
        else
            fig{1}(:,:,d) = imtile(permute(temp_disp,[1 2 4 3 5 6]));
        end
    end

    %% NOISY DISPLACEMENTS
    disp(['Tiling: ' fig_names{2} '...'])
    temp_disp = [];
    temp_msk = [];
    for d = 1:n_disp
        temp_msk = sum(msk(poi_1,poi_2,rep_soi,:,def_var1,def_var3),4);
        temp_disp = disps(poi_1,poi_2,soi(rep_soi),dir(d),def_var1,def_var3);
        temp_disp = awgn2(temp_disp,noise,noise_type);
        temp_disp = FillNaN(temp_disp,temp_msk);
        if use_intact
            tile1 = imtile(permute(temp_disp,[1 2 4 3 5 6]));
            temp_i_msk = sum(i_msk(poi_1,poi_2,rep_soi,:),4);
            temp_i_disp = i_disp(poi_1,poi_2,soi(rep_soi),dir(d));
            temp_i_disp = awgn2(temp_i_disp,noise,noise_type);
            temp_i_disp = FillNaN(temp_i_disp,temp_i_msk);
            tile2 = imtile(permute(temp_i_disp,[1 2 4 3 5 6]));
            fig{2}(:,:,d) = [tile1 tile2];
            
            tile1 = [];
            tile2 = [];
            temp_i_msk = [];
            temp_i_disp = [];
        else
            fig{2}(:,:,d) = imtile(permute(temp_disp,[1 2 4 3 5 6]));
        end
    end

    %% SMOOTHED DISPLACEMENTS
    % representative slice only
    disp(['Tiling: ' fig_names{3} '...'])
    temp_msk = [];
    temp_disp = [];
    temp_disp2 = [];
    for d = 1:n_disp
        for p = 1:n_roi
            temp_msk = msk_roi(:,:,rep_soi,p,def_var1,def_var3);
            temp_disp(:,:,p) = disps(:,:,soi(rep_soi),dir(d),def_var1,def_var3);
            temp_disp(:,:,p) = awgn2(temp_disp(:,:,p),noise,noise_type);
            for s = 1:smoothing
                temp_disp(:,:,p) = ROIfilter([],temp_disp(:,:,p),temp_msk);
            end
        end
        temp_msk2 = sum(msk_roi(poi_1,poi_2,rep_soi,:,def_var1,def_var3),4);
        temp_disp2 = sum(temp_disp(poi_1,poi_2,:),3);
        temp_disp2 = FillNaN(temp_disp2,temp_msk2);
        if use_intact
            for p = 1:n_roi
                temp_i_msk = i_msk(:,:,rep_soi,p);
                temp_i_disp(:,:,p) = i_disp(:,:,soi(rep_soi),dir(d));
                temp_i_disp(:,:,p) = awgn2(temp_i_disp(:,:,p),noise,noise_type);
                for s = 1:smoothing
                    temp_i_disp(:,:,p) = ROIfilter([],temp_i_disp(:,:,p),temp_i_msk);
                end
            end
            temp_i_msk2 = sum(i_msk(poi_1,poi_2,rep_soi,:),4);
            temp_i_disp2 = sum(temp_i_disp(poi_1,poi_2,:),3);
            temp_i_disp2 = FillNaN(temp_i_disp2,temp_i_msk2);
            
            tile1 = imtile(permute(temp_disp2,[1 2 4 3 5 6]));
            tile2 = imtile(permute(temp_i_disp2,[1 2 4 3 5 6]));
            fig{3}(:,:,d) = [tile1 tile2];
            
            tile1 = [];
            tile2 = [];
            temp_i_msk = [];
            temp_i_disp = [];
            temp_i_msk2 = [];
            temp_i_disp2 = [];
        else
            fig{3}(:,:,d) = imtile(permute(temp_disp2,[1 2 4 3 5 6]));
        end
    end

    % all slices, E-range
    disp(['Tiling: ' fig_names{4} '...'])
    temp_disp = [];
    temp_msk = [];
    for d = 1:n_disp
        temp_disp2 = [];
        for var1 = 1:n_rep_var1
            for p = 1:n_roi
                temp_msk(:,:,:,p) = msk_roi(:,:,:,p,rep_var1(var1),def_var3);
                temp_disp(:,:,:,p) = disps(:,:,soi,dir(d),rep_var1(var1),def_var3);
                temp_disp(:,:,:,p) = awgn2(temp_disp(:,:,:,p),noise,noise_type);
                for n = 1:n_soi
                    for s = 1:smoothing
                        temp_disp(:,:,n,p) = ROIfilter([],temp_disp(:,:,n,p),temp_msk(:,:,n,p));
                    end
                end
            end
            temp_msk2 = sum(msk_roi(poi_1,poi_2,:,:,rep_var1(var1),def_var3),4);
            temp_disp2(:,:,:,var1) = sum(temp_disp(poi_1,poi_2,:,:),4);
            temp_disp2(:,:,:,var1) = FillNaN(temp_disp2(:,:,:,var1),temp_msk2);
        end
        temp_disp2 = permute(temp_disp2,[1 2 5 4 3]);
        if use_intact
            for p = 1:n_roi
                temp_i_msk(:,:,:,p) = i_msk(:,:,:,p);
                temp_i_disp(:,:,:,p) = i_disp(:,:,soi,dir(d));
                temp_i_disp(:,:,:,p) = awgn2(temp_i_disp(:,:,:,p),noise,noise_type);
                for n = 1:n_soi
                    for s = 1:smoothing
                        temp_i_disp(:,:,n,p) = ROIfilter([],temp_i_disp(:,:,n,p),temp_i_msk(:,:,n,p));
                    end
                end
            end
            temp_i_msk2 = sum(i_msk(poi_1,poi_2,:,:),4);
            temp_i_disp2 = sum(temp_i_disp(poi_1,poi_2,:,:),4);
            temp_i_disp2 = FillNaN(temp_i_disp2,temp_i_msk2);
            
            tile1 = imtile(reshape(temp_disp2,[size_poi_1,size_poi_2,1,n_soi*n_rep_var1]),'GridSize',grid_shape(1,:));
            tile2 = imtile(permute(temp_i_disp2,[1 2 4 3]),'GridSize',[n_soi 1]);
            
            fig{4}(:,:,d) = [tile1 tile2];
            
            tile1 = [];
            tile2 = [];
            temp_i_msk = [];
            temp_i_disp = [];
            temp_i_msk2 = [];
            temp_i_disp2 = [];
        else
            fig{4}(:,:,d) = imtile(reshape(temp_disp2,[size_poi_1,size_poi_2,1,n_soi*n_rep_var1]),'GridSize',grid_shape(1,:));
        end
    end

    % all slices, s-range
    disp(['Tiling: ' fig_names{5} '...'])
    temp_disp = [];
    temp_msk = [];
    for d = 1:n_disp
        temp_disp2 = [];
        for var3 = 1:n_rep_var3
            for p = 1:n_roi
                temp_msk(:,:,:,p) = msk_roi(:,:,:,p,def_var1,rep_var3(var3));
                temp_disp(:,:,:,p) = disps(:,:,soi,dir(d),def_var1,rep_var3(var3));
                temp_disp(:,:,:,p) = awgn2(temp_disp(:,:,:,p),noise,noise_type);
                for n = 1:n_soi
                    for s = 1:smoothing
                        temp_disp(:,:,n,p) = ROIfilter([],temp_disp(:,:,n,p),temp_msk(:,:,n,p));
                    end
                end
            end
            temp_msk2 = sum(msk_roi(poi_1,poi_2,:,:,def_var1,rep_var3(var3)),4);
            temp_disp2(:,:,:,var3) = sum(temp_disp(poi_1,poi_2,:,:),4);
            temp_disp2(:,:,:,var3) = FillNaN(temp_disp2(:,:,:,var3),temp_msk2);
        end
        temp_disp2 = permute(temp_disp2,[1 2 5 4 3]);
        if use_intact
            for p = 1:n_roi
                temp_i_msk(:,:,:,p) = i_msk(:,:,:,p);
                temp_i_disp(:,:,:,p) = i_disp(:,:,soi,dir(d));
                temp_i_disp(:,:,:,p) = awgn2(temp_i_disp(:,:,:,p),noise,noise_type);
                for n = 1:n_soi
                    for s = 1:smoothing
                        temp_i_disp(:,:,n,p) = ROIfilter([],temp_i_disp(:,:,n,p),temp_i_msk(:,:,n,p));
                    end
                end
            end
            temp_i_msk2 = sum(i_msk(poi_1,poi_2,:,:),4);
            temp_i_disp2 = sum(temp_i_disp(poi_1,poi_2,:,:),4);
            temp_i_disp2 = FillNaN(temp_i_disp2,temp_i_msk2);
            
            tile1 = imtile(reshape(temp_disp2,[size_poi_1,size_poi_2,1,n_soi*n_rep_var3]),'GridSize',grid_shape(2,:));
            tile2 = imtile(permute(temp_i_disp2,[1 2 4 3]),'GridSize',[n_soi 1]);
            
            fig{5}(:,:,d) = [tile1 tile2];
            
            tile1 = [];
            tile2 = [];
            temp_i_msk = [];
            temp_i_disp = [];
            temp_i_msk2 = [];
            temp_i_disp2 = [];
        else
            fig{5}(:,:,d) = imtile(reshape(temp_disp2,[size_poi_1,size_poi_2,1,n_soi*n_rep_var3]),'GridSize',grid_shape(2,:));
        end
        %figure, imshow(fig{5}(:,:,d)), colormap('jet'), caxis('auto'), colorbar
    end

    disp(['Tiling: ' fig_names{13} '...'])
    for d = 1:n_disp
        fig{13}(:,:,d) = [fig{1}(:,:,d); fig{2}(:,:,d); fig{3}(:,:,d);];
    end
    
    %% PRINCIPAL & MAXIMUM SHEAR STRAINS
    % var1 range
    disp(['Tiling: ' fig_names{6} '...'])
    temp_strain = [];
    temp_msk = sum(msk(poi_1,poi_2,viz_soi,:,rep_var1,def_var3),4);
    for s = 1:n_strain
        temp_strain = strainP_noise(poi_1,poi_2,s,viz_soi,rep_var1,def_var3);
        temp_strain = FillNaN(temp_strain,temp_msk);
        temp_strain = permute(temp_strain,[1 2 3 5 4 6]);
        if use_intact
            temp_i_msk = sum(i_msk(poi_1,poi_2,viz_soi,:),4);
            temp_i_strain = i_strainP_noise(poi_1,poi_2,s,viz_soi);
            temp_i_strain = FillNaN(temp_i_strain,temp_i_msk);
            
            tile1 = imtile(reshape(temp_strain,[size_poi_1,size_poi_2,1,n_soi2*n_rep_var1]),'GridSize',[n_soi2 n_rep_var1]);
            tile2 = imtile(temp_i_strain,'GridSize',[n_soi2 1]);
            
            fig{6}(:,:,s) = [tile1 tile2];
            
            tile1 = [];
            tile2 = [];
            temp_i_msk = [];
            temp_i_strain = [];
        else
            fig{6}(:,:,s) = imtile(reshape(temp_strain,[size_poi_1,size_poi_2,1,n_soi2*n_rep_var1]),'GridSize',[n_soi2 n_rep_var1]);
        end
    end

    % s range
    disp(['Tiling: ' fig_names{7} '...'])
    temp_strain = [];
    temp_msk = sum(msk(poi_1,poi_2,viz_soi,:,def_var1,rep_var3),4);
    for s = 1:n_strain
        temp_strain = strainP_noise(poi_1,poi_2,s,viz_soi,def_var1,rep_var3);
        temp_strain = FillNaN(temp_strain,temp_msk);
        temp_strain = permute(temp_strain,[1 2 3 6 4 5]);
        if use_intact
            temp_i_msk = sum(i_msk(poi_1,poi_2,viz_soi,:),4);
            temp_i_strain = i_strainP_noise(poi_1,poi_2,s,viz_soi);
            temp_i_strain = FillNaN(temp_i_strain,temp_i_msk);
            
            tile1 = imtile(reshape(temp_strain,[size_poi_1,size_poi_2,1,n_soi2*n_rep_var3]),'GridSize',[n_soi2 n_rep_var3]);
            tile2 = imtile(temp_i_strain,'GridSize',[n_soi2 1]);
            
            fig{7}(:,:,s) = [tile1 tile2];
            
            tile1 = [];
            tile2 = [];
            temp_i_msk = [];
            temp_i_strain = [];
        else
            fig{7}(:,:,s) = imtile(reshape(temp_strain,[size_poi_1,size_poi_2,1,n_soi2*n_rep_var3]),'GridSize',[n_soi2 n_rep_var3]);
        end
    end

    %% SPATIAL ANALYSIS
    % var1 range
    disp(['Tiling: ' fig_names{8} '...'])
    temp_SA = [];
    for s = 1:n_strain
        for t = 1:n_test
            temp_msk = sum(msk(poi_1,poi_2,:,:,rep_var1,def_var3),4);
            if t == 3   % special case for lacunarity since its a bitch
                temp_SA = log10(strainSA_noise(poi_1,poi_2,s,:,t,rep_var1,def_var3));
            elseif t == 5 % special case for gradient to remove edges of the map
                [temp_SA,temp_msk] = SA_GradientHelper2(strainSA_noise(poi_1,poi_2,s,:,t,rep_var1,def_var3),temp_msk,3,'Method','slow');
            else
                temp_SA = strainSA_noise(poi_1,poi_2,s,:,t,rep_var1,def_var3);
            end
            temp_SA = permute(temp_SA,[1 2 3 4 6 7 5]);
            temp_SA = FillNaN(temp_SA, temp_msk);
            temp_SA = permute(temp_SA,[1 2 3 5 4 6 7]);
            if use_intact
                temp_i_msk = sum(i_msk(poi_1,poi_2,:,:),4);
                if t == 3 % special case for lacunarity since its a bitch
                    temp_i_SA = log10(i_strainSA_noise(poi_1,poi_2,s,:,t));
                elseif t == 5 % special case for gradient to remove edges of the map
                    temp_i_SA = SA_GradientHelper2(i_strainSA_noise(poi_1,poi_2,s,:,t),temp_i_msk,3,'Method','slow');
                else
                    temp_i_SA = i_strainSA_noise(poi_1,poi_2,s,:,t);
                end
                
                temp_i_SA = permute(temp_i_SA,[1 2 4 3]);
                temp_i_SA = FillNaN(temp_i_SA,temp_i_msk);
                
                tile1 = imtile(reshape(temp_SA,[size_poi_1,size_poi_2,1,n_soi*n_rep_var1]),'GridSize',grid_shape(1,:));
                tile2 = imtile(permute(temp_i_SA,[1 2 4 3]),'GridSize',[n_soi 1]);
                
                fig{8}(:,:,s,t) = [tile1 tile2];
                
                tile1 = [];
                tile2 = [];
                temp_i_msk = [];
                temp_i_SA = [];
            else
                fig{8}(:,:,s,t) = imtile(reshape(temp_SA,[size_poi_1,size_poi_2,1,n_soi*n_rep_var1]),'GridSize',grid_shape(1,:));
            end
            %figure, imshow(fig{6}(:,:,s,t)), colormap('jet'), caxis('auto'), colorbar, title([sub_figs{5}{s} ' - ' sub_figs{6}{t}])
        end
    end

    % s range
    disp(['Tiling: ' fig_names{9} '...'])
    temp_SA = [];
    for s = 1:n_strain
        for t = 1:n_test
            temp_msk = sum(msk(poi_1,poi_2,:,:,def_var1,rep_var3),4);
            if t == 3   % special case for lacunarity since its a bitch
                temp_SA = log10(strainSA_noise(poi_1,poi_2,s,:,t,def_var1,rep_var3));
            elseif t == 5   % special case for gradient to remove the edges
                [temp_SA,temp_msk] = SA_GradientHelper2(strainSA_noise(poi_1,poi_2,s,:,t,def_var1,rep_var3),temp_msk,3,'Method','slow');
            else
                temp_SA = strainSA_noise(poi_1,poi_2,s,:,t,def_var1,rep_var3);
            end
            temp_SA = permute(temp_SA,[1 2 3 4 6 7 5]);
            temp_SA = FillNaN(temp_SA, temp_msk);
            temp_SA = permute(temp_SA,[1 2 3 6 4 5 7]);
            if use_intact
                temp_i_msk = sum(i_msk(poi_1,poi_2,:,:),4);
                if t == 3
                    temp_i_SA = log10(i_strainSA_noise(poi_1,poi_2,s,:,t));
                elseif t == 5
                    temp_i_SA = SA_GradientHelper2(i_strainSA_noise(poi_1,poi_2,s,:,t),temp_i_msk,3,'Method','slow');
                else
                    temp_i_SA = i_strainSA_noise(poi_1,poi_2,s,:,t);
                end
                
                temp_i_SA = permute(temp_i_SA,[1 2 4 3]);
                temp_i_SA = FillNaN(temp_i_SA,temp_i_msk);
                
                tile1 = imtile(reshape(temp_SA,[size_poi_1,size_poi_2,1,n_soi*n_rep_var3]),'GridSize',grid_shape(2,:));
                tile2 = imtile(permute(temp_i_SA,[1 2 4 3]),'GridSize',[n_soi 1]);
                
                fig{9}(:,:,s,t) = [tile1 tile2];
                
                tile1 = [];
                tile2 = [];
                temp_i_msk = [];
                temp_i_SA = [];
            else
                fig{9}(:,:,s,t) = imtile(reshape(temp_SA,[size_poi_1,size_poi_2,1,n_soi*n_rep_var3]),'GridSize',grid_shape(2,:));
            end
            %figure, imshow(fig{7}(:,:,s,t)), colormap('jet'), caxis('auto'), colorbar, title([sub_figs{5}{s} ' - ' sub_figs{6}{t}])
        end
    end

    %% MASKS FOR SLICING
    disp(['Tiling: ' fig_names{10} '...'])
    if use_intact
        tile1 = imtile(permute(sum(msk(poi_1,poi_2,:,:,def_var1,def_var3),4)+msk(poi_1,poi_2,:,1,def_var1,def_var3)*2+msk(poi_1,poi_2,:,2,def_var1,def_var3),[1 2 4 3 5 6]),'GridSize',[n_soi 1]);
        tile2 = imtile(permute(sum(i_msk(poi_1,poi_2,:,:),4)+i_msk(poi_1,poi_2,:,1),[1 2 4 3]),'GridSize',[n_soi 1]);
        tile3 = imtile(permute(sum(i_msk(poi_1,poi_2,:,:),4)+i_msk(poi_1,poi_2,:,1)+msk(poi_1,poi_2,:,1,def_var1,def_var3),[1 2 4 3]),'GridSize',[n_soi 1]);

        
        fig{10} = [tile1 tile2 tile3];
        
        tile1 = [];
        tile2 = [];
    else
        sum_msk = zeros(size_poi_1,size_poi_2,n_soi);
        for r = 1:n_roi
            sum_msk = sum_msk + msk_roi(poi_1,poi_2,:,r,def_var1,def_var3)*r;
        end
        sum_msk = sum_msk + msk(poi_1,poi_2,:,main_roi,def_var1,def_var3)*(n_roi);
        fig{10} = imtile(permute(sum_msk,[1 2 4 3]),'GridSize',[n_soi 1]);
    end
    
    if use_intact
        fig{11} = sum(msk(poi_1,poi_2,rep_soi,:,def_var1,def_var3),4)+msk(poi_1,poi_2,rep_soi,main_roi,def_var1,def_var3)*2+msk(poi_1,poi_2,rep_soi,2,def_var1,def_var3);
    else
        fig{11}(:,:,1) = imtile(permute(sum(msk(poi_1,poi_2,:,:,def_var1,def_var3),4)+test_msk(poi_1,poi_2,:,def_var1,def_var3),[1 2 4 3 5 6]),'GridSize',[n_soi 1]);
        if exist('test_msk2','var')
            fig{11}(:,:,2) = imtile(permute(sum(msk(poi_1,poi_2,:,:,def_var1,def_var3),4)+test_msk2(poi_1,poi_2,:,def_var1,def_var3),[1 2 4 3 5 6]),'GridSize',[n_soi 1]);
        end
    end

    %% MASK OVERLAYS FOR ANALYSIS
    disp(['Tiling: ' fig_names{11} '...'])
    temp_msk = [];
    if exist('test_msk2','var')
        temp_msk2 = [];
        n_msk2 = 2;
    else
        n_msk2 = 1;
    end
    % var1 range
    if use_intact
        n_var1_msk = n_rep_var1+1;
    else
        n_var1_msk = n_rep_var1;
    end
    
    var1_msk = cell(n_soi,n_var1_msk,n_msk2);

    for n = 1:n_soi
        for var1 = 1:n_var1_msk
            if var1 > n_rep_var1
                var1_ind = find(rep_var1 == def_var1);
            else
                var1_ind = var1;
            end
            temp_msk = test_msk(poi_1,poi_2,n,rep_var1(var1_ind),def_var3);
            temp_msk = edge(temp_msk,'roberts');
            [x, y] = ind2sub([size_poi_1 size_poi_2],find(temp_msk == 1));
            var1_msk{n,var1,1} = [x y];      % list of points you can overlay on the image to indicate the border
            if exist('test_msk2','var')
                temp_msk2 = test_msk2(poi_1,poi_2,n,rep_var1(var1_ind),def_var3);
                temp_msk2 = edge(temp_msk2,'roberts');
                [x, y] = ind2sub([size_poi_1 size_poi_2],find(temp_msk2 == 1));
                var1_msk{n,var1,2} = [x y];
            end
        end
    end

    
    % s range
    temp_msk = [];
    if exist('test_msk2','var')
        temp_msk2 = [];
        n_msk2 = 2;
    else
        n_var3_msk = 1;
    end
    
    if use_intact
        n_var3_msk = n_rep_var3+1;
    else
        n_var3_msk = n_rep_var3;
    end

    var3_msk = cell(n_soi,n_var3_msk,n_msk2);
    for n = 1:n_soi
        for s = 1:n_var3_msk
            if s > n_rep_var3
                var3_ind = find(rep_var3 == def_var3);
            else
                var3_ind = s;
            end
            temp_msk = test_msk(poi_1,poi_2,n,def_var1,rep_var3(var3_ind));
            temp_msk = edge(temp_msk,'roberts');
            [x, y] = ind2sub([size_poi_1 size_poi_2],find(temp_msk == 1));
            var3_msk{n,s,1} = [x y];
            if exist('test_msk2','var')
                temp_msk2 = test_msk2(poi_1,poi_2,n,def_var1,rep_var3(var3_ind));
                temp_msk2 = edge(temp_msk2,'roberts');
                [x, y] = ind2sub([size_poi_1 size_poi_2],find(temp_msk2 == 1));
                var3_msk{n,s,2} = [x y];
            end
        end
    end
end


%% GENERATE IMAGES

%% 1 - interpolated disps
fig_no = 1;
if to_show(fig_no)
    for d = 1:n_disp
        ftitle = [fig_names{fig_no} ' - ' sub_figs{fig_no}{d}];
        %cb = colorbar;
        %set(cb,'YTick',[clim_disp(d,1):clim_disp()]);
        figure, imshow(fig{fig_no}(:,:,d)), colormap('jet'), caxis(clim_disp(d,:)), colorbar, title(ftitle), hold on;
        set(gcf,'Renderer','painters','Position',render1)
        set(gca, 'FontName', fontname,'FontSize',fontsize2);
        set(gcf, 'InvertHardCopy', 'off')
        if to_save(fig_no); saveas(gcf,[savepath ftitle],'svg'); end
        if to_save(fig_no); saveas(gcf,[savepath ftitle],'png'); end
    end
end

%% 2 - noisy disps
fig_no = 2;
if to_show(fig_no)
    for d = 1:n_disp
        ftitle = [fig_names{fig_no} ' - ' sub_figs{fig_no}{d}];
        figure, imshow(fig{fig_no}(:,:,d)), colormap('jet'), caxis(clim_disp(d,:)), colorbar, title(ftitle), hold on;
        set(gcf,'Renderer','painters','Position',render1)
        set(gca, 'FontName', fontname,'FontSize',fontsize2);
        set(gcf, 'InvertHardCopy', 'off')
        if to_save(fig_no); saveas(gcf,[savepath ftitle],'svg'); end
        if to_save(fig_no); saveas(gcf,[savepath ftitle],'png'); end
    end
end

%% 3-5 - smoothed disps
if to_show(fig_no)
    fig_no = 3;
    for d = 1:n_disp
        ftitle = [fig_names{fig_no} ' - ' sub_figs{fig_no}{d}];
        figure, imshow(fig{fig_no}(:,:,d)), colormap('jet'), caxis(clim_disp(d,:)), colorbar, title(ftitle), hold on;
        set(gcf,'Renderer','painters','Position',render1)
        set(gca, 'FontName', fontname,'FontSize',fontsize2);
        set(gcf, 'InvertHardCopy', 'off')
        if to_save(fig_no); saveas(gcf,[savepath ftitle],'svg'); end
        if to_save(fig_no); saveas(gcf,[savepath ftitle],'png'); end
    end
end

fig_no = 4;
if to_show(fig_no)
    for d = 1:n_disp
        ftitle = [fig_names{fig_no} ' - ' sub_figs{fig_no}{d}];
        figure, imshow(fig{fig_no}(:,:,d)), colormap('jet'), caxis(clim_disp(d,:)), colorbar, title(ftitle), hold on;
        % overlay the labels
        for label = 1:size(rep_var1_label,2)
            x_ind = (size_poi_2/2) + size_poi_2*(label-1) + lab_x_offset;
            y_ind = size_poi_1*0.10;
            to_write = rep_var1_label{label};
            text(x_ind,y_ind,to_write,'Color','white','HorizontalAlignment','center','FontWeight','bold','FontSize',fontsize3);
        end
        % overlay the slice numbers
        if n_soi > 1
            text(-15,-15,'Slices','Color','black','HorizontalAlignment','center','FontWeight','bold','FontSize',fontsize3);
            for label = 1:n_soi
                x_ind = -15;
                y_ind = (size_poi_1*0.50)+size_poi_1*(label-1);
                to_write = num2str(label);
                text(x_ind,y_ind,to_write,'Color','black','HorizontalAlignment','center','FontWeight','bold','FontSize',fontsize3);
            end
        end
        % overlay the mask edges
        for n = 1:n_soi
            for var1 = 1:n_var1_msk
                for m = size(var1_msk,3):-1:1
                    % grab the points making up the outline of the mask
                    x = var1_msk{n,var1,m}(:,2);
                    y = var1_msk{n,var1,m}(:,1);

                    n_pts = size(x,1);
                    % reduce the number of points
                    % if we want to keep most of the points, remove a small number
                    if line_factor >= 0.50
                        remove = 1:round(1/(1-line_factor)):n_pts;
                        x(remove) = [];
                        y(remove) = [];
                    else % if we want to remove most, only keep a small number
                        keep = 1:round(1/line_factor):n_pts;
                        x = x(keep);
                        y = y(keep);
                    end

                    % shift for the tiling
                    var1_shift = size_poi_2*(var1-1);
                    slice_shift = size_poi_1*(n-1);
                    % plot on the image
                    scatter(x+var1_shift,y+slice_shift,'k.');
                end
            end
        end
        set(gcf,'Renderer','painters','Position',render1)
        set(gca, 'FontName', fontname,'FontSize',fontsize2);
        set(gcf, 'InvertHardCopy', 'off')
        if to_save(fig_no); saveas(gcf,[savepath ftitle],'svg'); end
        if to_save(fig_no); saveas(gcf,[savepath ftitle],'png'); end
    end
end

fig_no = 5;
if to_show(fig_no)
    for d = 1:n_disp
        ftitle = [fig_names{fig_no} ' - ' sub_figs{fig_no}{d}];
        figure, imshow(fig{fig_no}(:,:,d)), colormap('jet'), caxis(clim_disp(d,:)), colorbar, title(ftitle), hold on;
        % overlay labels
        for label = 1:size(rep_var3_label,2)
            x_ind = (size_poi_2/2) + size_poi_2*(label-1) + lab_x_offset;
            y_ind = size_poi_1*0.10;
            to_write = rep_var3_label{label};
            text(x_ind,y_ind,to_write,'Color','white','HorizontalAlignment','center','FontWeight','bold','FontSize',fontsize3);
        end
        % overlay the slice numbers
        if n_soi > 1
            %text(-15,-15,'Slices','Color','black','HorizontalAlignment','center','FontWeight','bold','FontSize',fontsize2);
            for label = 1:n_soi
                x_ind = -15;
                y_ind = (size_poi_1*0.50)+size_poi_1*(label-1);
                to_write = num2str(label);
                text(x_ind,y_ind,to_write,'Color','black','HorizontalAlignment','center','FontWeight','bold','FontSize',fontsize3);
            end
        end
        % overlay the mask edges
        for n = 1:n_soi
            for var3 = 1:n_var3_msk
                for m = size(var3_msk,3):-1:1
                    % grab the points making up the outline of the mask
                    x = var3_msk{n,var3,m}(:,2);
                    y = var3_msk{n,var3,m}(:,1);

                    n_pts = size(x,1);
                    % reduce the number of points
                    % if we want to keep most of the points, remove a small number
                    if line_factor >= 0.50
                        remove = 1:round(1/(1-line_factor)):n_pts;
                        x(remove) = [];
                        y(remove) = [];
                    else % if we want to remove most, only keep a small number
                        keep = 1:round(1/line_factor):n_pts;
                        x = x(keep);
                        y = y(keep);
                    end

                    % shift for the tiling
                    s_shift = size_poi_2*(var3-1);
                    slice_shift = size_poi_1*(n-1);
                    % plot on the image
                    scatter(x+s_shift,y+slice_shift,'k.');
                end
            end
        end
        set(gcf,'Renderer','painters','Position',render1)
        set(gca, 'FontName', fontname,'FontSize',fontsize2);
        set(gcf, 'InvertHardCopy', 'off')
        if to_save(fig_no); saveas(gcf,[savepath ftitle],'svg'); end
        if to_save(fig_no); saveas(gcf,[savepath ftitle],'png'); end
    end
end

fig_no = 13;
if to_show(fig_no)
    for d = 1:n_disp
        ftitle = [fig_names{fig_no} ' - ' sub_figs{1}{d}];
        figure, imshow(fig{fig_no}(:,:,d)), colormap('jet'), caxis(clim_disp(d,:)), colorbar, title(ftitle), hold on;
        % overlay labels
        for label = 1:size(def_var1_label,2)
            x_ind = (size_poi_2/2) + size_poi_2*(label-1) + lab_x_offset;
            y_ind = size_poi_1*0.10;
            to_write = [def_var1_label{label} ' Model'];
            text(x_ind,y_ind,to_write,'Color','white','HorizontalAlignment','center','FontWeight','bold','FontSize',fontsize2);
        end
        for label = 1:3
            if use_intact
                x_ind = size_poi_2*0.85 + lab_x_offset;
            else
                x_ind = size_poi_2/2 + lab_x_offset;
            end
            y_ind = round((size_poi_1*0.18))+size_poi_1*(label-1);
            text(x_ind,y_ind,sub_figs{fig_no}{label},'Color','white','HorizontalAlignment','center','FontWeight','bold','FontSize',fontsize1);
        end
        set(gcf,'Renderer','painters','Position',render1)
        set(gca, 'FontName', fontname,'FontSize',fontsize2);
        set(gcf, 'InvertHardCopy', 'off');
        if to_save(fig_no); saveas(gcf,[savepath ftitle],'svg'); end
        if to_save(fig_no); saveas(gcf,[savepath ftitle],'png'); end
    end
end

%% 6 - var1 STRAINS
fig_no = 6;
if to_show(fig_no)
    for s = 1:n_strain
        ftitle = [fig_names{fig_no} ' - ' sub_figs{fig_no}{s}];
        figure, imshow(fig{fig_no}(:,:,s)), colormap(cmap(:,:,s)), caxis(clim_strain(s,:)), colorbar, title(ftitle), hold on;
        set(gcf,'Renderer','painters','Position',render1)
        set(gca, 'FontName', fontname,'FontSize',fontsize2);
        % overlay the labels
        for label = 1:size(rep_var1_label,2)
            x_ind = (size_poi_2/2) + size_poi_2*(label-1) + lab_x_offset;
            y_ind = size_poi_1*0.10;
            to_write = rep_var1_label{label};
            text(x_ind,y_ind,to_write,'Color','white','HorizontalAlignment','center','FontWeight','bold','FontSize',fontsize3);
        end
        % overlay the slice numbers
        if n_soi > 1
            %text(-15,-15,'Slices','Color','black','HorizontalAlignment','center','FontWeight','bold','FontSize',fontsize2);
            for label = 1:n_soi2
                x_ind = -15;
                y_ind = (size_poi_1*0.50)+size_poi_1*(label-1);
                to_write = num2str(viz_soi(label));
                text(x_ind,y_ind,to_write,'Color','black','HorizontalAlignment','center','FontWeight','bold','FontSize',fontsize3);
            end
        end
        % overlay the mask edges
        for n = 1:n_soi2
            for var1 = 1:n_var1_msk
                for m = size(var1_msk,3):-1:1
                    % grab the points making up the outline of the mask
                    x = var1_msk{viz_soi(n),var1,m}(:,2);
                    y = var1_msk{viz_soi(n),var1,m}(:,1);

                    n_pts = size(x,1);
                    % reduce the number of points
                    % if we want to keep most of the points, remove a small number
                    if line_factor >= 0.50
                        remove = 1:round(1/(1-line_factor)):n_pts;
                        x(remove) = [];
                        y(remove) = [];
                    else % if we want to remove most, only keep a small number
                        keep = 1:round(1/line_factor):n_pts;
                        x = x(keep);
                        y = y(keep);
                    end

                    % shift for the tiling
                    var1_shift = size_poi_2*(var1-1);
                    slice_shift = size_poi_1*(n-1);
                    % plot on the image
                    scatter(x+var1_shift,y+slice_shift,outline_strain{s,m});
                end
            end
        end
        % overlay information
        set(gcf, 'InvertHardCopy', 'off')
        if to_save(fig_no); saveas(gcf,[savepath ftitle],'svg'); end
        if to_save(fig_no); saveas(gcf,[savepath ftitle],'png'); end
        hold off;
    end
end

%% 7 - s STRAINS
fig_no = 7;
if to_show(fig_no)
    for s = 1:n_strain
        ftitle = [fig_names{fig_no} ' - ' sub_figs{fig_no}{s}];
        figure, imshow(fig{fig_no}(:,:,s)), colormap(cmap(:,:,s)), caxis(clim_strain(s,:)), colorbar, title(ftitle), hold on;
        set(gcf,'Renderer','painters','Position',render1)
        set(gca, 'FontName', fontname,'FontSize',fontsize2);
        % overlay the labels
        for label = 1:size(rep_var3_label,2)
            x_ind = (size_poi_2/2) + size_poi_2*(label-1) + lab_x_offset;
            y_ind = size_poi_1*0.10;
            to_write = rep_var3_label{label};
            text(x_ind,y_ind,to_write,'Color','white','HorizontalAlignment','center','FontWeight','bold','FontSize',fontsize3);
        end
        % overlay the slice numbers
        if n_soi > 1
            %text(-15,-15,'Slices','Color','black','HorizontalAlignment','center','FontWeight','bold','FontSize',fontsize2);
            for label = 1:n_soi2
                x_ind = -15;
                y_ind = (size_poi_1*0.50)+size_poi_1*(label-1);
                to_write = num2str(viz_soi(label));
                text(x_ind,y_ind,to_write,'Color','black','HorizontalAlignment','center','FontWeight','bold','FontSize',fontsize3);
            end
        end
        % overlay the mask edges
        for n = 1:n_soi2
            for var3 = 1:n_var3_msk
                for m = size(var3_msk,3):-1:1
                    % grab the points making up the outline of the mask
                    x = var3_msk{viz_soi(n),var3,m}(:,2);
                    y = var3_msk{viz_soi(n),var3,m}(:,1);

                    n_pts = size(x,1);
                    % reduce the number of points
                    % if we want to keep most of the points, remove a small number
                    if line_factor >= 0.50
                        remove = 1:round(1/(1-line_factor)):n_pts;
                        x(remove) = [];
                        y(remove) = [];
                    else % if we want to remove most, only keep a small number
                        keep = 1:round(1/line_factor):n_pts;
                        x = x(keep);
                        y = y(keep);
                    end

                    % shift for the tiling
                    s_shift = size_poi_2*(var3-1);
                    slice_shift = size_poi_1*(n-1);
                    % plot on the image
                    scatter(x+s_shift,y+slice_shift,outline_strain{s,m});
                end
            end
        end
        set(gcf, 'InvertHardCopy', 'off');
        if to_save(fig_no); saveas(gcf,[savepath ftitle],'svg'); end
        if to_save(fig_no); saveas(gcf,[savepath ftitle],'png'); end
        hold off;
    end
end

%% 8 - var1 SA
fig_no = 8;
if to_show(fig_no)
    for s = 1:n_strain
        for t = 1:n_test
            ftitle = [s_name{s} ' - ' fig_names{fig_no} ' - ' sub_figs{fig_no}{t}];
            figure, imshow(fig{fig_no}(:,:,s,t)), colormap(cmap(:,:,s)), caxis(clim_SA(s,t,:)), colorbar, title(ftitle), hold on;
            set(gcf,'Renderer','painters','Position',render1);
            set(gca, 'FontName', fontname,'FontSize',fontsize2);
            % overlay labels
            for label = 1:size(rep_var1_label,2)
                x_ind = (size_poi_2/2) + size_poi_2*(label-1) + lab_x_offset;
                y_ind = size_poi_1*0.10;
                to_write = rep_var1_label{label};
                text(x_ind,y_ind,to_write,'Color','white','HorizontalAlignment','center','FontWeight','bold','FontSize',fontsize3);
            end
            % overlay the slice numbers
            if n_soi > 1
                %text(-15,-15,'Slices','Color','black','HorizontalAlignment','center','FontWeight','bold','FontSize',fontsize2);
                for label = 1:n_soi
                    x_ind = -15;
                    y_ind = (size_poi_1*0.50)+size_poi_1*(label-1);
                    to_write = num2str(label);
                    text(x_ind,y_ind,to_write,'Color','black','HorizontalAlignment','center','FontWeight','bold','FontSize',fontsize3);
                end
            end
            % overlay the mask edges
            for n = 1:n_soi
                for var1 = 1:n_var1_msk
                    for m = size(var1_msk,3):-1:1
                        % grab the points making up the outline of the mask
                        x = var1_msk{n,var1,m}(:,2);
                        y = var1_msk{n,var1,m}(:,1);

                        n_pts = size(x,1);
                        % reduce the number of points
                        % if we want to keep most of the points, remove a small number
                        if line_factor >= 0.50
                            remove = 1:round(1/(1-line_factor)):n_pts;
                            x(remove) = [];
                            y(remove) = [];
                        else % if we want to remove most, only keep a small number
                            keep = 1:round(1/line_factor):n_pts;
                            x = x(keep);
                            y = y(keep);
                        end

                        % shift for the tiling
                        var1_shift = size_poi_2*(var1-1);
                        slice_shift = size_poi_1*(n-1);
                        % plot on the image
                        scatter(x+var1_shift,y+slice_shift,'w.');
                    end
                end
            end
            set(gcf, 'InvertHardCopy', 'off');
            if to_save(fig_no); saveas(gcf,[savepath ftitle],'svg'); end
            if to_save(fig_no); saveas(gcf,[savepath ftitle],'png'); end
            hold off;
        end
    end
end

%% 9 - s SA
fig_no = 9;
if to_show(fig_no)
    for s = 1:n_strain
        for t = 1:n_test
            ftitle = [s_name{s} ' - ' fig_names{fig_no} ' - ' sub_figs{fig_no}{t}];
            figure, imshow(fig{fig_no}(:,:,s,t)), colormap(cmap(:,:,s)), caxis(clim_SA(s,t,:)), colorbar, title(ftitle), hold on;
            set(gcf,'Renderer','painters','Position',render1)
            set(gca, 'FontName', fontname,'FontSize',fontsize2);
            % overlay the labels
            for label = 1:size(rep_var3_label,2)
                x_ind = (size_poi_2/2) + size_poi_2*(label-1) + lab_x_offset;
                y_ind = size_poi_1*0.10;
                to_write = rep_var3_label{label};
                text(x_ind,y_ind,to_write,'Color','white','HorizontalAlignment','center','FontWeight','bold','FontSize',fontsize3);
            end
            % overlay the slice numbers
            if n_soi > 1
                %text(-15,-15,'Slices','Color','black','HorizontalAlignment','center','FontWeight','bold','FontSize',fontsize2);
                for label = 1:n_soi
                    x_ind = -15;
                    y_ind = (size_poi_1*0.50)+size_poi_1*(label-1);
                    to_write = num2str(label);
                    text(x_ind,y_ind,to_write,'Color','black','HorizontalAlignment','center','FontWeight','bold','FontSize',fontsize3);
                end
            end
            % overlay the mask edges
            for n = 1:n_soi
                for var3 = 1:n_var3_msk
                    for m = size(var3_msk,3):-1:1
                        % grab the points making up the outline of the mask
                        x = var3_msk{n,var3,m}(:,2);
                        y = var3_msk{n,var3,m}(:,1);

                        n_pts = size(x,1);
                        % reduce the number of points
                        % if we want to keep most of the points, remove a small number
                        if line_factor >= 0.50
                            remove = 1:round(1/(1-line_factor)):n_pts;
                            x(remove) = [];
                            y(remove) = [];
                        else % if we want to remove most, only keep a small number
                            keep = 1:round(1/line_factor):n_pts;
                            x = x(keep);
                            y = y(keep);
                        end

                        % shift for the tiling
                        s_shift = size_poi_2*(var3-1);
                        slice_shift = size_poi_1*(n-1);
                        % plot on the image
                        scatter(x+s_shift,y+slice_shift,'w.');
                    end
                end
            end
            set(gcf, 'InvertHardCopy', 'off');
            if to_save(fig_no); saveas(gcf,[savepath ftitle],'svg'); end
            if to_save(fig_no); saveas(gcf,[savepath ftitle],'png'); end
            hold off;
        end
    end
end

%% 10 & 11 - masks
fig_no = 10;
if to_show(fig_no)
    ftitle = [fig_names{fig_no}];
    figure, imshow(fig{fig_no}), caxis([0 n_roi+2]), title(ftitle), hold on
    % overlay the slice numbers
    if n_soi > 1
        text(-15,-15,'Slices','Color','black','HorizontalAlignment','center','FontWeight','bold','FontSize',fontsize3);
        for label = 1:n_soi
            x_ind = -15;
            y_ind = (size_poi_1*0.50)+size_poi_1*(label-1);
            to_write = num2str(label);
            text(x_ind,y_ind,to_write,'Color','black','HorizontalAlignment','center','FontWeight','bold','FontSize',fontsize3);
        end
    end
    for n = 1:n_soi
        if use_intact
            n_mask = [1 2 3]; % multimask
        else
            n_mask = 1;
        end
        for mm = n_mask
            for m = size(var1_msk,3):-1:1
                var1_ind = find(rep_var1 == def_var1);
                % grab the points making up the outline of the mask
                x = var1_msk{n,var1_ind,m}(:,2);
                y = var1_msk{n,var1_ind,m}(:,1);

                n_pts = size(x,1);
                % reduce the number of points
                % if we want to keep most of the points, remove a small number
                if line_factor >= 0.50
                    remove = 1:round(1/(1-line_factor)):n_pts;
                    x(remove) = [];
                    y(remove) = [];
                else % if we want to remove most, only keep a small number
                    keep = 1:round(1/line_factor):n_pts;
                    x = x(keep);
                    y = y(keep);
                end

                % shift for the tiling
                var1_shift = size_poi_2*(mm-1);
                slice_shift = size_poi_1*(n-1);
                % plot on the image
                scatter(x+var1_shift,y+slice_shift,'w.');
            end
        end
    end
    set(gcf,'Renderer','painters','Position',render2)
    set(gca, 'FontName', fontname,'FontSize',fontsize3);
    set(gcf, 'InvertHardCopy', 'off');
    if to_save(fig_no); saveas(gcf,[savepath ftitle],'svg'); end
    if to_save(fig_no); saveas(gcf,[savepath ftitle],'png'); end
end

fig_no = 11;
if to_show(fig_no)
    for m = 1:size(fig{fig_no},3)
        ftitle = [fig_names{fig_no} ' - ' sub_figs{fig_no}{m}];
        figure, imshow(fig{fig_no}(:,:,m)), caxis('auto'), title(ftitle)
        set(gcf,'Renderer','painters','Position',render1)
        set(gca, 'FontName', fontname,'FontSize',fontsize2);
        set(gcf, 'InvertHardCopy', 'off');
        if to_save(fig_no); saveas(gcf,[savepath ftitle],'svg'); end
        if to_save(fig_no); saveas(gcf,[savepath ftitle],'png'); end
    end
end

%% 12 - correlation curves
fig_no = 12;
if to_show(fig_no)
    p_name = {'Stiffness Ratio';'Adhesion Strength'};
    for p = 1:2
        if p == 1
            plot_f1 = [1:13];
            plot_val = (range_var1(plot_f1)./range_var1(i_f1))*100;
            plot_x = 'Stiffness Ratio (%)';
        elseif p == 2
            if strcmp(model,'simple') || strcmp(model,'simple2')
                plot_f2 = 1;
            else
                plot_f2 = [1:11];
            end
            plot_val = log10(range_var3(plot_f2).*1e6);
            plot_x = 'Maximum Traction (log of Pa)';
        end
        for plot_strain = 1:3
            plot_y = 'value';
            ftitle = [s_name{plot_strain} ' - ' p_name{p}];
            figure, sgtitle(ftitle), hold on
            set(gcf,'Renderer','painters','Position',render2)
            set(gca, 'FontName', fontname,'FontSize',fontsize2);
            for t = 1:n_test
                subplot(n_test,1,t)
                for n = 2:n_noise+1
                    % the length of the plot
                    plot_len = size(plot_val,2);

                    % determine which data range to use
                    if plot_len <= 11
                        to_plot = squeeze(var3_vals_noise(plot_strain,t,plot_f2,n));
                    elseif plot_len == 13
                        to_plot = squeeze(var1_vals_noise(plot_strain,t,plot_f1,n));
                    end

                    % plot the data, and the intact data if its there
                    plot(plot_val,to_plot,'LineWidth',2), hold on
                    if exist('i_test_vals_noise','var')
                        to_i_plot = ones(plot_len,1)*i_test_vals_noise(plot_strain,t);
                        plot(plot_val,to_i_plot,'LineWidth',2), hold on
                        lim = expand_limits([to_plot; to_i_plot],0.3);
                    else
                        lim = expand_limits(to_plot,0.3);
                    end
                    
                    ylim(lim);
                    grid on;
                    grid minor;
                end
                if t == 1
                    xlabel(plot_x)
                    if exist('test_msk2','var')
                        ylabel('Mean Ratio')
                    else
                        ylabel('Heuristic Value')
                    end
                    if exist('i_test_vals_noise','var')
                        lgd = legend({'Inclusion';'Intact'},'Location','none','Position',[0.84 0.93 0.01 0.01]);
                        title(lgd,'Model Type');
                    else
                        %lgd = legend({'Inclusion';});
                    end
                end
                title(sub_figs{8}{t});
                set(gca, 'FontName', fontname,'FontSize',fontsize1);
                hold off
            end
            hold off
            set(gcf, 'InvertHardCopy', 'off');
            if to_save(fig_no); saveas(gcf,[savepath ftitle],'svg'); end
            if to_save(fig_no); saveas(gcf,[savepath ftitle],'png'); end
        end
    end
end




