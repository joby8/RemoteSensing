% A4b: try tie-point mask thresholds (meeting 2026-11-20).
%  Goal: more water tie-point pixels, but COLD open water (a better water reference for the RTM), and less land
%  spill-over. Thresholds varied (tp_masks.m opt):
%    sst_min  water ERA5 sst > sst_min [K]       278 (current) 277 276 275
%    wlat_min water |lat| > wlat_min [deg]       0 (= only the preprocessing |lat| >= 50) or 55
%    lsm_max  both  ERA5 lsm <= lsm_max          0 (current) 0.10 0.15
%  For each variant and day: full correction (correct_day.m, 2 iterations, current clipping without 15 % filter).
%  Output: output/A4b_tp_sweep.csv (one row per day, hemisphere, variant) and A4b_tp_sweep_mean.csv (mean over days).
%  Run from the repo root: matlab -batch "addpath('src/matlab'); a4b_tp_sweep"   (optionally set days = ["0201" ...] before)
addpath(fullfile('src','matlab'));
files = dir(fullfile('ESMR_colocated_filtered','*.nc'));
fday  = string(regexp({files.name}, '1973m(\d{4})t', 'tokens', 'once'));
if ~exist('days','var') || isempty(days), days = ["0201" "0208" "0215" "0222"]; end
sst_v = [278 277 276 275]; lat_v = [0 55]; lsm_v = [0 0.10 0.15];
[S1, L1, M1] = ndgrid(sst_v, lat_v, lsm_v); V = [S1(:) L1(:) M1(:)];
rows = {};
for d = days(:)'
    fi = find(fday == d);
    fn = arrayfun(@(k) fullfile(files(k).folder, files(k).name), fi, 'UniformOutput', false);
    for q = 1:size(V, 1)
        tp = struct('sst_min', V(q,1), 'wlat_min', V(q,2), 'lsm_max', V(q,3));
        [~, TP] = correct_day(fn, 2, [], struct('tp', tp));
        for h = 'NS'
            t = TP.(h);
            rows(end+1, :) = {d, h, V(q,1), V(q,2), V(q,3), t.nw, t.ni, t.Mw.Ts, t.water_u, t.water_c, ...
                t.ice_u, t.ice_c, t.w_std_u, t.w_std_c, t.i_std_u, t.i_std_c}; %#ok<SAGROW>
        end
        fprintf('%s  sst>%d |lat|>%2d lsm<=%.2f  N: nw=%6d  S: nw=%6d\n', d, V(q,1), V(q,2), V(q,3), ...
            TP.N.nw, TP.S.nw);
    end
end
T = cell2table(rows, 'VariableNames', {'day','hemi','sst_min','wlat_min','lsm_max','nw','ni','sst_water', ...
    'water_u','water_c','ice_u','ice_c','w_std_u','w_std_c','i_std_u','i_std_c'});
writetable(T, fullfile('output','A4b_tp_sweep.csv'));
G = groupsummary(T, {'hemi','sst_min','wlat_min','lsm_max'}, 'mean', ...
    {'nw','ni','sst_water','water_c','ice_c','w_std_c','i_std_c'});
G = sortrows(G, {'hemi','lsm_max','wlat_min','sst_min'}, {'ascend','ascend','ascend','descend'});
writetable(G, fullfile('output','A4b_tp_sweep_mean.csv'));
disp(G(:, {'hemi','sst_min','wlat_min','lsm_max','mean_nw','mean_ni','mean_sst_water','mean_water_c', ...
    'mean_ice_c','mean_w_std_c','mean_i_std_c'}));
