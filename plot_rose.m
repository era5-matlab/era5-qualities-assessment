
plot_rose1(direction_lon,speed_lon,fileout4,TitleString)

function [] = plot_rose1(direction,speed,fileout,TitleString)

% Rose diagramming
D = direction;
S = speed;

% color picking in the package
map = colormap(nclCM(399)); 
Options = {'anglenorth',0,...
           'angleeast',90,...
           'labels',{'0°','45°','90°','135°','180°','225°','270°','315°'},...
           'freqlabelangle','auto',...
           'nspeeds',6,...
           'ndirections',24,...
           'lablegend',TitleString,...
           'legendvariable','dT',...
           'axesfontsize',12,...
           'legendbarfontsize',12,...
           'legendfontsize',12,...
           'legendtype',1,...
           'min_radius',0.1,...
           'height',9*50,...
           'width',8*50,...
           'cmap',map};

figure_handle = WindRose(D,S,Options);

print(figure_handle, [fileout, '.png'], '-r600', '-dpng');

end