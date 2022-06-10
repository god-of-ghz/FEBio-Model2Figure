%% FEA PROCESSING SUITE - STEP 3/4 - GENERATE ANALYSIS RESULTS
%   ----------------------------------------------------------------------
%   This program is used to generate analysis results through generation of
%   analysis masks, computing spatial analysis heuristics, and performing a
%   correlation with those heuristics and the input variables

%% VERSION HISTORY
% CREATED 12/22/20 BY SS
% MODIFIED 1/XX/20 BY SS
%   - implemented serialized caching of SA results
%   - implemeneted analysis of unique/intact model 
% MODIFIED 2/19/20 BY SS
%   - moved correlation visualization code to FEA_MakeImages
% MODIFIED 4/27/20 BY SS
%   - cleaned up code, improved comments

%% SIMULATION LOADING PARAMETERS
% at a minimum, FEA_Strains must been run first. GenerateSims can be skipped after being run once, but not Strains
if ~exist('model','var')
    error('This script requires FEA_Strains already be run, and the contents loaded into the base workspace.')
end

disp('Computing masks...')
if strcmp(model,'defect1')
    % set analysis masks here
    test_msk = permute(msk(:,:,:,1,:,:),[1 2 3 5 6 4]);     % test_msk is the main analysis mask
    test_msk2 = false(im_size,im_size,n_soi,n_file_1,n_file_2); % test_msk2 (OPTIONAL)
    
    for i = 1:n_file_1
        for j = 1:n_file_2
            test_msk2(:,:,:,i,j) = FEA_BorderMask(msk(:,:,:,:,i,j),[2 1;],{2},3);  % generates a bordering mask
        end
    end
    
    % analysis methods here
    % default are these 5: mean strain, VMR, lacunarity, moran's I, gradient
    n_test = 5;                                                             % number of analysis tests
    test_name = {'strain'; 'vmr'; 'lacunarity'; 'moransI'; 'gradient';};    % names of the tests
    win = 5;                                                                % window size, where applicable
    i_file = 'intact_model';                                                % name of the unique/intact case file (OPTIONAL)
    i_f1 = 8;                                                               % index for which approximates the unique/intact case, for var_1
    i_f3 = 11;                                                              % index for the same, for var_3    
    
    % caching
    SA_cache = [1 1];                                                       % use caching for perfect and noisy strains?
elseif strcmp(model,'defect2')
    test_msk = false(im_size,im_size,n_soi,n_file_1,n_file_2);
    for i = 1:n_file_1
        for j = 1:n_file_2
            test_msk(:,:,:,i,j) = FEA_BorderMask(msk(:,:,:,:,i,j),[2 1;],{[2 1]}, 4);
        end
    end
    n_test = 5;
    test_name = {'strain'; 'vmr'; 'lacunarity'; 'moransI'; 'gradient';};
    win = 40;
    i_file = 'intact_model'; 
    i_f1 = 8;
    i_f3 = 11;
    SA_cache = [1 1];
elseif strcmp(model,'defect3')
    %test_msk = permute(msk(:,:,:,1,:,:),[1 2 3 5 6 4]);
    test_msk = false(im_size,im_size,n_soi,n_file_1,n_file_2);
    for i = 1:n_file_1
        for j = 1:n_file_2
            test_msk(:,:,:,i,j) = FEA_BorderMask(msk(:,:,:,:,i,j),[2 1;],{[2 1]}, 5);
        end
    end
	n_test = 5;
    test_name = {'strain'; 'vmr'; 'lacunarity'; 'moransI'; 'gradient';};
    win = 40;
    i_file = 'intact_model'; 
    i_f1 = 8;
    i_f3 = 11;
    SA_cache = [1 1];
elseif strcmp(model,'defect4')
    %sim_set = 'FEA_defect_model_0.26-1.28_0-10000000';
    test_msk = false(im_size,im_size,n_soi,n_file_1,n_file_2);
    for i = 1:n_file_1
        for j = 1:n_file_2
            test_msk(:,:,:,i,j) = FEA_BorderMask(msk(:,:,:,:,i,j),[1 2;],2);
        end
    end
