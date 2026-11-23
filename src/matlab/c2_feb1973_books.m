% C2 - Our February 1973 mean SIC, BOTH hemispheres, against the two NASA reference books:
%      South: SP-459 Fig. 5-2a (Zwally et al. 1983), North: SP-489 Fig. 4-19a (Parkinson et al. 1987).
%
% GRIDS (sphere Re = 6371 km, 30 km cells, L = 4800 km, n = 320 cells per side, cell centres
%   u = -L + dx/2 + (c-1)*dx,  v = -L + dx/2 + (r-1)*dx,  c = column, r = row, 1-based)
%   South:  u =  2Re*tan((90+lat)/2)*sin(lon),  v = +2Re*tan((90+lat)/2)*cos(lon)   (0 deg up, 90E right)
%           inverse: rho = hypot(u,v), colat = 2*atand(rho/(2Re)), lat = -(90-colat), lon = atan2d(u, v)
%   North:  u =  2Re*tan((90-lat)/2)*sin(lon),  v = -2Re*tan((90-lat)/2)*cos(lon)   (0 deg DOWN, 90E right)
%           inverse: lat = 90-colat, lon = atan2d(u, -v)
%   True cell area = dx^2*cos(colat/2)^4 [km2].
% MATRIX CONVENTION in this script: row 1 = BOTTOM of the map (v = -L+dx/2), plot with YDir normal.
% EXPORT (output/globe/feb1973.js): arrays are ROW-MAJOR over the stored crop: row r0 first, within a row
%   columns c0..c1 (index = (r-r0)*(c1-c0+1) + (c-c0), 0-based); r0 = lowest row of the crop (v smallest).
%
% STEPS
%   1. Our data: per day correct_day.m (A6b, 2 iterations), SIC per pixel with the day's corrected tie points of
%      the pixel's hemisphere, binned on the grids; daily cell mean = mean of the unclipped pixel SIC of that day,
%      monthly mean = mean of the daily cell means (every day with data in the cell has the same weight), then
%      clipped to 0..1. Days 0201..0228 (all days in ESMR_colocated_filtered, as in C1). Land = ERA5 (sst NaN).
%      Cache per day: output/C2_cache/.
%   2. Books: map scan -> affine georeference (fit on drawn parallels and meridians) -> every pixel to the
%      nearest swatch colour (CIE Lab) -> grid cell = majority of the non-line pixels around the cell centre.
%      South: as C1 (23 swatches of the SP-459 legend). North: swatches sampled from the SP-489 legend
%      (first-year column F_MY = 0) + land and water swatches sampled in the map.
%      Classes: 22 ice classes of 4 % width, lower bounds 14,18,...,94,98 (label = midpoint 16,...,96, >= 98),
%      water = "< 14 %", ice = any class >= 14 %.
%   3. Common cells (book ocean + our ocean data, lat >= 50 N / <= -50 S): edge agreement, extent, ice area,
%      mean of our SIC per book class, ice edges as lat/lon polylines.
% OUTPUT: output/C2_feb1973_maps.png, output/C2_conc_compare.png, output/C2_feb1973_books.csv,
%         output/globe/feb1973.js  (ESMR_MONTH(<json>);)
% Run from the project root:  matlab -batch "run('src/matlab/c2_feb1973_books.m')"
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile('src','matlab'));

%% grid
Re = 6371; dx = 30; L = 4800; g = (-L + dx/2):dx:(L - dx/2); n = numel(g);
[U, V] = meshgrid(g, g);                                   % row 1 = bottom (v = -L)
rho = hypot(U, V); colat = 2*atand(rho/(2*Re));
AREA = dx^2 * cosd(colat/2).^4;
LATh = {90 - colat, -(90 - colat)}; LONh = {atan2d(U, -V), atan2d(U, V)};   % {North, South}
hn = 'NS'; hname = {'Arctic', 'Antarctic'};
latlim = [50 -50];                                         % common-cell limit, both hemispheres (= preprocessing |lat| >= 50)
LO = 14:4:98; MID = [16:4:96 99]; nc = numel(LO);          % ice classes (ascending), lower bound / midpoint

