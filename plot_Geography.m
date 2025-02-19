
function [] = plot_Geography(x, y, z,colorbar_label, mask, fileout)

figure

if mask == "china"
    % Setting the map window size
    set(gcf, 'Position', [500, 100, 500, 350]);  
    scatter(x, y, 25, z, 'filled');
else
    set(gcf, 'Position', [500, 100, 580, 320]); 
    scatter(x, y, 8, z, 'filled');
end

% Using jet color mapping
colormap(jet);       

hColorBar = colorbar;
% Optional: fixed color bar range
caxis([min(z), max(z)]); 

% Setting the color bar unit
ylabel(hColorBar, colorbar_label, 'FontSize', 12);  
xlabel('Longitude(°)', 'FontSize', 12);
ylabel('Latitude(°)', 'FontSize', 12);

if mask == "china"
    xlim([73, 136]);
    ylim([3, 55]);
else
    xlim([-180, 180]);
    ylim([-90, 90]);
end

grid on;
set(gca, 'Box', 'on', 'LineWidth',0.8)   % Line width
set(gca, 'TickDir', 'out');            % Setting scale facing out
set(gca, 'TickLength', [0.005, 0]);    % Sets the length of the primary scale to and the secondary scale to 0
hold on
% mask == "china"   or   "global"

% Mapping of the South China Sea islands and the nine-dash line
plot_SouthSea(mask);   

print(gcf,[fileout, '.png'],'-r600','-dpng');


end