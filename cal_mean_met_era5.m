
% Find monthly averages, further annual averages, quarterly averages
% ERA5_P_T_PWV_Tm_Es: Processed ERA5 data result
% Met_Data_Struct_global: HadISD data processing results


clc;clear;close all



load F:\气象数据\era5\process_global_era5_results\ERA5_P_T_PWV_Tm_Es_2022.mat
load F:\气象数据\metoffice\processed_global_met_data_nc\2022_Met_Data_Struct_global.mat
load F:\气象数据\metoffice\processed_global_met_data_nc\2022_Met_Data_Struct_Others_global.mat
save_path = 'F:\气象数据\metoffice\processed_global_met_data_nc\mean_Met_ERA5_Data_Struct_2022.mat';



% Selection of time points to match the common time portion of MET and ERA5 data
disp('>> data matching')


% Average per month
% Designated time year
yr = 2022;
t_range = [1,2,3,4,5,6,7,8,9,10,11,12];



mean_Met_ERA5_Data_Struct = struct();  


% Get the name of the weather station in the Met_Data_Struct structure
fields = fieldnames(Met_Data_Struct);
len = length(fields);


% Traversing each weather station
hbar = waitbar(0,'Caculutating ...');
met_T = [];
met_P = [];
met_e = [];
met_rh = [];
met_q = [];

era_T = [];
era_P = [];
era_e = [];
era_rh = [];
era_q = [];



for i = 1 : len
    site_name = fields{i};

    % Extraction of meteorological station observation time
    site_time_met  = Met_Data_Struct.(site_name).MetData_1(:,1);

    % Time to extract ERA5 data
    site_time_era5 = ERA5_P_T_PWV_Tm_Es.ncdate;

    % If the time is of type table, it is extracted as an array
    if istable(site_time_met)
        site_time_met = site_time_met{:,:}; 
    end  
    if istable(site_time_era5)
        site_time_era5 = site_time_era5{:,:}; 
    end


    try
        % Time segmentation for averaging
        for j = 1 : length(t_range)
            target_time_start = datetime(yr,t_range(j),1,00,00,00);
            target_time_end   = datetime(yr,t_range(j)+1,1,00,00,00);
            id_time_met = site_time_met >= target_time_start & site_time_met <= target_time_end;

            % There are no observations for this point in time at this station, 
            % proceed to the next station.
            if isempty(id_time_met)
                continue;
            end


            %% Intercepted data based on indexing
            % ------------ met ---------------

            % Met_Data_Struct: DateTime--Temperature--Pressure--VaporPressure
            MetData_1 = Met_Data_Struct.(site_name).MetData_1(id_time_met,:);

            % Met_Data_Struct_Others:  DateTime--Dewpoints--RelativeHumidity--SpecificHumidity
            MetData_2 = Met_Data_Struct_Others.(site_name).MetData_2(id_time_met,:);
            
            % 1 means average by column, omitnan ignores nulls.
            mean_1 = mean(table2array(MetData_1(:,2:4)), 1, 'omitnan');  
            mean_2 = mean(table2array(MetData_2(:,2:4)), 1, 'omitnan');
            met_T(i,j) = mean_1(1);
            met_P(i,j) = mean_1(2);
            met_e(i,j) = mean_1(3);
            met_rh(i,j)= mean_2(2);
            met_q(i,j) = mean_2(3);


            %% ERA5
            id_time_era5 = site_time_era5 >= target_time_start & site_time_era5 <= target_time_end; 
            % There are no observations for this point in time at this station, 
            % proceed to the next station.
            if isempty(id_time_era5) 
                continue;
            end


            % ERA5 data
            era_T(i,j) = mean(ERA5_P_T_PWV_Tm_Es.ERA_T(id_time_era5, i) - 273.15);
            era_P(i,j) = mean(ERA5_P_T_PWV_Tm_Es.ERA_P(id_time_era5, i));
            era_e(i,j) = mean(ERA5_P_T_PWV_Tm_Es.ERA_ee(id_time_era5, i));
            era_rh(i,j)= mean(ERA5_P_T_PWV_Tm_Es.ERA_rh(id_time_era5, i));
            era_q(i,j) = mean(ERA5_P_T_PWV_Tm_Es.ERA_Q(id_time_era5, i))*1000;
        end


    catch ME
        fprintf('failed match:%s\n\n', ME.message);
    end


    msg = [num2str(i), '/', num2str(len)];
    waitbar(i / len, hbar, msg)
end
close(hbar)



% Preservation structure
% met
mean_Met_ERA5_Data_Struct.met_T = met_T;
mean_Met_ERA5_Data_Struct.met_P = met_P;
mean_Met_ERA5_Data_Struct.met_e = met_e;
mean_Met_ERA5_Data_Struct.met_rh= met_rh;
mean_Met_ERA5_Data_Struct.met_q = met_q;

% era5
mean_Met_ERA5_Data_Struct.era_T = era_T;
mean_Met_ERA5_Data_Struct.era_P = era_P;
mean_Met_ERA5_Data_Struct.era_e = era_e;
mean_Met_ERA5_Data_Struct.era_rh= era_rh;
mean_Met_ERA5_Data_Struct.era_q = era_q;

% met - era5
mean_Met_ERA5_Data_Struct.d_T = met_T - era_T;
mean_Met_ERA5_Data_Struct.d_P = met_P - era_P;
mean_Met_ERA5_Data_Struct.d_e = met_e - era_e;
mean_Met_ERA5_Data_Struct.d_rh= met_rh - era_rh;
mean_Met_ERA5_Data_Struct.d_q = era_q - era_q;


disp('>> Results are being saved')

save(save_path, 'mean_Met_ERA5_Data_Struct', '-v7.3');


