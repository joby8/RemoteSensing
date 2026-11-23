% A4d: lower SST limit of the water tie point (follow-up to A4b/A4c, 2026-11-23).
%  Masks fixed at the 20 Nov defaults (tp_opt: |lat| > 55 deg for water, lsm = 0 + 5x5 box land <= 10 %),
%  only the water SST limit varies: sst > 275 (default) 274 273 K. Same 4 days as A4b/A4c.
%  Output: output/A4d_sst_sweep.csv and A4d_sst_sweep_mean.csv.
%  Run from the repo root: matlab -batch "addpath('src/matlab'); a4d_sst_sweep"
addpath(fullfile('src','matlab'));
files = dir(fullfile('ESMR_colocated_filtered','*.nc'));
fday  = string(regexp({files.name}, '1973m(\d{4})t', 'tokens', 'once'));
if ~exist('days','var') || isempty(days), days = ["0201" "0208" "0215" "0222"]; end
sst_v = [275 274 273];
rows = {};
for d = days(:)'
    fi = find(fday == d);
    fn = arrayfun(@(k) fullfile(files(k).folder, files(k).name), fi, 'UniformOutput', false);
    for s = sst_v
        [~, TP] = correct_day(fn, 2, [], struct('tp', struct('sst_min', s)));
        for h = 'NS'
            t = TP.(h);
            rows(end+1, :) = {d, h, s, t.nw, t.ni, t.Mw.Ts, t.water_u, t.water_c, t.ice_u, t.ice_c, ...
                t.w_std_u, t.w_std_c, t.i_std_u, t.i_std_c}; %#ok<SAGROW>
        end
        fprintf('%s  sst>%d  N: nw=%6d  S: nw=%6d\n', d, s, TP.N.nw, TP.S.nw);
    end
end
T = cell2table(rows, 'VariableNames', {'day','hemi','sst_min','nw','ni','sst_water', ...
    'water_u','water_c','ice_u','ice_c','w_std_u','w_std_c','i_std_u','i_std_c'});
writetable(T, fullfile('output','A4d_sst_sweep.csv'));
G = groupsummary(T, {'hemi','sst_min'}, 'mean', {'nw','ni','sst_water','water_c','ice_c','w_std_c','i_std_c'});
G = sortrows(G, {'hemi','sst_min'}, {'ascend','descend'});
writetable(G, fullfile('output','A4d_sst_sweep_mean.csv'));
disp(G(:, {'hemi','sst_min','mean_nw','mean_ni','mean_sst_water','mean_water_c','mean_ice_c','mean_w_std_c','mean_i_std_c'}));
