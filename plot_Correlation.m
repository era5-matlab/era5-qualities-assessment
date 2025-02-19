
function [] = plot_Correlation(x,y,Xlable, Ylable, Legend,fileout)

% Calculated bias (Bias)
% Calculated correlation coefficient,
% Calculated root mean square error (RMSE)
bias = mean(y - x);
R    = corr(x, y);
rmse = sqrt(mean((y - x).^2));

% Use linear regression to fit the data: 
% y = a*x + b, 
% a is the slope
p     = polyfit(x, y, 1);
slope = p(1);


%% Density calculation
data       = [x, y];
radius     = 1.5;    % Defined radius
density_2D = density2D_KD(data(:,1:2),radius); % 2D planar density

%% Open window
figureHandle = figure;


%% Color Definition
map = colormap(nclCM(232));  % color picking in the package
map = flipud(map);


%% Picture size setting (in centimeters)
figureUnits = 'centimeters';
figureWidth = 13.5;
figureHeight = 10;


%% Window settings

set(gcf, 'Units', figureUnits, 'Position', [30 10 figureWidth figureHeight]);


%% Density scatter plotting

scatter(data(:,1), data(:,2), 5, density_2D, 'filled', DisplayName = Legend)

minx1 = min(x);
minx2 = min(y);
maxy1 = max(x);
maxy2 = max(y);
xlim([min(minx1,minx2)-5,max(maxy1,maxy2)]+5);
ylim([min(minx1,minx2)-5,max(maxy1,maxy2)]+5);


%% Add 1:1 line

xRange = xlim;  % Get the range of the axes

% Draw 1:1 line to connect axes
hold on 
plot([min(xRange) max(xRange)], [min(xRange) max(xRange)], 'r--', 'LineWidth', 1, 'DisplayName', '1:1 Line');


%% Set the normalized coordinates of the text position
text(0.05, 0.9, ['R = ' num2str(R, '%.3f')], 'Units', 'normalized', ...
    'FontSize', 12, 'FontAngle', 'italic', 'Color', 'k', 'BackgroundColor', 'none');

text(0.05, 0.8, ['Bias = ' num2str(bias, '%.3f')], 'Units', 'normalized', ...
    'FontSize', 12, 'FontAngle', 'italic', 'Color', 'k', 'BackgroundColor', 'none');

text(0.05, 0.7, ['RMSE = ' num2str(rmse, '%.3f')], 'Units', 'normalized', ...
    'FontSize', 12, 'FontAngle', 'italic', 'Color', 'k', 'BackgroundColor', 'none');

text(0.05, 0.6, ['Slope = ' num2str(slope, '%.3f')], 'Units', 'normalized', ...
    'FontSize', 12, 'FontAngle', 'italic', 'Color', 'k', 'BackgroundColor', 'none');


%% Setting up axis labels and legends
hXLabel = xlabel(Xlable);
hYLabel = ylabel(Ylable);
legend("show", 'Location', 'southeast');


%% Detail optimization
% Colorization
colormap(map)
colorbar

% Axis beautification
set(gca, 'Box', 'off', ...                                     % Border
         'LineWidth',0.8,...                                   % Line width
         'XGrid', 'on', 'YGrid', 'on', ...                     % Grid
         'TickDir', 'out', 'TickLength', [.005 .005], ...      % Scale
         'XMinorTick', 'off', 'YMinorTick', 'off', ...         % Small scale
         'XColor', [.1 .1 .1],  'YColor', [.1 .1 .1])          % Axis color

% Fonts and font sizes
set(gca, 'FontSize', 12)
set([hXLabel, hYLabel], 'FontSize', 12)

% Background color
set(gcf,'Color',[1 1 1])

% Add upper and right frame lines
xc = get(gca,'XColor');
yc = get(gca,'YColor');
unit = get(gca,'units');
ax = axes( 'Units', unit,...
           'Position',get(gca,'Position'),...
           'XAxisLocation','top',...
           'YAxisLocation','right',...
           'Color','none',...
           'XColor',xc,...
           'YColor',yc);
set(ax, 'linewidth',0.8,...
        'XTick', [],...
        'YTick', []);

% Image output
print(figureHandle, [fileout,'.png'],'-r600','-dpng');

end






