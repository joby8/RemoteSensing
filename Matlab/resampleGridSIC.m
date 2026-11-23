function [sic_grid, lat_grid, lon_grid] = resampleGridSIC(Data, Latitude, Longitude, d_grid, lat_range, fill_holes)
%RESAMPLEGRIDSIC Resampelt unstrukturierte Satellitenschwad-Daten (ESMR Swath)
% auf ein reguläres geographisches Gitter (Lat/Lon) mit definierter Auflösung.
%
%   Detailtreue:
%   - Bildet das lokale Zellenmittel (Cell-Binning) aller Messpunkte innerhalb
%     einer Gitterzelle. Dadurch wird das Instrumentenrauschen reduziert,
%     während Meereisränder und Feinstrukturen bis zur Gitterauflösung
%     präzise erhalten bleiben.
%   - Schließt optional schmale 1-Pixel-Lücken zwischen Bahnen, ohne Kanten
%     zu verwaschen.
%
%   INPUT:
%       Data        - 2D-Matrix der Eiskonzentration (z.B. DataArc oder DataAnt)
%       Latitude    - 2D-Matrix der Breitengrade
%       Longitude   - 2D-Matrix der Längengrade
%       d_grid      - Gitterweite in Grad (Standard: 0.5)
%       lat_range   - [lat_min, lat_max], z.B. [50, 90] (Nord) oder [-90, -50] (Süd)
%       fill_holes  - true/false: Schließe 1-Pixel-Lücken zwischen Bahnen (Standard: true)
%
%   OUTPUT:
%       sic_grid    - Resampelte Eiskonzentration [0 bis 1], NaN bei fehlenden Daten
%       lat_grid    - 2D-Gitter der Breitengrade (meshgrid)
%       lon_grid    - 2D-Gitter der Längengrade (meshgrid)

    if nargin < 4 || isempty(d_grid)
        d_grid = 0.5;
    end
    if nargin < 5 || isempty(lat_range)
        lat_range = [50, 90];
    end
    if nargin < 6 || isempty(fill_holes)
        fill_holes = true;
    end

    lat_min = min(lat_range);
    lat_max = max(lat_range);

    lat_vec = lat_min : d_grid : lat_max;
    lon_vec = -180 : d_grid : 180;

    [lon_grid, lat_grid] = meshgrid(lon_vec, lat_vec);
    sz = [length(lat_vec), length(lon_vec)];

    % 1. Daten säubern und Längengrade auf [-180, 180) normieren
    raw_data = double(Data);
    raw_lat  = double(Latitude);
    raw_lon  = mod(double(Longitude) + 180, 360) - 180;

    % 2. Gitter-Indizes berechnen (1-basiert)
    r = round((raw_lat - lat_min) / d_grid) + 1;
    c = round((raw_lon - (-180)) / d_grid) + 1;

    % Begrenzung auf Randspalten
    c(c > length(lon_vec)) = length(lon_vec);
    c(c < 1) = 1;

    % Nur endliche und im Zielgebiet liegende Punkte verwenden
    valid = isfinite(raw_data) & isfinite(raw_lat) & isfinite(raw_lon) & ...
            (r >= 1 & r <= length(lat_vec)) & (c >= 1 & c <= length(lon_vec));

    if ~any(valid(:))
        sic_grid = nan(sz);
        return;
    end

    r_idx = r(valid);
    c_idx = c(valid);
    vals  = raw_data(valid);

    % 3. Akkumulation: Lokales Zellenmittel bilden (extrem schnell & detailtreu)
    sub = [r_idx(:), c_idx(:)];
    cell_sum = accumarray(sub, vals(:), sz, @sum, 0);
    cell_cnt = accumarray(sub, 1, sz, @sum, 0);

    sic_grid = cell_sum ./ cell_cnt;
    sic_grid(cell_cnt == 0) = NaN;

    % Datumsgrenzen-Naht schließen (Spalte -180° und +180° abgleichen)
    seam_nan = isnan(sic_grid(:, end)) & ~isnan(sic_grid(:, 1));
    sic_grid(seam_nan, end) = sic_grid(seam_nan, 1);
    seam_nan2 = isnan(sic_grid(:, 1)) & ~isnan(sic_grid(:, end));
    sic_grid(seam_nan2, 1) = sic_grid(seam_nan2, end);

    % 4. Schließe isolierte 1-Pixel-Lücken zwischen Bahnen
    if fill_holes
        nan_mask = isnan(sic_grid);
        kernel = [0 1 0; 1 0 1; 0 1 0];
        valid_neighbors = conv2(double(~nan_mask), kernel, 'same');

        grid_zero = sic_grid;
        grid_zero(nan_mask) = 0;
        sum_neighbors = conv2(grid_zero, kernel, 'same');

        % Wenn eine Zelle von mindestens 3 gültigen Nachbarn umgeben ist:
        fill_mask = nan_mask & (valid_neighbors >= 3);
        sic_grid(fill_mask) = sum_neighbors(fill_mask) ./ valid_neighbors(fill_mask);
    end

    % 5. Schwellenwerte erhalten: Werte < 0.15 auf 0, > 0.95 auf 1
    % sic_grid(sic_grid < 0.15) = 0;
    % sic_grid(sic_grid > 0.95) = 1;
end
