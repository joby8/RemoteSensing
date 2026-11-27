% C3b: low pressure over the whole month (meeting 2026-11-24, point 12)
%  "The single low (12 Feb) is good as it is. Add the whole month and interpret it."
%  For every day 1-27 Feb 1973 (28 Feb: only 1 orbit): correct_day.m (A6b method, NIT = 2, daily tie points),
%  then all open-water pixels of the water tie-point mask (tp_masks.m, o.mw) with ERA5 msl, W, V, L and
%     SIC_u = (TB - Tpw_u) / (Tpi_u - Tpw_u)           uncorrected, daily uncorrected tie points
%     SIC_c = (TB + dTB - Tpw_c) / (Tpi_c - Tpw_c)    corrected, daily corrected tie points  (raw, not clipped)
%  Figure (Arctic top, Antarctic bottom):
%    (1) low pressure over the month: daily min / 5 % / median msl over open water + share of open water < 980 hPa
%    (2) the correction beside it: daily open-water SIC std and mean, uncorrected vs corrected
%    (3) whole month binned by msl: open-water SIC mean +- std, uncorrected vs corrected (+ pixel count)
% Run from the project root:  matlab -batch "run('src/matlab/c3b_low_month.m')"   (about 12 min, then cached)
% Outputs: output/C3b_low_month.png, output/C3b_low_month_days.csv, output/C3b_low_month_bins.csv,
%          output/C3b_cache.mat (pixels; delete it to recompute)
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile('src','matlab'));
LOW = 980;                                           % hPa, "inside a low"
cache = fullfile('output', 'C3b_cache.mat');
files = dir(fullfile('ESMR_colocated_filtered','*.nc'));
fday  = string(regexp({files.name}, '1973m(\d{4})t', 'tokens', 'once'));
days  = setdiff(unique(fday), "0228");

if isfile(cache)
    load(cache, 'X');
else
    X = struct('day', [], 'hemi', [], 'msl', [], 'W', [], 'V', [], 'L', [], 'su', [], 'sc', []);
    for d = days(:)'
        t0 = tic;
        fn = arrayfun(@(f) fullfile(f.folder, f.name), files(fday == d), 'UniformOutput', false);
        [O, TP] = correct_day(fn, 2);
        for k = 1:numel(O)
            o = O(k);
            msl = double(ncfast(fn{k}, 'msl'))' / 100;
            for h = 1:2
                if h == 1, tp = TP.N; hs = o.lat > 0; else, tp = TP.S; hs = o.lat < 0; end
                m = o.mw & hs & ~isnan(o.dtb);
                if ~any(m(:)), continue, end
                su = 100 * (o.tb_f(m) - tp.water_u) / (tp.ice_u - tp.water_u);
                sc = 100 * (o.tb_f(m) + o.dtb(m) - tp.water_c) / (tp.ice_c - tp.water_c);
                n = nnz(m);
                X.day  = [X.day;  repmat(str2double(extractAfter(d, 2)), n, 1)];
                X.hemi = [X.hemi; repmat(uint8(h), n, 1)];
                X.msl  = [X.msl;  single(msl(m))];
                X.W = [X.W; single(o.W(m))]; X.V = [X.V; single(o.V(m))]; X.L = [X.L; single(o.L(m))];
                X.su = [X.su; single(su)]; X.sc = [X.sc; single(sc)];
            end
        end
        fprintf('%s done (%.0f s)\n', d, toc(t0));
    end
    save(cache, 'X', '-v7.3');
end

%% daily statistics
hn = ["Arctic", "Antarctic"]; dd = unique(X.day)';
D = table();
for h = 1:2
    for d = dd
        m = X.hemi == h & X.day == d;
        if nnz(m) < 100, continue, end
        p = double(X.msl(m)); u = double(X.su(m)); c = double(X.sc(m)); lo = p < LOW;
        r = table(hn(h), d, nnz(m), min(p), prctile(p, 5), median(p), 100 * mean(lo), ...
            mean(u), std(u), mean(c), std(c), mean(c(lo)) , std(u(lo)), std(c(lo)), ...
            'VariableNames', {'hemi','day','n','msl_min','msl_p5','msl_median','pct_low', ...
            'sic_u_mean','sic_u_std','sic_c_mean','sic_c_std','sic_c_mean_low','sic_u_std_low','sic_c_std_low'});
        D = [D; r]; %#ok<AGROW>
    end
