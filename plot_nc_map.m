
% Plotting NC files using the m-map library

clc;
clear;
close;

%  Read NC file
filename = 'F:\气象数据\era5\global_era5_20220101_20221231\global_era5-2022-12-31.nc';
%View file information
% ncdisp(filename);

lat1 = ncread(filename,'latitude');
lon1 = ncread(filename,'longitude');
tt   = ncread(filename,'t');
time = ncread(filename,'valid_time');
pp   = ncread(filename,'pressure_level');

% Data pre-processing
[lat,lon] = meshgrid(lat1, lon1);

% Selection of layers and variables
% -----------------------------

layer = 12; 
ttt = tt(:,:,layer,2);

% -----------------------------


figureHandle = figure;

%% Drawing with the M_map tool miller robinson
% Crop the range to your desired area
m_proj('robinson','lon',[-180,180],'lat',[-90,90]);
m_pcolor(lon,lat,ttt);

% m_coast('patch',[.7 .7 .7],'edgecolor','none'); %  line     patch
m_coast('line'); %  line     patch
m_grid('tickdir','out','linew1',1); 
colormap(m_colmap('jet','step',10));

h = colorbar('southoutside','FontSize',11);

h.Label.String = strcat('Layer = ',num2str(layer),' Air Temperature(℃)');
% h.Label.String = strcat('Layer = ',num2str(layer),' Specific Humidity(g/kg)');
% h.Label.String = strcat('Layer = ',num2str(layer),' Relative humidity(%rh)');
% h.Label.String = strcat('Layer = ',num2str(layer),' Geopotential(m^2/s^-^2)');

h.Position = [0.25, 0.16, 0.55, 0.025]; 


fileout = 'D:\Desktop\EGNPD论文\results\plot\站点分布\';

% Image output
print(figureHandle, [fileout,'T_',num2str(layer),'_nc.png'],'-r600','-dpng');







 