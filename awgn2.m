function [new_data] = awgn2(old_data,noise_lvl,noise_type)
% helper function to quickly add white gaussian noise based on variance or standard deviation

%% SAFETY AND PREPARATION
% make sure its just a 2D array
%assert(size(size(old_data),2) == 2);
[a b c d e f] = size(old_data);
if size(size(old_data),2) > 4
    warning('The input data has more than 6 dimensions! Weird stuff may happen...');
end

% pick the amount of noise to add
if strcmp(noise_type,'var') || strcmp(noise_type,'variance')
    noise_lvl = sqrt(noise_lvl);
elseif strcmp(noise_type,'std') || strcmp(noise_type,'standard deviation') || strcmp(noise_type,'std dev') || strcmp(noise_type,'stddev')
    % do nothing
elseif strcmp(noise_type,'linear') || strcmp(noise_type,'dB')
    %disp('Linear or dB noise input, using awgn "measured" function...')
    new_data = awgn(old_data,noise_lvl,'measured',noise_type);
    return;
else
    error('That noise type is not supported!');
end

%% ADD NOISE
noise = randn(a,b,c,d,e,f).*noise_lvl;
new_data = old_data+noise;
return;