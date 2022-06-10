function [msk_new, msk_roi] = FEA_SeparateMasks(msk_old, tier, combine, cycles)
% helper function to separate overlapping masks, in a priority system.
% if two parts have overlapping pixels- those pixels go to the higher 'tier' part
% also creates another set of masks to indicate a roi to analyze strains

%% VERSION HISTORY
% CREATED 12/21/20

%% SAFETY AND PREPARATION
[x,y,z,a] = size(msk_old);
msk_new = false(x,y,z,a);
n_roi = size(combine,2);
msk_roi = false(x,y,z,n_roi);
%assert(max(size(tier)) == n_prt);

% tier list is expected to be a row or col of numbers, ex
% [5 2 3 1 4];
% the tier list does not have to include every part (like if we want to ignore or essentially delete one)

%% GO THROUGH EACH VOXEL, ASSIGNING IT TO THE HIGHEST PRIORITY PART
for i = 1:x
    for j = 1:y
        for k = 1:z
            % go through the tier
            for p = tier
                if msk_old(i,j,k,p)         % if this voxel is in this part's mask...
                    msk_new(i,j,k,p) = 1;   % give it to this part
                    break;                  % and skip the rest of the parts
                end
            end
            % repeat for all the voxels
        end
    end
end

%% REASSIGN HANGING PIXELS FROM THE MASKS
% use 2 cycles on each mask to reassign pixels that have fewer than 3 neighbors
%cycles = 5;
thresh = 3;
for c = 1:cycles
    for i = 1:x
        for j = 1:y
            for k = 1:z         % check only the slices of int erest
                for p = tier    % check only the parts we care about
                    % for each point of a mask
                    if msk_new(i,j,k,p)
                        % check the neighboring 8 pixels
                        i_min = max([i-1 1]);
                        i_max = min([i+1 x]);
                        j_min = max([j-1 1]);
                        j_max = min([j+1 y]);
                        count = 0;
                        for ii = i_min:i_max
                            if count > thresh
                                break;
                            end
                            for jj = j_min:j_max
                                % don't count the pixel itself
                                if ii == i && jj == j
                                    continue;
                                end
                                % if a neighboring pixel is valid
                                if msk_new(ii,jj,k,p)
                                    % increment the count
                                    count = count+1;
                                    % if we have at least 3 neighbors, stop
                                    % checking this pixel, cause its
                                    % probably fine
                                    if count > thresh
                                        break;
                                    end
                                % if the last neighbor we're checking isn't valid
                                % and we've gotten this far, it means we
                                % haven't found enough neighbors, and this
                                % pixel has to be reassigned
                                elseif ~msk_new(ii,jj,k,p) && ii == i_max && jj == j_max
                                    
                                    % check the other parts
                                    for pp = tier
                                        % dont reassign it to the same part lol
                                        if pp == p
                                            continue;
                                        end
                                        % check for neighbors in the other parts
                                        count2 = 0;
                                        for ii2 = i_min:i_max
                                            for jj2 = j_min:j_max
                                                if msk_new(ii2,jj2,k,pp)
                                                    count2 = count2+1;
                                                end
                                            end
                                        end
                                        % if another part seems like a
                                        % better fit for this pixel...
                                        if count2 > thresh-1
                                            % remove the pixel from the part
                                            msk_new(i,j,k,p) = 0;
                                            % to the new one
                                            msk_new(i,j,k,pp) = 1;
                                            break;
                                        end
                                    end 
                                    %msk_new(i,j,k,p) = 0;   % change its value to 0
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

%% MERGE CERTAIN MASKS TO CREATE ROI FOR ANALYSIS
for i = 1:n_roi
    parts2use = combine{i};
    msk_roi(:,:,:,i) = sum(msk_new(:,:,:,parts2use),4);
end
