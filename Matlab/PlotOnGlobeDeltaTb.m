function [A] = PlotOnGlobeDeltaTb(DataArc, DataAnt, Latitude, Longitude, name)

% [~, ~, ~, DataArc] = averageSICByCoords(DataArc, Latitude, Longitude);
% [~, ~, ~, DataAnt] = averageSICByCoords(DataAnt, Latitude, Longitude);


Longitude(Longitude > 180) = Longitude(Longitude > 180) - 360;

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

valid_N = isfinite(Latitude) & ...
          isfinite(Longitude) & ...
          isfinite(DataArc) & ...
          Latitude >= 50 & Latitude <= 90;

lat_N = Latitude;
lon_N = Longitude;
sic_N = DataArc;

lat_N(~valid_N) = NaN;
lon_N(~valid_N) = NaN;
sic_N(~valid_N) = NaN;

pcolorm(lat_N', lon_N', sic_N', 'AlphaData', ~isnan(sic_N));

load coastlines
plotm(coastlat, coastlon, 'k', 'LineWidth', 0.8);

colormap(gca,cmap)
% clim([0 1])
% clim([80,280])


title('Arctic Sea Ice Concentration', ...
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


valid_N = isfinite(Latitude) & ...
          isfinite(Longitude) & ...
          isfinite(DataAnt) & ...
          Latitude <= -50 & Latitude >= -90;

lat_N = Latitude;
lon_N = Longitude;
sic_N = DataAnt;

lat_N(~valid_N) = NaN;
lon_N(~valid_N) = NaN;
sic_N(~valid_N) = NaN;

pcolorm(lat_N, lon_N, sic_N, 'AlphaData', ~isnan(sic_N));

plotm(coastlat, coastlon, 'k', 'LineWidth', 0.8);

colormap(gca,cmap)
% clim([0 1])
% clim([80,280])


title('Antarctic Sea Ice Concentration', ...
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