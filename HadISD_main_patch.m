

% Processing: HadISD - global sub-daily station datase
% https://www.metoffice.gov.uk/hadobs/hadisd/index.html
% nc_path: Specify the path where HadISD weather station files are stored, this is a folder path.
% save_path: the result of the processing is stored as a structure, the main weather variables are stored in Met_Data_Struct_global
% save_path_others: secondary weather variables are stored in Met_Data_Struct_Others_global
% time_tag_start: time start of the intercepted data
% time_tag_end: end point of intercepted data



clc; clear; close all

%% Setting

nc_path = 'F:\气象数据\metoffice\选择站点8个';

save_path = 'F:\气象数据\metoffice\选择站点8个\Met_Data_Struct_global_8.mat';

save_path_others = 'F:\气象数据\metoffice\选择站点8个\Met_Data_Struct_Others_global_8.mat';


time_tag_start = datetime(2020, 1, 1, 0, 0, 0);   % time start of the intercepted data
time_tag_end = datetime(2023, 12, 31, 0, 0, 0);   % end point of intercepted data



%% Start processing
[Met_Data_Struct, Met_Data_Struct_Others] = delt_with_met_nc(time_tag_start, time_tag_end, nc_path);


%% Saving a structure to a file
save(save_path, 'Met_Data_Struct', '-v7.3');
save(save_path_others, 'Met_Data_Struct_Others','-v7.3');
disp(['Processing is complete and all data has been saved to.', save_path]);
disp(['Processing is complete and all data has been saved to.:', save_path_others]);





%% Functions for handling nc files
function [Met_Data_Struct, Met_Data_Struct_Others] = delt_with_met_nc(time_tag_start, time_tag_end, nc_path)

nc_files = dir(fullfile(nc_path, '*.nc'));

% Initialize the structure that stores all file data
Met_Data_Struct = struct();  
Met_Data_Struct_Others = struct();  % save the auxiliary data

% Iterate through each .nc file
hbar = waitbar(0,'Caculutating ...');
len = length(nc_files);

for i = 1 : len
    % Get the path and name of the file
    nc_file_path = fullfile(nc_files(i).folder, nc_files(i).name);

    % Extracts filenames as structure names
    [~, station_name, ~] = fileparts(nc_files(i).name);

    % Replace illegal characters with underscores
    Station_Name = matlab.lang.makeValidName(['M-', station_name]);

    % Read position data
    longitude = ncread(nc_file_path, 'longitude');
    latitude  = ncread(nc_file_path, 'latitude');
    elevation = ncread(nc_file_path, 'elevation');
    Position  = [longitude, latitude, elevation];

    % Read meteorological parameters
    dewpoints1    = ncread(nc_file_path, 'dewpoints');    % 2m dew point temperature
    temperatures1 = ncread(nc_file_path, 'temperatures'); % 2m temperature
    stnlp1        = ncread(nc_file_path, 'stnlp');        % surface pressure
    slp1          = ncread(nc_file_path, 'slp');          % Sea level pressure
    
    % Sea level pressure to surface pressure
    Pmst = sea_to_station_pressure(slp1, temperatures1, elevation);


    % Intercepted data based on time frame
    % HadISD's baseline time:(1931, 1, 1, 0, 0, 0)
    hours_since = ncread(nc_file_path, 'time');
    date_time1  = hours(hours_since) + datetime(1931, 1, 1, 0, 0, 0);  
    id_time_tag = find(date_time1 > time_tag_start & date_time1 < time_tag_end);

    temperatures= temperatures1(id_time_tag);
    dewpoints   = dewpoints1(id_time_tag);
    stnlp       = stnlp1(id_time_tag);
    slp         = slp1(id_time_tag);
    Pmst        = Pmst(id_time_tag);
    date_time   = date_time1(id_time_tag);


    % Handle outliers as NaN
    % The Data Processing Center designates the outlier as -2.0000e+30
    invalid_value = -2.0000e+30;
    temperatures(temperatures == invalid_value) = NaN;
    dewpoints(dewpoints == invalid_value) = NaN;
    stnlp(stnlp == invalid_value) = NaN;
    slp(slp == invalid_value) = NaN;
    Pmst(Pmst == invalid_value) = NaN;


    % Calculation of information on relevant meteorological parameters
    % e_v：Vapour pressure [hPa]；
    % e_s：Saturation vapour pressure [hPa]；
    % q：specific humidity；
    % rh：relative humidity;
    station_pressure = stnlp;
    [e_v, e_s, ~] = fix_wrt_ice_or_water(temperatures, dewpoints, station_pressure);
    rh = calculate_rh(e_v, e_s);              
    q = calculate_q(e_v, station_pressure);   
    

    % Create tables to store results
    data_table = table(date_time, temperatures, station_pressure, e_v, ...
        'VariableNames', {'DateTime', 'Temperature', ...
        'Pressure', 'VaporPressure'});

    other_table = table(date_time, dewpoints, rh, q, ...
        'VariableNames',{'DateTime', 'Dewpoints', ...
        'RelativeHumidity', 'SpecificHumidity'});


    % Create a structure for the current site
    station_struct = struct();
    station_struct.Position = Position;
    station_struct.MetData_1 = data_table;
    station_struct.Station_Name = Station_Name;


    % Ancillary data
    station_struct_other = struct();
    station_struct_other.Position = Position;
    station_struct_other.MetData_2 = other_table;
    station_struct_other.Station_Name = Station_Name;


    % Deposit site structure into master structure
    Met_Data_Struct.(Station_Name) = station_struct;
    Met_Data_Struct_Others.(Station_Name) = station_struct_other;
    msg = [num2str(i), '/', num2str(len)];
    waitbar(i / len, hbar, msg) 

