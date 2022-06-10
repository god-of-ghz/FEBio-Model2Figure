function [II,JJ]=FindPoints(mask,npts)

% FindPoints.m
%  Author: Corey Neu
%  Date: 011507
%  Modified 8/5/19 by SS
%
%  Finds (npts x npts) specified points in a rectangular grid
%
% NOTE: would be more appropriate to enter the mask into this function
% instead of entering disps, where a displacement value may well be = 0

% ddX=disps(:,:,1);
% ddY=disps(:,:,2);
%figure,imagesc(ddY),colormap('gray'),axis('square');colorbar;

[I,J]=find(mask~=0);
minI=min(I);maxI=max(I);
minJ=min(J);maxJ=max(J);
Irng=maxI-minI;
Jrng=maxJ-minJ;

% Range of points to take from mask
% lwI=0.2;hgI=0.85;		%vertical - UCD 7T phantom
% lwJ=0.45;hgJ=0.7;		%horizontal - UCD 7T phantom

%lwI=0.15;hgI=0.85;		%vertical - DDC121110 9.4T phantom
%lwJ=0.15;hgJ=0.85;		%horizontal - DDC121110 9.4T phantom
lwI = 0.3; hgI = 0.7;   % vertical, SS, 8/5/19, Bruker RPI 7T
lwJ = 0.3; hgJ = 0.7;   % horizontal, SS, 8/5/19, Bruker RPI 7T


% lwJ=0.35;hgJ=0.65;		%horizontal - DDC121110 9.4T phantom; phase
% advanced sets only

% lwI=0.25;hgI=0.75;		%vertical - CPN071710 14T phantom
% lwJ=0.25;hgJ=0.75;		%horizontal - CPN071710 14T phantom

if nargin < 2 % default if number of points is not entered
	npts = 5;
end

Ivals=round((lwI*Irng)+minI:(hgI-lwI)*Irng/(npts-1):(hgI*Irng)+minI);
Jvals=round((lwJ*Jrng)+minJ:(hgJ-lwJ)*Jrng/(npts-1):(hgJ*Jrng)+minJ);
[II,JJ]=meshgrid(Ivals,Jvals);
pI=reshape(II,size(II,1)*size(II,2),1);
pJ=reshape(JJ,size(JJ,1)*size(JJ,2),1);
hold on, plot(pJ,pI,'rx'), hold off