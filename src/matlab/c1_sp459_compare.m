% C1 - Compare our mean SIC for February 1973 (South, A6b method) with NASA SP-459 Fig. 5-2a
%      (Zwally et al. 1983, "Antarctic Sea Ice 1973-1976", p. 96, Feb 1973 panel).
% We do NOT extract concentration values from the book. From the scanned map we only take
% ice / no ice (>= 16 % class vs. "< 14 %" class) and compare the ice edge and the ice extent.
%
% Steps
%   1. Our data: per day correct_day.m (A6b, 2 iterations), SIC per pixel with the day's corrected
%      South tie points, binned on a 30 km polar stereographic grid (like SP-459, p. 69).
%      Daily cell mean = mean of the unclipped pixel SIC of that day; monthly mean = mean of the daily
%      cell means (each day with data in the cell weighted equally), then clipped to 0..1. Cached per day.
%   2. SP-459 map: docs/sp459/fig5-2a_feb1973.jpg (cut from the NTRS scan at 300 dpi).
%      Georeference: polar stereographic, 0 deg up; affine fit to the printed 50/60/70 S circles and the 45-deg
%      meridians (fit_grat in c2_feb1973_books.m, 376 points, rms 0.95 px = 5.3 km; until 2026-11-27: own fit, rms 1.6 px). Each grid cell takes the median
%      colour of a 5x5 pixel window (removes the printed graticule lines) and is assigned to the
%      nearest of the 23 legend colours or land (black). Ice = any class >= 16 %.
%      Note: the "32 %" class is close to the "< 14 %" water colour; nearest-class matching keeps them apart.
%   3. Common cells (lat <= -50, both have ocean data): ice extent, agreement map, extent per sector.
%      Ice area from SP-459 Table 3-2 (Feb 1973, all sectors): 2.712e6 km2.
% Output: output/C1_sp459_side_by_side.png, output/C1_sp459_overlay.png, output/C1_sp459_extent.csv
% Run from the project root:  matlab -batch "run('src/matlab/c1_sp459_compare.m')"
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile('src','matlab'));

%% grid: polar stereographic (sphere R = 6371 km), u to the right (90E), v up (0 deg), 30 km cells
Re = 6371; dx = 30; L = 4800; g = (-L + dx/2):dx:(L - dx/2); n = numel(g);
[U, V] = meshgrid(g, g);                                   % row 1 = bottom (v = -L)
rho = hypot(U, V); colat = 2*atand(rho/(2*Re));
LAT = -(90 - colat); LON = atan2d(U, V);
AREA = dx^2 * cosd(colat/2).^4;                            % true cell area on the sphere [km2]
cellidx = @(lat, lon) deal( ...
    floor((2*Re*tand((90 + lat)/2).*cosd(lon) + L)/dx) + 1, ...   % row (v)
    floor((2*Re*tand((90 + lat)/2).*sind(lon) + L)/dx) + 1);      % col (u)

