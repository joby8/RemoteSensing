% A3b: validate our preprocessing (esmr_preprocess.m) against DMI's prefiltered field
% 'brightness_temperature_filtered', over all 312 orbits of Feb 1973.
%   (a) pixel-by-pixel confusion tables for the presets 'default', 'paper', 'dmilike' (preproc_config.m)
%   (b) what DMI removes in addition: line-level tests of hypotheses for DMI's extra rule
%   (c) sanity checks: neighbour differences left in the used area, hard cases, pixels per step
%   (d) downstream: A6b method (correct_day.m, iteration 2) on 9 days for every preset + the DMI field
% Outputs: output/A3b_*.csv, output/A3b_*.png. Notes: report_notes/A3b_filter_validation.md
% Run from anywhere: matlab -batch "run('src/matlab/a3b_validate_filters.m')"   (~15 min)
% Only parts: set e.g. parts = "abc" or "d" before run().
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile('src', 'matlab'));
if ~exist('parts', 'var'), parts = "abcd"; end
files = dir(fullfile('ESMR_colocated_filtered', '*.nc'));
fn = @(k) fullfile(files(k).folder, files(k).name);
nf = numel(files);
PN = {'default', 'paper', 'dmilike', 'dmi'};                 % presets; 'dmi' = DMI field itself
CF = cellfun(@preproc_config, PN, 'UniformOutput', false); CF = [CF{:}];
npn = numel(PN);
LBL = strrep(PN, 'default', '\default');                    % 'default' alone is a graphics keyword
EDG = 0:0.5:600;                                             % histogram of |neighbour difference| [K]

if contains(parts, "a") || contains(parts, "b") || contains(parts, "c")
%% loop over all orbits
conf  = zeros(3, 2, 4);              % preset x (all, area) x (kept both, removed both, DMI only, ours only)
flagN = zeros(npn, 9); flagA = zeros(npn, 9);   % pixels per flag code, all / inside the used area
hAl = zeros(npn, numel(EDG)-1); hAc = hAl; mAl = zeros(npn, 1); mAc = mAl;   % along / across differences
nPix = 0; nArea = 0;
LN = struct('orb', [], 'line', [], 'nl', [], 'dmi', [], 'pixonly', [], 'an_diff', [], 'an_g15', [], ...
    'eq2', [], 'eq3f', [], 'eq3raw', [], 'eq3wrap', [], 'gap', [], 'dt', [], 'stat', [], 'G', []);