%    figure, montage(test_msk(:,:,:,1,1)+sum(msk(:,:,:,:,1,1),4)), axis equal off, colormap(jet), caxis('auto'), colorbar
    % mean strain, VMR, lacunarity, moran's I, gradient
	n_test = 5;
    test_name = {'strain'; 'vmr'; 'lacunarity'; 'moransI'; 'gradient';};
    win = 5;
    i_file = 'intact_model'; 
    i_f1 = 8;
    i_f3 = 11;
    SA_cache = [1 1];
elseif strcmp(model,'defect5')
    %sim_set = 'FEA_defect_model_0.26-1.28_0-10000000';
    test_msk = false(im_size,im_size,n_soi,n_file_1,n_file_2);
    for i = 1:n_file_1
        for j = 1:n_file_2
            test_msk(:,:,:,i,j) = FEA_BorderMask(msk(:,:,:,:,i,j),[1 2;],2);
        end
    end
    figure, montage(test_msk(:,:,:,1,1)+sum(msk(:,:,:,:,1,1),4)), axis equal off, colormap(jet), caxis('auto'), colorbar
    % mean strain, VMR, lacunarity, moran's I, gradient
    n_test = 5;
    test_name = {'strain'; 'vmr'; 'lacunarity'; 'moransI'; 'gradient';};
    win = 5;
    i_file = 'intact_model'; 
    i_f1 = 1;
    i_f3 = 1;
elseif strcmp(model,'simple')
    %sim_set = 'FEA_simple_model_0.26-1.28_0-0';
    test_msk = permute(msk(:,:,:,4,:,:),[1 2 3 5 6 4]);
    test_msk2 = false(im_size,im_size,n_soi,n_file_1,n_file_2);
    for i = 1:n_file_1
        for j = 1:n_file_2
            test_msk2(:,:,:,i,j) = FEA_BorderMask(msk(:,:,:,:,i,j),[1 4;2 4;3 4;],{1;2;3},5);
        end
    end
    n_test = 5;
    win = 20;
    test_name = {'strain'; 'vmr'; 'lacunarity'; 'moransI'; 'gradient';};
    i_f1 = 8;
    i_f3 = 1;
    SA_cache = [1 1];
elseif strcmp(model,'simple2')
    test_msk = permute(msk(:,:,:,4,:,:),[1 2 3 5 6 4]);
    test_msk2 = false(im_size,im_size,n_soi,n_file_1,n_file_2);
    for i = 1:n_file_1
        for j = 1:n_file_2
            test_msk2(:,:,:,i,j) = FEA_BorderMask(msk(:,:,:,:,i,j),[5 4;2 4;3 4;],{5;2;3},5);
        end
    end
    n_test = 5;
    win = 20;
    test_name = {'strain'; 'vmr'; 'lacunarity'; 'moransI'; 'gradient';};
    i_f1 = 8;
    i_f3 = 1;
    SA_cache = [1 1];
elseif strcmp(model,'simple3')
    test_msk = permute(msk(:,:,:,4,:,:),[1 2 3 5 6 4]);
    test_msk2 = false(im_size,im_size,n_soi,n_file_1,n_file_2);
    for i = 1:n_file_1
        for j = 1:n_file_2
            test_msk2(:,:,:,i,j) = FEA_BorderMask(msk(:,:,:,:,i,j),[5 4;2 4;3 4;],{5;2;3},5);
        end
    end
    n_test = 1;
    win = 20;
    test_name = {'strain';}; % 'lacunarity'; 'moransI'; 'gradient';};
    i_f1 = 8;
    i_f3 = 1;
    SA_cache = [1 1];
else
    disp('That simulation set has not been added yet!')
    return
end


%% LOAD IN THE DATA
%[strainP,msk,dmsk,to_use] = FEA_Strains(sim_set,smoothing,im_size,slices,soi,plane,noise,use_cache,msk_order);
if ~exist('strainP','var')
    error('Strains must already be loaded into memory!')
end
load([cache_path param_file '.mat'],'febfiles','logfiles','n_pts_1','n_pts_2','range_var1','range_var2','range_var3','root');