%% 1. our monthly mean SIC (South), cached per day
files = dir(fullfile('ESMR_colocated_filtered', '*.nc'));
fday  = string(regexp({files.name}, '1973m(\d{4})t', 'tokens', 'once'));
days  = unique(fday);
cdir  = fullfile('output', 'C1_cache'); if ~exist(cdir, 'dir'), mkdir(cdir); end
ckey  = struct('tp', tp_opt(), 'cfg', preproc_config());   % cache key: masks and preprocessing used
S = zeros(n); N = zeros(n); ND = zeros(n); NL = zeros(n); tpw = nan(numel(days), 1); tpi = tpw;
for i = 1:numel(days)
    cf = fullfile(cdir, days(i) + ".mat");
    if cache_stale(cf, ckey)                       % missing, or built with other masks / preprocessing
        fi = find(fday == days(i));
        fn = arrayfun(@(k) fullfile(files(k).folder, files(k).name), fi, 'UniformOutput', false);
        [O, TP] = correct_day(fn, 2);
        s = zeros(n); c = zeros(n); cl = zeros(n);
        for k = 1:numel(O)
            o = O(k);
            m = o.lat < -45 & ~isnan(o.dtb);              % corrected South ocean pixels
            sic = (o.tb_f(m) + o.dtb(m) - TP.S.water_c) / (TP.S.ice_c - TP.S.water_c);
            [r, q] = cellidx(o.lat(m), o.lon(m)); ok = r >= 1 & r <= n & q >= 1 & q <= n;
            s = s + accumarray([r(ok) q(ok)], sic(ok), [n n]);
            c = c + accumarray([r(ok) q(ok)], 1, [n n]);
            ml = o.lat < -45 & o.lat >= -90 & isnan(o.sst);  % ERA5 land; display only (land cells of the map), not o.valid
            [r, q] = cellidx(o.lat(ml), o.lon(ml)); ok = r >= 1 & r <= n & q >= 1 & q <= n;
            cl = cl + accumarray([r(ok) q(ok)], 1, [n n]);
        end
        tp = TP.S; save(cf, 's', 'c', 'cl', 'tp', 'ckey');
        fprintf('%s: %d orbits, %d South pixels\n', days(i), numel(O), sum(c(:)));
    end
    D = load(cf); hd = D.c > 0;                              % daily cell mean, each day weighted equally
    dm = zeros(n); dm(hd) = D.s(hd) ./ D.c(hd);
    S = S + dm; ND = ND + hd; N = N + D.c; NL = NL + D.cl;
    tpw(i) = D.tp.water_c; tpi(i) = D.tp.ice_c;
end
SIC = S ./ ND; SIC(N < 3) = NaN; SIC = min(max(SIC, 0, 'includenan'), 1, 'includenan');   % keep NaN (max(NaN,0) = 0)
landO = NL > N & N < 3;                                     % our land (ERA5) cells

%% 2. SP-459 map -> ice / water / land per grid cell
img = imread(fullfile('docs', 'sp459', 'fig5-2a_feb1973.jpg'));
A = [2259.9987 -0.2098; -0.8152 2296.9821]; t = [823.4905; 833.5406];   % image px = t + A*[X; Y] (C2 fit, 2026-11-27)
Xt = U/(2*Re); Yt = -V/(2*Re);                                           % tan(colat/2)*[sin(lon); -cos(lon)]
PX = t(1) + A(1,1)*Xt + A(1,2)*Yt; PY = t(2) + A(2,1)*Xt + A(2,2)*Yt;
pal = [186 195 190; 116 86 78; 205 114 87; 208 140 121; 207 188 174; 206 209 194; 56 63 59; 71 77 67; ...
       134 133 103; 184 182 143; 196 136 88; 211 159 87; 210 183 93; 214 221 177; 60 87 70; 62 129 94; ...
       71 160 126; 164 195 186; 57 91 101; 49 127 132; 36 170 174; 70 184 193; 170 205 201; 21 27 25];
% legend order: >=98 96 92 88 84 80 76 72 68 64 60 56 52 48 44 40 36 32 28 24 20 16 <14 %, land
lines = [116 160 162; 140 182 183];                         % printed graticule line: centre and blurred edge
% every image pixel -> nearest colour (1-22 ice classes, 23 water, 24 land, 25-26 graticule line)
P = double(reshape(img, [], 3)); C = [pal; lines]; dmin = inf(size(P, 1), 1); pc = zeros(size(P, 1), 1);
for j = 1:size(C, 1)
    d = sum((P - C(j, :)).^2, 2); b = d < dmin; dmin(b) = d(b); pc(b) = j;
end
pc = reshape(pc, size(img, 1), size(img, 2));
% printed longitude labels (dark grey text 45W 45E 135W 135E, 50S) match near-black ice classes: inside these text boxes
% [x1 x2 y1 y2] (scan px) every non-water pixel counts as line (same boxes as C2, 2026-11-27)
tb = [180 320 200 265; 1350 1480 200 265; 210 360 1380 1445; 1330 1475 1380 1445; 25 115 380 480];
for k = 1:size(tb, 1)
    sub = pc(tb(k, 3):tb(k, 4), tb(k, 1):tb(k, 2)); sub(sub ~= 23) = 25; pc(tb(k, 3):tb(k, 4), tb(k, 1):tb(k, 2)) = sub;
