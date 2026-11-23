% A4e: tie-point outlier test (tp_outlier.m, 2026-11-23), all days of Feb 1973.
%  Masks = tp_opt() defaults (sst > 273 K, |lat| > 55, lsm = 0 + 5x5 box <= 10 %). Two runs per day:
%  tb_mad = 3 and tb_mad = 0 (no outlier test, the default since 2026-11-23). The test runs on the corrected TB of iteration 1
%  (correct_day.m); lim_* = its [lo hi] limits. For the removed pixels: low/high side, mean wind and
%  water vapour (do we remove real weather, e.g. storms, or artefacts?).
%  Output: output/A4e_tp_outliers.csv (one row per day and hemisphere).
%  Run from the repo root: matlab -batch "addpath('src/matlab'); a4e_tp_outliers"
addpath(fullfile('src','matlab'));
files = dir(fullfile('ESMR_colocated_filtered','*.nc'));
fday  = string(regexp({files.name}, '1973m(\d{4})t', 'tokens', 'once'));
if ~exist('days','var') || isempty(days), days = unique(fday); end
rows = {};
for d = days(:)'
    fi = find(fday == d);
    fn = arrayfun(@(k) fullfile(files(k).folder, files(k).name), fi, 'UniformOutput', false);
    [O, TP]  = correct_day(fn, 2, [], struct('tp', struct('tb_mad', 3)));
    [~, TP0] = correct_day(fn, 2, [], struct('tp', struct('tb_mad', 0)));
    for h = 'NS'
        hs = arrayfun(@(o) (o.lat > 0) == (h == 'N'), O, 'UniformOutput', false);
        g = @(f, m) cell2mat(arrayfun(@(o, s) o.(f)(o.(m) & s{1}), O, hs, 'UniformOutput', false)');
        t = TP.(h); t0 = TP0.(h);
        for k = 1:numel(O), O(k).tbc = O(k).tb_f + O(k).dtb; end   % corrected TB (iteration 2; the test uses iteration 1)
        g = @(f, m) cell2mat(arrayfun(@(o, s) o.(f)(o.(m) & s{1}), O, hs, 'UniformOutput', false)');
        wx = g('tbc', 'mwx'); ix = g('tbc', 'mix');   % side: below / above the cluster median (middle of the limits)
        rows(end+1, :) = {d, h, t0.nw, t.nwx, nnz(wx < mean(t.lim_w)), nnz(wx > mean(t.lim_w)), t.lim_w(1), t.lim_w(2), ...
            t0.ni, t.nix, nnz(ix < mean(t.lim_i)), nnz(ix > mean(t.lim_i)), t.lim_i(1), t.lim_i(2), ...
            t0.water_c, t.water_c, t0.ice_c, t.ice_c, t0.w_std_c, t.w_std_c, t0.i_std_c, t.i_std_c, ...
            mean(g('W', 'mw')), mean(g('W', 'mwx')), mean(g('V', 'mw')), mean(g('V', 'mwx'))}; %#ok<SAGROW>
        fprintf('%s %s  water -%d of %d  ice -%d of %d  w_std %.2f -> %.2f  i_std %.2f -> %.2f\n', d, h, ...
            t.nwx, t0.nw, t.nix, t0.ni, t0.w_std_c, t.w_std_c, t0.i_std_c, t.i_std_c);
    end
end
T = cell2table(rows, 'VariableNames', {'day','hemi','nw0','nwx','nwx_lo','nwx_hi','w_lo','w_hi', ...
    'ni0','nix','nix_lo','nix_hi','i_lo','i_hi','water_c0','water_c','ice_c0','ice_c', ...
    'w_std0','w_std','i_std0','i_std','W_kept','W_out','V_kept','V_out'});
writetable(T, fullfile('output','A4e_tp_outliers.csv'));
