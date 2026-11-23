% A4c: land rule of the tie-point masks (meeting 2026-11-20, correction of A4b point 4).
%  Goal: keep MORE land influence (spill-over) OUT of the tie points. The pixel's own ERA5 lsm cannot be stricter
%  than lsm = 0, so the stricter variants also test the land fraction in a box around the pixel.
%  Fixed: water sst > 275 K, |lat| > 55 deg (A4b). Variants of the land rule (both clusters):
%    pix0     pixel lsm = 0                                   (17 Nov rule)
%    pix10    pixel lsm <= 0.10                               (A4b default, LOOSER)
%    b3_10    pixel lsm = 0 and 3x3 box mean lsm <= 0.10
%    b3_0     pixel lsm = 0 and no land in the 3x3 box
%    b5_15    pixel lsm = 0 and 5x5 box mean lsm <= 0.15
%    b5_10    pixel lsm = 0 and 5x5 box mean lsm <= 0.10
%    b5_0     pixel lsm = 0 and no land in the 5x5 box
%  Output: output/A4c_land_sweep.csv, A4c_land_sweep_mean.csv.  Run from the repo root:
%    matlab -batch "addpath('src/matlab'); a4c_land_sweep"
addpath(fullfile('src','matlab'));
files = dir(fullfile('ESMR_colocated_filtered','*.nc'));
fday  = string(regexp({files.name}, '1973m(\d{4})t', 'tokens', 'once'));
if ~exist('days','var') || isempty(days), days = ["0201" "0208" "0215" "0222"]; end
V = struct('name', {'pix0','pix10','b3_10','b3_0','b5_15','b5_10','b5_0'}, ...
    'lsm_max', {0, 0.10, 0, 0, 0, 0, 0}, 'lsm_box', {0, 0, 3, 3, 5, 5, 5}, 'lsm_boxmax', {1, 1, 0.10, 0, 0.15, 0.10, 0});
rows = {};
for d = days(:)'
    fi = find(fday == d);
    fn = arrayfun(@(k) fullfile(files(k).folder, files(k).name), fi, 'UniformOutput', false);
    for q = 1:numel(V)
        tp = struct('sst_min', 275, 'wlat_min', 55, 'lsm_max', V(q).lsm_max, 'lsm_box', V(q).lsm_box, ...
                    'lsm_boxmax', V(q).lsm_boxmax);
        [~, TP] = correct_day(fn, 2, [], struct('tp', tp));
        for h = 'NS'
            t = TP.(h);
            rows(end+1, :) = {d, h, V(q).name, t.nw, t.ni, t.Mw.Ts, t.water_c, t.ice_c, t.w_std_c, t.i_std_c}; %#ok<SAGROW>
        end
        fprintf('%s %-6s N nw=%6d ni=%6d  S nw=%6d ni=%6d\n', d, V(q).name, TP.N.nw, TP.N.ni, TP.S.nw, TP.S.ni);
    end
end
T = cell2table(rows, 'VariableNames', {'day','hemi','variant','nw','ni','sst_water','water_c','ice_c','w_std_c','i_std_c'});
writetable(T, fullfile('output','A4c_land_sweep.csv'));
G = groupsummary(T, {'hemi','variant'}, 'mean', {'nw','ni','water_c','ice_c','w_std_c','i_std_c'});
[~, ord] = ismember(G.variant, {V.name}); G = sortrows(addvars(G, ord), {'hemi','ord'}); G.ord = [];
writetable(G, fullfile('output','A4c_land_sweep_mean.csv'));
disp(G(:, {'hemi','variant','mean_nw','mean_ni','mean_water_c','mean_ice_c','mean_w_std_c','mean_i_std_c'}));
