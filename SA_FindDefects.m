function def_map = SA_FindDefects(strainP, strainD, msk, lvl)
% a function to map out all the points corresponding to 'defects' in a map

%% VERSION CONTROL
% CREATED 12/4/19 BY SS

%% SAFETY AND PREPARATION
% skipped safety for now because I code hard, fast, and close to the metal
[x y] = size(strainP);
def_map = zeros(x,y);

%% PERFORM SUBTRACTION & THRESHOLDING
temp = abs(strainP-strainD);
def_map(find(temp >= lvl)) = 1;
