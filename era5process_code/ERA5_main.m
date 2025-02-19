
% Processing of ERA5 data


clc;clear;close all


%% ====================================================================


% ERA5 data path, folder path of nc
nc_path = 'D:\Desktop\era5数据质检代码\test_data\global_era5-2024-04-01.nc';

% Path to the folder where the results are stored
save_path = 'D:\Desktop\era5数据质检代码\test_data\';   

% Path to the meteorological station location information file
csv_path  = 'D:\Desktop\era5数据质检代码\test_data\station_info.csv';

% Grid file after EGM2008 gravity field model processing
grd_path = 'D:\Desktop\era5数据质检代码\era5process\gpt3_5.grd';


% ====================================================================
dataTable_point = readtable(csv_path);

% ERA5_P_T_PWV_Tm_Es has been automatically saved
ERA5_P_T_PWV_Tm_Es = ERA5_cal_Meteorological_parameters(nc_path,dataTable_point,grd_path,save_path);

