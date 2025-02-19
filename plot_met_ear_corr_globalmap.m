
% Load monthly average meteorological data processing results
% Load weather station coordinate information


clc; clear; close all

load F:\气象数据\metoffice\processed_global_met_data_nc\mean_Met_ERA5_Data_Struct_2020_2021_2022.mat
station_csv = 'F:\气象数据\metoffice\met_office_station_info.csv';
shp_path = 'D:\Projects\matlab_Projects\大气模型\GUI\Met-office\data\wordshpfile\country.shp';
png_path = 'F:\气象数据\metoffice\plot\2022-相关性figure\冬季1\';


position = readmatrix(station_csv);
lon = position(:,2);
lat = position(:,3);
hhh = position(:,4);

% 'Temperatures','Pressure', 'VaporPressure', 'RelativeHumidity  %rh ', 'SpecificHumidity g/kg '
% temperature：1   Pressure：2  VaporPressure：3   RelativeHumidity：4    SpecificHumidity：5
tag = 5; 

% spring：3 4 5   summers：6 7 8   autumn：9 10 11  winner：12 1 2
column = 1;      


if tag == 1
    met_type = "Temperature";
    colorbar_label = "Temperature(℃)"; 
    spring_data_met = mean_Met_ERA5_Data_Struct_2022.met_T(:,column);
    spring_data_era = mean_Met_ERA5_Data_Struct_2022.era_T(:,column);
elseif tag == 2   
    met_type = "Pressure";
    colorbar_label = "Pressure(hPa)";   
    spring_data_met = mean_Met_ERA5_Data_Struct_2022.met_P(:,column);
    spring_data_era = mean_Met_ERA5_Data_Struct_2022.era_P(:,column);
elseif tag == 3
    met_type = "VaporPressure";
    colorbar_label = "VaporPressure(hPa)";   
    spring_data_met = mean_Met_ERA5_Data_Struct_2022.met_e(:,column);
    spring_data_era = mean_Met_ERA5_Data_Struct_2022.era_e(:,column);
elseif tag == 4
    met_type = "RelativeHumidity";
    colorbar_label = "RelativeHumidity(%rh)";  
    spring_data_met = mean_Met_ERA5_Data_Struct_2022.met_rh(:,column);
    spring_data_era = mean_Met_ERA5_Data_Struct_2022.era_rh(:,column);
elseif tag == 5
    met_type = "SpecificHumidity";
    colorbar_label = "SpecificHumidity(g/kg)";  
    spring_data_met = mean_Met_ERA5_Data_Struct_2022.met_q(:,column);
    spring_data_era = mean_Met_ERA5_Data_Struct_2022.era_q(:,column);
end


% Sliding window de-exception
spring_data_dt  = spring_data_met - spring_data_era;
[spring_T,spring_oid] = outer_move_medium(spring_data_dt,50,3);
spring_data_met = spring_data_met(~spring_oid);
spring_data_era = spring_data_era(~spring_oid);
spring_T = spring_T(~spring_oid);
lon = lon(~spring_oid);
lat = lat(~spring_oid);
hhh = hhh(~spring_oid);


% Remove 0 value
id_0 = spring_data_met == 0;
spring_data_met = spring_data_met(~id_0);
spring_data_era = spring_data_era(~id_0);
spring_T = spring_T(~id_0);
lon = lon(~id_0);
lat = lat(~id_0);
hhh = hhh(~id_0);


% Extract non-null indexes
non_id = ~isnan(spring_data_met);

%% 
disp('Figure 1: Correlation diagram')

Xlable   = strcat("HadISD ",  colorbar_label);
Ylable   = strcat("ERA5 ", colorbar_label);
Legend   = met_type;
fileout3 = [png_path, char(met_type), 'MET与ERA5相关性图'];
plot_Correlation(spring_data_met(non_id), spring_data_era(non_id), Xlable, Ylable, Legend, fileout3)
close all


%% 
disp('Figure 2: Plotting station meteorological parameter errors on a geographic map')

fileout2 = [png_path, char(met_type), '误差空间分布图'];
plot_Geography(lon(non_id), lat(non_id), spring_T(non_id), colorbar_label, "global", fileout2)
close all


%%
disp('Figure 3: Plotting station meteorological parameter errors versus elevation') 

hhh = hhh(non_id);
h0_id = hhh >= 0;
dt = spring_T(non_id);

