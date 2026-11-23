function out = resampleGaussian(DataOfDay, d_grid, sigma_deg)
%RESAMPLEGAUSSIAN Speicheroptimiertes Gaussian Resampling für |Latitude| > 50°.
%
%   Berechnet Werte nur für Breitengrade kleiner als -50° und größer als +50°.

    if nargin < 2 || isempty(d_grid)
        d_lon = 0.05;
        d_lat = 0.05;
    elseif isscalar(d_grid)
        d_lon = double(d_grid);
        d_lat = double(d_grid);
    elseif numel(d_grid) == 2
        d_lon = double(d_grid(1));
        d_lat = double(d_grid(2));
    else
        error('d_grid muss ein Skalar oder ein 2-Element-Vektor [d_lon, d_lat] sein.');
    end

    if d_lon <= 0 || d_lat <= 0
        error('d_lon und d_lat müssen positiv sein.');
    end

    if nargin < 3 || isempty(sigma_deg)
        sig_lon = 1.5 * d_lon;
        sig_lat = 1.5 * d_lat;
    elseif isscalar(sigma_deg)
        sig_lon = double(sigma_deg);
        sig_lat = double(sigma_deg);
    elseif numel(sigma_deg) == 2
        sig_lon = double(sigma_deg(1));
        sig_lat = double(sigma_deg(2));
    else
        error('sigma_deg muss ein Skalar oder ein 2-Element-Vektor [sigma_lon, sigma_lat] sein.');
    end

    if sig_lon <= 0 || sig_lat <= 0
        error('sigma_lon und sigma_lat müssen positiv sein.');
    end

    if ~isstruct(DataOfDay) || ~isscalar(DataOfDay)
        error('DataOfDay muss ein skalares Struct sein.');
    end

    expected_fields = { ...
        'Tbfilt', 'Latitude', 'Longitude', 'lsm', 'u10', 'v10', ...
        't2m', 'siconc', 'sst', 'tcw', 'tcwv', 'incidence'};

    missing = setdiff(expected_fields, fieldnames(DataOfDay));
    if ~isempty(missing)
        error('Fehlende Felder in DataOfDay: %s', strjoin(missing, ', '));
    end

    lat = double(DataOfDay.Latitude);
    lon = double(DataOfDay.Longitude);
    sz  = size(lat);

    for i = 1:numel(expected_fields)
        f = expected_fields{i};
        if ~isequal(size(DataOfDay.(f)), sz)
            error('Feld "%s" hat nicht dieselbe Größe wie Latitude/Longitude.', f);
        end
    end

    % 1. Nur gültige Quellpunkte mit |lat| > 50° behalten (inkl. Randpuffer für 3*sigma)
    lat_pad = 3 * sig_lat;
    valid_coord = isfinite(lat(:)) & isfinite(lon(:)) & (abs(lat(:)) > (50 - lat_pad));
    src_lat = lat(valid_coord);
    src_lon = lon(valid_coord);
    clear lat lon lat_pad

    if isempty(src_lat)
        error('Keine gültigen Koordinaten im Bereich |Latitude| > 50° vorhanden.');
    end

    % 2. Zielgitter-Vektoren nur für lat < -50° und lat > +50° aufbauen
    min_lat = min(src_lat);
    max_lat = max(src_lat);

    if min_lat < -50
        lat_south = floor(min_lat / d_lat) * d_lat : d_lat : (floor(-50 / d_lat) * d_lat - d_lat);
    else
        lat_south = [];
    end

    if max_lat > 50
        lat_north = (ceil(50 / d_lat) * d_lat + d_lat) : d_lat : ceil(max_lat / d_lat) * d_lat;
    else
        lat_north = [];
    end

    lat_vec = [lat_south, lat_north];
    clear lat_south lat_north min_lat max_lat

    if isempty(lat_vec)
        error('Kein Zielgitter-Bereich mit |Latitude| > 50° abgedeckt.');
    end

    lon_vec = floor(min(src_lon) / d_lon) * d_lon : d_lon : ceil(max(src_lon) / d_lon) * d_lon;
    [lon_grid, lat_grid] = meshgrid(lon_vec, lat_vec);
    clear lon_vec lat_vec

    grid_sz  = size(lat_grid);
    n_target = numel(lat_grid);

    % 3. Nachbarsuche und Gauss-Gewichte im skalierten Raum berechnen
    cutoff_scaled = 3.0;
    target_scaled = [lat_grid(:) ./ sig_lat, lon_grid(:) ./ sig_lon];
    source_scaled = [src_lat(:) ./ sig_lat, src_lon(:) ./ sig_lon];
    clear src_lat src_lon

    [idx_cell, dist_cell] = rangesearch(source_scaled, target_scaled, cutoff_scaled);
    clear source_scaled target_scaled

    src_idx_cell = cell(n_target, 1);
    weights_cell = cell(n_target, 1);

    for t = 1:n_target
        idx = idx_cell{t};
        if ~isempty(idx)
            d = single(dist_cell{t});
            src_idx_cell{t} = int32(idx(:));
            weights_cell{t} = exp(-0.5 .* (d(:) .^ 2));
        end
    end

    clear idx_cell dist_cell

    % 4. Felder einzeln resamplen und direkt freigeben
    Tbfilt_grid    = resample_single_field(DataOfDay.Tbfilt,    valid_coord, src_idx_cell, weights_cell, grid_sz);
    lsm_grid       = resample_single_field(DataOfDay.lsm,       valid_coord, src_idx_cell, weights_cell, grid_sz);
    u10_grid       = resample_single_field(DataOfDay.u10,       valid_coord, src_idx_cell, weights_cell, grid_sz);
    v10_grid       = resample_single_field(DataOfDay.v10,       valid_coord, src_idx_cell, weights_cell, grid_sz);
    t2m_grid       = resample_single_field(DataOfDay.t2m,       valid_coord, src_idx_cell, weights_cell, grid_sz);
    siconc_grid    = resample_single_field(DataOfDay.siconc,    valid_coord, src_idx_cell, weights_cell, grid_sz);
    sst_grid       = resample_single_field(DataOfDay.sst,       valid_coord, src_idx_cell, weights_cell, grid_sz);
    tcw_grid       = resample_single_field(DataOfDay.tcw,       valid_coord, src_idx_cell, weights_cell, grid_sz);
    tcwv_grid      = resample_single_field(DataOfDay.tcwv,      valid_coord, src_idx_cell, weights_cell, grid_sz);
    incidence_grid = resample_single_field(DataOfDay.incidence, valid_coord, src_idx_cell, weights_cell, grid_sz);

    clear src_idx_cell weights_cell valid_coord

    out = struct( ...
        'Tbfilt',    Tbfilt_grid, ...
        'Latitude',  lat_grid, ...
        'Longitude', lon_grid, ...
        'lsm',       lsm_grid, ...
        'u10',       u10_grid, ...
        'v10',       v10_grid, ...
        't2m',       t2m_grid, ...
        'siconc',    siconc_grid, ...
        'sst',       sst_grid, ...
        'tcw',       tcw_grid, ...
        'tcwv',      tcwv_grid, ...
        'incidence', incidence_grid);
end

function field_grid = resample_single_field(raw_mat, valid_coord, src_idx_cell, weights_cell, grid_sz)
    n_target = prod(grid_sz);
    raw_vec  = single(raw_mat);
    raw_vec  = raw_vec(valid_coord);
    res_vec  = nan(n_target, 1, 'single');

    for t = 1:n_target
        idx = src_idx_cell{t};
        if isempty(idx)
            continue;
        end
        vals = raw_vec(idx);
        w    = weights_cell{t};
        ok   = isfinite(vals);
        if any(ok)
            res_vec(t) = sum(w(ok) .* vals(ok)) / sum(w(ok));
        end
    end

    clear raw_vec
    field_grid = reshape(res_vec, grid_sz);
end