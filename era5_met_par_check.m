

%% Matching ERA5 to weather station temperature, barometric pressure, water vapor pressure

function [met_data, era5_data, position, position_region] = era5_met_par_check(Met_Data_Struct,Met_Data_Struct_Others_global,ERA5_P_T_PWV_Tm_Es,target_time)

% Matching function of temperature, air pressure, water vapor pressure

met_data = [];
era5_data = [];
position = [];
position_region = [];


% Get the name of the weather station in the Met_Data_Struct structure
fields = fieldnames(Met_Data_Struct);

len = length(fields);

% Iterate over each weather station
hbar = waitbar(0,'Caculutating ...');

for i = 1 : len
    site_name = fields{i};

    % Extraction of weather station observation times
    site_time_met  = Met_Data_Struct.(site_name).MetData_1(:,1);
    
    % Extraction of era5 times
    site_time_era5 = ERA5_P_T_PWV_Tm_Es.ncdate;

    % Station name, longitude, latitude, elevation
    pos_region_table = table(string(site_name), ...
        Met_Data_Struct.(site_name).Position(1), ...
        Met_Data_Struct.(site_name).Position(2), ...
        Met_Data_Struct.(site_name).Position(3), ...
        'VariableNames', {'site_name', 'lon', 'lat','ele'});

    position_region = [position_region; pos_region_table];
    


    % If the time is of type table, it is extracted as an array
    if istable(site_time_met)
        site_time_met = site_time_met{:,:}; 
    end
    if istable(site_time_era5)
        site_time_era5 = site_time_era5{:,:};
    end

    try
        % Determine if target_time time is in the met data
        id_time_met = find(site_time_met == target_time, 1);
        % There are no observations for this point in time at this station, 
        % proceed to the next station.
        if isempty(id_time_met) 
            continue;
        end


        % Determine if the target_time is in the ERA5 data.
        id_time_era5 = find(site_time_era5 == target_time, 1);

        % There are no observations for this point in time at this station, 
        % proceed to the next station.
        if isempty(id_time_era5) 
            continue;
        end


        % Determine the position of the met site within the era5 site
        met_site_name = cellstr([site_name(3:8),'-',site_name(10:14)]);
        era5_site_name = ERA5_P_T_PWV_Tm_Es.dataTable_point{:,1};
        id_site_era5 = find(strcmp(met_site_name, era5_site_name));
        
        if isempty(id_site_era5)    
            disp([site_name,' This station is not present in ERA5.'])
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
        q_era5    = ERA5_P_T_PWV_Tm_Es.ERA_Q(id_time_era5, id_site_era5);

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


