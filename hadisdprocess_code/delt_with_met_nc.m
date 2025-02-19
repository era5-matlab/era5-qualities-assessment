
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


