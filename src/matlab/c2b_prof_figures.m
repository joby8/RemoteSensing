% C2b - Presentation figures of the February 1973 book comparison (C2), for meetings / the report.
%       Reads output/C2_results.mat (written by c2_feb1973_books.m); no recomputation.
% OUTPUT (output/):
%   C2b_maps.png         rows Arctic / Antarctic; columns: book scan (re-projected onto our grid), book classified,
%                        this work, agreement + both 15 % ice edges
%   C2b_difference.png   this work minus book class midpoint (map) and its histogram
%   C2b_classes.png      mean SIC of this work per book class (1:1 line)
%   C2b_summary.png      extent, ice area and agreement, this work vs book
% Run from the project root:  matlab -batch "run('src/matlab/c2b_prof_figures.m')"
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));
D = load(fullfile('output', 'C2_results.mat'));
od = 'output';
g = D.g; n = D.n; Re = D.Re;
book = {'SP-489 (Parkinson et al. 1987)', 'SP-459 (Zwally et al. 1983)'}; bshort = {'SP-489', 'SP-459'};
latc = [50 -55];                                            % plotted region (Antarctic ice lies south of 55 S)
lim = 2*Re*tand((90 - abs(latc))/2);

blue = hex2rgb_({'#cde2fb','#b7d3f6','#9ec5f4','#86b6ef','#6da7ec','#5598e7','#3987e5','#2a78d6','#256abf','#1c5cab','#184f95','#104281','#0d366b'});
water = [1 1 1]; landc = [0.72 0.72 0.70]; nocomp = [0.90 0.90 0.89]; ink = [0.1 0.1 0.1];
cm = interp1(linspace(0.15, 1, size(blue, 1)), blue, linspace(0.15, 1, 86)');
ccA = [hex2rgb_({'#2a78d6'}); hex2rgb_({'#eb6834'}); hex2rgb_({'#1baf7a'}); water];
fs = 12;

%% re-project the scans onto the polar grid (5 km pixels) with the C2 affine georeference
img = {imread(fullfile('docs', 'sp489', 'fig_feb1973.jpg')), imread(fullfile('docs', 'sp459', 'fig5-2a_feb1973.jpg'))};
SCAN = cell(1, 2); gs = cell(1, 2);
for h = 1:2
    gs{h} = -lim(h):5:lim(h); [Us, Vs] = meshgrid(gs{h}, gs{h});
    X = Us/(2*Re); Y = -Vs/(2*Re);
    PX = D.t{h}(1) + D.A{h}(1,1)*X + D.A{h}(1,2)*Y; PY = D.t{h}(2) + D.A{h}(2,1)*X + D.A{h}(2,2)*Y;
    I = double(img{h})/255; out = ones([size(Us) 3]);
    for ch = 1:3, v = interp2(I(:,:,ch), PX, PY, 'linear', NaN); v(isnan(v)) = 1; out(:,:,ch) = v; end
    SCAN{h} = out;
end

%% figure 1: maps
f = figure('Visible', 'off', 'Position', [0 0 2000 1080], 'Color', 'w');
tl = tiledlayout(f, 2, 4, 'TileSpacing', 'compact', 'Padding', 'compact');
for h = 1:2
    s = D.R(h).st; SIC = D.SICh(:,:,h); cl = D.CLS(:,:,h); land = D.landO(:,:,h) | cl == 3;
    % (a) scan
    ax = nexttile; image(ax, gs{h}, gs{h}, SCAN{h}); set(ax, 'YDir', 'normal'); hold(ax, 'on');
    finish(ax, Re, h, lim(h), latc(h)); title(ax, sprintf('%s, original map (scan)', book{h}), 'FontWeight', 'normal', 'FontSize', fs);
    % (b) book classified
    ax = nexttile; Zb = s.midB/100; Zb(Zb == 0) = NaN;
    rgb = sicrgb(Zb, cm, water); rgb = paint(rgb, ~s.common, nocomp); rgb = paint(rgb, land, landc);
    image(ax, g, g, rgb); set(ax, 'YDir', 'normal'); hold(ax, 'on');
    finish(ax, Re, h, lim(h), latc(h)); title(ax, sprintf('%s, read from the colours', bshort{h}), 'FontWeight', 'normal', 'FontSize', fs);
    % (c) this work
    ax = nexttile; Z = SIC; Z(SIC < 0.15) = NaN;
    rgb = sicrgb(Z, cm, water); rgb = paint(rgb, ~s.common, nocomp); rgb = paint(rgb, land, landc);
    image(ax, g, g, rgb); set(ax, 'YDir', 'normal'); hold(ax, 'on');
    finish(ax, Re, h, lim(h), latc(h)); title(ax, 'This work, mean SIC Feb 1973', 'FontWeight', 'normal', 'FontSize', fs);
    if h == 2
        colormap(ax, cm); clim(ax, [15 100]); cb = colorbar(ax, 'southoutside'); cb.Label.String = 'sea ice concentration [%]';
        cb.FontSize = fs - 1;
    end
    % (d) agreement
    ax = nexttile; rgb = repmat(reshape(nocomp, 1, 1, 3), n, n);
    for j = 1:4, rgb = paint(rgb, s.agr == j, ccA(j, :)); end
    rgb = paint(rgb, land, landc);
    image(ax, g, g, rgb); set(ax, 'YDir', 'normal'); hold(ax, 'on');
    for k = 1:numel(D.R(h).edge_book), pl = ll2uv_(D.R(h).edge_book{k}, h, Re); plot(ax, pl(:,1), pl(:,2), '-', 'Color', '#b8400f', 'LineWidth', 1.4); end
    for k = 1:numel(D.R(h).edge_ours), pl = ll2uv_(D.R(h).edge_ours{k}, h, Re); plot(ax, pl(:,1), pl(:,2), '-', 'Color', ink, 'LineWidth', 0.8); end
    finish(ax, Re, h, lim(h), latc(h));
    title(ax, sprintf('Agreement ice / water: %.1f %%', s.agree_pct), 'FontWeight', 'bold', 'FontSize', fs);
    hh = gobjects(5, 1);
    nm = {sprintf('ice in both (%.2f)', s.both_ice), sprintf('ice only this work (%.2f)', s.only_ours), ...
          sprintf('ice only %s (%.2f)', bshort{h}, s.only_book), ['15 % edge ' bshort{h}], '15 % edge this work'};
    for j = 1:3, hh(j) = plot(ax, nan, nan, 's', 'MarkerFaceColor', ccA(j, :), 'MarkerEdgeColor', 'none', 'MarkerSize', 10); end
    hh(4) = plot(ax, nan, nan, '-', 'Color', '#b8400f', 'LineWidth', 1.4); hh(5) = plot(ax, nan, nan, '-', 'Color', ink, 'LineWidth', 0.8);
    lg = legend(ax, hh, nm, 'Location', 'southoutside', 'Box', 'off', 'NumColumns', 2, 'FontSize', fs - 2);
    title(lg, 'areas in 10^6 km^2', 'FontWeight', 'normal');
end
% row labels
for h = 1:2
    ax = nexttile(tl, 4*(h - 1) + 1);
    text(ax, -1.16*lim(h), 0, D.hname{h}, 'Rotation', 90, 'HorizontalAlignment', 'center', 'FontSize', fs + 4, 'FontWeight', 'bold');
end
title(tl, 'February 1973 monthly mean: ESMR (this work) vs. NASA atlas maps', 'FontSize', fs + 4, 'FontWeight', 'bold');
subtitle(tl, 'White: open water (< 15 %).  Grey: land.  Light grey: not compared (no data, or ocean in only one of the two maps).', 'FontSize', fs - 1);
exportgraphics(f, fullfile(od, 'C2b_maps.png'), 'Resolution', 150); close(f);

%% figure 2: difference map + histogram
dcm = interp1([-1 -0.5 0 0.5 1], [0.72 0.27 0.06; 0.96 0.70 0.55; 1 1 1; 0.55 0.72 0.94; 0.05 0.25 0.55], linspace(-1, 1, 101)');
f = figure('Visible', 'off', 'Position', [0 0 1350 1150], 'Color', 'w');
tl = tiledlayout(f, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
edges = -60:5:80;
for h = 1:2
    s = D.R(h).st; cl = D.CLS(:,:,h); land = D.landO(:,:,h) | cl == 3; dm = s.diffm;
    ax = nexttile; rgb = repmat(reshape(water, 1, 1, 3), n, n);
    i = round((min(max(dm, -50), 50) + 50)/100*100) + 1; ok = ~isnan(dm);
    for ch = 1:3, x = rgb(:,:,ch); x(ok) = dcm(i(ok), ch); rgb(:,:,ch) = x; end
    rgb = paint(rgb, ~s.common, nocomp); rgb = paint(rgb, land, landc);
    image(ax, g, g, rgb); set(ax, 'YDir', 'normal'); hold(ax, 'on'); finish(ax, Re, h, lim(h), latc(h));
    title(ax, sprintf('%s: this work minus %s', D.hname{h}, bshort{h}), 'FontWeight', 'bold', 'FontSize', fs);
    colormap(ax, dcm); clim(ax, [-50 50]); cb = colorbar(ax, 'eastoutside'); cb.Label.String = 'SIC difference [%-points]'; cb.FontSize = fs - 1;
    ax = nexttile; v = dm(~isnan(dm) & s.common);
    histogram(ax, v, edges, 'FaceColor', '#2a78d6', 'EdgeColor', 'w', 'FaceAlpha', 1); hold(ax, 'on');
    xline(ax, 0, '-', 'Color', [0.4 0.4 0.4], 'HandleVisibility', 'off');
    xline(ax, mean(v), '--', 'Color', '#b8400f', 'LineWidth', 1.8, 'DisplayName', sprintf('mean %+.1f', mean(v)));
    xline(ax, median(v), ':', 'Color', ink, 'LineWidth', 1.8, 'DisplayName', sprintf('median %+.1f', median(v)));
    legend(ax, findobj(ax, 'Type', 'ConstantLine', '-not', 'DisplayName', ''), 'Location', 'northeast', 'Box', 'off', 'FontSize', fs);
    xlabel(ax, 'this work minus book class midpoint [%-points]'); ylabel(ax, 'number of 30 km cells');
    title(ax, sprintf('%s: cells with ice in at least one map (n = %d)', D.hname{h}, numel(v)), 'FontWeight', 'normal', 'FontSize', fs);
    box(ax, 'off'); grid(ax, 'on'); set(ax, 'FontSize', fs - 1); xlim(ax, [-60 80]);
end
exportgraphics(f, fullfile(od, 'C2b_difference.png'), 'Resolution', 150); close(f);

%% figure 3: our SIC per book class
f = figure('Visible', 'off', 'Position', [0 0 1000 1050], 'Color', 'w');
tl = tiledlayout(f, 2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
for h = 1:2
    ct = D.cls_tab{h}(2:end, :); x = D.MID(:); ok = ct(:, 2) >= 30; few = ct(:, 2) > 0 & ~ok;
    ax = nexttile; hold(ax, 'on');
    plot(ax, [0 100], [0 100], '-', 'Color', [0.6 0.6 0.6], 'LineWidth', 1);
    errorbar(ax, x(ok), ct(ok, 3), ct(ok, 4), 'o', 'Color', '#2a78d6', 'MarkerFaceColor', '#2a78d6', 'MarkerSize', 7, 'LineWidth', 1.3, 'CapSize', 4);
    plot(ax, x(few), ct(few, 3), 'o', 'Color', '#2a78d6', 'MarkerSize', 7, 'LineWidth', 1.2);
    w0 = D.cls_tab{h}(1, :);
    subtitle(ax, sprintf('book open water (< 14 %%): this work %.1f %% \\pm %.1f (n = %d)', w0(3), w0(4), w0(2)), 'FontSize', fs - 2, 'Color', [0.3 0.3 0.3]);
    xlabel(ax, sprintf('%s class (midpoint) [%%]', bshort{h})); ylabel(ax, 'this work, mean SIC [%]');
    axis(ax, [10 102 0 110]); axis(ax, 'square'); grid(ax, 'on'); box(ax, 'off'); set(ax, 'FontSize', fs);
    title(ax, sprintf('%s: this work vs. %s per concentration class', D.hname{h}, bshort{h}), 'FontWeight', 'bold', 'FontSize', fs);
    hl = [plot(ax, nan, nan, 'o', 'Color', '#2a78d6', 'MarkerFaceColor', '#2a78d6'), plot(ax, nan, nan, 'o', 'Color', '#2a78d6'), plot(ax, nan, nan, '-', 'Color', [0.6 0.6 0.6])];
    legend(ax, hl, {'mean \pm 1 std (\geq 30 cells)', 'mean (< 30 cells)', '1:1'}, 'Location', 'southeast', 'Box', 'off', 'FontSize', fs - 2);
end
exportgraphics(f, fullfile(od, 'C2b_classes.png'), 'Resolution', 150); close(f);

%% figure 4: summary numbers
f = figure('Visible', 'off', 'Position', [0 0 1300 480], 'Color', 'w');
tl = tiledlayout(f, 1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
c1 = hex2rgb_({'#2a78d6'}); c2 = hex2rgb_({'#eb6834'});
st = [D.R(1).st, D.R(2).st];
ax = nexttile; Y = [[st.extent_ours]' [st.extent_book]'];
bb = bar(ax, Y, 'grouped'); bb(1).FaceColor = c1; bb(2).FaceColor = c2; lab(ax, bb, '%.2f', fs);
set(ax, 'XTickLabel', D.hname, 'FontSize', fs); ylabel(ax, '10^6 km^2'); title(ax, 'Ice extent (SIC \geq 15 %)', 'FontSize', fs);
legend(ax, {'this work', 'book'}, 'Box', 'off', 'Location', 'northeast'); box(ax, 'off'); ylim(ax, [0 1.2*max(Y(:))]);
ax = nexttile; Y = [[st.area_ours]' [st.area_book_classes]'];
bb = bar(ax, Y, 'grouped'); bb(1).FaceColor = c1; bb(2).FaceColor = c2; lab(ax, bb, '%.2f', fs); hold(ax, 'on');
xb = 2 + bb(2).XOffset; yt = st(2).area_book_table;
plot(ax, xb + [-0.17 0.17], [yt yt], 'k--', 'LineWidth', 1.5);
text(ax, xb, yt + 1.0, {'- - SP-459', sprintf('Table 3-2: %.2f', yt)}, 'FontSize', fs - 3, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
set(ax, 'XTickLabel', D.hname, 'FontSize', fs); ylabel(ax, '10^6 km^2'); title(ax, 'Ice area (SIC \times cell area)', 'FontSize', fs);
box(ax, 'off'); ylim(ax, [0 1.2*max(Y(:))]);
ax = nexttile; Y = [st.agree_pct]';
bb = bar(ax, Y, 0.5, 'FaceColor', [0.45 0.45 0.45]); lab(ax, bb, '%.1f %%', fs);
set(ax, 'XTickLabel', D.hname, 'FontSize', fs); ylabel(ax, '% of compared cells'); ylim(ax, [0 109]);
title(ax, 'Ice / water agreement', 'FontSize', fs); box(ax, 'off');
title(tl, 'February 1973: this work vs. NASA atlas (SP-489 Arctic, SP-459 Antarctic), common ocean cells only', 'FontSize', fs + 1, 'FontWeight', 'bold');
exportgraphics(f, fullfile(od, 'C2b_summary.png'), 'Resolution', 150); close(f);
fprintf('saved output/C2b_maps.png, C2b_difference.png, C2b_classes.png, C2b_summary.png\n');

%% helpers
function finish(ax, Re, h, lim, latc)
graticule_xy(ax, Re, h, lim, latc); axis(ax, 'image'); axis(ax, 1.08*[-lim lim -lim lim]);
set(ax, 'XTick', [], 'YTick', [], 'XColor', 'none', 'YColor', 'none');
end
function lab(ax, bb, fmt, fs)
for k = 1:numel(bb)
    text(ax, bb(k).XEndPoints, bb(k).YEndPoints, compose(fmt, bb(k).YData), 'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', 'FontSize', fs - 2);
end
end
function rgb = sicrgb(Z, cm, water)
i = round((Z - 0.15)/0.85*(size(cm, 1) - 1)) + 1; ok = ~isnan(i); i = min(max(i, 1), size(cm, 1));
rgb = repmat(reshape(water, 1, 1, 3), [size(Z) 1]);
for ch = 1:3, x = rgb(:,:,ch); c = cm(:, ch); x(ok) = c(i(ok)); rgb(:,:,ch) = x; end
end
function c = hex2rgb_(h)
c = cell2mat(cellfun(@(s) sscanf(s(2:end), '%2x%2x%2x')'/255, h(:), 'UniformOutput', false));
end
function rgb = paint(rgb, m, c)
for ch = 1:3, x = rgb(:, :, ch); x(m) = c(ch); rgb(:, :, ch) = x; end
end
function pl = ll2uv_(ll, h, Re)
lat = ll(:,1); lon = ll(:,2);
if h == 1, rad = 2*Re*tand((90 - lat)/2); pl = [rad.*sind(lon), -rad.*cosd(lon)];
else,      rad = 2*Re*tand((90 + lat)/2); pl = [rad.*sind(lon),  rad.*cosd(lon)]; end
end
function graticule_xy(ax, Re, h, lim, latc)
gc = [0.55 0.55 0.53]; a = linspace(0, 360, 361);
if h == 1, las = 60:10:80; else, las = -60:-10:-80; end
for la = [las latc]
    r = 2*Re*tand((90 - abs(la))/2);
    plot(ax, r*sind(a), r*cosd(a), '-', 'Color', gc, 'LineWidth', 0.4 + 0.4*(la == latc));
end
for lo = 0:45:315
    ux = lim*sind(lo); vy = lim*cosd(lo); if h == 1, vy = -vy; end
    r0 = 2*Re*tand(5);                                      % meridians start at 80 deg
    plot(ax, [r0/lim*ux ux], [r0/lim*vy vy], '-', 'Color', gc, 'LineWidth', 0.4);
    if mod(lo, 90) == 0
        s = {'0°', '90°E', '180°', '90°W'}; text(ax, 1.045*ux, 1.045*vy, s{lo/90 + 1}, 'HorizontalAlignment', 'center', ...
            'FontSize', 9, 'Color', [0.3 0.3 0.3]);
    end
end
end
