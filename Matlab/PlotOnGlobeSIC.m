function [A] = PlotOnGlobeSIC(DataArc, DataAnt, Latitude, Longitude, name)

DataArc(DataArc < 0.15) = 0;
DataArc(DataArc > 0.95) = 1;
DataAnt(DataAnt < 0.15) = 0;
DataAnt(DataAnt > 0.95) = 1;

d_grid = 0.25;
[sic_N, lat_N, lon_N] = resampleGridSIC(DataArc, Latitude, Longitude, d_grid, [50, 90]);
[sic_S, lat_S, lon_S] = resampleGridSIC(DataAnt, Latitude, Longitude, d_grid, [-90, -50]);

figure('Color','w','Position',[100 100 1400 650]);

cmap = parula(256);

% ============================
% 1. NORTHERN HEMISPHERE
% ============================

subplot(1,2,1)

axesm('stereo', ...
    'Origin',[90 0 0], ...
    'MapLatLimit',[50 90]);

axis off
framem on
gridm on
hold on

pcolorm(lat_N, lon_N, sic_N, 'AlphaData', ~isnan(sic_N));

load coastlines
plotm(coastlat, coastlon, 'k', 'LineWidth', 0.8);

colormap(gca,cmap)
clim([0 1])

title('Arctic', ...
    'FontSize',14,'FontWeight','bold');


% ============================
% 2. SOUTHERN HEMISPHERE
% ============================

subplot(1,2,2)

axesm('stereo', ...
    'Origin',[-90 0 0], ...
    'MapLatLimit',[-90 -50]);

axis off
framem on
gridm on
hold on

pcolorm(lat_S, lon_S, sic_S, 'AlphaData', ~isnan(sic_S));

plotm(coastlat, coastlon, 'k', 'LineWidth', 0.8);

colormap(gca,cmap)
clim([0 1])

title('Antarctic', ...
    'FontSize',14,'FontWeight','bold');


% ============================
% COLORBAR
% ============================

cb = colorbar('Position',[0.92 0.2 0.015 0.6]);
cb.Label.String = 'Sea Ice Concentration';
cb.FontSize = 11;

sgtitle(name, ...
    'FontSize',16,'FontWeight','bold');
end