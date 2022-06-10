function [new_map, new_msk] = SA_GradientHelper2(map,msk_roi,cycles,varargin)
% a helper function to remove the edges of a map and its mask for analysis,
% based on a certain number of points
%% SAFETY AND PREPARATION
[x1 y1 z1] = size(map);
[x2 y2 z2] = size(msk_roi);

% make sure the maps are the same size
if ~isempty(msk_roi)
    assert(x1 == x2);
    assert(y1 == y2);
    assert(z1 == z2);
end

if nargin >= 4
    for i = 1:2:nargin-4
        if strcmp(varargin{i},'Method')
            try
                method = varargin{i+1};
            catch msg
                warning('Arguments must be passed in pairs! Defaulting to fast approximation...');
                method = 'fast';
            end
        else
            error(['There is no ' varargin{i} ' functionality here. Try "Method" instead.']);
        end
    end
else
    method = 'fast';
end

%% --- AN APPROXIMATION, BUT MUCH FASTER ---
%% GENERATE A FULL MASK, USED FOR EDGE DETECTION
if strcmp(method,'fast') || strcmp(method,'roberts')
    new_map = map;
    new_msk = msk_roi;
    msk_full = zeros(x1,y1,z1);
    for k = 1:z1
        msk_full(:,:,k) = MakeMsk(new_map(:,:,k),NaN);
        msk_full(:,:,k) = NaN2msk(msk_full(:,:,k));
    end

    for c = 1:cycles
        %disp(c)
        %disp('finding edges...')
        edge_msk = zeros(x1,y1,z1);
        for k = 1:z1
            edge_msk(:,:,k) = edge(msk_full(:,:,k),'roberts');
        end

        % grab those points of the edges
        %disp('grabbing edge points...')
        ind = find(edge_msk == 1);

        %disp('eroding...')
        % erode them from the map, the full mask, roi mask
        new_map(ind) = NaN;
        msk_full(ind) = 0;
        new_msk(ind) = 0;
    end
elseif strcmp(method,'slow') || strcmp(method,'perfect')

    %%  --- PERFECT SOLUTION, BUT INEFFICIENT, REPLACED WITH ABOVE CODE ---
    %% ERODE THE EDGE PIXELS A CERTAIN NUMBER OF TIMES
    new_map = map;
    new_msk = msk_roi;

    for c = 1:cycles
        border_px = []; % a list of the pixels belonging to the border

        % find all the border pixels
        parfor i = 1:x1
            for j = 1:y1
                for k = 1:z1
                    % for each pixel...
                    i_min = max([i-1 1]);
                    i_max = min([i+1 x1]);
                    j_min = max([j-1 1]);
                    j_max = min([j+1 y1]);
                    found = false;
                    % ...check all the neighbors
                    for ii = i_min:i_max
                        if found
                            break
                        end
                        for jj = j_min:j_max
                            % skipping the pixel itself
                            if ii == i && jj == j
                                continue;
                            end
                            % if a neighbor is NaN...
                            if isnan(new_map(ii,jj,k))
                                % this is a border pixel, add it to the list
                                border_px = [border_px; [i j k];];
                                found = true;
                                break;
                            end
                        end
                    end
                end
            end
        end

        % for each border pixel
        n_px = size(border_px,1);
        for p = 1:n_px
            temp = border_px(p,:);
            i = temp(1);
            j = temp(2);
            k = temp(3);

            % erode it from the map
            new_map(i,j,k) = NaN;

            % and if it was a valid pixel on the mask, erode it there too
            if new_msk(i,j,k)
                new_msk(i,j,k) = 0;
            end
        end
    end
else
    error(['Method: ' method ' is currently unsupported! Try "fast" or "slow" isntead.']);
end