%% 1. our monthly mean SIC, both hemispheres, cached per day
files = dir(fullfile('ESMR_colocated_filtered', '*.nc'));
fday  = string(regexp({files.name}, '1973m(\d{4})t', 'tokens', 'once'));
days  = unique(fday);
cdir  = fullfile('output', 'C2_cache'); if ~exist(cdir, 'dir'), mkdir(cdir); end
ckey  = struct('tp', tp_opt(), 'cfg', preproc_config());   % cache key: masks and preprocessing used
S = zeros(n, n, 2); N = S; ND = S; NL = S; tpw = nan(numel(days), 2); tpi = tpw;
for i = 1:numel(days)
    cf = fullfile(cdir, days(i) + ".mat");
    if cache_stale(cf, ckey)                       % missing, or built with other masks / preprocessing
        fi = find(fday == days(i));
        fn = arrayfun(@(k) fullfile(files(k).folder, files(k).name), fi, 'UniformOutput', false);
        [O, TP] = correct_day(fn, 2);
        s = zeros(n, n, 2); c = s; cl = s; tp = TP;
        for h = 1:2
            T = TP.(hn(h));
            for k = 1:numel(O)
                o = O(k);
                if h == 1, hm = o.lat > 45; else, hm = o.lat < -45; end
                m = hm & ~isnan(o.dtb);                          % corrected ocean pixels of the hemisphere
                sic = (o.tb_f(m) + o.dtb(m) - T.water_c) / (T.ice_c - T.water_c);
                [r, q] = cellidx(h, o.lat(m), o.lon(m), Re, L, dx); ok = r >= 1 & r <= n & q >= 1 & q <= n;
                s(:,:,h) = s(:,:,h) + accumarray([r(ok) q(ok)], sic(ok), [n n]);
                c(:,:,h) = c(:,:,h) + accumarray([r(ok) q(ok)], 1, [n n]);
                ml = hm & isnan(o.sst);                          % ERA5 land (display only)
                [r, q] = cellidx(h, o.lat(ml), o.lon(ml), Re, L, dx); ok = r >= 1 & r <= n & q >= 1 & q <= n;
                cl(:,:,h) = cl(:,:,h) + accumarray([r(ok) q(ok)], 1, [n n]);
            end
        end
        tp = struct('N', TP.N, 'S', TP.S); save(cf, 's', 'c', 'cl', 'tp', 'ckey');
        fprintf('%s: %d orbits\n', days(i), numel(O));
    end
    D = load(cf); hd = D.c > 0;                              % daily cell mean, each day weighted equally
    dm = zeros(size(D.s)); dm(hd) = D.s(hd) ./ D.c(hd);
    S = S + dm; ND = ND + hd; N = N + D.c; NL = NL + D.cl;
    for h = 1:2, tpw(i, h) = D.tp.(hn(h)).water_c; tpi(i, h) = D.tp.(hn(h)).ice_c; end
end
SICh = S ./ ND; SICh(N < 3) = NaN; SICh = min(max(SICh, 0), 1);
landO = NL > N & N < 3;                                     % our land (ERA5) cells

%% 2a. North: SP-489 map. Legend swatches (first-year column) and georeference
img = {imread(fullfile('docs', 'sp489', 'fig_feb1973.jpg')), imread(fullfile('docs', 'sp459', 'fig5-2a_feb1973.jpg'))};
leg = imread(fullfile('docs', 'sp489', 'legend.jpg')); y14 = 1370; ppp = (1370 - 85)/86;   % legend: y of 14 %, px per %
swN = zeros(nc + 1, 3);                                    % row 1..22 ice classes (ascending), row 23 = "< 14 %"
for k = 0:nc
    if k == 0, lo = 10; hi = 14; elseif k == nc, lo = 98; hi = 100; else, lo = 10 + 4*k; hi = lo + 4; end
    yc = round(y14 - ((lo + hi)/2 - 14)*ppp);
    sw = squeeze(median(median(leg(yc-6:yc+6, 233:285, :), 1), 2))';
    if k == 0, swN(nc + 1, :) = sw; else, swN(k, :) = sw; end
end
M = img{1}; ptc = @(x, y) squeeze(median(median(M(y-3:y+3, x-3:x+3, :), 1), 2))';
waterMap = [ptc(900, 1400); ptc(1000, 1250); ptc(100, 700)];         % open water in the map (a bit darker than the legend)
landMap  = [ptc(1100, 350); ptc(800, 950); ptc(1300, 700); ptc(300, 1250); ptc(1400, 1400)];
% class 26-30 % (swatch 4, navy) is dropped: the violet of 100 % (WET) in the map lies between it and swatch 22 and was
% matched to it (14000 px of violet); true 26-30 % pixels (narrow edge band) then go to the neighbouring classes
keepc = [1:3 5:nc];
palN = [swN(keepc, :); swN(nc+1, :); waterMap; landMap; 8 8 8];     % ice classes, water (legend + map), land, line
grpN = [keepc, repmat(nc + 1, 1, 4), repmat(nc + 2, 1, 5), nc + 3];  % group: 1..22 class, 23 water, 24 land, 25 line
[AN, tN, rmsN] = fit_north(M);
fprintf('North georeference: rms %.2f px = %.1f km (%d points)\n', rmsN.px, rmsN.km, rmsN.n);

%% 2b. South: SP-459 (as C1). Palette order: >= 98, 96, ..., 16, < 14, land, lines
A = {AN, [2258.429 0.5917799; -0.11675 2296.727]}; t = {tN, [825.0353; 833.3931]};
palS = [186 195 190; 116 86 78; 205 114 87; 208 140 121; 207 188 174; 206 209 194; 56 63 59; 71 77 67; ...
        134 133 103; 184 182 143; 196 136 88; 211 159 87; 210 183 93; 214 221 177; 60 87 70; 62 129 94; ...
        71 160 126; 164 195 186; 57 91 101; 49 127 132; 36 170 174; 70 184 193; 170 205 201; 21 27 25];
