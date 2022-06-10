function [strainGL, strainP, F] = ProcessDisplacements(dX,dY,dZ,msk,px_size,smooth,use_all,n_pts,msg)
% function to compute strains and deformation tensor F directly from imported displacements

%% VERSION HISTORY
% CREATED 7/6/20 BY SS

%% SAFETY AND PREPARATION
if isempty(msk)
    % generate mask from dX
end

%% SMOOTH AS NEEDED

if smooth > 0
    if msg
        disp('Smoothing data...');
    end
    sX = ROIfilter([],dX,msk);
    sY = ROIfilter([],dY,msk);
    %sZ = ROIfilter([],dY,msk);
    for i = 1:smooth-1
        sX = ROIfilter([],sX,msk);
        sY = ROIfilter([],sY,msk);
        %sZ = ROIfilter([],dZ,msk);
    end
else
    if msg
        disp('Using unsmoothed data...');
    end
    sX = dX;
    sY = dY;
    %sZ = dZ;
end

%% FIND POINTS FOR STRAIN ANALYSIS
if msg
	disp('Finding points for analysis...');
end
if use_all
    [II,JJ] = ROIPoints(msk);               % just get them all
else
    [II,JJ] = FindPoints(msk,n_pts);
end

% resize points for deformation tensor
pI=reshape(II,size(II,1)*size(II,2),1);
pJ=reshape(JJ,size(JJ,1)*size(JJ,2),1);

%% COMPUTE STRAINS AND DEFORMATION GRADIENT
if msg
	disp('Computing strains...')
end
[~, strainGL, F, ~, ~] = Disp2Strain(sX,sY,[],msk,px_size, II, JJ);

if msg
	disp('Computing principal strains...')
end
strainP = Strain2PrinStrain(strainGL,msk);