%% SHOW MASK (mainly for debugging)
figure, montage(test_msk(:,:,:,1,1)+sum(msk(:,:,:,:,1,1),4)), axis equal off, caxis('auto')
if exist('test_msk2','var')
    figure, montage(test_msk2(:,:,:,1,1)+sum(msk(:,:,:,:,1,1),4)), axis equal off, caxis('auto')
end

%% PERFORM SPATIAL ANALYSIS
if ~exist('strainSA','var')
    strainSA = zeros(im_size,im_size,3,n_soi,n_test,n_file_1,n_file_2);
    if n_noise > 0 && exist('strainP_noise','var')
        strainSA_noise_mean = zeros(3,n_test,n_file_1,n_file_2,n_noise);
        if exist('test_msk2','var')
            strainSA_noise_mean2 = zeros(3,n_test,n_file_1,n_file_2,n_noise);
        end
        % if there's JUST one or two noise levels... i guess we can make room for the extra memory
        if n_noise <= 2
            strainSA_noise = zeros(im_size,im_size,3,n_soi,n_test,n_file_1,n_file_2,n_noise);
        end
    end
    SA_run_times = [];
    disp('Performing spatial analysis...')
    for t = 1:n_test
        for f1 = 1:n_file_1
            for f2 = 1:n_file_2
                tic
                if to_use(f1,f2)
                    disp(['Running file: ' extract_filename(febfiles{f1,f2})]);
                    disp('--------------------------------------------------');

                    SA_vars = ['_' test_name{t} '_' num2str(win) '_win_SA'];
                    savefile = [cache_path extract_filename(febfiles{f1,f2}) strain_vars  SA_vars '.mat'];
                    if exist(savefile,'file') && SA_cache(1)
                        load(savefile,'s_strainSA');
                        strainSA(:,:,:,:,t,f1,f2) = s_strainSA;
                    else
                        for i = 1:3
                            for j = 1:n_soi
                                % the strain map to analyze
                                target = squeeze(strainP(:,:,i,j,f1,f2));
                                % *all* the parts together as a collective mask
                                target_msk = squeeze(sum(msk(:,:,j,:,f1,f2),4));
                                strainSA(:,:,i,j,t,f1,f2) = SA_Helper(target,target_msk,win,test_name{t});
                            end
                        end
                        s_strainSA = strainSA(:,:,:,:,t,f1,f2);
                        save_helper(savefile,s_strainSA,'s_strainSA');                        
                    end
                    if n_noise > 0
                        % since we can't hold ALL the noisy SA maps, here's
                        % a holder for ONE file's noisy SA
                        strainSA_noise_temp = zeros(im_size,im_size,3,n_soi,n_noise);
                        % only used for noisy strains SA analysis    
                        mean_msk = squeeze(test_msk(:,:,:,f1,f2)); 
                        for n = 1:n_noise
                            noise_vars = ['_' num2str(noise(n)) '_' noise_type '_SNR'];
                            savefile = [cache_path extract_filename(febfiles{f1,f2}) strain_vars SA_vars noise_vars '.mat'];
                            % try to load the data
                            if exist(savefile,'file') && SA_cache(2)
                                load(savefile,'s_strainSA_noise');
                                strainSA_noise_temp(:,:,:,:,n) = s_strainSA_noise;
                            % or just compute it
                            else
                                for i = 1:3
                                    for j = 1:n_soi
                                        target = squeeze(strainP_noise(:,:,i,j,f1,f2,n));
                                        target_msk = squeeze(sum(msk(:,:,j,:,f1,f2),4));
                                        strainSA_noise_temp(:,:,i,j,n) = SA_Helper(target,target_msk,win,test_name{t});
                                    end
                                end

                                s_strainSA_noise = strainSA_noise_temp(:,:,:,:,n);
                                % need to do this dumb thing to save...
                                save_helper(savefile,s_strainSA_noise,'s_strainSA_noise');
                            end
                            % now grab the mean of all the slices
                            for i = 1:3
                                target = squeeze(strainSA_noise_temp(:,:,i,:,n));
                                target_msk = squeeze(test_msk(:,:,:,f1,f2));
                                if exist('test_msk2','var')
                                    target_msk2 = squeeze(test_msk2(:,:,:,f1,f2));
                                end
