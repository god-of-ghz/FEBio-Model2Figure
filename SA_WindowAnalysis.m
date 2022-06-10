function pointmap = SA_WindowAnalysis(image, mask, r)
% a function to compile all windows of size r for every pixel in an image
%% VERSION HISTORY
% CREATED 11/9/2019 BY SS

%% SAFETY AND PREPARATION
[x, y] = size(image);
pointmap = cell(x,y);

if isempty(image)
    error('Please input an image.');
end
if ~isempty(mask)
    if size(image) ~= size(mask)
        error('Image and mask MUST be the same size.');
    end
else

    mask = ones(x,y);   % use entire image
end
if isempty(r)   % if no r was provided, just use 1 (the pixel itself)
    r = 1;
elseif r < 0
    error('Window size r must be a positive number greater than or equal to 0');
end
if size(size(image),2) ~= 2
    error('Image MUST be a 2D matrix');
end


%% RUN THROUGH IMAGE, COMPILING THE RELEVANT PIXELS FOR CHOSEN FORM OF ANALYSIS
parfor i = 1:x
    for j = 1:y
        if mask(i,j)
            [imax, imin] = LimitHelper(x, 1, i, r);
            [jmax, jmin] = LimitHelper(y, 1, j, r);
            for ii = imin:imax
                for jj = jmin:jmax
                    if mask(ii,jj)
                        if Distance(i,j,ii,jj) <= r
                            pointmap(i,j) = {[pointmap{i,j}; image(ii,jj);]};
                        end
                    end
                end
            end
        end
    end
end
