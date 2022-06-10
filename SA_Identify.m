function [def_pts] = SA_Identify(lmap, msk, n_std)
% a function to identify outlier points as defects

%% VERSION HISTORY
% CREATED 12/11/19 BY SS

%% SAFETY AND PREPARATION
% IGNORING SAFETY FOR NOW BECAUSE I'M IN A HURRY
vals = [];
ind = [];
def_pts = [];
[x, y] = size(lmap);
lmap = clean_nan(lmap);

%% MAKE DISTRIBUTION OF ALL POINTS AND THEIR VALUES
for i = 1:x
    for j = 1:y
        if msk(i,j)
            vals = [vals; lmap(i,j)];
            ind = [ind; [i j]];
        end
    end
end

%% COMPUTE THE THRESHOLD (# OF STANDARD DEVIATIONS)
ptmean = mean(vals);
ptstd = std(vals);
upper = ptmean + n_std*ptstd;
lower = ptmean - n_std*ptstd;

for i = 1:max(size(vals))
    if vals(i) > upper || vals(i) < lower
        def_pts = [def_pts; ind(i,:)];
    end
end