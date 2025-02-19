
function [] = plot_DensityScatter_fit(x, y, DSxlabel, DSylabel, DSlegend, fileout)


% Density Scatter Plot

data = [x, y];

%% Density calculation
% Defined radius
radius = 1.5;
density_2D = density2D_KD(data(:,1:2), radius); % 2D planar density

%% Color definition
% Color selection from the color package
map = colormap(nclCM(232)); 
map = flipud(map);

%% Picture size setting (in centimeters)
close all;
figureUnits  = 'centimeters';
figureWidth  = 13.5;
figureHeight = 10;

%% Window settings

figureHandle = figure;
set(gcf, 'Units', figureUnits, 'Position', [0 10 figureWidth figureHeight]);
hold on;

%% Density scatter plotting

scatter(data(:,1), data(:,2), 5, density_2D, 'filled', 'DisplayName', DSlegend);

ylim([min(y)-20, max(y)+20]);

hXLabel = xlabel(DSxlabel);
hYLabel = ylabel(DSylabel);
legend("show");

%% Normal curve fit

% Fit data to normal distribution (1D for both x and y)
pd_x = fitdist(x, 'Normal'); % Normal distribution for x
pd_y = fitdist(y, 'Normal'); % Normal distribution for y

% Generate a grid of points to plot the normal distribution contour
x_grid = linspace(min(x), max(x), 100);
y_grid = linspace(min(y), max(y), 100);
[X, Y] = meshgrid(x_grid, y_grid);

% Compute the joint probability density function for a 2D normal distribution
mu = [pd_x.mu, pd_y.mu]; % Means
sigma = [pd_x.sigma, pd_y.sigma]; % Standard deviations
R = corrcoef(x, y); % Correlation matrix
cov_matrix = sigma(1) * sigma(2) * R(1,2); % Covariance

% Create the 2D normal distribution
Z = mvnpdf([X(:), Y(:)], mu, [sigma(1)^2, cov_matrix; cov_matrix, sigma(2)^2]);
Z = reshape(Z, size(X));

% Overlay the 2D normal distribution as a contour
contour(X, Y, Z, 10, 'LineWidth', 0.8, 'LineColor', 'r','DisplayName','Fit Line'); % 10 contour levels

%% Labeling of the ellipse direction
% Eigenvalues and eigenvectors of the covariance matrix

cov_matrix_full = [sigma(1)^2, cov_matrix; cov_matrix, sigma(2)^2];
[eigenvec, ~] = eig(cov_matrix_full);

% Calculation of the direction of the main axis of the ellipse (tilt angle)
% Tilt angle of the main axis

theta = atan2(eigenvec(2,1), eigenvec(1,1)); 


% Marks the angle of inclination of the ellipse
% Convert the angle to degrees

angle_deg = rad2deg(theta); 
text(20, 20, ['Angle: ' num2str(angle_deg, '%.2f') '^\circ'], ...
    'FontSize', 12, 'FontAngle', 'italic', 'Color', 'k', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');

%% Detail optimization
% Colorization

colormap(map);
colorbar;

% Axis beautification

set(gca, 'Box', 'off', ...                                       % Border
         'LineWidth', 0.8, ...                                   % Line width
         'XGrid', 'on', 'YGrid', 'on', ...                       % Grid
         'TickDir', 'out', 'TickLength', [.005 .005], ...        % Scale
         'XMinorTick', 'off', 'YMinorTick', 'off', ...           % Small scale
         'XColor', [.1 .1 .1],  'YColor', [.1 .1 .1]);           % Axis color

% Fonts and font sizes
set(gca, 'FontSize', 12);
set([hXLabel, hYLabel], 'FontSize', 12);

% Background colo
set(gcf, 'Color', [1 1 1]);

% Add upper and right frame lines
xc = get(gca, 'XColor');
yc = get(gca, 'YColor');
unit = get(gca, 'units');
ax = axes('Units', unit, ...
           'Position', get(gca, 'Position'), ...
           'XAxisLocation', 'top', ...
           'YAxisLocation', 'right', ...
           'Color', 'none', ...
           'XColor', xc, ...
           'YColor', yc);
set(ax, 'LineWidth', 0.8, ...
        'XTick', [], ...
        'YTick', []); 

% Image output
print(figureHandle, [fileout, '.png'], '-r600', '-dpng');

end
