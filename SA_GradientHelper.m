function [cleaned_pts] = SA_GradientHelper(def_pts, msk)
% helper function, removes points associated with the 'edge' using a mask

%% VERSION HISTORY
% CREATED 1/14/20 BY SS

%% SAFETY AND PREPARATION
if isempty(def_pts)
    error('No defects were identified! Check parameters.');
end

% EXPLANATION: emsk is edge mask, tells you what to consider an edge. if a
% point falls in any denoted area, it is excluded.
cleaned_pts = [];   % points that are NOT near an edge

%figure, imshow(msk), title('check mask for my sanity...')

%% POINT REMOVAL
n_pts = size(def_pts, 1);
for i = 1:n_pts
    x = def_pts(i,1);
    y = def_pts(i,2);
    if msk(x,y) == 0    % x and y are backwards because matlab
        %code = ['skipped adding: ' num2str(x) ' ' num2str(y)];
        %disp(code)
        cleaned_pts = [cleaned_pts; [x y];];
    end
end

%% CHECK
if isempty(cleaned_pts)
    disp('Warning! All points were removed, check mask or point parameters...')
end