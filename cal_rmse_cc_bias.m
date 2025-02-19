

% HadISD - global sub-daily station datase
% Errors in matching weather station data with era5 interpolation results
% ERA5_P_T_PWV_Tm_Es: Processed ERA5 data result
% Met_Data_Struct_global: HadISD data processing results


%-------------------------------- Global Regions -------------------------------

clc; clear; close all

disp('>> Loading data')


load F:\气象数据\era5\process_global_era5_results\ERA5_P_T_PWV_Tm_Es_2020.mat
load F:\气象数据\metoffice\processed_global_met_data_nc\2020_Met_Data_Struct_global.mat
load F:\气象数据\metoffice\processed_global_met_data_nc\2020_Met_Data_Struct_Others_global.mat
save_path = 'F:\气象数据\metoffice\processed_global_met_data_nc\RMSE_CC_BIAS_SLOP_Struct_2020.mat';



% Selection of time points to match MET and ERA5 data common time segments
disp('>> data matching')

site_time_era5 = ERA5_P_T_PWV_Tm_Es.ncdate;
if istable(site_time_era5)
    site_time_era5 = site_time_era5{:,:};
end

RMSE_CC_BIAS_SLOP_Struct = struct();  

lenT = length(site_time_era5);

results_T = NaN(lenT,5);
results_P = NaN(lenT,5);
results_e = NaN(lenT,5);
results_rh= NaN(lenT,5);
results_q = NaN(lenT,5);


% Iterate over each weather station
hbar1 = waitbar(0,'Caculutating ...');

for i = 1 : lenT
    disp(i)
    target_time = datetime(site_time_era5(i));
    [met_data, era5_data, position, position_region] = era5_met_par_check(Met_Data_Struct, Met_Data_Struct_Others, ERA5_P_T_PWV_Tm_Es, target_time);
    
    %       1             2            3                   4                 5
    % 'Temperatures','Pressure', 'VaporPressure', 'RelativeHumidity  %rh ', 'SpecificHumidity g/kg '


    if isempty(met_data) || isempty(era5_data)
        disp([string(target_time),'no data'])
        continue
    end

    segment = 0;
    results_T(i,1:5)  = cal_rmse_cc_bias_slop(met_data,era5_data,position,segment,1,15);
    results_P(i,1:5)  = cal_rmse_cc_bias_slop(met_data,era5_data,position,segment,2,30);
    results_e(i,1:5)  = cal_rmse_cc_bias_slop(met_data,era5_data,position,segment,3,30);
    results_rh(i,1:5) = cal_rmse_cc_bias_slop(met_data,era5_data,position,segment,4,60);
    results_q(i,1:5)  = cal_rmse_cc_bias_slop(met_data,era5_data,position,segment,5,60);

    msg = [num2str(i), '/', num2str(lenT)];
    waitbar(i / lenT, hbar1, msg)


end
close(hbar1)


% Output structure
RMSE_CC_BIAS_SLOP_Struct.results_T  = results_T;
RMSE_CC_BIAS_SLOP_Struct.results_P  = results_P;
RMSE_CC_BIAS_SLOP_Struct.results_e  = results_e;
RMSE_CC_BIAS_SLOP_Struct.results_rh = results_rh;
RMSE_CC_BIAS_SLOP_Struct.results_q  = results_q;


disp('>> Results are being saved')


save(save_path, 'RMSE_CC_BIAS_SLOP_Struct', '-v7.3');




%% auxiliary function

function [results] = cal_rmse_cc_bias_slop(met_data,era5_data,position,segment,columns,outers)
met_data_region    = met_data(:, columns);
era5_data_region   = era5_data(:, columns);
lon_lat_ele_region = position(:,:);

% Find index of non-null value Extract non-null value

non_Idx            = ~isnan(table2array(met_data_region));
met_data_region    = table2array(met_data_region(non_Idx,:));
era5_data_region   = table2array(era5_data_region(non_Idx,:));
lon_lat_ele_region = table2array(lon_lat_ele_region(non_Idx,2:4));
ele_region         = lon_lat_ele_region(:,3);

% Find data that meets elevation requirements
ele_id = find(ele_region > segment);  % m


%% Extraction of latitude and longitude
% lonn_region = lon_lat_ele_region(ele_id,1);
% latt_region = lon_lat_ele_region(ele_id,2);

met_data_region_1  = met_data_region(ele_id);
era5_data_region_1 = era5_data_region(ele_id);

% Location of meteorological errors
Dt_temp_region  = met_data_region_1 - era5_data_region_1;
% Find exceptions
outer_id_region = find(abs(Dt_temp_region) < outers);  


%% Calculated indicators
xx = met_data_region_1(outer_id_region);
yy = era5_data_region_1(outer_id_region);

