
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






