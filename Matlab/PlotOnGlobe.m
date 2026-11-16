function [A] = PlotOnGlobe(DataStruct)
Latitude = DataStruct.variables.Latitude.data(5:end-4,:);
Longitude = DataStruct.variables.Longitude.data(5:end-4,:);



idx = isnan(DataStruct.TP.TbArcIce);
Data = DataStruct.TP.TbArcIce;
Data(idx) = DataStruct.TP.TbArcOcean(idx);

% sic_ant = Data.variables.siconc.data(5:end-4,:);

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
          isfinite(Data) & ...
          Latitude >= 50 & Latitude <= 90;

% Ungültige Werte auf NaN setzen
lat_N = Latitude;
lon_N = Longitude;
sic_N = Data+0;

% lat_N(~valid_N) = NaN;
% lon_N(~valid_N) = NaN;
% sic_N(~valid_N) = NaN;

% Zusammenhängende Fläche
pcolorm(lat_N, lon_N, sic_N);

load coastlines
plotm(coastlat, coastlon, 'k', 'LineWidth', 0.8);

colormap(gca,cmap)
% clim([0 1])
clim([80,280])


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

idx = isnan(DataStruct.TP.TbAntIce);
Data = DataStruct.TP.TbAntIce;
Data(idx) = DataStruct.TP.TbAntOcean(idx);

valid_S = isfinite(Latitude) & ...
          isfinite(Longitude) & ...
          isfinite(Data) & ...
          Latitude <= -50 & Latitude >= -90;

lat_S = Latitude;
lon_S = Longitude;
sic_S = Data+0;

% lat_S(~valid_S) = NaN;
% lon_S(~valid_S) = NaN;
% sic_S(~valid_S) = NaN;

% Zusammenhängende Fläche
pcolorm(lat_S, lon_S, sic_S);

plotm(coastlat, coastlon, 'k', 'LineWidth', 0.8);

colormap(gca,cmap)
% clim([0 1])
clim([80,280])


title('Antarctic Sea Ice Concentration', ...
    'FontSize',14,'FontWeight','bold');


% ============================
% COLORBAR
% ============================

cb = colorbar('Position',[0.92 0.2 0.015 0.6]);
cb.Label.String = 'Sea Ice Concentration';
cb.FontSize = 11;

sgtitle('Satellite Sea Ice Concentration', ...
    'FontSize',16,'FontWeight','bold');
end