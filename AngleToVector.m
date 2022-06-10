function [x, y] = AngleToVector(degrees, rot)
% takes an angle in radians and creates a unit vector with components x and y with a desired rotational offset to compensate for matlab's stupidity
%% VERSION HISTORY
% CREATED 4/9/20 BY SS

% RECOMMENDED ROTATIONAL OFFSET: 0 or pi/2 (check by inspection)

%% COMPUTE CALCULATION
x = 1*cos(degrees+rot);
y = 1*sin(degrees+rot);