end
close(hbar)

end





%% Functions to calculate relevant meteorological parameters

%% Calculate water vapor pressure, saturated water vapor pressure, wet bulb temperature

function [e_v, e_s, Tw] = fix_wrt_ice_or_water(temperatures, dewpoints, station_pressure)
    % Calculate the vapour pressures and wet-bulb temperatures, adjusting
    % for an ice- or water-bulb as appropriate based on Tw.
    %
    % Parameters:
    % temperatures: Temperature array [deg C]
    % dewpoints: Dewpoint temperature array [deg C]
    % station_pressure: Station pressure array [hPa]
    %
    % Returns:
    % e_v: Vapour pressure [hPa]
    % e_s: Saturation vapour pressure [hPa]
    % Tw: Wet-bulb temperature [deg C]

    % Calculate vapour pressures
    e_v = calculate_e_v_wrt_water(dewpoints, station_pressure);
    e_v_ice = calculate_e_v_wrt_ice(dewpoints, station_pressure);

    % Calculate saturation vapour pressures
    e_s = calculate_e_v_wrt_water(temperatures, station_pressure);
    e_s_ice = calculate_e_v_wrt_ice(temperatures, station_pressure);

    % Calculate wet-bulb temperatures
    Tw = calculate_Tw(e_v, station_pressure, dewpoints, temperatures);
    Tw_ice = calculate_Tw(e_v_ice, station_pressure, dewpoints, temperatures);

    % Adjust for ice-bulbs where Tw <= 0
    ice_indices = Tw <= 0; % Logical index for Tw <= 0
    e_v(ice_indices) = e_v_ice(ice_indices);
    e_s(ice_indices) = e_s_ice(ice_indices);
    Tw(ice_indices) = Tw_ice(ice_indices);
end