rmse = sqrt(mean((xx - yy).^2));
ccor    = corr(xx, yy);
bias = mean(xx - yy);
% Fitting the data using linear regression：y = a*x + b，a is slope 
p     = polyfit(xx, yy, 1);
slop = p(1);

results = [rmse,ccor,bias,slop,length(xx)];

end




%% Matching function of temperature, air pressure, water vapor pressure

function [met_data, era5_data, position, position_region] = era5_met_par_check(Met_Data_Struct,Met_Data_Struct_Others_global,ERA5_P_T_PWV_Tm_Es,target_time)

% Matching ERA5 to weather station temperature, barometric pressure, water vapor pressure

met_data = [];
era5_data = [];
position = [];
position_region = [];

% Get the name of the weather station in the Met_Data_Struct structure
fields = fieldnames(Met_Data_Struct);

len = length(fields);

% 遍历每个气象站
hbar = waitbar(0,'Caculutating ...');

for i = 1 : len
    site_name = fields{i};

    % Extraction of weather station observation times
    site_time_met  = Met_Data_Struct.(site_name).MetData_1(:,1);
    
    % Extraction of weather era5 times
    site_time_era5 = ERA5_P_T_PWV_Tm_Es.ncdate;

    % Station name, longitude, latitude, elevation
    pos_region_table = table(string(site_name), ...
        Met_Data_Struct.(site_name).Position(1), ...
        Met_Data_Struct.(site_name).Position(2), ...
        Met_Data_Struct.(site_name).Position(3), ...
        'VariableNames', {'site_name', 'lon', 'lat','ele'});

    position_region = [position_region; pos_region_table];
    
    % If the time is of type table, it is extracted as an array.
    if istable(site_time_met)
        site_time_met = site_time_met{:,:}; 
    end
    if istable(site_time_era5)
        site_time_era5 = site_time_era5{:,:};
    end


    try
        % Determine if target_time time is in the met data
        % There are no observations for this point in time at this station,
        % proceed to the next station.
        id_time_met = find(site_time_met == target_time, 1);
        if isempty(id_time_met) 
            continue;
        end

        % Determine if the target_time is in the ERA5 data.
        % There are no observations for this point in time at this station,
        % proceed to the next station.
        id_time_era5 = find(site_time_era5 == target_time, 1);
        if isempty(id_time_era5)
            continue;
        end

        % Determine the position of the met site within the era5 site

        met_site_name = cellstr([site_name(3:8),'-',site_name(10:14)]);
        era5_site_name = ERA5_P_T_PWV_Tm_Es.dataTable_point{:,1};
        id_site_era5 = find(strcmp(met_site_name, era5_site_name));

        if isempty(id_site_era5) 
            disp([site_name,' This station is not in ERA5'])
            continue;
        end


        % Trying to extract data
        % MetData_1:Datetime | Temperature | Pressure | VaporPressure
        met_data_1 = Met_Data_Struct.(site_name).MetData_1(id_time_met, 2:4);

        % MetData_2:Datetime | Dewpoints | RelativeHumidity | SpecificHumidity
        met_data_2 = Met_Data_Struct_Others_global.(site_name).MetData_2(id_time_met, 3:4);

        met_data_F = [met_data_1,met_data_2];

        % ERA5 data
        temp_era5 = ERA5_P_T_PWV_Tm_Es.ERA_T(id_time_era5, id_site_era5) - 273.15;
        pres_era5 = ERA5_P_T_PWV_Tm_Es.ERA_P(id_time_era5, id_site_era5);
        vpre_era5 = ERA5_P_T_PWV_Tm_Es.ERA_ee(id_time_era5, id_site_era5);
        rh_era5   = ERA5_P_T_PWV_Tm_Es.ERA_rh(id_time_era5, id_site_era5);
        q_era5    = (ERA5_P_T_PWV_Tm_Es.ERA_Q(id_time_era5, id_site_era5)).*1000;

        era5_data_1 = table(temp_era5, pres_era5, vpre_era5,rh_era5, q_era5, ...
            'VariableNames', {'Temp_era5', 'Pressure_era5', 'VaporPressure_era5', ...
            'RelativeHumidity_era5','SpecificHumidity_era5'});

        lon = Met_Data_Struct.(site_name).Position(1);
        lat = Met_Data_Struct.(site_name).Position(2);
        ele = Met_Data_Struct.(site_name).Position(3);

        pos_table = table(string(site_name), lon, lat, ele, ...
            'VariableNames', {'site_name', 'lon', 'lat','ele'});

        met_data = [met_data; met_data_F];
        era5_data = [era5_data; era5_data_1];
        position = [position; pos_table];

    catch ME
        fprintf('failed match:%s\n\n', ME.message);
    end


    % disp([site_name,' Station matching complete'])
    msg = [num2str(i), '/', num2str(len)];
    waitbar(i / len, hbar, msg)


end

close(hbar)


end




