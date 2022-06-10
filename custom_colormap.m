function [C] = custom_colormap(rgb1, rgb2, n_step)
% a custom colormap to create colors from 2 rgb values;

C = [rgb1;rgb2]./255;
C_excel = rgb2hsv(C);
C_excel_interp = interp1([0 n_step], C_excel(:, 1), 1:n_step);
C_excel = [C_excel_interp(:), repmat(C_excel(1,2:3), n_step, 1)];
C = hsv2rgb(C_excel);