function [x y] = SA_GradientAngleHelper(angle, mag)
% function to compute vectors from angle and magnitude

%% VERSION HISTORY
% CREATED 6/24/20 BY SS

%% SAFETY AND PREPARATION
if angle < -180 || angle > 180
    error('Angle exceeds expected range!')
end

%% COMPUTE VECTORS
x = mag*cos(angle);
y = mag*sin(angle);