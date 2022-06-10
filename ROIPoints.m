function [pI,pJ] = ROIPoints(mask,lnoi,direc)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%	ROIPoints.m
%	Author: Deva Chan
%	Date: 062507
%
%	Defines region of interest for strains to be computed
%	ROIPoints(disp,mask) if a full ROI is desired
%	ROIPoints(disp,mask,lnoi) is a line of interest is to be defined
%	ROIPoints(disp,mask,lnoi,direc) is a line of interest in the vertical
%	(0) or horizontal (1) direction
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% all = 1;	% entire region of interest

vert = 1;	% vertical line - default
if nargin > 2
	if direc == 1
		vert = 0;	% horizontal line
	end
end

if nargin > 1
	all = 0;
	if vert
		fprintf(1,'\tVertical Line of Interest Along Pixel %.0f\r',lnoi);
	else
		fprintf(1,'\tHorizontal Line of Interest Along Pixel %.0f\r',lnoi);
	end
else
	all = 1;
end


if all
	[II,JJ]=find(mask~=0);	%I is y (horizontal), J is x (vertical)
	pI=II;pJ=JJ;
elseif vert		% vertical line of interest
	% Using a predefined vertical line of interest
	Jmm = lnoi;					%defines horizontal coordinates of vertical line
	I = find(mask(:,Jmm)~=0);	%finds indices of ROI pixels in vertical line
	minI=min(I);
	maxI=max(I);
	[II,JJ] = meshgrid(minI:maxI,Jmm);
	pI=reshape(II,size(II,1)*size(II,2),1);
	pJ=reshape(JJ,size(JJ,1)*size(JJ,2),1);
else			% horizontal line of interest
	% Using a predefined line of interest
	Imm = lnoi;					%defines vertical coordinates of horizontal line
	J = find(mask(Imm,:)~=0);	%finds indices of ROI pixels in horizontal line
	minJ=min(J);
	maxJ=max(J);
	[II,JJ] = meshgrid(Imm,minJ:maxJ);
	pI=reshape(II,size(II,1)*size(II,2),1);
	pJ=reshape(JJ,size(JJ,1)*size(JJ,2),1);
end

if ~all
	figure,imagesc(mask),colormap('gray'),axis('square');title('ROIPoints'),colorbar;	
	hold on; plot(pJ,pI,'rx'); hold off;
end
