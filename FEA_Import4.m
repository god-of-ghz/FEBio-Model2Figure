function [disp_data,dmsk,img_info] = FEA_Import4(ele_conn,ele_parts,ele_disp,node_coor,dim_raw,opt,im_size,n_slc,soi,scale,plane,parts)
% function to import nodal displacement data from PostView/FEBio

%% VERSION HISTORY
% CREATED 12/10/19 BY SS
% MODIFIED 5/21/20 BY SS - improved code flow
% MODIFIED 6/16/20 BY SS - fixed bugs with larger images, made function
% MODIFIED 9/14/20 BY SS - moved data reading outside of this function
% MODIFIED 12/18/20 BY SS - re-worked element and node data inputs
%                         - functionality for element sizes more than 4 nodes

%% VARIABLE DOCUMENTATION
% ele_conn - element connectivity, the index # of each node comprising an element
% ele_parts - element parts, the part # an element belongs to
% ele_disp - element displacements, the X Y Z displacement values of an element
% node_coor - nodal coordinates, the X Y Z position of each node
% dim_raw - the rectangular dimensions of the model
% opt - optimizer file, contains number of elements, number of nodes, etc
% im_size - size of the resulting images
% n_slc - number of slices
% scale - how much of the image should be the resulting displacement maps
% occupy (always centered)

%% INTERPOLATE DATA
disp('Interpolating data...')
%shift the nodal displacements into a positive 3D frame
[node_shift,dim_shift] = FEA_DataShift(node_coor,dim_raw);
% interpolate the nodal displacements into slices
[img_data,msk,~,slc_thick,px_size] = FEA_InterpolateSlices4(ele_conn,ele_parts,ele_disp,dim_shift,node_shift,opt,n_slc,soi,im_size,scale,plane,parts);

%% ORGANIZE INTO PROCESSABLE 2D MAPS
disp('Processing into 2D slices...')
disp_data = NaN(im_size,im_size,n_slc,3);
dmsk = false(im_size,im_size,n_slc,opt.n_prt);
[x,y,z,~] = size(img_data);

% default settings
if scale <= 1
    for i = 1:x
        for j = 1:y
            for k = 1:z
                % insert the data in the rectangular center of the image
                for d = 1:3
                    disp_data(round((im_size/2-x/2))+i,round((im_size/2-y/2))+j,k,d) = img_data(i,j,k,d);
                end
                for p = 1:opt.n_prt
                    dmsk(round((im_size/2-x/2))+i,round((im_size/2-y/2))+j,k,p) = msk(i,j,k,p);
                end
            end
        end
    end
elseif scale > 1
    % HARD CODED! centers the zoomed in image on this point
    cntr_x = round(x/2);        % horizontal center (unsure about left/right orientation)
    cntr_y = round(y/4);        % vertical center (0 is the bottom, y = image top)
    
    % to avoid having the image touch the edges
    px_size = px_size*0.90;
    im_scale_min = round(0.05*im_size);
    im_scale_max = round(0.95*im_size);
    im_scale = im_scale_max - im_scale_min;
    
    % insert the data in the rectangular center of the image
    for i = im_scale_min:im_scale_max
        for j = im_scale_min:im_scale_max
            x_ind = (cntr_x-im_scale/2)+i;
            y_ind = (cntr_y-im_scale/2)+j;
            for k = 1:n_slc
                for d = 1:3 
                    if x_ind > 0 && x_ind <= x && y_ind > 0 && y_ind <= y
                        disp_data(i,j,k,d) = img_data(x_ind,y_ind,k,d);
                    else
                        disp_data(i,j,k,d) = NaN;
                    end
                end
                for p = 1:opt.n_prt
                    if x_ind > 0 && x_ind <= x && y_ind > 0 && y_ind <= y
                        dmsk(i,j,k,p) = msk(x_ind,y_ind,k,p);
                    else
                        dmsk(i,j,k,p) = false;
                    end
                end
            end
        end
    end
end

%% FIX DIMENSIONS
% data requires reorganizing to look right sometimes, hard coded for now
if strcmp(plane,'ZYX')
    disp_data = permute(disp_data,[2 1 3 4]);
    dmsk = permute(dmsk,[2 1 3 4]);
    
    disp_data = flip(disp_data,2);
    dmsk = flip(dmsk,2);
end

% the data are always upside down for some reason...
disp_data = flip(disp_data,1);
dmsk = flip(dmsk,1);

%% REMOVE NAN
disp_data = clean_nan(disp_data);

%% OUTPUT STATS
msg_slc = ['Slice thickness: ' num2str(slc_thick) 'mm'];
msg_px = ['Pixel size: ' num2str(px_size(1)) ' by ' num2str(px_size(2)) 'mm'];
msg_prt = [num2str(opt.n_prt) ' discrete part(s) detected!'];
disp(msg_slc)
disp(msg_px)
disp(msg_prt)
img_info.px_size = px_size;
img_info.n_slc = n_slc;
img_info.slc_thick = slc_thick;
img_info.n_prt = opt.n_prt;