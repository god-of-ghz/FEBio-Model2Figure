function [lmap] = SA_Helper(data,msk,win,test)
% helper function to easily coordinate which spatial analysis method to run

%% VERSION HISTORY
%   CREATED 12/28/20 BY SS

%% SAFETY AND PREPARATION
if isempty(test)
    test = 'strain';    % default is just the strain map (no processing)
end

%% PERFORM TESTS
if strcmp(test,'strain')
    lmap = data;
elseif strcmp(test,'VMR') || strcmp(test, 'vmr') || strcmp(test,'vmratio')
    pointmap = SA_WindowAnalysis(data,msk,win);
    lmap = SA_VMRatio(pointmap);
elseif strcmp(test,'lacunarity') || strcmp(test,'lac')
    pointmap = SA_WindowAnalysis(data,msk,win);
    lmap = SA_Lacunarity(pointmap);
elseif strcmp(test,'moransI') || strcmp(test,'morans')
    if mod(win,2) == 0 && win > 2
        m_win = win - 1;
    else
        m_win = win;
    end
    lmap = SA_MoransI(data,ones(m_win,m_win),'true');
elseif strcmp(test,'gradient') || strcmp(test,'grad')
    [lmap, ~,~] = SA_Gradient(data,msk);
else
    lmap = [];
    error([test ' is not a currently supported spatial analysis method!'])
end