DSxlabel = 'Elevation(m)';
DSylabel = colorbar_label;
DSlegend = met_type;
fileout1 = [png_path , char(met_type), '误差与高程关系','fit'];
plot_DensityScatter_fit(hhh(h0_id), dt(h0_id), DSxlabel, DSylabel, DSlegend, fileout1)
close all


%% 
disp('Figure 4: Error versus longitude')
% Rosettes

TitleString = strcat("d",char(colorbar_label));
direction_lon = lon(h0_id);
speed_lon = dt(h0_id);
% lon_0 = direction_lon < 0;
% aaa = zeros(length(direction_lon),1);
% aaa(lon_0) = 180;
% direction_lon = direction_lon + aaa;
fileout4  = [png_path , char(met_type), '误差与经度的关系'];
labels_lon = {'0°','45°','90°','135°','±180°','-135°','-90°','-45°'};
plot_rose(direction_lon,speed_lon,fileout4,TitleString,labels_lon,48)
close all


%% 
disp('Figure 5: Error versus latitude')
% Rosettes

TitleString = strcat("d",char(colorbar_label));
direction_lat = lat(h0_id);
speed_lat = dt(h0_id);
fileout4  = [png_path , char(met_type), '误差与纬度的关系'];
labels_lat = {'0°','45°','90°','135°','±180°','-135°','-90°','-45°'};
plot_rose(direction_lat,speed_lat,fileout4,TitleString,labels_lat,54)
close all




















