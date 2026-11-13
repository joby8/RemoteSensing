
figure();
subplot(2,1,1)
imagesc(TP.TbAntIce,'AlphaData',~isnan(TP.TbAntIce))
title("Tie Point Ice in Antarctic")
clim([80,280])
c = colorbar;
c.Label.String = "Tb in K";
xlabel("Along Track")
ylabel("Across track")

subplot(2,1,2)
imagesc(TP.TbAntOcean,'AlphaData',~isnan(TP.TbAntOcean))
title("Tie Point Ocean in Antarctic")
clim([80,280])
c = colorbar;
c.Label.String = "Tb in K";
xlabel("Along Track")
ylabel("Across track")


figure();
subplot(2,1,1)
imagesc(TP.TbArcIce,'AlphaData',~isnan(TP.TbArcIce))
title("Tie Point Ice in Arctic")
clim([80,280])
c = colorbar;
c.Label.String = "Tb in K";
xlabel("Along Track")
ylabel("Across track")

subplot(2,1,2)
imagesc(TP.TbArcOcean,'AlphaData',~isnan(TP.TbArcOcean))
title("Tie Point Ocean in Arctic")
c = colorbar;
c.Label.String = "Tb in K";
xlabel("Along Track")
ylabel("Across track")
clim([80,280])

% figure();
% imagesc(TP.TbAntIce,'AlphaData',~isnan(TP.TbAntIce))
% title("Antarctic")
% hold on
% imagesc(TP.TbAntOcean,'AlphaData',~isnan(TP.TbAntOcean))
% c = colorbar;
% c.Label.String = "Tb in K";
% xlabel("Along Track")
% ylabel("Across track")
% clim([80,280])
% 
% figure();
% imagesc(TP.TbArcIce,'AlphaData',~isnan(TP.TbArcIce))
% title("Arctic")
% hold on
% imagesc(TP.TbArcOcean,'AlphaData',~isnan(TP.TbArcOcean))
% c = colorbar;
% c.Label.String = "Tb in K";
% xlabel("Along Track")
% ylabel("Across track")
% clim([80,280])

if 1

% Assuming Lon, Lat, and DataMatrix are all 2D matrices of the same size (e.g., M x N)
R = 1; % Radius of the sphere

% 1. Convert degrees to radians
lon_rad = deg2rad(A.variables.Longitude.data(5:end-5,:));
lat_rad = deg2rad(A.variables.Latitude.data(5:end-5,:));

% 2. Convert spherical coordinates to 3D Cartesian coordinates
[X, Y, Z] = sph2cart(lon_rad, lat_rad, R);

% 3. Plot the 3D sphere and project it onto a 2D view
figure;
surf(X, Y, Z, TP.TbArcIce); % 'EdgeColor','none' removes grid lines
hold on
surf(X, Y, Z, TP.TbArcOcean, 'EdgeColor', 'none'); % 'EdgeColor','none' removes grid lines
surf(X, Y, Z, TP.TbAntIce, 'EdgeColor', 'none'); % 'EdgeColor','none' removes grid lines
surf(X, Y, Z, TP.TbAntOcean, 'EdgeColor', 'none'); % 'EdgeColor','none' removes grid lines
shading interp;   % Smooths out the color transitions
colorbar;
axis equal;       % Ensures the sphere looks circular, not stretched
axis off;         % Hides the 3D axes box for a clean look

% 4. Set the camera to look straight down at a 2D flat projection
% view(0, 90);      % Top-down 2D orthographic view (looking down the Z-axis)
end