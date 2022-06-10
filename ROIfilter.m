function jm = ROIfilter(filter_type,image_mag,image_roi)
% ROIFILTER(H,I,BW) Filter region of interest.
%	J = ROIFILTER(H,I,BW) filters the data in I with a 2-D filter H.  BW is
%	binary image that is the same size as I and defines the region of
%	interest for filtering.  ROIFILT returns filtered values for all points
%	where BW is equal to 1, and unfiltered values for all points where BW
%	is equal to 0.  ROIFILT is different from the Matlab native function
%	ROIFILT2 in that it accounts for the region of interests's border
%	pixels by modifying the weight of the filter to ignore pixel values
%	outside of the region of interest.  This difference is key when the
%	values of pixels outside the region of interest in I are also 0.

%% VERSION HISTORY
% CREATED (A LONG, LONG TIME AGO... IN A UNIVERSITY FAR, FAR AWAY) BY DDC
% MODIFIED 11/29/19 BY SS
%   - CLARIFIED FILTER OPTIONS

% filter must be a kernel of some specified size and shape
% default is Gaussian filter: 5x5 kernel, stdev = 0.5*2 = 1
h = filter_type;
im = image_mag;
bw = image_roi;

%% Initialize variables and check inputs
if isempty(h)
    h = fspecial('gaussian',5,0.5);         % Gaussian filter; 5x5 kernel; stdev = 0.5*2 = 1
end
if size(h,1) ~= size(h,2)
	disp('Filter must be a square matrix')
	return
end
if mod(size(h,1),2) == 0
	disp('Filter must be a 2N*1 size square')
	return
else
	r = floor(size(h,1)/2);
	c = r+1;
end
if sum(sum(bw([1:r,end-r+1:end],:))) || sum(sum(bw(:,[1:r,end-r+1:end])))
	disp('Region of interest is too close to the border')
	%return
end
jm = zeros(size(im));
[vs hs] = size(im);
im = im.*bw;

%% Compute filtered image
for vv = 1:vs
	for hh = 1:hs
		if bw(vv,hh)
			wt = 0;
			sm = 0;
			for ii = -r:r
				for jj = -r:r
					sm = sm + im(vv+ii,hh+jj)*h(c+ii,c+jj);
					wt = wt + bw(vv+ii,hh+jj)*h(c+ii,c+jj);
				end
			end
			jm(vv,hh)=sm/wt;
		end
	end
end

