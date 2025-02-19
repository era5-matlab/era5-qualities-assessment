

function [] = plot_SouthSea(mask)

% 绘制地理边界
if mask == "china"
    % Read geographic information from China .shp files
    S = shaperead('D:\Projects\matlab_Projects\大气模型\GUI\Met-office\data\china_shp\china.shp');  
else
    % Read geographic information from global .shp files
    S = shaperead('D:\Projects\matlab_Projects\大气模型\GUI\Met-office\data\wordshpfile\country.shp');  
end

for k = 1:length(S)
    lon_shp = S(k).X; 
    lat_shp = S(k).Y;  
    % Mapping of geographical boundaries (e.g. coastlines or national borders)
    plot(lon_shp, lat_shp, 'k', 'LineWidth', 0.4); 
end

% South China Sea islands and the nine-dash line
S1 = shaperead('D:\Projects\matlab_Projects\大气模型\GUI\Met-office\data\SouthSea\bou2_4l.shp');
for k = 1:length(S1)
    lon_shp1 = S1(k).X; 
    lat_shp1 = S1(k).Y; 
    plot(lon_shp1, lat_shp1, 'k', 'LineWidth', 0.4); 
end

S2 = shaperead('D:\Projects\matlab_Projects\大气模型\GUI\Met-office\data\SouthSea\九段线.shp');
for k = 1:length(S2)
    lon_shp2 = S2(k).X;  
    lat_shp2 = S2(k).Y;  
    plot(lon_shp2, lat_shp2, 'k', 'LineWidth', 0.4);
end

S3 = shaperead('D:\Projects\matlab_Projects\大气模型\GUI\Met-office\data\SouthSea\南海诸岛及其它岛屿.shp');
for k = 1:length(S3)
    lon_shp3 = S3(k).X; 
    lat_shp3 = S3(k).Y;  
    plot(lon_shp3, lat_shp3, 'k', 'LineWidth', 0.4); 
end

end