%                                 vals_temp = target(find(mean_msk == 1));
%                                 vals_temp = remove_outliers(vals_temp,10);
                                strainSA_noise_mean(i,t,f1,f2,n) = SA_RoiVal(target,target_msk,test_name{t},'mean');
                                if exist('test_msk2','var')
                                    strainSA_noise_mean2(i,t,f1,f2,n) = SA_RoiVal(target,target_msk2,test_name{t},'mean');
                                end
                            end
                        end
                        if n_noise <= 2
                            %strainSA_noise = zeros(im_size,im_size,3,n_soi,n_test,n_file_1,n_file_2,n_noise);
                            strainSA_noise(:,:,:,:,t,f1,f2,:) = strainSA_noise_temp;
                        end
                    end
                    [msg,SA_run_times] = estimate_time(SA_run_times,t,f1,f2,n_test,n_file_1,n_file_2,[]);
                    disp(msg);
                end
            end
        end
    end
end


%% ASSEMBLE THE DATA
% acquire means of the important values
% test_vars = [sim_set '_' strain_vars '_' num2str(win) '_win'];
% savefile = [cache_path test_vars '.mat'];
% if exist(savefile,'file')
%     load(savefile,'test_vals','test_vals2','test_vals_noise','test_vals_noise2');
% else
    test_vals = zeros(3,n_file_1,n_file_2,n_test);
    if exist('test_msk2','var')
        test_vals2 = zeros(3,n_file_1,n_file_2,n_test);
    end
    if n_noise > 0
        test_vals_noise = zeros(3,n_file_1,n_file_2,n_test,n_noise);
        if exist('test_msk2','var')
            test_vals_noise2 = zeros(3,n_file_1,n_file_2,n_test,n_noise);
        end
    end
    disp('Reorganizing data...')
    for i = 1:3
        for j = 1:n_file_1
            for k = 1:n_file_2
                % grab the mask
                target_msk = squeeze(test_msk(:,:,:,j,k));
                if exist('test_msk2','var')
                    target_msk2 = squeeze(test_msk2(:,:,:,j,k));
                end
                for t = 1:n_test
                    % grab the data
                    target = squeeze(strainSA(:,:,i,:,t,j,k));
    %                 vals_temp = target(find(target_msk == 1));
    %                 vals_temp = remove_outliers(vals_temp,10);
    %                 test_vals(i,j,k,t) = mean(vals_temp,'all','omitnan');
                    test_vals(i,j,k,t) = SA_RoiVal(target,target_msk,test_name{t},'mean');
                    if exist('test_msk2','var')
    %                     vals_temp = target(find(target_msk2 == 1));
    %                     vals_temp = remove_outliers(vals_temp,10);
                        test_vals2(i,j,k,t) = SA_RoiVal(target,target_msk2,test_name{t},'mean');
                    end
                    if n_noise > 0
                        for n = 1:n_noise
                            % we calculated the mean earlier, just grab it
                            test_vals_noise(i,j,k,t,n) = strainSA_noise_mean(i,t,j,k,n);
                            if exist('test_msk2','var')
                                test_vals_noise2(i,j,k,t,n) = strainSA_noise_mean2(i,t,j,k,n);
                            end
                        end
                    end
                end
            end
        end
    end
%     if exist('test_msk2','var')
%         save(savefile,'test_vals','test_vals2','test_vals_noise','test_vals_noise2');
%     else
%         save(savefile,'test_vals','test_vals_noise');
%     end
%end