end
% grid cell = majority of the non-line pixels in a 7x7 window around the cell centre
cls = zeros(n);                                             % 0 outside, 1 ice, 2 water, 3 land
use = LAT <= -50 & PX >= 4 & PY >= 4 & PX <= size(img, 2) - 3 & PY <= size(img, 1) - 3;
iu = find(use); [ox, oy] = meshgrid(-3:3);
w = pc(sub2ind(size(pc), round(PY(iu)) + oy(:)', round(PX(iu)) + ox(:)'));
nIce = sum(w <= 22, 2); nWat = sum(w == 23, 2); nLand = sum(w == 24, 2);
[~, mx] = max([nIce nWat nLand], [], 2); mx(nIce + nWat + nLand == 0) = 2;   % only line pixels -> water
cls(iu) = mx; cls0 = cls;                                  % cls0 = before the speckle filter (step figure)
% remove digitising noise: an SP-459 ice cell needs >= 3 ice neighbours (3x3); light speckles in the
% printed water fall into the ">= 98 %" class and dots of the graticule survive the line filter
iceS = cls == 1 & conv2(double(cls == 1), ones(3), 'same') >= 4;
cls(cls == 1 & ~iceS) = 2;

%% 3. comparison on common cells
common = cls > 0 & cls < 3 & ~isnan(SIC) & LAT <= -50;
iceO = SIC >= 0.15;
agr = zeros(n);                       % 1 both ice, 2 only ours, 3 only SP-459, 4 both water
agr(common & iceO & iceS) = 1; agr(common & iceO & ~iceS) = 2;
agr(common & ~iceO & iceS) = 3; agr(common & ~iceO & ~iceS) = 4;
km = @(m) sum(AREA(m), 'all') / 1e6;  % 10^6 km2
sectors = {'Weddell', -60, 20; 'Indian', 20, 90; 'Pacific', 90, 160; 'Ross', 160, -130; 'Bell-Amundsen', -130, -60};
row = @(name, m) {name, km(common & iceS & m), km(common & iceO & m), km(agr == 1 & m), ...
                  km(agr == 2 & m), km(agr == 3 & m), km(iceO & LAT <= -50 & m), ...
                  sum(AREA(iceO & m) .* SIC(iceO & m), 'all', 'omitnan') / 1e6};
T = cell2table(row('All', true(n)), 'VariableNames', {'region', 'extent_SP459', 'extent_ours', ...
    'both_ice', 'only_ours', 'only_SP459', 'extent_ours_all', 'area_ours_all'});
for j = 1:size(sectors, 1)
    a = sectors{j, 2}; b = sectors{j, 3};
    if a < b, m = LON >= a & LON < b; else, m = LON >= a | LON < b; end
    T = [T; cell2table(row(sectors{j, 1}, m), 'VariableNames', T.Properties.VariableNames)]; %#ok<AGROW>
end
writetable(T, fullfile('output', 'C1_sp459_extent.csv'));
disp(T);
fprintf('common cells: %.2f e6 km2; agreement (both ice + both water): %.1f %% of common area\n', ...
    km(common), 100*(km(agr == 1) + km(agr == 4))/km(common));
fprintf('ice area ours (all cells >= 15 %%, lat <= -50): %.2f e6 km2  vs SP-459 Table 3-2: 2.71 e6 km2\n', T.area_ours_all(1));
fprintf('tie points South, month mean: water %.1f K, ice %.1f K (SP-459: T_O = 135 K)\n', mean(tpw), mean(tpi));