end
for v = D.Properties.VariableNames(3:end), D.(v{1}) = round(D.(v{1}), 2); end
writetable(D, fullfile('output', 'C3b_low_month_days.csv'));

%% binned by msl (whole month)
be = 940:5:1040; bc = (be(1:end-1) + be(2:end)) / 2;
B = table();
for h = 1:2
    for b = 1:numel(bc)
        m = X.hemi == h & X.msl >= be(b) & X.msl < be(b+1);
        n = nnz(m); if n < 200, continue, end
        u = double(X.su(m)); c = double(X.sc(m));
        B = [B; table(hn(h), bc(b), n, mean(double(X.W(m))), mean(double(X.V(m))), mean(double(X.L(m))), ...
            mean(u), std(u), mean(c), std(c), 'VariableNames', ...
            {'hemi','msl','n','W','V','L','sic_u_mean','sic_u_std','sic_c_mean','sic_c_std'})]; %#ok<AGROW>
    end
end
for v = B.Properties.VariableNames(3:end), B.(v{1}) = round(B.(v{1}), 2); end
writetable(B, fullfile('output', 'C3b_low_month_bins.csv'));

%% figure
cU = [.55 .55 .55]; cC = [0 .45 .74]; cP = [.10 .10 .10]; cL = [.80 .30 .10];
fig = figure('Visible','off','Color','w','Position',[50 50 1900 950]);
tl = tiledlayout(fig, 2, 3, 'TileSpacing','compact','Padding','compact');
for h = 1:2
    s = D(D.hemi == hn(h), :); t = datetime(1973, 2, s.day);
    % (1) pressure
    ax = nexttile(tl); hold(ax, 'on'); grid(ax, 'on'); box(ax, 'on');
    yyaxis(ax, 'left');
    plot(ax, t, s.msl_min, '-o', 'Color', cP, 'LineWidth', 2, 'MarkerSize', 4, 'MarkerFaceColor', cP);
    plot(ax, t, s.msl_p5, '--', 'Color', cP, 'LineWidth', 1.2);
    plot(ax, t, s.msl_median, ':', 'Color', cP, 'LineWidth', 1.2);
    yline(ax, LOW, '-', sprintf('%d hPa', LOW), 'Color', [.6 .6 .6], 'HandleVisibility', 'off');
    ylabel(ax, 'msl over open water [hPa]'); ylim(ax, [935 1015]);
    yyaxis(ax, 'right');
    bar(ax, t, s.pct_low, 0.6, 'FaceColor', cL, 'FaceAlpha', .35, 'EdgeColor', 'none');
    ylabel(ax, sprintf('open water with msl < %d hPa [%%]', LOW)); ylim(ax, [0 80]);
    ax.YAxis(1).Color = cP; ax.YAxis(2).Color = cL;
    if h == 1, xline(ax, datetime(1973, 2, 12), 'k-.', '12 Feb case (C3)', 'HandleVisibility', 'off', ...
            'LabelVerticalAlignment', 'top', 'LabelHorizontalAlignment', 'left'); end
    legend(ax, {'minimum', '5 % quantile', 'median', sprintf('share < %d hPa', LOW)}, 'Location', 'northeast');
    title(ax, sprintf('%s: low pressure over open water, 1-27 Feb 1973', hn(h)), 'FontWeight', 'normal');
    % (2) correction beside it
    ax = nexttile(tl); hold(ax, 'on'); grid(ax, 'on'); box(ax, 'on');
    plot(ax, t, s.sic_u_std, ':o', 'Color', cU, 'LineWidth', 1.4, 'MarkerSize', 4);
    plot(ax, t, s.sic_c_std, '-o', 'Color', cC, 'LineWidth', 2.2, 'MarkerSize', 4, 'MarkerFaceColor', cC);
    % std inside the lows only (msl < LOW), days with >= 300 such pixels
    ok = s.pct_low .* s.n / 100 >= 300; ul = s.sic_u_std_low; cl = s.sic_c_std_low; ul(~ok) = NaN; cl(~ok) = NaN;
    plot(ax, t, ul, ':s', 'Color', cL, 'LineWidth', 1.2, 'MarkerSize', 5);
    plot(ax, t, cl, '-s', 'Color', cL, 'LineWidth', 1.8, 'MarkerSize', 5, 'MarkerFaceColor', cL);
    R = corrcoef(s.pct_low, s.sic_u_std); rr = R(1,2); R = corrcoef(s.pct_low, s.sic_c_std); rc = R(1,2);
    legend(ax, {sprintf('all open water, no RTM correction (mean %.1f %%)', mean(s.sic_u_std)), ...
                sprintf('all open water, with RTM correction (mean %.1f %%)', mean(s.sic_c_std)), ...
                sprintf('inside lows (msl < %d hPa), no RTM correction', LOW), ...
                sprintf('inside lows (msl < %d hPa), with RTM correction', LOW)}, 'Location', 'northoutside');
    text(ax, 0.02, 0.04, sprintf('r(daily std, share < %d hPa):  no corr. %.2f,  with corr. %.2f', LOW, rr, rc), ...
        'Units', 'normalized', 'FontSize', 9);
    ylabel(ax, 'std of open-water SIC per day [%]'); ylim(ax, [4 16]);
    title(ax, sprintf('%s: std of open-water SIC per day (daily mean = 0 by the tie points)', hn(h)), 'FontWeight', 'normal');
    % (3) binned by msl
    ax = nexttile(tl); hold(ax, 'on'); grid(ax, 'on'); box(ax, 'on');
    q = B(B.hemi == hn(h), :);
    yyaxis(ax, 'right');
    hb = bar(ax, q.msl, q.n / 1e3, 0.9, 'FaceColor', [.9 .9 .9], 'EdgeColor', 'none'); ylim(ax, [0 3 * max(q.n) / 1e3]);
    ylabel(ax, 'pixels [1000]'); ax.YAxis(2).Color = [.5 .5 .5];
    yyaxis(ax, 'left');
    hu = errorbar(ax, q.msl - 0.6, q.sic_u_mean, q.sic_u_std, 'o:', 'Color', cU, 'LineWidth', 1.3, 'MarkerFaceColor', cU);
    hc = errorbar(ax, q.msl + 0.6, q.sic_c_mean, q.sic_c_std, 'o-', 'Color', cC, 'LineWidth', 1.8, 'MarkerFaceColor', cC);
    yline(ax, 0, 'k-', 'HandleVisibility', 'off'); xline(ax, LOW, '--', 'HandleVisibility', 'off');
    ylabel(ax, 'open-water SIC: mean \pm std [%]'); ylim(ax, [-20 25]); ax.YAxis(1).Color = 'k';
    xlabel(ax, 'ERA5 msl [hPa] (5 hPa bins)'); xlim(ax, [940 1040]);
    legend(ax, [hu hc hb], {'no RTM correction', 'with RTM correction', 'pixels per bin (right axis)'}, 'Location', 'northeast');
    title(ax, sprintf('%s: all days, open-water SIC vs pressure', hn(h)), 'FontWeight', 'normal');