% function [] = plot_Correlation(x, y, Xlable, Ylable, Legend, fileout)
% % 计算偏差 (Bias),% 计算相关系数,% 计算均方根误差 (RMSE)
% bias = mean(y - x);
% R    = corr(x, y);
% rmse = sqrt(mean((y - x).^2));
% 
% % 使用线性回归拟合数据：y = a*x + b，a为斜率
% p     = polyfit(x, y, 1);
% slope = p(1);
% 
% %% 密度计算
% data       = [x, y];
% radius     = 1.5; % 定义半径
% density_2D = density2D_KD(data(:,1:2),radius); % 2D平面密度
% 
% %% 打开窗口
% figureHandle = figure;
% 
% %% 颜色定义
% map = colormap(nclCM(232));  %color包里选颜色
% map = flipud(map);
% 
% %% 图片尺寸设置（单位：厘米）
% figureUnits = 'centimeters';
% figureWidth = 11;
% figureHeight = 7.5;
% 
% %% 窗口设置
% set(gcf, 'Units', figureUnits, 'Position', [30 10 figureWidth figureHeight]);
% 
% %% 密度散点图绘制
% 
% scatter(data(:,1), data(:,2), 8, density_2D, 'filled', DisplayName = Legend)
% 
% minx1 = min(x);
% minx2 = min(y);
% maxy1 = max(x);
% maxy2 = max(y);
% xlim([min(minx1,minx2)-5,max(maxy1,maxy2)]+5);
% ylim([min(minx1,minx2)-5,max(maxy1,maxy2)]+5);
% 
% %% 添加 1:1 线
% 
% xRange = xlim;  % 获取坐标轴的范围
% 
% % 绘制 1:1 线，连接坐标轴
% hold on 
% plot([min(xRange) max(xRange)], [min(xRange) max(xRange)], 'r--', 'LineWidth', 1.5, 'DisplayName', '1:1 Line');
% 
% %% 设置文本位置的归一化坐标
% text(0.05, 0.9, ['CC = ' num2str(R, '%.3f')], 'Units', 'normalized', ...
%     'FontSize', 11, 'FontAngle', 'italic', 'Color', 'k', 'BackgroundColor', 'none');
% 
% text(0.05, 0.8, ['Bias = ' num2str(bias, '%.3f')], 'Units', 'normalized', ...
%     'FontSize', 11, 'FontAngle', 'italic', 'Color', 'k', 'BackgroundColor', 'none');
% 
% text(0.05, 0.7, ['RMSE = ' num2str(rmse, '%.3f')], 'Units', 'normalized', ...
%     'FontSize', 11, 'FontAngle', 'italic', 'Color', 'k', 'BackgroundColor', 'none');
% 
% text(0.05, 0.6, ['Slope = ' num2str(slope, '%.3f')], 'Units', 'normalized', ...
%     'FontSize', 11, 'FontAngle', 'italic', 'Color', 'k', 'BackgroundColor', 'none');
% 
% %% 设置轴标签和图例
% hXLabel = xlabel(Xlable);
% hYLabel = ylabel(Ylable);
% legend("show", 'Location', 'southeast',"EdgeColor",[255/255,153/255,204/255]);
% 
% %% 细节优化
% % 赋色
% colormap(map)
% colorbar
% % colorbar_handle = colorbar;
% % % 设置colorbar的宽度（调整Position，增加宽度，减少高度）
% % colorbar_handle.Position = [0.92, 0.1, 0.03, 0.8];  % 位置调整：x, y, 宽度, 高度
% 
% % 坐标轴美化
% set(gca, 'Box', 'off', ...                                     % 边框
%          'LineWidth',0.8,...                                   % 线宽
%          'XGrid', 'on', 'YGrid', 'on', ...                     % 网格
%          'TickDir', 'out', 'TickLength', [.005 .005], ...      % 刻度
%          'XMinorTick', 'off', 'YMinorTick', 'off', ...         % 小刻度
%          'XColor', [.1 .1 .1],  'YColor', [.1 .1 .1])          % 坐标轴颜色
% % 字体和字号
% set(gca, 'FontSize', 11)
% set([hXLabel, hYLabel], 'FontSize', 11)
% % 背景颜色
% set(gcf,'Color',[1 1 1])
% % 添加上、右框线
% xc = get(gca,'XColor');
% yc = get(gca,'YColor');
% unit = get(gca,'units');
% ax = axes( 'Units', unit,...
%            'Position',get(gca,'Position'),...
%            'XAxisLocation','top',...
%            'YAxisLocation','right',...
%            'Color','none',...
%            'XColor',xc,...
%            'YColor',yc);
% set(ax, 'linewidth',0.8,...
%         'XTick', [],...
%         'YTick', []);
% % 图片输出
% print(figureHandle, [fileout,'.png'],'-r600','-dpng');
% end
% 
% %% 
% function density_2D = density2D_KD(data,radius)
% M = size(data,1);
% density_2D = zeros(M,1);
% idx = rangesearch(data(:,1:2),data(:,1:2),radius,'Distance','euclidean','NSMethod','kdtree');
% for i = 1:M
%     density_2D(i,1) = length(idx{i})/(pi*radius^2);
% end
% end
% 
% %% 
% function colorList=nclCM(type,num)
% if nargin<2
%     num=-1;
% end
% if nargin<1
%     type=73;
% end
% nclCM_Data=load('nclCM_Data.mat');
% CList_Data=nclCM_Data.Colors;
% 
% if isnumeric(type)
%     Cmap=CList_Data{type};
% else
%     Cpos=strcmpi(type,nclCM_Data.Names);
%     Cmap=CList_Data{find(Cpos,1)};
% end
% if num>0
% Ci=1:size(Cmap,1);Cq=linspace(1,size(Cmap,1),num);
% colorList=[interp1(Ci,Cmap(:,1),Cq,'linear')',...
%            interp1(Ci,Cmap(:,2),Cq,'linear')',...
%            interp1(Ci,Cmap(:,3),Cq,'linear')'];
% else
% colorList=Cmap;
% end
% end
% 
% 
% %% 
% 
% 
% function [] = plot_DensityScatter_fit(x, y, DSxlabel, DSylabel, DSlegend, fileout)
% % 密度散点图
% 
% %% 数据准备
% data = [x, y];
% 
% %% 密度计算
% radius = 1.5; % 定义半径
% density_2D = density2D_KD(data(:,1:2), radius); % 2D平面密度
% 
% %% 颜色定义
% map = colormap(nclCM(232)); % color包里选颜色
% map = flipud(map);
% 
% %% 图片尺寸设置（单位：厘米）
% close all;
% figureUnits  = 'centimeters';
% figureWidth  = 10;
% figureHeight = 8;
% 
% %% 窗口设置
% figureHandle = figure;
% set(gcf, 'Units', figureUnits, 'Position', [10 10 figureWidth figureHeight]);
% hold on;
% 
% %% 密度散点图绘制
% scatter(data(:,1), data(:,2), 5, density_2D, 'filled', 'DisplayName', DSlegend);
% 
% ylim([min(y)-20, max(y)+20]);
% 
% hXLabel = xlabel(DSxlabel);
% hYLabel = ylabel(DSylabel);
% legend("show",'EdgeColor',[255/255,153/255,204/255]);
% 
% %% 正态曲线拟合
% 
% % Fit data to normal distribution (1D for both x and y)
% pd_x = fitdist(x, 'Normal'); % Normal distribution for x
% pd_y = fitdist(y, 'Normal'); % Normal distribution for y
% 
% % Generate a grid of points to plot the normal distribution contour
% x_grid = linspace(min(x), max(x), 100);
% y_grid = linspace(min(y), max(y), 100);
% [X, Y] = meshgrid(x_grid, y_grid);
% 
% % Compute the joint probability density function for a 2D normal distribution
% mu = [pd_x.mu, pd_y.mu]; % Means
% sigma = [pd_x.sigma, pd_y.sigma]; % Standard deviations
% R = corrcoef(x, y); % Correlation matrix
% cov_matrix = sigma(1) * sigma(2) * R(1,2); % Covariance
% 
% % Create the 2D normal distribution
% Z = mvnpdf([X(:), Y(:)], mu, [sigma(1)^2, cov_matrix; cov_matrix, sigma(2)^2]);
% Z = reshape(Z, size(X));
% 
% % Overlay the 2D normal distribution as a contour
% contour(X, Y, Z, 10, 'LineWidth', 0.5, 'LineColor', 'r','DisplayName','Fit Line'); % 10 contour levels
% 
% %% 椭圆方向的标记
% % 协方差矩阵的特征值和特征向量
% cov_matrix_full = [sigma(1)^2, cov_matrix; cov_matrix, sigma(2)^2];
% [eigenvec, ~] = eig(cov_matrix_full);
% 
% % 计算椭圆的主轴方向（倾斜角度）
% theta = atan2(eigenvec(2,1), eigenvec(1,1)); % 主轴的倾斜角度
% 
% % 标记椭圆的倾斜角度
% angle_deg = rad2deg(theta); % 将角度转换为度
% text(20, 20, ['Angle: ' num2str(angle_deg, '%.2f') '^\circ'], ...
%     'FontSize', 12, 'FontAngle', 'italic', 'Color', 'k', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
% 
% %% 细节优化
% % 赋色
% colormap(map);
% %colorbar;
% 
% % 坐标轴美化
% set(gca, 'Box', 'off', ...                                     % 边框
%          'LineWidth', 0.8, ...                                   % 线宽
%          'XGrid', 'on', 'YGrid', 'on', ...                       % 网格
%          'TickDir', 'out', 'TickLength', [.005 .005], ...        % 刻度
%          'XMinorTick', 'off', 'YMinorTick', 'off', ...           % 小刻度
%          'XColor', [.1 .1 .1],  'YColor', [.1 .1 .1]);           % 坐标轴颜色
% 
% % 字体和字号
% set(gca, 'FontSize', 12);
% set([hXLabel, hYLabel], 'FontSize', 12);
% 
% % 背景颜色
% set(gcf, 'Color', [1 1 1]);
% 
% % 添加上、右框线
% xc = get(gca, 'XColor');
% yc = get(gca, 'YColor');
% unit = get(gca, 'units');
% ax = axes('Units', unit, ...
%            'Position', get(gca, 'Position'), ...
%            'XAxisLocation', 'top', ...
%            'YAxisLocation', 'right', ...
%            'Color', 'none', ...
%            'XColor', xc, ...
%            'YColor', yc);
% set(ax, 'LineWidth', 0.8, ...
%         'XTick', [], ...
%         'YTick', []); 
% 
% %% 图片输出
% print(figureHandle, [fileout, '.png'], '-r600', '-dpng');
% end
% 
% 
% function [] = plot_rose(direction,speed,fileout,TitleString,labels,ndirections)
% 
% %玫瑰图绘制
% D = direction;
% S = speed;
% 
% map = colormap(nclCM(399)); %color包里选颜色
% Options = {'anglenorth',0,...
%            'angleeast',90,...
%            'labels',labels,...   % {'0°','45°','90°','135°','180°','225°','270°','315°'}
%            'freqlabelangle','auto',...
%            'nspeeds',6,...
%            'ndirections',ndirections,...
%            'lablegend',TitleString,...
%            'legendvariable','dT',...
%            'axesfontsize',12,...
%            'legendbarfontsize',12,...
%            'legendfontsize',12,...
%            'legendtype',1,...
%            'min_radius',0.1,...
%            'height',9*50,...
%            'width',8*50,...
%            'cmap',map};
% figure_handle = WindRose(D,S,Options);
% print(figure_handle, [fileout, '.png'], '-r600', '-dpng');
% 
% end
% 
% 