for k = 1:nf
    o = load_orbit(fn(k));                                   % default preset
    [nl, np] = size(o.tb);
    E = false(nl, np); E(:, setdiff(1:78, CF(1).edge)) = true;
    area = E & abs(o.lat) >= 50 & ~isnan(o.sst);             % positions 5-74, |lat| >= 50, ocean: fixed comparison
                                                             % region, deliberately NOT o.valid (that depends on the filter)
    dm = isnan(o.tb_file);
    for c = 1:npn
        if c == 1, q = o; else, q = esmr_preprocess(o, CF(c)); end
        rm = isnan(q.tb_f);
        if c <= 3
            for a = 1:2
                if a == 1, R = true(nl, np); else, R = area; end
                conf(c, a, :) = squeeze(conf(c, a, :)) + [nnz(~rm & ~dm & R); nnz(rm & dm & R); nnz(~rm & dm & R); nnz(rm & ~dm & R)];
            end
        end
        flagN(c, :) = flagN(c, :) + accumarray(double(q.flag(:)) + 1, 1, [9 1])';
        flagA(c, :) = flagA(c, :) + accumarray(double(q.flag(area)) + 1, 1, [9 1])';
        v  = ~rm & area;
        al = v(1:end-1, :) & v(2:end, :) & ~q.F.gap;  d1 = abs(diff(q.tb_f, 1, 1)); d1 = d1(al);
        ac = v(:, 1:end-1) & v(:, 2:end);              d2 = abs(diff(q.tb_f, 1, 2)); d2 = d2(ac);
        hAl(c, :) = hAl(c, :) + histcounts(d1, EDG); hAc(c, :) = hAc(c, :) + histcounts(d2, EDG);
        mAl(c) = max([mAl(c); d1]); mAc(c) = max([mAc(c); d2]);
    end
    nPix = nPix + nl * np; nArea = nArea + nnz(area);
    % ---- line-level indicators for (b)
    t  = o.tb; e1 = ~(t > 90 & t <= 273.15); tf = t; tf(e1) = NaN;
    up = abs([NaN(1, np); diff(t)]); dn = abs([diff(t); NaN(1, np)]);
    upf = abs([NaN(1, np); diff(tf)]); dnf = abs([diff(tf); NaN(1, np)]);
    smw = abs(t - circshift(t, 1, 1)) + abs(circshift(t, -1, 1) - t);
    D  = mean(abs(diff(tf)), 2, 'omitnan'); j2 = [D > 50; false] | [false; D > 50];
    A  = o.A; g = zeros(nl, 16); g(2:end-1, :) = (A(3:end, :) - A(1:end-2, :)) / 2;
    g(1, :) = A(2, :) - A(1, :); g(end, :) = A(end, :) - A(end-1, :);
    ad = any(abs(diff(A)) > 10, 2);
    tm = double(ncread(fn(k), 'Time')); s1 = str2double(strtrim(ncread(fn(k), 'Status_indicator_1')));
    LN.orb = [LN.orb; k * ones(nl, 1)]; LN.line = [LN.line; (1:nl)']; LN.nl = [LN.nl; nl * ones(nl, 1)];
    LN.dmi = [LN.dmi; all(dm, 2) & ~all(e1, 2)];                  % DMI removes the line, not just Eq. 1 pixels
    LN.pixonly = [LN.pixonly; nnz(dm & ~e1 & ~all(dm, 2))];      % DMI-only pixels outside whole lines (should be 0)
    LN.an_diff = [LN.an_diff; [ad; false] | [false; ad]];
    LN.an_g15 = [LN.an_g15; any(abs(g(:, 1:15)) > 10, 2)];
    LN.G   = [LN.G; abs(g) > 10];
    LN.eq2 = [LN.eq2; j2];
    LN.eq3f = [LN.eq3f; any(upf + dnf > 150, 2)];
    LN.eq3raw = [LN.eq3raw; any(up + dn > 150, 2)];
    LN.eq3wrap = [LN.eq3wrap; any(smw > 150, 2)];
    LN.gap = [LN.gap; [o.F.gap; false] | [false; o.F.gap]];
    LN.dt  = [LN.dt; [diff(tm); 4]];
    LN.stat = [LN.stat; s1];
    if mod(k, 50) == 0, fprintf('%d/%d orbits\n', k, nf); end
end
save(fullfile('output', 'A3b_cache.mat'), 'conf', 'flagN', 'flagA', 'hAl', 'hAc', 'mAl', 'mAc', 'nPix', 'nArea', 'LN', '-v7.3');
end

if contains(parts, "a")
%% (a) confusion tables
S = load(fullfile('output', 'A3b_cache.mat'));
rows = {};
for c = 1:3, for a = 1:2
    x = squeeze(S.conf(c, a, :))'; n = sum(x);
    rg = ["all", "area"]; rows(end+1, :) = {PN{c}, rg(a), x(1), x(2), x(3), x(4), 100*(x(1)+x(2))/n, n}; %#ok<SAGROW>
end, end
T = cell2table(rows, 'VariableNames', {'preset', 'region', 'kept_both', 'removed_both', 'removed_DMI_only', 'removed_ours_only', 'agree_pct', 'n'});
writetable(T, fullfile('output', 'A3b_confusion.csv')); disp(T);
end

if contains(parts, "b")
%% (b) DMI's extra rule: line-level hypotheses
S = load(fullfile('output', 'A3b_cache.mat')); L = S.LN;
fprintf('DMI-only pixels outside whole removed lines: %d\n', sum(L.pixonly));
dil = @(x, k) cell2mat(arrayfun(@(r) movmax(double(x(L.orb == r)), [k k]) > 0, (1:nf)', 'UniformOutput', false));
cdil = @(x, k) cell2mat(arrayfun(@(r) cdil1(x(L.orb == r), k), (1:nf)', 'UniformOutput', false));
st0 = mode(L.stat);
H = { % name, line mask
    'analog |diff| > 10 (ch 0-15), +-0',        L.an_diff
    'analog |diff| > 10 (ch 0-15), +-5',        dil(L.an_diff, 5)
    'analog central gradient > 10 (ch 0-14), +-5', dil(L.an_g15, 5)
    'Eq. 2 jump (row mean > 50 K), +-1',        dil(L.eq2, 1)
    'Eq. 2 jump (row mean > 50 K), +-2',        dil(L.eq2, 2)
    'Eq. 3 after Eq. 1, +-1',                   dil(L.eq3f, 1)
    'Eq. 3 on raw TB, +-1',                     dil(L.eq3raw, 1)
    'Eq. 3 on raw TB, wrap-around, +-1',        cdil(L.eq3wrap, 1)
    'data gap, +-2',                            dil(L.gap, 2)
    'time step ~= 4 s',                         abs(L.dt - 4) > 0.05
    'Status_indicator_1 not the usual value',   L.stat ~= st0
    'last 3 lines of the file',                 L.line > L.nl - 3
    'DMI-like = Eq. 3 raw wrap +-1 OR analog gradient ch 0-14 +-5', cdil(L.eq3wrap, 1) | dil(L.an_g15, 5)};
rows = {};
for i = 1:size(H, 1)
    m = H{i, 2}; tp = nnz(m & L.dmi);
    rows(end+1, :) = {H{i, 1}, nnz(m), tp, 100*tp/nnz(L.dmi), 100*tp/max(nnz(m), 1)}; %#ok<SAGROW>
end
TH = cell2table(rows, 'VariableNames', {'hypothesis', 'lines_flagged', 'DMI_lines_hit', 'recall_pct', 'precision_pct'});
writetable(TH, fullfile('output', 'A3b_dmi_hypotheses.csv')); disp(TH);
fprintf('DMI lines (removed by DMI, not all Eq. 1): %d of %d lines\n', nnz(L.dmi), numel(L.dmi));
% analog channels: lines flagged ONLY by channel c (central gradient), share removed by DMI
rows = {};
for c = 1:16
    only = L.G(:, c) & ~any(L.G(:, [1:c-1 c+1:16]), 2);
    rows(end+1, :) = {sprintf('Analog_%d', c-1), nnz(L.G(:, c)), nnz(only), 100*mean(L.dmi(only))}; %#ok<SAGROW>
end
TC = cell2table(rows, 'VariableNames', {'channel', 'lines_flagged', 'lines_only_this_channel', 'of_those_DMI_pct'});
writetable(TC, fullfile('output', 'A3b_dmi_analog_channels.csv')); disp(TC);
% position in the file and day
rel = (L.line - 0.5) ./ L.nl; bins = discretize(rel, 0:0.1:1);
pr = accumarray(bins, L.dmi, [], @mean) * 100;
day = cellfun(@(t) str2double(t{1}), regexp({files.name}, '1973m02(\d{2})t', 'tokens', 'once'))';
pd = accumarray(day(L.orb), L.dmi, [], @mean) * 100;
po = accumarray(L.orb, L.dmi, [], @mean) * 100;
fprintf('DMI line share per tenth of the file [%%]: %s\n', sprintf('%.1f ', pr));
fprintf('orbits with > 50 %% of lines removed by DMI: %d; max share per orbit %.1f %%\n', nnz(po > 50), max(po));
fprintf('DMI line share per day: %.1f-%.1f %% (median %.1f %%); per orbit: median %.1f %%, 95th pct %.1f %%\n', min(pd), max(pd), median(pd), median(po), prctile(po, 95));
writetable(table((1:10)', pr, 'VariableNames', {'tenth_of_file', 'dmi_line_pct'}), fullfile('output', 'A3b_dmi_position.csv'));
% figure: block lengths and the two components of the rule
blk = []; for r = 1:nf, x = L.dmi(L.orb == r); d = diff([0; x; 0]); blk = [blk; find(d == -1) - find(d == 1)]; end %#ok<AGROW>
fig = figure('Position', [100 100 1100 380], 'Color', 'w', 'Visible', 'off');
tl = tiledlayout(fig, 1, 3, 'TileSpacing', 'compact');
ax = nexttile(tl); histogram(ax, blk, 0.5:1:40.5, 'FaceColor', [.3 .45 .7]);
xlabel(ax, 'length of a DMI block [scan lines]'); ylabel(ax, 'blocks'); title(ax, '(a) DMI removes blocks of 3, 5 and 16 lines', 'FontWeight', 'normal');
ax = nexttile(tl); bar(ax, categorical(TH.hypothesis, TH.hypothesis), [TH.recall_pct TH.precision_pct]);
ylabel(ax, '%'); legend(ax, {'recall', 'precision'}, 'Location', 'southoutside', 'Orientation', 'horizontal', 'Box', 'off');
title(ax, '(b) hypotheses vs. DMI lines', 'FontWeight', 'normal'); ax.FontSize = 7; ax.TickLabelInterpreter = 'none';
ax = nexttile(tl); bar(ax, 0:15, TC.of_those_DMI_pct, 'FaceColor', [.3 .45 .7]);
xlabel(ax, 'Analog channel'); ylabel(ax, 'lines flagged only by it, removed by DMI [%]');
title(ax, '(c) Analog\_15 is not used by DMI', 'FontWeight', 'normal');
exportgraphics(fig, fullfile('output', 'A3b_dmi_rule.png'), 'Resolution', 150); close(fig);
end

if contains(parts, "c")
%% (c) sanity checks
S = load(fullfile('output', 'A3b_cache.mat'));
cen = (EDG(1:end-1) + EDG(2:end)) / 2;
pc = @(h, p) cen(find(cumsum(h) >= p/100 * sum(h), 1));
rows = {};
for c = 1:npn
    rows(end+1, :) = {PN{c}, sum(S.hAl(c, :)), S.mAl(c), pc(S.hAl(c, :), 99.9), pc(S.hAl(c, :), 99.99), ...
        sum(S.hAc(c, :)), S.mAc(c), pc(S.hAc(c, :), 99.9), pc(S.hAc(c, :), 99.99)}; %#ok<SAGROW>
end
TN = cell2table(rows, 'VariableNames', {'preset', 'n_along', 'max_along_K', 'p999_along_K', 'p9999_along_K', ...
    'n_across', 'max_across_K', 'p999_across_K', 'p9999_across_K'});
writetable(TN, fullfile('output', 'A3b_neighbour_diffs.csv')); disp(TN);
names = ["kept", "Eq. 1", "Eq. 2", "Eq. 3", "Eq. 4", "analog", "edge", "latitude", "land"];
TF = array2table([S.flagN; S.flagA], 'VariableNames', cellstr(names));
TF = addvars(TF, [string(PN)'; string(PN)'], [repmat("all", npn, 1); repmat("area", npn, 1)], 'Before', 1, ...
    'NewVariableNames', {'preset', 'region'});
writetable(TF, fullfile('output', 'A3b_flag_counts.csv')); disp(TF);
fprintf('all pixels %d, used area %d\n', S.nPix, S.nArea);
% histograms of neighbour differences
fig = figure('Position', [100 100 1000 380], 'Color', 'w', 'Visible', 'off');
tl = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact'); col = lines(npn);
for d = 1:2
    ax = nexttile(tl); hold(ax, 'on');
    if d == 1, H = S.hAl; ttl = '(a) along track (consecutive scan lines)'; else, H = S.hAc; ttl = '(b) across track (neighbouring positions)'; end
    for c = 1:npn, stairs(ax, EDG(1:end-1), max(H(c, :), 0.5), 'Color', col(c, :), 'LineWidth', 1.2, 'DisplayName', LBL{c}); end
    set(ax, 'YScale', 'log'); xlim(ax, [0 150]); grid(ax, 'on');
    xlabel(ax, '|\DeltaT_B| [K]'); ylabel(ax, 'pixel pairs per 0.5 K'); title(ax, ttl, 'FontWeight', 'normal');
    if d == 2, legend(ax, 'Location', 'northeast', 'Box', 'off'); end
end
title(tl, 'Neighbour differences left in the used area (pos. 5-74, |lat| \geq 50°, ocean), all 312 orbits');
exportgraphics(fig, fullfile('output', 'A3b_neighbour_diffs.png'), 'Resolution', 150); close(fig);
% hard cases: TB around a spot, raw and after each preset
HC = { % file pattern, centre line, position range, label
    '1973m0220t0605', 657, 30:48, '20 Feb 06:05, line 657: 240 K next to -214 K (54.7°S 84.6°E)'
    '1973m0201t0421', 381, 1:78,  '1 Feb 04:21, lines 374-389: analog glitch (Analog\_8) + spike at line 387'
    '1973m0201t1113', 801, 1:78,  '1 Feb 11:13, lines 800-807: offset block (+110 K)'};
fig = figure('Position', [50 50 1500 900], 'Color', 'w', 'Visible', 'off');
tl = tiledlayout(fig, size(HC, 1), npn + 1, 'TileSpacing', 'compact', 'Padding', 'compact');
for h = 1:size(HC, 1)
    k = find(contains({files.name}, HC{h, 1}), 1); o = load_orbit(fn(k));
    rr = max(1, HC{h, 2} - 15):min(size(o.tb, 1), HC{h, 2} + 15); pp = HC{h, 3};
    for c = 0:npn
        ax = nexttile(tl);
        if c == 0, x = o.tb; ttl = 'raw'; else, q = esmr_preprocess(o, CF(c)); x = q.tb_f; ttl = LBL{c}; end
        imagesc(ax, pp, rr, x(rr, pp), 'AlphaData', ~isnan(x(rr, pp))); set(ax, 'Color', [.85 .85 .85]);
        clim(ax, [100 280]); colormap(ax, parula); axis(ax, 'tight');
        title(ax, ttl, 'FontWeight', 'normal');
        if c == 0, ylabel(ax, {HC{h, 4}, 'scan line'}, 'FontSize', 7); end
        if h == size(HC, 1), xlabel(ax, 'scan position'); end
    end
end
cb = colorbar(ax); cb.Layout.Tile = 'east'; cb.Label.String = 'T_B [K] (grey = removed)';
exportgraphics(fig, fullfile('output', 'A3b_hard_cases.png'), 'Resolution', 130); close(fig);
% the 20 Feb pixels
k = find(contains({files.name}, '1973m0220t0605'), 1); o = load_orbit(fn(k));
for c = 1:npn
    q = esmr_preprocess(o, CF(c));
    fprintf('20 Feb 06:05 line 657 pos 37-41 (%s): raw %s -> %s, flag %s\n', PN{c}, mat2str(o.tb(657, 37:41), 4), ...
        mat2str(q.tb_f(657, 37:41), 4), mat2str(q.flag(657, 37:41)));
end
end

if contains(parts, "d")
%% (d) downstream: A6b (correct_day, iteration 2) on 9 days, every preset + DMI field
fday = string(regexp({files.name}, '1973m(\d{4})t', 'tokens', 'once'));
days = compose("02%02d", 1:3:25);
% plus the old default (per-pixel Eq. 3, until 2026-11-17) and two diagnostic variants on top of it:
% which part of DMI's rule changes the result? (the new default = old default + line Eq. 3 without wrap)
CD = CF; PD = PN; LD = LBL;
c0 = CF(1); c0.eq3.mode = 'pixel'; c0.name = 'eq3pixel';  CD(end+1) = c0; PD{end+1} = c0.name; LD{end+1} = c0.name;
c1 = c0; c1.analog = CF(3).analog; c1.name = 'eq3pixel+analog'; CD(end+1) = c1; PD{end+1} = c1.name; LD{end+1} = c1.name;
c1 = c0; c1.eq3 = CF(3).eq3;       c1.name = 'eq3pixel+eq3line_wrap'; CD(end+1) = c1; PD{end+1} = c1.name; LD{end+1} = c1.name;
rows = {};
for c = 1:numel(CD)
    for d = days
        fi = find(fday == d);
        [~, TP] = correct_day(arrayfun(fn, fi, 'UniformOutput', false), 2, CD(c));
        for h = 'NS'
            t = TP.(h);
            rows(end+1, :) = {PD{c}, d, h, t.nw, t.ni, t.w_std_u, t.w_std_c, t.i_std_u, t.i_std_c, t.water_c, t.ice_c}; %#ok<SAGROW>
        end
    end
    fprintf('downstream %s done\n', PD{c});
end
TD = cell2table(rows, 'VariableNames', {'preset', 'day', 'hemi', 'n_water', 'n_ice', 'w_std_u', 'w_std_c', 'i_std_u', 'i_std_c', 'tp_water_c', 'tp_ice_c'});
TD.preset = string(TD.preset); TD.hemi = string(TD.hemi);
writetable(TD, fullfile('output', 'A3b_downstream.csv'));
G = groupsummary(TD, {'preset', 'hemi'}, 'mean', {'n_water', 'n_ice', 'w_std_u', 'w_std_c', 'i_std_u', 'i_std_c'}); disp(G);
writetable(G, fullfile('output', 'A3b_downstream_mean.csv'));
fig = figure('Position', [100 100 1000 650], 'Color', 'w', 'Visible', 'off');
tl = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact'); col = lines(npn); hz = "NS"; hn = {'Arctic', 'Antarctic'};
for h = 1:2, for w = 1:2
    ax = nexttile(tl); hold(ax, 'on'); grid(ax, 'on');
    if w == 1, f = 'w_std_'; ttl = 'water'; else, f = 'i_std_'; ttl = 'ice'; end
    for c = 1:npn
        m = TD.preset == PN{c} & TD.hemi == extract(hz, h); x = str2double(extractAfter(TD.day(m), 2));
        plot(ax, x, TD.([f 'u'])(m), '--', 'Color', col(c, :), 'HandleVisibility', 'off');
        plot(ax, x, TD.([f 'c'])(m), '-o', 'Color', col(c, :), 'MarkerSize', 4, 'DisplayName', LBL{c});
    end
    title(ax, sprintf('%s, %s tie point', hn{h}, ttl), 'FontWeight', 'normal');
    xlabel(ax, 'day of Feb 1973'); ylabel(ax, 'std SIC [%]');
    if h == 1 && w == 2, legend(ax, 'Location', 'eastoutside', 'Box', 'off'); end
end, end
title(tl, 'Daily SIC std, A6b iteration 2 (solid = corrected, dashed = uncorrected)');
exportgraphics(fig, fullfile('output', 'A3b_downstream.png'), 'Resolution', 150); close(fig);
end

function z = cdil1(x, k)
x = double(x(:)); n = numel(x); y = movmax([x(n-k+1:n); x; x(1:k)], [k k]); z = y(k+1:k+n) > 0;
end
