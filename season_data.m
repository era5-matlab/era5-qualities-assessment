
%% Segmented by quarter
function [month_data, error_bars ,time_day ,ci_lower, ci_upper] = season_data(nc_date, T)
month_data = [];
ci_lower   = [];
ci_upper   = [];
error_bars = [];
time_day   = [];
yr = [2020, 2021, 2022];
t_range = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
for i = 1:length(yr)
    for j = 1:length(t_range)
        target_time_start = datetime(yr(i), t_range(j), 1, 00, 00, 00);
        target_time_end = datetime(yr(i), t_range(j) + 1, 1, 00, 00, 00);
        day15 = datetime(yr(i), t_range(j), 15, 00, 00, 00);
 
        id_time = nc_date > target_time_start & nc_date < target_time_end;
        data = T(id_time, 1);

        % Compute the mean, standard deviation, and standard error of the mean (SEM)
        mean_val = mean(data, 'omitnan');
        std_val = std(data, 'omitnan');
        n = sum(id_time);  

        % Calculate the standard error of the mean (SEM)
        sem = std_val / sqrt(n);
        
        % Assuming a 95% confidence interval, the critical value is 1.96
        ci_margin = 1.96 * sem;

        % Calculate the confidence interval bounds
        ci_lower_val = mean_val - ci_margin;
        ci_upper_val = mean_val + ci_margin;

        % Store the results
        month_data = [month_data; mean_val];
        ci_lower = [ci_lower; ci_lower_val];
        ci_upper = [ci_upper; ci_upper_val];
        error_bars = [error_bars; sem]; 
        time_day = [time_day;day15];
    end
end
end