%% figure 1: side by side, our map painted in the SP-459 colour classes, same projection / frame
[H, W, ~] = size(img); [qx, qy] = meshgrid(1:W, 1:H);
Ainv = inv(A); X2 = Ainv(1,1)*(qx - t(1)) + Ainv(1,2)*(qy - t(2)); Y2 = Ainv(2,1)*(qx - t(1)) + Ainv(2,2)*(qy - t(2));
r2 = floor((-Y2*2*Re + L)/dx) + 1; c2 = floor((X2*2*Re + L)/dx) + 1;
okp = r2 >= 1 & r2 <= n & c2 >= 1 & c2 <= n; lin = sub2ind([n n], r2(okp), c2(okp));
lab = [98 96 92 88 84 80 76 72 68 64 60 56 52 48 44 40 36 32 28 24 20 16];
v = nan(H, W); v(okp) = SIC(lin);
k = nan(H, W); k(v < 0.15) = 23;
iv = find(v >= 0.15); [~, kk] = min(abs(100*v(iv) - lab), [], 2); k(iv) = kk;
lo = false(H, W); lo(okp) = landO(lin); k(lo) = 24;
out = repmat(uint8(255), H, W, 3);
for ch = 1:3
    o = out(:, :, ch); o(~isnan(k)) = pal(k(~isnan(k)), ch); out(:, :, ch) = o;
