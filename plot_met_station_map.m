
% Mapping the global distribution of weather stations using the m-map package


position = readmatrix('F:\气象数据\metoffice\met_office_station_info.csv');
fileout = 'F:\气象数据\metoffice\plot\站点分布\';


lon = position(:,2);  % Longitude
lat = position(:,3);  % Latitude
hhh = position(:,4);  % Numerical values (e.g., meteorological data, temperature, elevation, etc.)

%% ------------------------------------------------------------------------% 

disp('the (whole) world')

figureHandle = figure;


% Image size setting (in centimeters)
figureUnits = 'centimeters';
figureWidth = 30;
figureHeight = 18;

% Window settings
set(gcf, 'Units', figureUnits, 'Position', [1 1 figureWidth figureHeight]);


% Setting the map projection
m_proj('miller', 'lon', [-180 180]);
m_coast('patch', [0.7 0.7 0.7], 'edgecolor', 'r');  % 绘制海岸线

hold on

m_scatter(lon, lat, 10, hhh, 'filled');
m_grid('tickdir', 'out', 'linewi', 1.5);    % Mapping grid
colormap(m_colmap('jet', 'step', 5));      % Setting the color map (based on hhh values)

h = colorbar('southoutside','FontSize',11);
h.Label.String = 'Elevation(m)';

% Image output
print(figureHandle, [fileout,'global_met_position.png'],'-r600','-dpng');
close(figureHandle)


%% ------------------------------------------------------------------------
disp('>> Antarctica')

figureHandle1 = figure;
figureUnits = 'centimeters';
figureWidth1 = 10;
figureHeight1 = 10;

% Window settings
set(gcf, 'Units', figureUnits, 'Position', [1 1 figureWidth1 figureHeight1]);

id_b = lat > 66.5;
b = size(find(id_b == 1),1);
disp(b)

m_proj('stereographic','lat',90,'long',30,'radius',25);
m_coast('patch',[.7 .7 .7],'edgecolor','r');

hold on

m_scatter(lon(id_b), lat(id_b), 20, hhh(id_b), 'filled');

m_grid('xtick',12,'tickdir','out','ytick',[70 80],'linest','--','linewidth',0.5,'linewi', 1.5);
colormap(m_colmap('jet', 'step', 5)); 

% Image output
print(figureHandle1, [fileout,'beipole.png'],'-r600','-dpng');
close(figureHandle1)




%% 
disp('>> Arctic')


figureHandle2 = figure;
figureUnits = 'centimeters';
figureWidth2 = 10;
figureHeight2 = 10;

% Window settings
set(gcf, 'Units', figureUnits, 'Position', [1 1 figureWidth2 figureHeight2]);

id_n = lat < -66.5;
c = size(find(id_n == 1),1);
disp(c)

m_proj('stereographic','lat',-90,'long',30,'radius',25);
m_coast('patch',[.7 .7 .7],'edgecolor','r');

hold on

m_scatter(lon(id_n), lat(id_n), 20, hhh(id_n), 'filled');
m_grid('xtick',12,'tickdir','out','ytick',[-70 -80],'linest','--','xaxisloc','top','linewi', 1.5);
colormap(m_colmap('jet', 'step', 5)); 

% Image output
print(figureHandle2, [fileout,'nanpole.png'],'-r600','-dpng');
close(figureHandle2)









