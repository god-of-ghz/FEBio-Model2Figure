function [msg,run_times] = estimate_time(run_times,i,j,k,var1,var2,var3,to_use)
% helper function to compute estimated remaining time,
% works up to a triple nested loop

% first replace values we don't care about
var_name = {'i';'j';'k';'var1';'var2';'var3';};
n_var = size(var_name,1);
for ii = 1:n_var
    eval(['if isempty(' var_name{ii} ') ' var_name{ii} ' = 1, end'])
end

cTime = toc;
run_times = [run_times; cTime;];
if isempty(to_use)
    n_runs = var1*var2*var3;
else
    n_runs = sum(to_use,'all');
end
cur_runs = ((i-1)*var2*var3) + (j-1)*var3 + k;
remTime = mean(run_times)*(n_runs - cur_runs);
msg = ['This run took: ' num2str(cTime) ' seconds' 10 ...
	'Mean run time: ' num2str(mean(run_times)) ' seconds' 10 ...
	'Estimated time of completion: ' Clock2String(AddTime(clock,remTime)) 10 ...
	num2str(round(cur_runs/n_runs,4)*100) '% complete' 10 ...
	'--------------------------------------------------'];