%% Calculate water pressure relative to water
function e_v = calculate_e_v_wrt_water(t, P)
    % Calculate vapour pressure with respect to ice
    %
    % Buck, A. L.: New equations for computing vapor pressure and 
    % enhancement factor, J. Appl. Meteorol., 20, 1527–1532, 1981.
    %
    % Inputs:
    %   t - Temperature (or dewpoint temperature for saturation e_v) [deg C]
    %   P - Station level pressure [hPa]
    %
    % Outputs:
    %   e_v - Vapour pressure (or saturation vapour pressure if 
    %         dewpoint temperature used) [hPa]
    %   q  -  specific humidity (g/kg)
    
    % Compute enhancement factor:计算增强因子（Enhancement Factor）：用于修正由于大气压力对水汽压的微小影响
    f = 1 + (3e-4) + (4.18e-6) * P;
    
    % Compute vapour pressure with respect to ice
    e_v = 6.1115 * f .* exp(((23.036 - (t ./ 333.7)) .* t) ./ (279.82 + t));

    % specific humidity
    % q = 1000. * ((0.622 .* e_v) ./ (P - ((1 - 0.622) .* e_v)));

end



%% Calculate the air pressure of water relative to ice
function e_v = calculate_e_v_wrt_ice(t, P)
    % Calculate vapour pressure with respect to ice
    %
    % Reference:
    % Buck, A. L.: New equations for computing vapor pressure and enhancement factor, 
    % J. Appl. Meteorol., 20, 1527–1532, 1981.
    %
    % Parameters:
    % t: Temperature (or dewpoint temperature for saturation e_v) [deg C]
    % P: Station level pressure [hPa]
    %
    % Returns:
    % e_v: Vapour pressure (or saturation vapour pressure if dewpoint temperature is used) [hPa]

    % Calculate enhancement factor
    f = 1 + (3e-4) + (4.18e-6) .* P;

    % Calculate vapour pressure
    e_v = 6.1115 .* f .* exp(((23.036 - (t ./ 333.7)) .* t) ./ (279.82 + t));

end



%% Calculated ball temperature
function Tw = calculate_Tw(e_v, P, Td, t)
    % Calculate the wet-bulb temperature
    %
    % Reference:
    % Jensen, M. E., Burman, R. D., and Allen, R. G. (Eds.): Evapotranspiration 
    % and Irrigation Water Requirements: ASCE Manuals and Reports on 
    % Engineering Practices No. 70, American Society of Civil Engineers, 
    % New York, 360 pp., 1990.
    %
    % Parameters:
    % e_v: Vapour pressure [hPa]
    % P: Station level pressure [hPa]
    % Td: Dewpoint temperature [deg C]
    % t: Dry-bulb temperature [deg C]
    %
    % Returns:
    % Tw: Wet-bulb temperature [deg C]

    % Calculate coefficients
    a = 0.000066 * P;
    b = (409.8 * e_v) ./ ((Td + 237.3).^2);

    % Calculate wet-bulb temperature
    Tw = ((a .* t) + (b .* Td)) ./ (a + b);
end



%% Calculate relative humidity
function rh = calculate_rh(e_v, es)
   
    % Calculate relative humidity
    % Inputs:
    %   e_v - Vapour pressure (hPa)
    %   es  - Saturation vapour pressure (hPa)
    %
    % Output:
    %   rh - Relative humidity (%rh)

    % Calculate relative humidity
    rh = (e_v ./ es) * 100;  % 相对湿度公式
end



%% Convert sea level pressure to station pressure
function Pmst = sea_to_station_pressure(Pmsl, T, Z)
    % Convert sea level pressure to station pressure
    %
    % Parameters:
    % Pmsl: Sea level pressure [hPa]
    % T: Temperature at the station [°C]
    % Z: Station height above sea level [m]
    %
    % Returns:
    % Pmst: Station pressure [hPa]

    % Constants
    L = 0.0065; % Temperature lapse rate [K/m]
    exponent = 5.625;

    % Convert temperature to Kelvin
    T_kelvin = T + 273.15;

    % Compute station pressure
    Pmst = Pmsl .* (T_kelvin ./ (T_kelvin + L * Z)).^exponent;
end


%% specific humidity
function q = calculate_q(e_v, P)
    % specific humidity
    q = 1000. * ((0.622 .* e_v) ./ (P - ((1 - 0.622) .* e_v)));
end






