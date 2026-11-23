function [T1_grid, T2_grid, lon_grid, lat_grid] = resampleNearestSIC(T1, T2, lat, lon, d_grid, max_dist_deg)
%RESAMPLENEARESTTWOT Nearest-Neighbor für zwei Temperaturfelder (T1, T2)
% auf gemeinsamem Grid bei |lat| > 50° und Datumsgrenzen-Korrektur (-180° / +180°).

    if nargin < 5 || isempty(d_grid)
        d_lon = 0.05;
        d_lat = 0.05;
    elseif isscalar(d_grid)
        d_lon = double(d_grid);
        d_lat = double(d_grid);
    elseif numel(d_grid) == 2
        d_lon = double(d_grid(1));
        d_lat = double(d_grid(2));
    else
        error('d_grid muss ein Skalar oder [d_lon, d_lat] sein.');
    end

    if nargin < 6 || isempty(max_dist_deg)
        max_lon = 1.5 * d_lon;
        max_lat = 1.5 * d_lat;
    elseif isscalar(max_dist_deg)
        max_lon = double(max_dist_deg);
        max_lat = double(max_dist_deg);
    elseif numel(max_dist_deg) == 2
        max_lon = double(max_dist_deg(1));
        max_lat = double(max_dist_deg(2));
    else
        error('max_dist_deg muss ein Skalar oder [max_lon, max_lat] sein.');
    end

    if ~isequal(size(T1), size(T2)) || ~isequal(size(T1), size(lat)) || ~isequal(size(T1), size(lon))
        error('T1, T2, lat und lon müssen dieselbe Größe haben.');
    end

    lat = double(lat);
    lon = double(lon);

    % 1. Nur gültige Koordinaten mit |lat| > 50° (inkl. Puffer max_lat) behalten
    valid = isfinite(lat(:)) & isfinite(lon(:)) & (abs(lat(:)) > (50 - max_lat));
    src_lat = lat(valid);
    src_lon = mod(lon(valid) + 180, 360) - 180;
    clear lat lon

    if isempty(src_lat)
        error('Keine gültigen Koordinaten im Bereich |Latitude| > 50° vorhanden.');
    end

    % 2. Zielgitter für |lat| > 50° aufbauen
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
    tgt_lat  = lat_grid(:);
    tgt_lon  = lon_grid(:);

    % 3. Nächsten Nachbarn einmalig für beide Temperaturfelder suchen
    nearest_idx = zeros(n_target, 1, 'int32');

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

        if min_d2 <= 1.0
            nearest_idx(t) = int32(sort_order(cand_pos(local_min_pos)));
        end
    end

    clear tgt_lat tgt_lon src_lat_sorted src_lon_sorted sort_order

    % 4. Beide Temperaturfelder einzeln zuweisen und direkt freigeben
    T1_grid = map_single_T(T1, valid, nearest_idx, grid_sz);
    T2_grid = map_single_T(T2, valid, nearest_idx, grid_sz);
end

function T_grid = map_single_T(raw_T, valid, nearest_idx, grid_sz)
    n_target = prod(grid_sz);
    src_T    = single(raw_T);
    src_T    = src_T(valid);
    res_vec  = nan(n_target, 1, 'single');

    has_nn = nearest_idx > 0;
    res_vec(has_nn) = src_T(nearest_idx(has_nn));

    clear src_T
    T_grid = reshape(res_vec, grid_sz);
end