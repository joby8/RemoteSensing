function out = resampleNearest(DataOfDay, d_grid, max_dist_deg)
%RESAMPLENEAREST Nearest-Neighbor-Resampling aller Felder in DataOfDay
% für |Latitude| > 50° mit Datumsgrenzen-Korrektur (-180° / +180°).
% Erhält Rauschen und Pixelwerte weitgehend unverfälscht.
%
%   Aufruf:
%     out = resampleNearest(DataOfDay, [d_lon, d_lat], [max_lon, max_lat])
%     out = resampleNearest(DataOfDay, d_grid, max_dist_deg)
%
%   Eingaben:
%     DataOfDay    - Struct mit Feldern: Tbfilt, Latitude, Longitude, lsm, u10,
%                    v10, t2m, siconc, sst, tcw, tcwv, incidence
%     d_grid       - Gitterauflösung in Grad: Skalar d oder [d_lon, d_lat]
%                    (Standard: [0.05, 0.05])
%     max_dist_deg - Maximaler Suchradius in Grad: Skalar r oder [max_lon, max_lat]
%                    (Standard: 1.5 * [d_lon, d_lat]; weiter entfernte Punkte -> NaN)

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

    if nargin < 3 || isempty(max_dist_deg)
        max_lon = 1.5 * d_lon;
        max_lat = 1.5 * d_lat;
    elseif isscalar(max_dist_deg)
        max_lon = double(max_dist_deg);
        max_lat = double(max_dist_deg);
    elseif numel(max_dist_deg) == 2
        max_lon = double(max_dist_deg(1));
        max_lat = double(max_dist_deg(2));
    else
        error('max_dist_deg muss ein Skalar oder ein 2-Element-Vektor [max_lon, max_lat] sein.');
    end

    if max_lon <= 0 || max_lat <= 0
        error('max_lon und max_lat müssen positiv sein.');
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

    % 1. Nur gültige Quellpunkte mit |lat| > 50° (inkl. Randpuffer max_lat) behalten
    valid_coord = isfinite(lat(:)) & isfinite(lon(:)) & (abs(lat(:)) > (50 - max_lat));
    src_lat = lat(valid_coord);
    src_lon = mod(lon(valid_coord) + 180, 360) - 180;
    clear lat lon

    if isempty(src_lat)
        error('Keine gültigen Koordinaten im Bereich |Latitude| > 50° vorhanden.');
    end

    % 2. Zielgitter für |lat| > 50° und Longitude auf [-180, 180] aufbauen
    min_lat = min(src_lat);
    max_lat_data = max(src_lat);

    if min_lat < -50
        lat_south = floor(min_lat / d_lat) * d_lat : d_lat : (floor(-50 / d_lat) * d_lat - d_lat);
    else
        lat_south = [];
    end

    if max_lat_data > 50
        lat_north = (ceil(50 / d_lat) * d_lat + d_lat) : d_lat : ceil(max_lat_data / d_lat) * d_lat;
    else
        lat_north = [];
    end

    lat_vec = [lat_south, lat_north];
    clear lat_south lat_north min_lat max_lat_data

    if isempty(lat_vec)
        error('Kein Zielgitter-Bereich mit |Latitude| > 50° abgedeckt.');
    end

    lon_min = max(-180, floor(min(src_lon) / d_lon) * d_lon);
    lon_max = min(180,  ceil(max(src_lon)  / d_lon) * d_lon);
    lon_vec = lon_min : d_lon : lon_max;

    [lon_grid, lat_grid] = meshgrid(lon_vec, lat_vec);
    clear lon_vec lat_vec lon_min lon_max

    grid_sz  = size(lat_grid);
    n_target = numel(lat_grid);

    tgt_lat = lat_grid(:);
    tgt_lon = lon_grid(:);

    % 3. Nächsten Nachbarn pro Zielpunkt bestimmen (normierte Distanz über max_lon / max_lat)
    % nearest_idx(t) speichert den Index in src_lat (0 = kein Punkt innerhalb max_dist_deg)
    nearest_idx = zeros(n_target, 1, 'int32');
    max_norm_sq = 1.0;

    [src_lat_sorted, sort_order] = sort(src_lat);
    src_lon_sorted = src_lon(sort_order);
    clear src_lat src_lon

    for t = 1:n_target
        tlat = tgt_lat(t);
        tlon = tgt_lon(t);

        i_start = find(src_lat_sorted >= (tlat - max_lat), 1, 'first');
        i_end   = find(src_lat_sorted <= (tlat + max_lat), 1, 'last');
        if isempty(i_start) || isempty(i_end) || i_start > i_end
            continue;
        end

        cand_pos = i_start:i_end;
        dlat_n   = (src_lat_sorted(cand_pos) - tlat) ./ max_lat;

        dlon_raw = src_lon_sorted(cand_pos) - tlon;
        dlon_wrp = mod(dlon_raw + 180, 360) - 180;
        dlon_n   = dlon_wrp ./ max_lon;

        d2_norm = dlat_n.^2 + dlon_n.^2;
        [min_d2, local_min_pos] = min(d2_norm);

        if min_d2 <= max_norm_sq
            best_pos = cand_pos(local_min_pos);
            nearest_idx(t) = int32(sort_order(best_pos));
        end
    end

    clear tgt_lat tgt_lon src_lat_sorted src_lon_sorted sort_order

    % 4. Felder einzeln per Nearest-Neighbor zuweisen und direkt freigeben
    Tbfilt_grid    = assign_nearest_field(DataOfDay.Tbfilt,    valid_coord, nearest_idx, grid_sz);
    lsm_grid       = assign_nearest_field(DataOfDay.lsm,       valid_coord, nearest_idx, grid_sz);
    u10_grid       = assign_nearest_field(DataOfDay.u10,       valid_coord, nearest_idx, grid_sz);
    v10_grid       = assign_nearest_field(DataOfDay.v10,       valid_coord, nearest_idx, grid_sz);
    t2m_grid       = assign_nearest_field(DataOfDay.t2m,       valid_coord, nearest_idx, grid_sz);
    siconc_grid    = assign_nearest_field(DataOfDay.siconc,    valid_coord, nearest_idx, grid_sz);
    sst_grid       = assign_nearest_field(DataOfDay.sst,       valid_coord, nearest_idx, grid_sz);
    tcw_grid       = assign_nearest_field(DataOfDay.tcw,       valid_coord, nearest_idx, grid_sz);
    tcwv_grid      = assign_nearest_field(DataOfDay.tcwv,      valid_coord, nearest_idx, grid_sz);
    incidence_grid = assign_nearest_field(DataOfDay.incidence, valid_coord, nearest_idx, grid_sz);

    clear nearest_idx valid_coord

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

function field_grid = assign_nearest_field(raw_mat, valid_coord, nearest_idx, grid_sz)
    n_target = prod(grid_sz);
    raw_vec  = single(raw_mat);
    raw_vec  = raw_vec(valid_coord);
    res_vec  = nan(n_target, 1, 'single');

    has_nn = nearest_idx > 0;
    res_vec(has_nn) = raw_vec(nearest_idx(has_nn));

    clear raw_vec
    field_grid = reshape(res_vec, grid_sz);
end