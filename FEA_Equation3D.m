function [constants] = FEA_Equation3D(pt1, pt2)
% helper function to quickly compute the constants needed for plotting

%% VERSION HISTORY
% CREATED 7/12/20 BY SS

%% PERFORM CALCULATION
constants = zeros(1,3);
for i = 1:3
    constants(i) = pt2(i) - pt1(i);
end