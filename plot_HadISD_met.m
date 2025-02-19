

% Plotting of HadISD-converted meteorological parameter information for stations of own choice


load F:\气象数据\metoffice\选择站点8个\Met_Data_Struct_global_8.mat
load F:\气象数据\metoffice\选择站点8个\Met_Data_Struct_Others_global_8.mat
savepath = 'F:\气象数据\metoffice\选择站点8个\第二版图\';


fields = fieldnames(Met_Data_Struct);


for i = 1 : 8
    site_name = fields{i};

    % Extraction of weather station observation times and locations
    site_met_1  = Met_Data_Struct.(site_name).MetData_1;
    site_met_2  = Met_Data_Struct_Others.(site_name).MetData_2;

    % Create new figure
    figureHandle = figure;

    % Resize the picture window
    set(figureHandle, 'Position', [500, 100, 1000, 200]);  

    % Set overall spacing
    margin = 0.05;   % Setting subgraph spacing
    width = (1 - 5 * margin) / 4;    % Width of each subgraph
    height = 0.65;           % Height of each subgraph
    try

        % Temperature graph
        ax1 = axes('Position', [margin, 0.2, width, height]);  % Adjustment of position and size
        plot(table2array(site_met_1(:,1)), table2array(site_met_1(:,2)), 'Color', [153/255, 0, 102/255], 'LineWidth', 1.2);
        xtickformat('yyyy-MM-dd');
        xlabel('Date');
        ylabel('Temperature/(℃)');
        box on 

        % pressure graph
        ax2 = axes('Position', [margin + width + margin, 0.2, width, height]); 
        plot(table2array(site_met_1(:,1)), table2array(site_met_1(:,3)), 'Color', [153/255, 0, 102/255], 'LineWidth', 1.2);
        xtickformat('yyyy-MM-dd');
        xlabel('Date');
        ylabel('Pressure/(hPa)');
        box on  

        % Relative humidity graph
        ax3 = axes('Position', [margin + 2 * (width + margin), 0.2, width, height]);  
        plot(table2array(site_met_2(:,1)), table2array(site_met_2(:,3)), 'Color', [153/255, 0, 102/255], 'LineWidth', 1.2);
        xtickformat('yyyy-MM-dd');
        xlabel('Date');
        ylabel('RelativeHumidity/(%rh)');
        box on  

        % Specific humidity graph
        ax4 = axes('Position', [margin + 3 * (width + margin), 0.2, width, height]); 
        plot(table2array(site_met_2(:,1)), table2array(site_met_2(:,4)), 'Color', [153/255, 0, 102/255], 'LineWidth', 1.2);
        xtickformat('yyyy-MM-dd');
        xlabel('Date');
        ylabel('SpecificHumidity/(g/kg)');
        box on  

        % Image output
        print(figureHandle, [savepath,site_name,'.png'],'-r600','-dpng');
        close(gcf)
        
    catch
        continue

    end

end



