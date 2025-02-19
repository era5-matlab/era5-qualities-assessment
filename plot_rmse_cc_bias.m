
% Load the processed accuracy evaluation indicator data mat file (cal_rmse_cc_bias.m)
% Load the date information of ERA5 data, you can save the time manually in the ERA5 data processing result


clc; clear; close all


load F:\气象数据\metoffice\processed_global_met_data_nc\RMSE_CC_BIAS_SLOP_Struct_2020_2021_2022.mat
load F:\气象数据\metoffice\processed_global_met_data_nc\NC_date_2020_2021_2022.mat
save_path = 'F:\气象数据\metoffice\plot\指标figure';


% Create a new structure to hold the results of the merge
comb_data = struct();
fields = {'results_T', 'results_P', 'results_e', 'results_rh', 'results_q'};  

for i = 1:length(fields)
    field = fields{i};

    % Use the cat function to merge the data of the corresponding fields for each year
    comb_data.(field) = cat(1, RMSE_CC_BIAS_SLOP_Struct_2020.(field), ...
                                       RMSE_CC_BIAS_SLOP_Struct_2021.(field), ...
                                       RMSE_CC_BIAS_SLOP_Struct_2022.(field));
end

% -------------------------
% Manually select the evaluation metrics to be mapped
% rmse: 1 cc: 2 bias: 3 slope: 4 stnums: 5

column = 3;

% -------------------------

if column == 1
    disp('RMSE')
    % ----------------------- RMSE ----------------------------------
    % temp
    [T, ~] = outer_move_medium(comb_data.results_T(:, column), 50, 3);
    [month_data_T, error_bars_T, time_day_T, ~, ~] = season_data(nc_date, T);
    plot_rmse_cc_bias_bar(nc_date, T, time_day_T, month_data_T, error_bars_T, 5, 'Temperature', 'RMSE','(℃)', save_path);
    
    % pressure
    [P, ~] = outer_move_medium(comb_data.results_P(:, column), 50, 3);
    [month_data_P, error_bars_P, time_day_P, ~, ~] = season_data(nc_date, P);
    plot_rmse_cc_bias_bar(nc_date, P, time_day_P, month_data_P, error_bars_P, 5, 'Pressure', 'RMSE','(hPa)', save_path);
    
    % relative humidity
    [R, ~] = outer_move_medium(comb_data.results_rh(:, column), 50, 3);
    [month_data_R, error_bars_R, time_day_R, ~, ~] = season_data(nc_date, R);
    plot_rmse_cc_bias_bar(nc_date, R, time_day_R, month_data_R, error_bars_R, 5, 'RelativeHumidity', 'RMSE','(%rh)', save_path);
   
    % specific humidity
    [Q, ~] = outer_move_medium(comb_data.results_q(:, column), 50, 3);
    [month_data_Q, error_bars_Q, time_day_Q, ~, ~] = season_data(nc_date, Q);
    plot_rmse_cc_bias_bar(nc_date, Q, time_day_Q, month_data_Q, error_bars_Q, 5, 'SpecificHumidity', 'RMSE','(g/kg)', save_path);


elseif column == 2
    disp('CC ')
    % ----------------------- CC ----------------------------------
    % temp
    [T, ~] = outer_move_medium(comb_data.results_T(:, column), 50, 3);
    [month_data_T, error_bars_T, time_day_T, ~, ~] = season_data(nc_date, T);
    plot_rmse_cc_bias_bar(nc_date, T*100, time_day_T, month_data_T*100, error_bars_T*100, 5, 'Temperature', 'CC','(%)', save_path);
    
    % pressure
    [P, ~] = outer_move_medium(comb_data.results_P(:, column), 50, 2.5);
    [month_data_P, error_bars_P, time_day_P, ~, ~] = season_data(nc_date, P);
    plot_rmse_cc_bias_bar(nc_date, P*100, time_day_P, month_data_P*100, error_bars_P*100, 5, 'Pressure', 'CC','(%)', save_path);
    
    % relative humidity
    [R, ~] = outer_move_medium(comb_data.results_rh(:, column), 50, 3);
    [month_data_R, error_bars_R, time_day_R, ~, ~] = season_data(nc_date, R);
    plot_rmse_cc_bias_bar(nc_date, R*100, time_day_R, month_data_R*100, error_bars_R*100, 5, 'RelativeHumidity', 'CC','(%)', save_path);
    
    % specific humidity
    [Q, ~] = outer_move_medium(comb_data.results_q(:, column), 50, 3);
    [month_data_Q, error_bars_Q, time_day_Q, ~, ~] = season_data(nc_date, Q);
    plot_rmse_cc_bias_bar(nc_date, Q*100, time_day_Q, month_data_Q*100, error_bars_Q*100, 5, 'SpecificHumidity', 'CC','(%)', save_path);


elseif column == 3
    disp('BIAS')
    % ----------------------- BIAS ----------------------------------
    % temp
    [T, ~] = outer_move_medium(comb_data.results_T(:, column), 50, 3);
    [month_data_T, error_bars_T, time_day_T, ~, ~] = season_data(nc_date, T);
    plot_rmse_cc_bias_bar(nc_date, T, time_day_T, month_data_T, error_bars_T, 5, 'Temperature', 'Bias','(℃)', save_path);
    
    % pressure
    [P, outers_bias_P] = outer_move_medium(comb_data.results_P(:, column), 90, 1.2);
    [month_data_P, error_bars_P, time_day_P, ~, ~] = season_data(nc_date, P);
    plot_rmse_cc_bias_bar(nc_date, P, time_day_P, month_data_P, error_bars_P, 5, 'Pressure', 'Bias','(hPa)', save_path);
    
    % relative humidity
    [R, ~] = outer_move_medium(comb_data.results_rh(:, column), 50, 3);
    [month_data_R, error_bars_R, time_day_R, ~, ~] = season_data(nc_date, R);
    plot_rmse_cc_bias_bar(nc_date, R, time_day_R, month_data_R, error_bars_R, 5, 'RelativeHumidity', 'Bias','(%rh)', save_path);
    
    % specific humidity
    [Q, ~] = outer_move_medium(comb_data.results_q(:, column), 50, 3);
    [month_data_Q, error_bars_Q, time_day_Q, ~, ~] = season_data(nc_date, Q);
    plot_rmse_cc_bias_bar(nc_date, Q, time_day_Q, month_data_Q, error_bars_Q, 5, 'SpecificHumidity', 'Bias','(g/kg)', save_path);

end