%% IMPORT INTACT DATA
% load the intact file for this simulation set, if one exists
if exist('i_file','var')
    i_file_strains = [cache_path i_file strain_vars '_strains.mat'];
    if exist(i_file_strains,'file')
        use_intact = true;
        disp('Intact file processing...')
        load(i_file_strains,'s_strainP','s_msk');
        i_strainP = s_strainP;
        i_msk = s_msk;

        % run spatial analysis
    %     i_strainSA = zeros(im_size,im_size,3,n_soi,n_test);
    %     i_test_vals = zeros(3,n_test);
    %     for i = 1:3
    %         for t = 1:n_test
    %             for j = n_soi
    %                 target = squeeze(i_strainP(:,:,i,j));
    %                 target_msk = squeeze(sum(i_msk(:,:,j,:),4));
    %                 i_strainSA(:,:,i,j,t) = SA_Helper(target,target_msk,win,test_name{t});
    %             end
    %             target = squeeze(i_strainSA(:,:,i,:,t));
    %             target_msk = squeeze(test_msk(:,:,:,i_f1,i_f2));
    %             i_test_vals(i,t) = SA_RoiVal(target,target_msk,test_name{t},'mean');
    %         end
    %     end

        % repeat for noisy strains
        if n_noise > 0  
            i_strainP_noise = zeros(im_size,im_size,3,n_soi,n_noise);
            i_strainSA_noise = zeros(im_size,im_size,3,n_soi,n_test,n_noise);
            for n = 1:n_noise
                noise_vars = ['_' num2str(noise(n)) '_' noise_type '_SNR'];
                i_file_noise = [cache_path i_file strain_vars  noise_vars '_strains.mat'];
                if exist(i_file_noise,'file')
                    load(i_file_noise,'s_strainP_noise');
                    i_strainP_noise(:,:,:,:,n) = squeeze(s_strainP_noise);
                else
                    disp([extract_filename(i_file_noise) ' does not exist! Skipping...']);
                end
            end
            i_test_vals_noise = zeros(3,n_test,n_noise);
            if exist('test_msk2','var')
                i_test_vals_noise2 = zeros(3,n_test,n_noise);
            end
            i_run_times = [];
            for n = 1:n_noise
                for i = 1:3
                    for t = 1:n_test
                        tic
                        for j = 1:n_soi
                            target = squeeze(i_strainP_noise(:,:,i,j,n));
                            target_msk = squeeze(sum(i_msk(:,:,j,:),4));
                            i_strainSA_noise(:,:,i,j,t,n) = SA_Helper(target,target_msk,win,test_name{t});
                        end
                        target = squeeze(i_strainSA_noise(:,:,i,:,t,n));
                        target_msk = squeeze(test_msk(:,:,:,i_f1,i_f3));
                        i_test_vals_noise(i,t,n) = SA_RoiVal(target,target_msk,test_name{t},'mean');
                        % if a second mask exists
                        if exist('test_msk2','var')
                            % repeat the analysis
                            target_msk = squeeze(test_msk2(:,:,:,i_f1,i_f3));
                            i_test_vals_noise2(i,t,n) = SA_RoiVal(target,target_msk,test_name{t},'mean');
                            % take the ratio of their means
                            i_test_vals_noise(i,t,n) = i_test_vals_noise(i,t,n)/i_test_vals_noise2(i,t,n);
                        end
                        [msg,i_run_times] = estimate_time(i_run_times,n,i,t,n_noise,3,n_test,[]);
                        disp(msg);
                    end
                end
            end
        end

        % also load the displacements (needed later)
        i_file_disp = [cache_path i_file int_vars '_intslices.mat'];
        if exist(i_file_disp,'file')
            load(i_file_disp,'s_disp');
            i_disp = s_disp;
        end
        disp('Intact file loaded!');
    else
        disp('There was no processed strain map of the unique/intact simulation for this simulation!')
        use_intact = false;
    end
else
    disp('There was no processed strain map of the unique/intact simulation for this simulation!')
    use_intact = false;
end


%% COMPUTE CORRELATIONS
disp('Computing correlation!')

var1_vals = zeros(3,n_test,n_file_1);
var3_vals = zeros(3,n_test,n_file_2);
var1_vals_noise = zeros(3,n_test,n_file_1,n_noise+1);
var3_vals_noise = zeros(3,n_test,n_file_2,n_noise+1);
if exist('test_msk2','var')
    var1_vals2 = zeros(3,n_test,n_file_1);
    var3_vals2 = zeros(3,n_test,n_file_2);
    var1_vals_noise2 = zeros(3,n_test,n_file_1,n_noise+1);
    var3_vals_noise2 = zeros(3,n_test,n_file_2,n_noise+1);
end

