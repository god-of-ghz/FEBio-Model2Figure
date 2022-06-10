function [data,n_nodes] = FEA_ParseFebLine(ldata)
% helper function to parse through a line of element data from a .feb file

%% VERSION HISTORY
% CREATED 12/16/20 BY SS

%% SAFETY AND PREPARATION
if ~strcmp(ldata(end-6:end),'</elem>') || ~strcmp(ldata(1:12),'			<elem id=')
    error('Line is not formatted properly!');
end

%% PARSE THROUGH THE DATA
% example line:
% '			<elem id="9">  3936,  3532,  3650,  3107</elem>'
q_ind = find(ldata == '"');     % find the first two quote symbols (")
data(1) = str2num(ldata(q_ind(1)+1:q_ind(2)-1));

a_ind = find(ldata == '<');     % find the last '<' symbol

% use those two indices, the last " symbol and the last < symbol to isolate the data
data_temp = str2num(ldata(q_ind(2)+2:a_ind(end)-1));

n_nodes = size(data_temp,2);
data(2:n_nodes+1) = data_temp;

