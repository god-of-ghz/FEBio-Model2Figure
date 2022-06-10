function [PrinStrain, PrinAngle] = Strain2PrinStrain(strain, mask)
% a function to quickly compute principal strains
% as of 2/21/2019, hardcoded to compute in-plane strains only for X and Y

% for reference
%       1 = Exx
%       2 = Eyy
%       3 = Ezz
%       4 = Exy
%       5 = Exz
%       6 = Eyz
[x, y, ~, frames] = size(strain);

% 1 = max, 2 = min, 3 = max shear
PrinStrain = zeros(x, y, 3, frames);
PrinAngle = zeros(x, y, 3, frames);

% max/min principal strain
for i = 1:x
    for j = 1:y
        for m = 1:frames
            if mask(i,j,m)
                Exx = strain(i,j,1,m);
                Eyy = strain(i,j,2,m);
                Exy = strain(i,j,4,m);
                A = (Exx + Eyy)/2;
                B = ((Exx - Eyy)/2)^2;
                C = (Exy)^2;
                %max
                PrinStrain(i,j,1,m) = A + sqrt(B + C);
                %min
                PrinStrain(i,j,2,m) = A - sqrt(B + C);
                %max shear
                PrinStrain(i,j,3,m) = sqrt(B + C)/2;
                %PrinStrain(i,j,3,m) = PrinStrain(i,j,1,m) - PrinStrain(i,j,2,m);
                
                % E1 angle (in degrees)
                E1_angle = atan((2*Exy)/(Exx - Eyy))/2;
                PrinAngle(i,j,1,m) = E1_angle;
                % E2 angle
                PrinAngle(i,j,2,m) = E1_angle + pi/2;
                % max shear angle
                shear_angle = atan(-(Exx - Eyy/(2*Exy)))/2;
                PrinAngle(i,j,3,m) = shear_angle;
            end
        end
    end
end
