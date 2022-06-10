function [msk_border] = FEA_BorderMask(msk_old, border_parts, border_grow, cycles)
% helper function to quickly generate a mask that comprises the *border* between touching masks
% this function works most efficiently when overlaps have been removed, but
% it works okay even with laptops

%% VERSION HISTORY
% CREATED 12/22/20 BY SS
% MODIFIED 2/7/21 BY SS
%   - allows for one-sided masks, can ID a border between two parts, but
%   only grow toward one of them

%% SAFETY & PREPARATION
[x y z a] = size(msk_old);
msk_border = zeros(x,y,z);

% a border is expected in the following format:
% [3 1; 3 2; 3 4];
% this means we have 3 total border regions to merge- a border between
% parts 3 & 1, between parts 3 & 2, and 3 & 4.
n_bord = size(border_parts,1);
assert(size(border_parts,1) == size(border_grow,1));
border_px= [];       % a list of the pixels belonging to the border

%% IDENTIFY THE BORDER REGIONS
for i = 1:x
    for j = 1:y
        for k = 1:z
            for b = 1:n_bord
                % establish which two parts we are trying to find the border for 
                prt1 = border_parts(b,1);
                prt2 = border_parts(b,2);
                if msk_old(i,j,k,prt1) % if the current position is valid for part #1...
                    % we need check the 8 surrounding pixels, establish their range
                    i_min = max([i-1 1]);
                    i_max = min([i+1 x]);
                    j_min = max([j-1 1]);
                    j_max = min([j+1 y]);
                    % check the surrounding 8 pixels
                    found = 0;
                    for ii = i_min:i_max
                        if found
                            break;
                        end
                        for jj = j_min:j_max
                            % skip the pixel itself
                            if ii == i && jj == j
                                continue;
                            end
                            % if an adjacent pixel belongs to part 2...
                            if msk_old(ii,jj,k,prt2)
                                % mark that pixel as being a border pixel
                                msk_border(i,j,k) = 1;
                                border_px = [border_px; [i j k]];
                                found = 1;
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end

%% EXPAND THE BORDER
% 'cycles' is the number of times to expand the thickness of the border. 
% 0 cycles means the border will be only 1 pixel thick, and not expanded at all.
% Here, we iteratively expand the border in all directions- so 1 cycle will add 2
% pixels to the thickness
% the resulting thickness is roughly (1+cycles*2) = pixels wide

for c = 1:cycles
    % grab the # of pixels to examine
    n_pts = size(border_px,1);
    % output progress (Mainly for debugging)
%     disp(['Cycle # ' num2str(c)]);
%     disp(['Examining '  num2str(n_pts) ' pixels...']);
    % remove the used pixels, for performance
    to_remove = [];
    border_px_new = border_px;
    % for each border point...
    for p = 1:n_pts
        % check the adjacent 8 pixels to see if they are in bordering parts
        temp = border_px(p,:);
        i = temp(1);
        j = temp(2);
        k = temp(3);
        %[i, j, k] = border_px(p,:);
        i_min = max([i-1 1]);
        i_max = min([i+1 x]);
        j_min = max([j-1 1]);
        j_max = min([j+1 y]);
        for ii = i_min:i_max
            for jj = j_min:j_max
                found = 0;
                % skip the pixel itself
                if ii == i && jj == j
                    continue;
                end
                % check all the borders
                for b = 1:n_bord
                    if found
                        break;
                    end
                    % check both parts
                    for prt = border_grow{b}%[border_parts(b,1) border_parts(b,2)]
                        % if a touching pixel is found belonging to a part...
                        if msk_old(ii,jj,k,prt)
                            % and its NOT already part of the border mask...
                            if ~msk_border(ii,jj,k)
                                % add it to the border mask
                                msk_border(ii,jj,k) = 1;
                                % add it to the list of new border pixels
                                border_px_new = [border_px_new; [ii jj k]];
                                % if we find this point, no sense in adding it more than once
                                found = 1;
                                break;
                            end
                        end
                    end
                end
            end
        end
        % remove the border pixel we just examined, since we no longer need it
        to_remove = [to_remove, p];
    end
    % remove those pixels
    border_px_new(to_remove,:) = [];
    % assign the next set of pixels to examine
    border_px = border_px_new;
end

% output result (mainly for debugging)
%figure, imagesc(msk_border), axis equal off