palS = [flipud(palS(1:nc, :)); palS(nc+1, :); palS(nc+2, :); 116 160 162; 140 182 183];   % ascending classes, water, land, lines
grpS = [1:nc, nc + 1, nc + 2, nc + 3, nc + 3];
pal = {palN, palS}; grp = {grpN, grpS}; win = [2 3];       % half window of the majority vote (5x5 N, 7x7 S)

%% 2c. classify every grid cell of both books
CLS = zeros(n, n, 2); BCL = zeros(n, n, 2); CLS0 = CLS; PC = cell(1, 2); PXY = cell(1, 2);
for h = 1:2
    I = img{h}; [H, W, ~] = size(I);
    if h == 1, Xt = U/(2*Re); Yt = -V/(2*Re); else, Xt = U/(2*Re); Yt = -V/(2*Re); end
    PX = t{h}(1) + A{h}(1,1)*Xt + A{h}(1,2)*Yt; PY = t{h}(2) + A{h}(2,1)*Xt + A{h}(2,2)*Yt; PXY{h} = {PX, PY};
    lab = rgb2lab_(double(reshape(I, [], 3))); labp = rgb2lab_(double(pal{h}));
    dmin = inf(size(lab, 1), 1); pc = zeros(size(lab, 1), 1);
    for j = 1:size(labp, 1)
        d = sum((lab - labp(j, :)).^2, 2); b = d < dmin; dmin(b) = d(b); pc(b) = grp{h}(j);
    end
    pc = reshape(pc, H, W);
    if h == 1   % near-black ice classes: only blobs >= 5 px count (thin black coast / graticule lines -> line)
        dk = ismember(pc, [8 14 15 16 21]); op = conv2(double(conv2(double(dk), ones(5), 'same') == 25), ones(5), 'same') > 0;
        pc(dk & ~op) = nc + 3;
    end
    PC{h} = pc;                    % 1..22 ice class, 23 water, 24 land, 25 line
    if h == 1, use = LATh{1} >= latlim(1) & PX >= 30 & PY >= 30 & PX <= 1497 & PY <= 1538;
    else,      use = LATh{2} <= latlim(2) & PX >= 4 & PY >= 4 & PX <= W - 3 & PY <= H - 3; end
    iu = find(use); [ox, oy] = meshgrid(-win(h):win(h));
    w = pc(sub2ind(size(pc), round(PY(iu)) + oy(:)', round(PX(iu)) + ox(:)'));
    cnt = zeros(numel(iu), nc + 3); for j = 1:nc + 2, cnt(:, j) = sum(w == j, 2); end
    nIce = sum(cnt(:, 1:nc), 2); nWat = cnt(:, nc + 1); nLand = cnt(:, nc + 2);
    [~, mx] = max([nIce nWat nLand], [], 2); mx(nIce + nWat + nLand == 0) = 2;
    [~, jm] = max(cnt(:, 1:nc), [], 2);
    c0 = zeros(n); c0(iu) = mx; CLS0(:,:,h) = c0;
    bc = zeros(n); bc(iu(mx == 1)) = jm(mx == 1);
    if h == 2   % South: the dark-grey swatch of class 76 is also the printed coastline; keep such a cell as ice only
                % if >= 2 of its 8 neighbours are ice cells of another class (else it is coast -> land)
        o = ones(3); o(2, 2) = 0; nb = conv2(double(bc > 0 & bc ~= 16), o, 'same');
        cst = bc == 16 & nb < 2; bc(cst) = 0; c0(cst) = 3; CLS0(:,:,h) = c0;
    end
    BCL(:,:,h) = bc;
end
ICEB = false(n, n, 2);
for h = 1:2
    c0 = CLS0(:,:,h);
    if h == 1   % isolated land cells (graticule dots in the water) -> water; real 1-cell islands are lost
        c0(c0 == 3 & conv2(double(c0 == 3), ones(3), 'same') < 3) = 2;
    end
    ib = c0 == 1 & conv2(double(c0 == 1), ones(3), 'same') >= 4;   % speckle filter as C1
    c0(c0 == 1 & ~ib) = 2; CLS(:,:,h) = c0; ICEB(:,:,h) = ib;
    b = BCL(:,:,h); b(~ib) = 0; BCL(:,:,h) = b;
end

