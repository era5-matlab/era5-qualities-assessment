

%% Outlier rejection
function [x,outliers] = outer_move_medium(x,window_size,sigma)
x(isnan(x)) = mean(x,'omitnan');
moving_avg = movmean(x, window_size);

% Difference between calculated and sliding scale
diff = abs(x - moving_avg);

% Set the threshold to twice the standard deviation of the difference
threshold = sigma * std(diff); 

% Mark the location of the anomaly
outliers = diff > threshold;  
x(outliers) = NaN;
end