end
title(tl, {'Lows over the whole month: pressure (left) and what the RTM correction does (middle, right)', ...
    'open water = water tie-point mask of Task 1, daily tie points, A6b correction (2 iterations), SIC raw (not clipped)'}, ...
    'FontSize', 12);
exportgraphics(fig, fullfile('output', 'C3b_low_month.png'), 'Resolution', 150);

%% numbers for the note
for h = 1:2
    m = X.hemi == h; lo = m & X.msl < LOW; hi = m & X.msl >= 1000;
    f = @(g) sprintf('n %7d  W %.1f  V %.1f  L %.2f  SIC_u %+.2f / %.2f  SIC_c %+.2f / %.2f', nnz(g), ...
        mean(X.W(g)), mean(X.V(g)), mean(X.L(g)), mean(X.su(g)), std(X.su(g)), mean(X.sc(g)), std(X.sc(g)));
    fprintf('%s  msl < %d : %s\n', hn(h), LOW, f(lo));
    fprintf('%s  msl >= 1000: %s\n', hn(h), f(hi));
    fprintf('%s  all        : %s\n', hn(h), f(m));
end
disp(D(:, {'hemi','day','msl_min','pct_low','sic_u_std','sic_c_std','sic_c_mean'}));
fprintf('saved output/C3b_low_month.png, C3b_low_month_days.csv, C3b_low_month_bins.csv\n');