%% 3. comparison
km = @(m) sum(AREA(m), 'all') / 1e6;                        % 10^6 km2
R = struct(); rows = {};
tabT = []; cls_tab = cell(1, 2);
for h = 1:2
    SIC = SICh(:,:,h); LAT = LATh{h}; cl = CLS(:,:,h); iceB = ICEB(:,:,h); bcl = BCL(:,:,h); lnd = landO(:,:,h);
    if h == 1, inlat = LAT >= latlim(1); else, inlat = LAT <= latlim(2); end
    common = cl > 0 & cl < 3 & ~isnan(SIC) & inlat;
    iceO = SIC >= 0.15;
    agr = zeros(n); agr(common & iceO & iceB) = 1; agr(common & iceO & ~iceB) = 2;
    agr(common & ~iceO & iceB) = 3; agr(common & ~iceO & ~iceB) = 4;
    midB = zeros(n); midB(bcl > 0) = MID(bcl(bcl > 0));
    st.extent_ours = km(common & iceO); st.extent_book = km(common & iceB);
    st.both_ice = km(agr == 1); st.only_ours = km(agr == 2); st.only_book = km(agr == 3); st.both_water = km(agr == 4);
    st.common_area = km(common); st.agree_pct = 100*(st.both_ice + st.both_water)/st.common_area;
    st.n_common = sum(common(:));
    st.area_ours = sum(AREA(common & iceO) .* SIC(common & iceO)) / 1e6;
    st.area_book_classes = sum(AREA(common & iceB) .* midB(common & iceB)/100) / 1e6;
    st.area_ours_all = sum(AREA(iceO & inlat) .* SIC(iceO & inlat), 'omitnan') / 1e6;
    st.extent_ours_all = km(iceO & inlat);
    if h == 2, st.area_book_table = 2.712; else, st.area_book_table = NaN; end
    st.tp_water = mean(tpw(:, h)); st.tp_ice = mean(tpi(:, h));
    % mean of our SIC per book class (common cells)
    ct = zeros(nc + 1, 4);                                    % lower bound, n, mean, std of our SIC [%]
    for j = 0:nc
        if j == 0, m = common & ~iceB; lo = 0; else, m = common & bcl == j; lo = LO(j); end
        x = 100*SIC(m); ct(j + 1, :) = [lo sum(m(:)) mean(x) std(x)];
    end
    cls_tab{h} = ct;
    diffm = nan(n); mm = common & (iceO | iceB); diffm(mm) = 100*SIC(mm) - midB(mm);
    st.mean_diff = mean(diffm(mm)); st.agr = agr; st.common = common; st.midB = midB; st.diffm = diffm;
    R(h).st = st;
    fprintf('%s: extent ours %.2f book %.2f (1e6 km2); agreement %.1f %%; area ours %.2f book classes %.2f; n=%d\n', ...
        hname{h}, st.extent_ours, st.extent_book, st.agree_pct, st.area_ours, st.area_book_classes, st.n_common);
end

%% table csv
vn = {'hemisphere', 'book', 'common_area', 'extent_ours', 'extent_book', 'both_ice', 'only_ours', 'only_book', 'both_water', ...
      'agree_pct', 'area_ours', 'area_book_classes', 'area_book_table', 'extent_ours_all', 'area_ours_all', 'mean_diff', 'tp_water', 'tp_ice'};
bk = {'SP-489', 'SP-459'}; T = table();
for h = 1:2
    s = R(h).st;
    T = [T; table(string(hname{h}), string(bk{h}), s.common_area, s.extent_ours, s.extent_book, s.both_ice, s.only_ours, ...
        s.only_book, s.both_water, s.agree_pct, s.area_ours, s.area_book_classes, s.area_book_table, s.extent_ours_all, ...
        s.area_ours_all, s.mean_diff, s.tp_water, s.tp_ice, 'VariableNames', vn)]; %#ok<AGROW>
end
writetable(T, fullfile('output', 'C2_feb1973_books.csv')); disp(T);
CT = table();
for h = 1:2
    ct = cls_tab{h};
    CT = [CT; table(repmat(string(hname{h}), nc + 1, 1), ct(:,1), ct(:,2), ct(:,3), ct(:,4), 'VariableNames', ...
        {'hemisphere', 'class_lower', 'n_cells', 'mean_our_sic', 'std_our_sic'})]; %#ok<AGROW>
end
writetable(CT, fullfile('output', 'C2_feb1973_classes.csv')); disp(CT);

%% edge polylines (lat/lon)
for h = 1:2
    s = R(h).st; SIC = SICh(:,:,h); cl = CLS(:,:,h);
    if h == 1, inlat = LATh{1} >= latlim(1); else, inlat = LATh{2} <= latlim(2); end
    inv = ~s.common;                                          % both edges only on the common ocean cells (same cells as the numbers)
    R(h).edge_ours = edge_lines(SIC >= 0.15, inv, g, h, Re);
    R(h).edge_book = edge_lines(ICEB(:,:,h), inv, g, h, Re);
    fprintf('%s: edge polylines ours %d, book %d\n', hname{h}, numel(R(h).edge_ours), numel(R(h).edge_book));
end