end
f1 = figure('Visible', 'off', 'Position', [0 0 1500 760], 'Color', 'w');
tl = tiledlayout(f1, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile; image(img); axis image off; title('NASA SP-459, Fig. 5-2a: February 1973 (Zwally et al. 1983)', 'FontWeight', 'normal');
nexttile; image(out); axis image off; hold on; graticule_img(A, t, [0.27 0.6 0.6]); xlim([0.5 W+0.5]); ylim([0.5 H+0.5]);
title('This work: mean SIC February 1973 (A6b, ERA5-corrected), same colour classes', 'FontWeight', 'normal');
text(W - 20, 60, {'white = no data', 'black = land (ERA5)'}, 'HorizontalAlignment', 'right', 'FontSize', 9, 'Color', [0.32 0.32 0.31]);
exportgraphics(f1, fullfile('output', 'C1_sp459_side_by_side.png'), 'Resolution', 150);

%% figure 2: overlay of the SP-459 ice edge on our map + agreement map
blue = hex2rgb_({'#cde2fb','#b7d3f6','#9ec5f4','#86b6ef','#6da7ec','#5598e7','#3987e5','#2a78d6','#256abf','#1c5cab','#184f95','#104281','#0d366b'});
surf_ = [0.988 0.988 0.984]; landc = [0.66 0.66 0.64]; nodat = [0.92 0.92 0.91]; ink = [0.043 0.043 0.043];
lim = 2*Re*tand(20);                                        % lat -50
f2 = figure('Visible', 'off', 'Position', [0 0 1500 760], 'Color', 'w');
tiledlayout(f2, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
% (a) our SIC + edges
ax = nexttile; hold(ax, 'on');
cm = [surf_; interp1(linspace(0.15, 1, size(blue, 1)), blue, linspace(0.15, 1, 85)')];
Z = SIC; Z(SIC < 0.15) = 0.14;
rgbA = ind2rgb_(Z, cm, [0.14 1]); rgbA = paint(rgbA, isnan(SIC), nodat); rgbA = paint(rgbA, landO, landc);
image(ax, g, g, rgbA); set(ax, 'YDir', 'normal');
contour(ax, g, g, double(iceS & common) + 0*U, [0.5 0.5], 'Color', '#eb6834', 'LineWidth', 2);
contour(ax, g, g, double(iceO & common), [0.5 0.5], 'Color', ink, 'LineWidth', 1);
graticule_xy(ax, Re);
axis(ax, 'image'); axis(ax, [-lim lim -lim lim]); axis(ax, 'off');
h1 = plot(ax, nan, nan, '-', 'Color', '#eb6834', 'LineWidth', 2); h2 = plot(ax, nan, nan, '-', 'Color', ink, 'LineWidth', 1);
legend(ax, [h1 h2], {'ice edge SP-459 (>= 16 % class, digitised)', 'ice edge this work (SIC = 15 %)'}, 'Location', 'southoutside', 'Box', 'off');
colormap(ax, cm(2:end, :)); clim(ax, [15 100]); cb = colorbar(ax, 'eastoutside'); cb.Label.String = 'mean SIC February 1973 [%]';
title(ax, '(a) This work, mean SIC, with both ice edges', 'FontWeight', 'normal');
% (b) agreement
ax = nexttile; hold(ax, 'on');
cc = [hex2rgb_({'#2a78d6'}); hex2rgb_({'#eb6834'}); hex2rgb_({'#1baf7a'}); surf_];
rgbB = repmat(reshape(nodat, 1, 1, 3), n, n); for j = 1:4, rgbB = paint(rgbB, agr == j, cc(j, :)); end
rgbB = paint(rgbB, landO | cls == 3, landc);
image(ax, g, g, rgbB); set(ax, 'YDir', 'normal'); graticule_xy(ax, Re);
axis(ax, 'image'); axis(ax, [-lim lim -lim lim]); axis(ax, 'off');
hh = gobjects(3, 1); nm = {'both ice', 'ice only in this work', 'ice only in SP-459'};
for j = 1:3
    hh(j) = plot(ax, nan, nan, 's', 'MarkerFaceColor', cc(j, :), 'MarkerEdgeColor', 'none', 'MarkerSize', 10);
    nm{j} = sprintf('%s: %.2f x 10^6 km^2', nm{j}, km(agr == j));
end
legend(ax, hh, nm, 'Location', 'southoutside', 'Box', 'off');
title(ax, sprintf('(b) Agreement (common cells, lat \\leq -50): extent SP-459 %.2f, this work %.2f x 10^6 km^2', ...
    T.extent_SP459(1), T.extent_ours(1)), 'FontWeight', 'normal');
exportgraphics(f2, fullfile('output', 'C1_sp459_overlay.png'), 'Resolution', 150);
fprintf('saved output/C1_sp459_side_by_side.png, output/C1_sp459_overlay.png, output/C1_sp459_extent.csv\n');

%% step images for the explainer page report_notes/C1_sp459_steps.html -> output/C1_steps/
sd = fullfile('output', 'C1_steps'); if ~exist(sd, 'dir'), mkdir(sd); end
cIce = hex2rgb_({'#2a78d6'}); cLine = hex2rgb_({'#eb6834'}); cWat = surf_;
% step 1: scan + fitted graticule (full map and zoom)
f = figure('Visible', 'off', 'Position', [0 0 900 860], 'Color', 'w');
axes('Position', [0 0 1 1]); image(img); axis image off; hold on;
graticule_img(A, t, cLine, 1.6); xlim([0.5 W+0.5]); ylim([0.5 H+0.5]);
rectangle('Position', [300 250 400 400], 'EdgeColor', ink, 'LineWidth', 1.5, 'LineStyle', '--');
exportgraphics(f, fullfile(sd, 's1_georef.png'), 'Resolution', 110);
f = figure('Visible', 'off', 'Position', [0 0 700 700], 'Color', 'w');
axes('Position', [0 0 1 1]); image(img); axis image off; hold on;
graticule_img(A, t, cLine, 1.6); xlim([300 700]); ylim([250 650]);
exportgraphics(f, fullfile(sd, 's1_georef_zoom.png'), 'Resolution', 110);
% step 2: pixel classes, Weddell Sea zoom: scan vs. class per pixel
pcol = [repmat(cIce, 22, 1); cWat; landc; cLine; cLine];
pimg = reshape(pcol(pc(:), :), [size(pc) 3]);
for nmz = {'scan', 'classes'}
    f = figure('Visible', 'off', 'Position', [0 0 700 560], 'Color', 'w');
    axes('Position', [0 0 1 1]);
    if strcmp(nmz{1}, 'scan'), image(img); else, image(pimg); end
    axis image off; xlim([330 830]); ylim([380 780]);
    exportgraphics(f, fullfile(sd, ['s2_' nmz{1} '.png']), 'Resolution', 110);
end
% step 3: SP-459 ice mask on the 30 km grid, before and after the speckle filter
for nmz = {'before', 'after'}
    if strcmp(nmz{1}, 'before'), cc3 = cls0; else, cc3 = cls; end
    rgb3 = repmat(reshape(nodat, 1, 1, 3), n, n);
    rgb3 = paint(rgb3, cc3 == 2, cWat); rgb3 = paint(rgb3, cc3 == 1, cIce); rgb3 = paint(rgb3, cc3 == 3, landc);
    f = figure('Visible', 'off', 'Position', [0 0 700 700], 'Color', 'w');
    ax = axes('Position', [0 0 1 1]); hold(ax, 'on');
    image(ax, g, g, rgb3); set(ax, 'YDir', 'normal'); graticule_xy(ax, Re);
    axis(ax, 'image'); axis(ax, [-lim lim -lim lim]); axis(ax, 'off');
    exportgraphics(f, fullfile(sd, ['s3_mask_' nmz{1} '.png']), 'Resolution', 110);
end
% step 4: our mean SIC (no edges)
f = figure('Visible', 'off', 'Position', [0 0 760 700], 'Color', 'w');
ax = axes('Position', [0.02 0.02 0.8 0.96]); hold(ax, 'on');
image(ax, g, g, rgbA); set(ax, 'YDir', 'normal'); graticule_xy(ax, Re);
axis(ax, 'image'); axis(ax, [-lim lim -lim lim]); axis(ax, 'off');
colormap(ax, cm(2:end, :)); clim(ax, [15 100]); cb = colorbar(ax, 'eastoutside'); cb.Label.String = 'mean SIC February 1973 [%]';
exportgraphics(f, fullfile(sd, 's4_our_sic.png'), 'Resolution', 110);
fprintf('saved step images in %s\n', sd);

%% helpers
function c = hex2rgb_(h)
c = cell2mat(cellfun(@(s) sscanf(s(2:end), '%2x%2x%2x')'/255, h(:), 'UniformOutput', false));
end
function rgb = ind2rgb_(Z, cm, lims)
i = round((Z - lims(1)) / diff(lims) * (size(cm, 1) - 1)) + 1; i(isnan(i)) = 1; i = min(max(i, 1), size(cm, 1));
rgb = reshape(cm(i, :), [size(Z) 3]);
end
function rgb = paint(rgb, m, c)
for ch = 1:3, x = rgb(:, :, ch); x(m) = c(ch); rgb(:, :, ch) = x; end
end
function graticule_xy(ax, Re)
gc = [0.75 0.75 0.73];
for la = [-55 -60 -65 -70 -75 -80]
    r = 2*Re*tand((90 + la)/2); a = linspace(0, 360, 361);
    plot(ax, r*sind(a), r*cosd(a), '-', 'Color', gc, 'LineWidth', 0.5);
end
r = 2*Re*tand(19);
for lo = 0:45:315
    plot(ax, [0 r*sind(lo)], [0 r*cosd(lo)], '-', 'Color', gc, 'LineWidth', 0.5);
    if mod(lo, 90) == 0
        s = {'0°', '90°E', '180°', '90°W'}; text(ax, 1.04*r*sind(lo), 1.04*r*cosd(lo), s{lo/90 + 1}, ...
            'HorizontalAlignment', 'center', 'FontSize', 8, 'Color', [0.32 0.32 0.31]);
    end
end
end
function graticule_img(A, t, col, lw)
if nargin < 4, lw = 0.5; end
for la = [-50 -55 -60 -65 -70]
    a = linspace(0, 360, 721); r = tand((90 + la)/2);
    X = r*sind(a); Y = -r*cosd(a);
    plot(t(1) + A(1,1)*X + A(1,2)*Y, t(2) + A(2,1)*X + A(2,2)*Y, '-', 'Color', col, 'LineWidth', lw);
end
r = tand(20);
for lo = 0:45:315
    X = [0 r*sind(lo)]; Y = [0 -r*cosd(lo)];
    plot(t(1) + A(1,1)*X + A(1,2)*Y, t(2) + A(2,1)*X + A(2,2)*Y, '-', 'Color', col, 'LineWidth', lw);
end
end
