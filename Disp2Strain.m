%function [ostrain]=Disp2Strain(dX,dY,dZ,ImageRes,II,JJ)
%function [ostrain]=Disp2Strain(dX,dY,IM,matrix,ImageRes,II,JJ)
% function [ostrain strainM]=Disp2Strain(dX,dY,mask,ImageRes,II,JJ)
function [ostrain, strainM, F, pI, pJ]=Disp2Strain(dX,dY,dZ,mask,ImageRes,II,JJ)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	Disp2Strain.m
%	Author: Corey Neu
%	Date: 011507
%	Modified: Deva Chan
%
%	Computes Strain at specified points
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% VERSION HISTORY
% CREATED 11/5/07 BY DDC
% MODIFIED 6/30/20 BY SS
%   - returns deformation tensor F as well
% MODIFIED 7/20/30 BY SS
%   - parallelized strain and deformation tensor calculation

spac=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% List Points to Analyze
pI=reshape(II,size(II,1)*size(II,2),1);
pJ=reshape(JJ,size(JJ,1)*size(JJ,2),1);

%figure,imagesc(dX),colormap('gray'),axis('square');colorbar;
%hold on;plot(pJ,pI,'yx');hold off;
%figure,imagesc(dY),colormap('gray'),axis('square');colorbar;
%hold on;plot(pJ,pI,'yx');hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Find Strain at the Points
ostrain=[];
oF = [];

[dflocs, udlocs] = CalcUndefLocs(mask,dX,dY,dZ,ImageRes);

%for mm=1:size(pI,1)
parfor mm=1:size(pI,1)

	loc = [pI(mm) pJ(mm) 0];	% only if calculating strains from a single slice

	[points, dpoints] = DefinePointCluster(loc,mask,dflocs,udlocs,ImageRes);
% 	[points,dpoints] = DefineDefPointCluster(loc,mask,dX,dY,ImageRes);

    pts = [];
	pts(2,:,:)=reshape(points,1,27,3);
	pts(1,:,:)=reshape(dpoints,1,27,3);
    %assignin('base','pts',pts);

% 	[tempstrain,temppstrain] = ExtractF3(pts,26,0,2,1,1); %code courtesy of M. Geers - Lagragian E
	[tempstrain,~,tempF] = ExtractF3(pts,26,0,2,1,1); %code courtesy of M. Geers - Lagragian E
%     to_disp = ['single iteration of F'];
%     disp(to_disp)
%     disp(size(tempF));
%         
%     to_disp = ['single iteration of strain'];
%     disp(to_disp)
%     disp(size(tempstrain));
% 	[tempstrain,~] = ExtractF3(pts,26,0,1,1,3); %code courtesy of M. Geers - linear E

    ostrain=[ostrain; tempstrain];
    oF = [oF; tempF];
end
%assignin('base','full_strain',ostrain);
%assignin('base','full_F',F);


strainM = zeros(size(mask,1),size(mask,2),6);
F = zeros(size(mask,1),size(mask,2),3,3);
%metric = zeros(size(mask,1),size(mask,2));
%operator = 'jac';

for qq = 1:size(pI,1)
    for nn = 1:6
		strainM(pI(qq),pJ(qq),nn) = ostrain(qq,nn);
    end
    
    ind = 1+(qq-1)*3;   % this index is needed to compute where in the list of points we are
    F(pI(qq),pJ(qq),:,:) = oF(ind:ind+2,:);   % fix the shape of the deformation gradient tensor
    %metric(pI(qq),pJ(qq)) = MatrixOperator(oF(ind:ind+2,:),{'dev';'inv3'});
    %metric(pI(qq),pJ(qq)) = MatrixOperator(MatrixOperator(oF(ind:ind+2,:),'dev'),'inv3');
% 	strainM(:,:,nn) = strainM(:,:,nn)';
end

%assignin('base','metric',metric);



