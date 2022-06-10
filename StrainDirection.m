function [pts, s_vec] = StrainDirection(strain, angle, mask, rot, reduce)
% a function to quickly generate a map of arrows based on the strains

%% VERSION HISTORY
% CREATED 4/9/20 BY SS

%% SAFETY AND PREPARATION
to_scale = 1;           % use scaling or make all arrows uniform?
scale = 1;              % scaling factor, try a few rounds to see which one works best
to_contour = 0;         % make a contour map?


[x, y, z, s] = size(strain);
[a, b, c, d] = size(angle);
if a ~= x || b ~= y || c ~= z
    error('Strain map and angular map must align!');
end

[a, b, c] = size(mask);
if a ~= x || b ~= y
    error('Maps and mask must have the same 2D dimensions');
end

%% COMPILE VALID POINTS
pts = [];           % holder for the valid points (needed for vector calc)
for i = 1:x
    for j = 1:y
        if mask(i,j)    % if the mask is valid here
            pts = [pts; [i, j]];    % add that point
        end
    end
end
%% REDUCE NUMBER OF USED POINTS
% arrow graph can become visually busy, so specify a factor to reduce the #of points used
% to half the # of points, reduce = 2. to use 1/3, reduce = 3, and so on.
if ~isempty(reduce) && reduce >= 1
    pts = pts(1:reduce:end,:);
elseif reduce < 0 && reduce > 1
    pts = pts(1:(1/reduce):end,:);  % in case someone messes up :)
end
n_pts = max(size(pts)); % store the max number of points, for convenience

%% COMPUTE UNIT VECTORS FOR EACH POINT
u_vec = zeros(n_pts, 2, z);
for i = 1:n_pts
    for j = 1:z
        [temp1, temp2] = AngleToVector(angle(pts(i,1),pts(i,2),j), rot); 
        u_vec(i,1,j) = temp1;
        u_vec(i,2,j) = temp2;
    end
end

%% SCALE EACH VECTOR TO THE MAGNITUDE OF THE STRAIN AT THAT POINT
s_vec = zeros(n_pts,2, z);
if to_scale
    for i = 1:n_pts
        for j = 1:z
            val = abs(strain(pts(i,1),pts(i,2),j));
            s_vec(i,1,j) = u_vec(i,1,j)*val;
            s_vec(i,2,j) = u_vec(i,2,j)*val;
        end
    end
else
    s_vec = u_vec;
end

%% OVERLAY THE MAP OF ARROWS ONTO THE STRAIN MAPS
% for i = 1:z
%     ftitle = ['E_' num2str(i)];
%     QuiverOverlay(strain(:,:,i), pts, s_vec(:,:,i),scale,ftitle)
% %     figure, imagesc(strain(:,:,i)), axis off, colorbar, title(ftitle), hold on
% %     q = quiver(pts(:,2),pts(:,1),s_vec(:,1,i),s_vec(:,2,i), 'Color', 'black','AutoScaleFactor',scale,'MaxHeadSize',1);
% %     hold off
%     
%     if to_contour
%         ftitle = ['E_' num2str(i) ' Contour'];
%         figure, contour(strain(:,:,1)), axis off, title(ftitle), hold on;
%         q = quiver(pts(:,2),pts(:,1),s_vec(:,2,i),s_vec(:,1,i), 'Color', 'black','AutoScaleFactor',scale,'MaxHeadSize',1);
%         hold off
%     end
% end