%% figure 1: maps. rows Arctic / Antarctic; columns our SIC, book classified, agreement + both edges
blue = hex2rgb_({'#cde2fb','#b7d3f6','#9ec5f4','#86b6ef','#6da7ec','#5598e7','#3987e5','#2a78d6','#256abf','#1c5cab','#184f95','#104281','#0d366b'});
surf_ = [0.988 0.988 0.984]; landc = [0.66 0.66 0.64]; nodat = [0.92 0.92 0.91]; ink = [0.043 0.043 0.043];
cm = [surf_; interp1(linspace(0.15, 1, size(blue, 1)), blue, linspace(0.15, 1, 85)')];
ccA = [hex2rgb_({'#2a78d6'}); hex2rgb_({'#eb6834'}); hex2rgb_({'#1baf7a'}); surf_];
f1 = figure('Visible', 'off', 'Position', [0 0 1700 1180], 'Color', 'w');
tl = tiledlayout(f1, 2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
for h = 1:2
    s = R(h).st; SIC = SICh(:,:,h); cl = CLS(:,:,h); lim = 2*Re*tand((90 - abs(latlim(h)))/2);
    % (a) ours
    ax = nexttile; hold(ax, 'on');
    Z = SIC; Z(SIC < 0.15) = 0.14; rgb = ind2rgb_(Z, cm, [0.14 1]);
    rgb = paint(rgb, isnan(SIC) | ~s.common, nodat); rgb = paint(rgb, landO(:,:,h), landc);   % only common ocean cells coloured
    image(ax, g, g, rgb); set(ax, 'YDir', 'normal'); graticule_xy(ax, Re, h, lim);
    axis(ax, 'image'); axis(ax, [-lim lim -lim lim]); axis(ax, 'off');
    title(ax, sprintf('%s: this work, mean SIC February 1973', hname{h}), 'FontWeight', 'normal');
    % (b) book classified
    ax = nexttile; hold(ax, 'on');
    Zb = zeros(n); Zb(s.midB > 0) = s.midB(s.midB > 0)/100; Zb(Zb == 0) = 0.14; rgb = ind2rgb_(Zb, cm, [0.14 1]);
    rgb = paint(rgb, cl == 0 | ~s.common, nodat); rgb = paint(rgb, cl == 3, landc);
    image(ax, g, g, rgb); set(ax, 'YDir', 'normal'); graticule_xy(ax, Re, h, lim);
    axis(ax, 'image'); axis(ax, [-lim lim -lim lim]); axis(ax, 'off');
    title(ax, sprintf('%s: %s, classified (class midpoints)', hname{h}, bookname_(h)), 'FontWeight', 'normal');
    % (c) agreement
    ax = nexttile; hold(ax, 'on');
    rgb = repmat(reshape(nodat, 1, 1, 3), n, n); for j = 1:4, rgb = paint(rgb, s.agr == j, ccA(j, :)); end
    rgb = paint(rgb, landO(:,:,h) | cl == 3, landc);
    image(ax, g, g, rgb); set(ax, 'YDir', 'normal'); graticule_xy(ax, Re, h, lim);
    fld = {'both_ice', 'only_ours', 'only_book'}; hh = gobjects(5, 1); nm = {'both ice', 'only this work', ['only ' bookname_(h)]};
    for j = 1:3
        hh(j) = plot(ax, nan, nan, 's', 'MarkerFaceColor', ccA(j, :), 'MarkerEdgeColor', 'none', 'MarkerSize', 9);
        nm{j} = sprintf('%s: %.2f', nm{j}, s.(fld{j}));
    end
    for k = 1:numel(R(h).edge_book), pl = ll2uv_(R(h).edge_book{k}, h, Re); plot(ax, pl(:,1), pl(:,2), '-', 'Color', '#eb6834', 'LineWidth', 1.6); end
    for k = 1:numel(R(h).edge_ours), pl = ll2uv_(R(h).edge_ours{k}, h, Re); plot(ax, pl(:,1), pl(:,2), '-', 'Color', ink, 'LineWidth', 0.9); end
    hh(4) = plot(ax, nan, nan, '-', 'Color', '#eb6834', 'LineWidth', 1.6); hh(5) = plot(ax, nan, nan, '-', 'Color', ink, 'LineWidth', 0.9);
    nm = [nm, {['edge ' bookname_(h)], 'edge this work (15 %)'}];
    axis(ax, 'image'); axis(ax, [-lim lim -lim lim]); axis(ax, 'off');
    legend(ax, hh, nm, 'Location', 'southoutside', 'Box', 'off', 'NumColumns', 2, 'FontSize', 8);
    title(ax, sprintf('%s: agreement %.1f %%, extent this work %.2f, %s %.2f (10^6 km^2)', hname{h}, s.agree_pct, ...
        s.extent_ours, bookname_(h), s.extent_book), 'FontWeight', 'normal', 'FontSize', 10);
end
ax2 = nexttile(2); colormap(ax2, cm(2:end, :)); clim(ax2, [15 100]); cb = colorbar(ax2, 'eastoutside'); cb.Label.String = 'SIC [%]';
title(tl, 'Coloured: cells that are ocean in both maps (all numbers use these cells). Light grey: no data or ocean in one map only.', 'FontSize', 10);
exportgraphics(f1, fullfile('output', 'C2_feb1973_maps.png'), 'Resolution', 130);

%% figure 2: our SIC per book class
f2 = figure('Visible', 'off', 'Position', [0 0 1100 1100], 'Color', 'w');
tiledlayout(f2, 2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
for h = 1:2
    ax = nexttile; hold(ax, 'on'); ct = cls_tab{h}; x = [8 MID]; ok = ct(:, 2) > 0;
    plot(ax, [0 100], [0 100], '-', 'Color', [0.7 0.7 0.7]);
    errorbar(ax, x(ok), ct(ok, 3), ct(ok, 4), 'o-', 'Color', '#2a78d6', 'MarkerFaceColor', '#2a78d6', 'LineWidth', 1.3);
    for j = find(ok)', text(ax, x(j), min(ct(j, 3) + ct(j, 4), 100) + 2.5, sprintf('%d', ct(j, 2)), 'HorizontalAlignment', 'center', 'FontSize', 7, 'Color', [0.4 0.4 0.4]); end
    xlabel(ax, ['class of ' bookname_(h) ' (midpoint, %; first point = open water "< 14 %")']); ylabel(ax, 'mean SIC of this work [%]  (bars: std)');
    axis(ax, [0 105 -5 115]); grid(ax, 'on'); box(ax, 'off');
    title(ax, sprintf('%s: this work per %s class (numbers = cells; grey line = 1:1)', hname{h}, bookname_(h)), 'FontWeight', 'normal');
end
exportgraphics(f2, fullfile('output', 'C2_conc_compare.png'), 'Resolution', 130);

%% diagnostic figure: classified scan (look at it)
f3 = figure('Visible', 'off', 'Position', [0 0 1700 800], 'Color', 'w'); tiledlayout(f3, 1, 2, 'TileSpacing', 'none', 'Padding', 'none');
for h = 1:2
    ax = nexttile; pc = PC{h}; colors = [repmat([0.2 0.5 0.9], nc, 1); 0.85 0.93 1; 0.5 0.5 0.5; 0 0 0];
    cmap = [flipud(parula(nc)); 0.85 0.93 1; 0.5 0.5 0.5; 0 0 0];
    image(ax, ind2rgb(double(pc), cmap)); axis(ax, 'image', 'off'); hold(ax, 'on');
    [Hh, Ww] = size(pc); [gq, gp] = meshgrid(1:round(n/3):n); %#ok<ASGLU>
    cs = (1:n); lim = 2*Re*tand((90 - abs(latlim(h)))/2);
    % cell grid corner outline of the used region
    th = linspace(0, 2*pi, 400); ru = lim; Xc = ru*cos(th)/(2*Re); Yc = ru*sin(th)/(2*Re);
    plot(ax, t{h}(1) + A{h}(1,1)*Xc + A{h}(1,2)*Yc, t{h}(2) + A{h}(2,1)*Xc + A{h}(2,2)*Yc, 'm-');
end
exportgraphics(f3, fullfile('output', 'C2_classified_scans.png'), 'Resolution', 100);

%% export for the globe
if ~exist(fullfile('output', 'globe'), 'dir'), mkdir(fullfile('output', 'globe')); end
Hs = struct();
srcs = {'NASA SP-489, Fig. 4-19a', 'NASA SP-459, Fig. 5-2a'};
notes = {'Book classes from legend colours (first-year scale); central Arctic classes are pseudo concentrations (multiyear ice, e = 0.92).', ...
         'Book classes from legend colours; summer ice tie point makes our concentrations higher than the book.'};
for h = 1:2
    s = R(h).st; SIC = SICh(:,:,h); cl = CLS(:,:,h);
    if h == 1, inlat = LATh{1} >= 50; else, inlat = LATh{2} <= -50; end
    [rr, qq] = find(inlat); r0 = min(rr); r1 = max(rr); c0 = min(qq); c1 = max(qq);
    sic = uint8(255*ones(n)); okS = ~isnan(SIC); sic(okS) = uint8(round(100*SIC(okS))); sic(landO(:,:,h)) = 254; sic(~inlat) = 255;
    bk = uint8(255*ones(n)); bk(cl == 2) = 0; bk(cl == 3) = 254; bkc = BCL(:,:,h); ib = ICEB(:,:,h); bk(ib) = uint8(LO(bkc(ib)));
    bk(~inlat | cl == 0) = 255;
    ag = uint8(R(h).st.agr);
    cr = @(a) a(r0:r1, c0:c1);
    enc = @(a) matlab.net.base64encode(reshape(cr(a)', 1, []));
    ct = cls_tab{h}; ctab = cell(1, nc + 1);
    for j = 1:nc + 1, ctab{j} = struct('lo', ct(j, 1), 'n', ct(j, 2), 'mean_ours', round(ct(j, 3), 2), 'std_ours', round(ct(j, 4), 2)); end
    stt = struct('extent_ours', rd(s.extent_ours), 'extent_book', rd(s.extent_book), 'area_ours', rd(s.area_ours), ...
        'area_book_classes', rd(s.area_book_classes), 'area_book_table', s.area_book_table, 'agree_pct', rd(s.agree_pct, 1), ...
        'n_common', s.n_common, 'both_ice', rd(s.both_ice), 'only_ours', rd(s.only_ours), 'only_book', rd(s.only_book), ...
        'both_water', rd(s.both_water), 'area_ours_all', rd(s.area_ours_all), 'extent_ours_all', rd(s.extent_ours_all), ...
        'mean_diff', rd(s.mean_diff, 1), 'tp_water', rd(s.tp_water, 1), 'tp_ice', rd(s.tp_ice, 1), 'class_table', {ctab});
    H = struct('proj', struct('Re', Re, 'dx', dx, 'L', L, 'n', n, 'hemi', hn(h)), ...
        'bbox', struct('r0', r0, 'r1', r1, 'c0', c0, 'c1', c1), 'sic', enc(sic), 'book', enc(bk), 'agree', enc(ag), ...
        'edge_ours', {R(h).edge_ours}, 'edge_book', {R(h).edge_book}, 'stats', stt, ...
        'src', struct('book', srcs{h}, 'note', notes{h}), 'classes', LO);
    Hs.(hn(h)) = H;
end
js = jsonencode(Hs);
fid = fopen(fullfile('output', 'globe', 'feb1973.js'), 'w'); fprintf(fid, 'ESMR_MONTH(%s);\n', js); fclose(fid);
d = dir(fullfile('output', 'globe', 'feb1973.js')); fprintf('saved output/globe/feb1973.js (%.2f MB)\n', d.bytes/1e6);
fprintf('saved output/C2_feb1973_maps.png, C2_conc_compare.png, C2_feb1973_books.csv\n');

%% helpers
function [r, q] = cellidx(h, lat, lon, Re, L, dx)
if h == 1, rad = 2*Re*tand((90 - lat)/2); r = floor((-rad.*cosd(lon) + L)/dx) + 1;
else,      rad = 2*Re*tand((90 + lat)/2); r = floor(( rad.*cosd(lon) + L)/dx) + 1; end
q = floor((rad.*sind(lon) + L)/dx) + 1;
end
function x = rd(x, k)
if nargin < 2, k = 3; end
x = round(x, k);
end
function s = bookname_(h)
b = {'SP-489', 'SP-459'}; s = b{h};
end
function pl = ll2uv_(ll, h, Re)
lat = ll(:,1); lon = ll(:,2);
if h == 1, rad = 2*Re*tand((90 - lat)/2); pl = [rad.*sind(lon), -rad.*cosd(lon)];
else,      rad = 2*Re*tand((90 + lat)/2); pl = [rad.*sind(lon),  rad.*cosd(lon)]; end
end
function lab = rgb2lab_(rgb)                                % sRGB 0..255 -> CIE Lab (D65)
c = rgb/255; lin = ((c + 0.055)/1.055).^2.4; lin(c <= 0.04045) = c(c <= 0.04045)/12.92;
XYZ = lin * [0.4124 0.2126 0.0193; 0.3576 0.7152 0.1192; 0.1805 0.0722 0.9505];
XYZ = XYZ ./ [0.95047 1 1.08883]; f = XYZ.^(1/3); sm = XYZ <= 0.008856; f(sm) = 7.787*XYZ(sm) + 16/116;
lab = [116*f(:,2) - 16, 500*(f(:,1) - f(:,2)), 200*(f(:,2) - f(:,3))];
end
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
function graticule_xy(ax, Re, h, lim)
gc = [0.75 0.75 0.73]; a = linspace(0, 360, 361);
if h == 1, las = 55:5:85; else, las = -55:-5:-80; end
for la = las
    if h == 1, r = 2*Re*tand((90 - la)/2); else, r = 2*Re*tand((90 + la)/2); end
    plot(ax, r*sind(a), r*cosd(a), '-', 'Color', gc, 'LineWidth', 0.5);
end
for lo = 0:45:315
    if h == 1, ux = lim*sind(lo); vy = -lim*cosd(lo); else, ux = lim*sind(lo); vy = lim*cosd(lo); end
    plot(ax, [0 ux], [0 vy], '-', 'Color', gc, 'LineWidth', 0.5);
    if mod(lo, 90) == 0
        s = {'0°', '90°E', '180°', '90°W'}; text(ax, 1.05*ux, 1.05*vy, s{lo/90 + 1}, 'HorizontalAlignment', 'center', 'FontSize', 8, 'Color', [0.32 0.32 0.31]);
    end
end
end
function out = edge_lines(mask, invalid, g, h, Re)
% ice edge as lat/lon polylines: contour 0.5 of the (smoothed) binary mask, invalid cells filled with their nearest valid
% value; vertices next to invalid cells (land, no data) dropped; pieces < 3 points dropped
m = double(mask & ~invalid); known = ~invalid; vals = m; vals(invalid) = NaN;
for it = 1:60
    nanm = isnan(vals); if ~any(nanm(:)), break; end
    num = conv2(double(~nanm) .* (~nanm .* vals + nanm * 0), ones(3), 'same'); cn = conv2(double(~nanm), ones(3), 'same');
    num(isnan(num)) = 0; fillv = num ./ max(cn, 1); upd = nanm & cn > 0; vals(upd) = round(fillv(upd) + 1e-9);
end
vals(isnan(vals)) = 0; k = [1 2 1]'*[1 2 1]/16; sm = conv2(vals, k, 'same');
C = contourc(g, g, sm, [0.5 0.5]); dil = conv2(double(invalid), ones(3), 'same') > 0;
out = {}; i = 1; n = numel(g); dx = g(2) - g(1);
while i < size(C, 2)
    np = C(2, i); xy = C(:, i + 1:i + np)'; i = i + np + 1;
    cr = round((xy(:,2) - g(1))/dx) + 1; cc = round((xy(:,1) - g(1))/dx) + 1;
    ok = cr >= 1 & cr <= n & cc >= 1 & cc <= n; bad = true(size(ok)); bad(ok) = dil(sub2ind([n n], cr(ok), cc(ok)));
    keep = ~bad; d = diff([0; keep; 0]); s0 = find(d == 1); e0 = find(d == -1) - 1;
    for j = 1:numel(s0)
        if e0(j) - s0(j) + 1 >= 3
            u = xy(s0(j):e0(j), 1); v = xy(s0(j):e0(j), 2); rr = hypot(u, v); co = 2*atand(rr/(2*Re));
            if h == 1, la = 90 - co; lo = atan2d(u, -v); else, la = -(90 - co); lo = atan2d(u, v); end
            out{end + 1} = round([la lo], 2); %#ok<AGROW>
        end
    end
end
end
function [A, t, rms] = fit_north(M)
% Affine georeference of the SP-489 map: image px = t + A*[tan(colat/2)sin(lon); -V/(2Re) = tan(colat/2)cos(lon)]
% points: darkest thin line near the predicted position on the parallels 50..85 N (every 5 deg) and on the 8 meridians (45 deg)
G = double(M(:,:,1))*0.299 + double(M(:,:,2))*0.587 + double(M(:,:,3))*0.114;
s = 2033; A = s/sqrt(2)*[1 1; -1 1]; t = [768; 787];        % start: pole, 50 N circle at the frame, 0 deg lower right
% (X,Y) = [tan sin; tan cos]; lon 0 -> Y = 1 -> image (+,+) lower right; lon 90 -> X = 1 -> upper right
tanc = @(lat) tand((90 - lat)/2);
for it = 1:12
    wd = max(26 - 2.5*it, 3.5); P = []; Q = [];   % wide start window: the scan is ~3.5 % stretched vertically
    for lat = 50:5:85
        for lon = 0:1.5:359
            X = tanc(lat)*sind(lon); Y = tanc(lat)*cosd(lon); p = t + A*[X; Y];
            d = A*[sind(lon); cosd(lon)]; d = d/norm(d);   % radial direction in the image (approx.)
            [ok, pm] = findline(G, p, d, wd);
            if ok, P(end+1, :) = [X Y]; Q(end+1, :) = pm'; end %#ok<AGROW>
        end
    end
    for lon = 0:45:315
        for lat = 52:1:84
            X = tanc(lat)*sind(lon); Y = tanc(lat)*cosd(lon); p = t + A*[X; Y];
            e = A*[cosd(lon); -sind(lon)]; e = e/norm(e);  % perpendicular to the meridian line
            [ok, pm] = findline(G, p, e, wd);
            if ok, P(end+1, :) = [X Y]; Q(end+1, :) = pm'; end %#ok<AGROW>
        end
    end
    % NOTE: parallel points move along d (radial), meridian points move along e (perpendicular); both sample points are
    % corrected only perpendicular to their own line, but we fit the point itself -> add the along-line freedom by using
    % the unknown position on the line: handled by fitting the signed distance below
    K = size(P, 1);
    % robust fit on residual along the search direction: use total least squares via point-to-line distance
    [A, t, res, nin] = refit(P, Q, A, t, wd); %#ok<ASGLU>
end
rms.px = res; rms.km = res/(norm(A(:, 2))/(2*6371)); rms.n = nin;
end
function [ok, pm] = findline(G, p, d, wd)
o = -wd:0.5:wd; xs = p(1) + o*d(1); ys = p(2) + o*d(2);
if any(xs < 3 | ys < 3 | xs > size(G, 2) - 2 | ys > size(G, 1) - 2), ok = false; pm = []; return; end
pr = interp2(G, xs, ys, 'linear'); [mn, im] = min(pr);
ends = [mean(pr(1:3)) mean(pr(end-2:end))];
ok = im > 3 && im < numel(o) - 2 && mn < min(ends) - 12;
pm = [xs(im); ys(im)];
end
function [A, t, rmsr, nin] = refit(P, Q, A, t, wd)
% iteratively reweighted: inliers = distance to predicted position < 0.6*wd + 1.5; fit affine on inliers
for k = 1:6
    pred = (t + A*P')'; r = hypot(Q(:,1) - pred(:,1), Q(:,2) - pred(:,2)); in = r < max(0.6*wd, 2.5);
    X = [ones(sum(in), 1) P(in, :)]; cx = X \ Q(in, 1); cy = X \ Q(in, 2);
    t = [cx(1); cy(1)]; A = [cx(2:3)'; cy(2:3)'];
end
pred = (t + A*P')'; r = hypot(Q(:,1) - pred(:,1), Q(:,2) - pred(:,2)); in = r < max(0.6*wd, 2.5);
rmsr = sqrt(mean(r(in).^2)); nin = sum(in);
end
