

function [] = plot_rmse_cc_bias_bar(nc_Time,T,time_day,month_data,error_bars,bsize,type,target,unit,save_path)
%% Picture size setting (in centimeters)

close all;
figureUnits = 'centimeters';
figureWidth = 10;
figureHeight = 7.5;

%% Window settings
figureHandle = figure;
set(gcf, 'Units', figureUnits, 'Position', [10 10 figureWidth figureHeight]);
hold on

%% Density scatter plotting
color_matrix = [51/255,51/255,153/255];

h1 = scatter(nc_Time, T, 12, [204/255,204/255,204/255], 'filled');
hold on
h2 = errorbar(time_day,month_data,error_bars*bsize,'Marker','o','MarkerSize',3,'MarkerFaceColor',color_matrix, ...
    'LineStyle','-','LineWidth',1,'Color',color_matrix);

xtickformat('yyyy-MM-dd');
hXLabel = xlabel('Date');
hYLabel = ylabel([type,'-',target,unit]);
legend([h1,h2],{['D-',target]',['M-',target]},"Orientation","horizontal","Location","southeast","EdgeColor",[255/255,153/255,204/255])

%% Detail optimization
% Axis beautification
set(gca, 'Box', 'off', ...                                        % Border
         'LineWidth',0.7,...                                      % Line width
         'XGrid', 'on', 'YGrid', 'on', ...                        % Grid
         'TickDir', 'out', 'TickLength', [.005 .005], ...         % Scale
         'XMinorTick', 'off', 'YMinorTick', 'off', ...            % Small scale
         'XColor', [.1 .1 .1],  'YColor', [.1 .1 .1])             % Axis color

% Fonts and font sizes
set(gca,'FontSize', 10)
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
set(ax, 'linewidth',0.7,...
        'XTick', [],...
        'YTick', []);

%% Image output
figW = figureWidth;
figH = figureHeight;
set(figureHandle,'PaperUnits',figureUnits);
set(figureHandle,'PaperPosition',[0 0 figW figH]);
fileout = [save_path,'\',type,'-',target];
print(figureHandle,[fileout,'.png'],'-r600','-dpng');
disp(['saved：',fileout])
end