for i = 1:3
    for t = 1:n_test
        for f1 = 1:n_file_1
            var1_vals(i,t,f1) = mean(test_vals(i,f1,:,t),'all','omitnan');
            var1_vals_noise(i,t,f1,1) = var1_vals(i,t,f1);
            if exist('test_msk2','var')
                var1_vals2(i,t,f1) = mean(test_vals2(i,f1,:,t),'all','omitnan');
                var1_vals_noise2(i,t,f1,1) = var1_vals2(i,t,f1);
            end
            for n = 2:n_noise+1
                var1_vals_noise(i,t,f1,n) = mean(test_vals_noise(i,f1,:,t,n-1),'all','omitnan');
                if exist('test_msk2','var')
                    var1_vals_noise2(i,t,f1,n) = mean(test_vals_noise2(i,f1,:,t,n-1),'all','omitnan');
                end
            end
        end
        for f2 = 1:n_file_2
            var3_vals(i,t,f2) = mean(test_vals(i,:,f2,t),'all','omitnan');
            var3_vals_noise(i,t,f2,1) = var3_vals(i,t,f2);
            if exist('test_msk2','var')
                var3_vals2(i,t,f2) = mean(test_vals2(i,:,f2,t),'all','omitnan');
                var3_vals_noise2(i,t,f2,1) = var3_vals2(i,t,f2);
            end
            for n = 2:n_noise+1
                var3_vals_noise(i,t,f2,n) = mean(test_vals_noise(i,:,f2,t,n-1),'all','omitnan');
                if exist('test_msk2','var')
                    var3_vals_noise2(i,t,f2,n) = mean(test_vals_noise2(i,:,f2,t,n-1),'all','omitnan');
                end
            end
        end
    end
end


if exist('test_msk2','var')
    var1_vals = var1_vals./var1_vals2;
    var3_vals = var3_vals./var3_vals2;
    if n_noise > 0
        var1_vals_noise = var1_vals_noise./var1_vals_noise2;
        var3_vals_noise = var3_vals_noise./var3_vals_noise2;
    end
end


corr_var1 = zeros(3,n_test);
corr_var3 = zeros(3,n_test);
if n_noise > 0
    corr_var1_noise = zeros(3,n_test,n_noise+1);
    corr_var3_noise = zeros(3,n_test,n_noise+1);
end
for i = 1:3
    for t = 1:n_test
        % var 1
        corr_var1_temp = corrcoef(squeeze(var1_vals(i,t,:)),range_var1./range_var1(i_f1));        
        corr_var3_temp = corrcoef(squeeze(var3_vals(i,t,:)),range_var3);
        corr_var1(i,t) = corr_var1_temp(1,2);
        if size(corr_var3_temp,2) == 2
            corr_var3(i,t) = corr_var3_temp(1,2);
        end
        
        % compile the correlation for the noise values
        if n_noise > 0
            for n = 1:n_noise+1
                corr_var1_temp_noise = corrcoef(squeeze(var1_vals_noise(i,t,:,n)),range_var1./range_var1(i_f1));    
                corr_var3_temp_noise = corrcoef(squeeze(var3_vals_noise(i,t,:,n)),range_var3);

                corr_var1_noise(i,t,n) = corr_var1_temp_noise(1,2);
                if size(corr_var3_temp_noise,2) == 2
                    corr_var3_noise(i,t,n) = corr_var3_temp_noise(1,2);
                end
            end
        end
    end
end

% for easy formatting
corr_var1_excel = corr_var1_noise(:,:,2);
corr_var3_excel = corr_var3_noise(:,:,2);



%% VISUALIZE DATA
% code moved to FEA_MakeImages

%% VISUALIZE CHANGE IN CORRELATION
% if n_noise > 0
%     for i = 1:3
%         figure, sgtitle(s_name{i}), hold on
%         for t = 1:5
%             subplot(5,1,t)
%             to_plot = squeeze(corr_var1_100_noise(i,t,:));
%             plot_range = 1:size(corr_var1_100_noise,3);
%             plot(plot_range,to_plot,'LineWidth',2)
%             title(test_name{t})
%             xlabel('Noise level')
%             ylabel('Correlation')
%         end
%         hold off
%     end
% end
