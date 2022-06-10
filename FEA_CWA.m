function [avg, cw_avg] = FEA_CWA(vx_corners,ele_coor,ele_disp)
% function to compute the centroid-weighted average and normal average of a voxel's displacements, based on the elements touching it

%% VERSION HISTORY
% CREATED 1/7/21 BY SS

%% SAFETY & PREPARATION
cw_avg = zeros(1,3);
avg = zeros(1,3);

assert(size(ele_coor,1) == size(ele_disp,1))
n_ele = size(ele_coor,1);

%% COMPUTE NORMAL MEANS
for i = 1:3
    avg = mean(ele_disp,1);
end

%% COMPUTE CENTROIDS
cen_vx = mean(vx_corners,1);
cen_ele = squeeze(mean(ele_coor,2));

%% COMPUTE WEIGHTING FACTORS
base_fac = 1/n_ele; % base weighting factor per element

d = zeros(n_ele,1); 
for i = 1:n_ele
    d(i) = Distance(cen_vx,cen_ele(i));
end
d_fac = (d-mean(d))./mean(d);   % distance-based % weighting factor
cw_fac = base_fac + d_fac*-1;   % centroid-weighted factor

%% COMPUTE CENTROID-WEIGHTED AVERAGES
cw_avg = sum(ele_disp.*cw_fac,1);
%disp(cw_avg)
%disp(avg)