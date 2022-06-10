% a script to test SA methods from imported FEA data

%% PARAMETERS AND SETUP
% if ~exist(strainI, 'var')
%     error('need the intact strains yo');
% end
% if ~exist(strainD, 'var')
%     error('need the defect strains yo');
% end
% 
% if ~exist(def_map, 'var');
%     def_map = SA_FindDefects(strainI, strainD, dmsk); 
% end


windows = [20];         % window sizes to use
n_win = size(windows,2);    
n_std = 2;              % number of stds away to treat as a 'defect'
spath = 'results_SA/';  % save path

edge_corr = 1;          % correct for edges?

%method = 'lacunarity';  % method to test
%method = 'vmratio';     
method = 'moransI';
%method = 'gradient';
%method = 'ripleysK';

%% MAKE DIRECTORIES
for i = 1:3
    dfolder = ['fea model - EP' num2str(i) '/'];
    if ~exist([spath dfolder], 'dir')
        mkdir ([spath dfolder])
    end
end

%% PERFORM ANALYSIS
for i = 1:3
    dfolder = ['fea model - EP' num2str(i) '/'];

    % display base data
    ftitle = ['defect - EP' num2str(i)];
    figure, imagesc(strainD(:,:,i)), axis equal off, colorbar, title(ftitle);
    saveas(gcf, [spath dfolder ftitle], 'png');

    ftitle = ['intact - EP' num2str(i)];
    figure, imagesc(strainI(:,:,i)), axis equal off, colorbar, title(ftitle);
    saveas(gcf, [spath dfolder ftitle], 'png');
    for j = 1:n_win
        if strcmp(method, 'lacunarity')
            pointmap = SA_WindowAnalysis(strainD(:,:,i),dmsk,windows(j));
            lmap = SA_Lacunarity(pointmap);
        elseif strcmp(method, 'vmratio')
            pointmap = SA_WindowAnalysis(strainD(:,:,i),dmsk,windows(j));
            lmap = SA_VMRatio(pointmap);
        elseif strcmp(method, 'moransI')
            win = [];
            if mod(windows(j),2) == 0 && windows(j) > 0
                windows(j) = windows(j) - 1;
            end
            win = ones(windows(j), windows(j));
            lmap = SA_MoransI(strainD(:,:,i), win, 'true');
        elseif strcmp(method, 'gradient')
            [lmap, ~] = SA_Gradient(strainD(:,:,i),dmsk);
        else
            error([method ' has not been implemented.']);
        end
        ftitle = [method ' window ' num2str(windows(j))];
        figure, imagesc(lmap), axis equal off, title(ftitle), colorbar;
        saveas(gcf, [spath dfolder ftitle], 'png');
        
        % label the defect points
        ftitle = [method ' window ' num2str(windows(j)) ' - defects'];
        def_pts = SA_Identify(lmap, dmsk, n_std);
        figure, imagesc(strainD(:,:,i)), axis equal off, colorbar, title(ftitle)
        hold on
        if ~isempty(def_pts)
            plot(def_pts(:,2), def_pts(:,1), 'r+', 'MarkerSize', 10, 'LineWidth', 2);
        end
        saveas(gcf, [spath dfolder ftitle], 'png');
        hold off
    end
end