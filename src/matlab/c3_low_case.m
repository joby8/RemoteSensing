% C3: one low-pressure system as an example (Tonboe, meeting 2026-11-20, point 8)
%  Case: 12 Feb 1973, deepest low over open water in Feb 1973 in the Arctic (ERA5 msl about 941 hPa,
%  Norwegian Sea / Greenland Sea, close to the ice edge). Found with a search of the daily msl minimum over
%  open water (siconc <= 0.01, |lat| >= 55) in all swath files.
%  One orbit only (the one whose corrected pixels contain the lowest msl), so all fields are at the same time.
%  Correction: correct_day.m (A6b method, NIT = 2, tie points of the whole day, masks tp_opt.m), as B7:
%     SIC_u = (TB - Tpw_u) / (Tpi_u - Tpw_u)           uncorrected, daily uncorrected tie points
%     SIC_c = (TB + dTB - Tpw_c) / (Tpi_c - Tpw_c)    corrected, daily corrected tie points
%  SIC is shown raw (not clipped), so the noise over open water stays visible.
% Run from the project root:  matlab -batch "run('src/matlab/c3_low_case.m')"
% Outputs: output/C3_low_map.png (map), output/C3_low_transect.png (cut through the core + statistics),
%          output/C3_low_numbers.csv
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile('src','matlab'));
if ~exist('day','var') || isempty(day), day = "0212"; end
R_CORE = 600;                                   % km, "inside the low"
files = dir(fullfile('ESMR_colocated_filtered', ['*1973m' char(day) 't*.nc']));
fn = arrayfun(@(f) fullfile(f.folder, f.name), files, 'UniformOutput', false);
[O, TP] = correct_day(fn, 2);
tp = TP.N;

%% orbit and core: lowest msl over corrected open-water pixels in the Arctic, per orbit.
%  Several orbits see the core; take the one (core within 2 hPa of the day's minimum) that has the core
%  closest to nadir, so the whole low lies inside the swath (12 Feb: 08:19 UTC, scan position 34).
Q = nan(numel(O), 3);                            % [min msl, linear index, scan position]
for k = 1:numel(O)
    msl = double(ncread(fn{k}, 'msl'))' / 100;
    m = O(k).lat >= 55 & ~isnan(O(k).dtb) & O(k).siconc <= 0.01;
    if ~any(m(:)), continue, end
    mm = msl; mm(~m) = inf; [v, i] = min(mm(:)); [~, c] = ind2sub(size(mm), i);
    Q(k, :) = [v i c];
end
cand = find(Q(:, 1) <= min(Q(:, 1)) + 2);
[~, b] = min(abs(Q(cand, 3) - 39.5)); kb = cand(b); best = Q(kb, 1); ic = Q(kb, 2);
o = O(kb); o.msl = double(ncread(fn{kb}, 'msl'))' / 100;
lat0 = o.lat(ic); lon0 = o.lon(ic); [r0, c0] = ind2sub(size(o.lat), ic);
[~, nm] = fileparts(fn{kb});
fprintf('orbit %s, core %.1f hPa at %.1f N %.1f E (line %d, scan position %d)\n', nm, best, lat0, lon0, r0, c0);

%% per-pixel fields
corr = ~isnan(o.dtb) & o.lat > 0;
su = 100 * (o.tb_f - tp.water_u) / (tp.ice_u - tp.water_u);
sc = 100 * (o.tb_f + o.dtb - tp.water_c) / (tp.ice_c - tp.water_c);
su(~corr) = NaN; sc(~corr) = NaN; ds = sc - su;
% map only: SIC smoothed over 3 x 3 pixels (about 75 km), so the pixel noise (std about 6 %) does not hide the
% weather pattern (the correction is only +-2-5 %). Only pixels of the water tie-point mask (tp_masks.m) enter the mean (siconc <= 0.01 alone still kept a red band next to ice and coasts = spill-over).
owm = corr & o.mw;                               % water tie-point mask: 5x5 box keeps ice and land 2 pixels away
su_s = smooth3x3(su, owm); sc_s = smooth3x3(sc, owm);
den = tp.ice_c - tp.water_c;
dist = gcdist(o.lat, o.lon, lat0, lon0);        % km from the core
ow = o.mw & o.lat > 0;                          % open water = water tie-point mask of Task 1 (tp_masks.m: siconc <= 0.01, sst > 273, |lat| > 55, no land in the 5x5 box)

%% figure 1: map
[x, y] = proj(o.lat, o.lon); [x0, y0] = proj(lat0, lon0);
box_km = 1500;
win = abs(x - x0) < box_km + 300 & abs(y - y0) < box_km + 300;   % pixels near the window (speed)
rows = any(win, 2); X = x(rows, :); Y = y(rows, :);
sel = @(F) F(rows, :);
land = sel(o.lsm) > 0.5;
fig = figure('Visible','off','Color','w','Position',[50 50 1700 900]);
tl = tiledlayout(fig, 2, 4, 'TileSpacing','compact','Padding','compact');
P = {sel(o.msl), 'mean sea-level pressure [hPa]', parula(256), [940 1010];
     sel(o.W),   'wind speed W [m/s]',             parula(256), [0 25];
     sel(o.V),   'water vapour V [kg/m^2]',        parula(256), [0 15];
     sel(o.L),   'cloud liquid L = tcw - tcwv [kg/m^2] (not corrected)', parula(256), [0 0.6];
     sel(su_s),  'SIC uncorrected [%], open water, 75 km mean', diverging(256), [-8 8];
     sel(sc_s),  'SIC corrected [%], open water, 75 km mean',   diverging(256), [-8 8];
     sel(ds),    '\DeltaSIC = corrected - uncorrected [%]', diverging(256), [-20 20];
     sel(100 * o.dW ./ den), 'wind part of \DeltaSIC [%]', diverging(256), [-20 20]};
for p = 1:size(P, 1)
    ax = nexttile(tl); hold(ax, 'on');
    Z = P{p, 1}; if p >= 5, Z(~sel(corr)) = NaN; end
    surface(ax, X, Y, zeros(size(X)), Z, 'EdgeColor', 'none', 'FaceColor', 'flat');
    G = double(land); G(~land) = NaN;
    surface(ax, X, Y, 0.1 + zeros(size(X)), repmat(0.62, [size(G) 3]), 'EdgeColor', 'none', ...
        'FaceColor', 'flat', 'FaceAlpha', 'flat', 'AlphaData', double(land), 'AlphaDataMapping', 'none');
    contour(ax, X, Y, sel(o.msl), 900:8:1040, 'k', 'LineWidth', 0.7, 'ShowText', p == 1, 'LabelSpacing', 400);
    ice = sel(o.siconc); ice(isnan(ice)) = 0;
    contour(ax, X, Y, ice, [0.15 0.15], 'Color', [0.85 0.1 0.1], 'LineWidth', 1.3);
    plot(ax, x0, y0, 'kx', 'MarkerSize', 12, 'LineWidth', 2);
    t = linspace(0, 2*pi, 181); plot(ax, x0 + R_CORE*cos(t), y0 + R_CORE*sin(t), 'k--', 'LineWidth', 0.8);
    plot(ax, x(:, c0), y(:, c0), 'm-', 'LineWidth', 1);                 % transect of figure 2
    colormap(ax, P{p, 3}); clim(ax, P{p, 4}); colorbar(ax);
    axis(ax, 'equal'); xlim(ax, x0 + [-1 1]*box_km); ylim(ax, y0 + [-1 1]*box_km);
    set(ax, 'XTick', [], 'YTick', []); box(ax, 'on');
    title(ax, P{p, 2}, 'FontWeight', 'normal', 'FontSize', 11);
end
title(tl, {sprintf('Low-pressure system over open water, %s (orbit %s UTC): core %.0f hPa at %.1f°N %.1f°%s', ...
    datestr(datenum(1973, 2, str2double(extractAfter(day, 2))), 'dd mmm yyyy'), nm(24:27), best, lat0, abs(wrap(lon0)), ew(lon0)), ...
    sprintf(['black: isobars every 8 hPa (ERA5 msl), red: ERA5 ice edge (siconc = 0.15), x: core, dashed: %d km around the core, ' ...
    'magenta: cut of the transect figure; grey: land; window 3000 km, polar projection'], R_CORE)}, 'FontSize', 12);
exportgraphics(fig, fullfile('output','C3_low_map.png'), 'Resolution', 150);

%% figure 2: transect through the core (along track, scan position of the core) + statistics
j = c0; dd = gcdist(o.lat(:, j), o.lon(:, j), lat0, lon0);
sg = sign((1:size(o.lat, 1))' - r0); s = sg .* dd;                    % signed distance along track
k2 = abs(s) < 1500 & o.lat(:, j) > 0;
fig2 = figure('Visible','off','Color','w','Position',[50 50 1500 900]);
t2 = tiledlayout(fig2, 2, 2, 'TileSpacing','compact','Padding','compact');
% (a) atmosphere
ax = nexttile(t2); hold(ax, 'on');
yyaxis(ax, 'left'); plot(ax, s(k2), o.msl(k2, j), 'k-', 'LineWidth', 1.5); ylabel(ax, 'msl [hPa]');
yyaxis(ax, 'right');
plot(ax, s(k2), o.W(k2, j), '-', 'LineWidth', 1.2, 'Color', [0.85 0.37 0.01]);
plot(ax, s(k2), o.V(k2, j), '-', 'LineWidth', 1.2, 'Color', [0.12 0.47 0.71]);
plot(ax, s(k2), 20 * o.L(k2, j), '-', 'LineWidth', 1.2, 'Color', [0.46 0.44 0.70]);
ylabel(ax, 'W [m/s], V [kg/m^2], 20·L [kg/m^2]'); ax.YAxis(1).Color = 'k'; ax.YAxis(2).Color = 'k';
xline(ax, 0, ':', 'HandleVisibility', 'off'); legend(ax, {'msl', 'W', 'V', '20·L'}, 'Location', 'best');
xlabel(ax, 'distance from the core along track [km]'); xlim(ax, [-1500 1500]); grid(ax, 'on');
title(ax, '(a) atmosphere along the cut (ERA5)', 'FontWeight', 'normal');
% (b) SIC
ax = nexttile(t2); hold(ax, 'on');
plot(ax, s(k2), su(k2, j), '-', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.2);
plot(ax, s(k2), sc(k2, j), 'k-', 'LineWidth', 1.5);
plot(ax, s(k2), 100 * o.siconc(k2, j), 'r--', 'LineWidth', 1);
yline(ax, 0, ':'); xline(ax, 0, ':'); ylim(ax, [-30 100]);
legend(ax, {'no RTM correction', 'with RTM correction', 'ERA5 siconc'}, 'Location', 'best');
xlabel(ax, 'distance from the core along track [km]'); xlim(ax, [-1500 1500]); ylabel(ax, 'SIC [%]'); grid(ax, 'on');
title(ax, '(b) SIC along the cut', 'FontWeight', 'normal');
% (c) parts of the correction
ax = nexttile(t2); hold(ax, 'on');
cl = [0.12 0.47 0.71; 0.85 0.37 0.01; 0.46 0.44 0.70; 0.75 0.10 0.30];
vv = {'dV','dW','dTs','dTi'}; lb = {'V','W','T_s','T_i'};
for q = 1:4, plot(ax, s(k2), 100 * o.(vv{q})(k2, j) / den, '-', 'Color', cl(q, :), 'LineWidth', 1.2); end
plot(ax, s(k2), ds(k2, j), 'k-', 'LineWidth', 1.5);
yline(ax, 0, ':'); xline(ax, 0, ':');
legend(ax, [lb, {'total'}], 'Location', 'best');
xlabel(ax, 'distance from the core along track [km]'); xlim(ax, [-1500 1500]); ylabel(ax, 'part of \DeltaSIC [% SIC]'); grid(ax, 'on');
title(ax, '(c) what the correction does: part of each input', 'FontWeight', 'normal');
% (d) open water: SIC vs distance from the core (whole orbit, Arctic)
ax = nexttile(t2); hold(ax, 'on');
be = 0:200:2400; bc = (be(1:end-1) + be(2:end)) / 2;
[mu, sdu, mc, sdc, nb] = deal(nan(size(bc)));
for b = 1:numel(bc)
    m = ow & dist >= be(b) & dist < be(b+1);
    nb(b) = nnz(m); if nb(b) < 30, continue, end
    mu(b) = mean(su(m)); sdu(b) = std(su(m)); mc(b) = mean(sc(m)); sdc(b) = std(sc(m));
end
errorbar(ax, bc - 15, mu, sdu, 'o-', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.2, 'MarkerFaceColor', [0.5 0.5 0.5]);
errorbar(ax, bc + 15, mc, sdc, 'o-', 'Color', 'k', 'LineWidth', 1.5, 'MarkerFaceColor', 'k');
yline(ax, 0, ':'); xline(ax, R_CORE, '--');
legend(ax, {'no RTM correction', 'with RTM correction'}, 'Location', 'best');
xlabel(ax, 'distance from the core [km] (200 km bins)'); ylabel(ax, 'open-water SIC: mean ± std [%]'); grid(ax, 'on');
title(ax, '(d) open water (water tie-point mask of Task 1) of this orbit vs distance from the core', 'FontWeight', 'normal');
title(t2, sprintf('Cut through the low (scan position %d, along track), %s orbit %s UTC; core %.0f hPa', ...
    j, char(day), nm(24:27), best), 'FontSize', 12);
exportgraphics(fig2, fullfile('output','C3_low_transect.png'), 'Resolution', 150);

%% numbers: open water inside / outside the low
grp = {ow & dist < R_CORE, ow & dist >= R_CORE, ow & o.L > 0.3, ow & o.L < 0.1};
names = ["inside " + R_CORE + " km"; "rest of the orbit (Arctic)"; "cloud band L > 0.3"; "clear L < 0.1"];
T = table(names, cellfun(@nnz, grp)', 'VariableNames', {'open_water', 'n'});
f2 = @(F) cellfun(@(g) mean(F(g)), grp)';
T.msl = f2(o.msl); T.W = f2(o.W); T.V = f2(o.V); T.L = f2(o.L);
T.sic_u_mean = f2(su); T.sic_u_std = cellfun(@(g) std(su(g)), grp)';
T.sic_c_mean = f2(sc); T.sic_c_std = cellfun(@(g) std(sc(g)), grp)';
T.dsic_V = f2(100*o.dV/den); T.dsic_W = f2(100*o.dW/den); T.dsic_Ts = f2(100*o.dTs/den);
for v = T.Properties.VariableNames(3:end), T.(v{1}) = round(T.(v{1}), 2); end
disp(T); writetable(T, fullfile('output','C3_low_numbers.csv'));
fprintf('tie points N (%s): water %.1f -> %.1f K, ice %.1f -> %.1f K\n', day, tp.water_u, tp.water_c, tp.ice_u, tp.ice_c);
fprintf('saved output/C3_low_map.png, output/C3_low_transect.png, output/C3_low_numbers.csv\n');

%% helpers
function [x, y] = proj(lat, lon)
% azimuthal equidistant around the North Pole, 0 deg lon points down (as B7), km
rho = (90 - lat) * 111.2; x = rho .* sind(lon); y = -rho .* cosd(lon);
end

function d = gcdist(la, lo, la0, lo0)
d = 6371 * acos(min(1, sind(la).*sind(la0) + cosd(la).*cosd(la0).*cosd(lo - lo0)));
end

function l = wrap(l), l = mod(l + 180, 360) - 180; end
function s = ew(l), if wrap(l) < 0, s = 'W'; else, s = 'E'; end, end

function S = smooth3x3(F, m)
% NaN-aware 3 x 3 mean over the pixels in mask m (scan lines x scan positions); NaN outside m
F(~m) = 0; k = ones(3);
S = conv2(F, k, 'same') ./ conv2(double(m), k, 'same'); S(~m) = NaN;
end

function c = sicmap()
% blue below 0 (impossible values), grey-white over 0..15, then towards dark blue/ice white
c = [interp1([0 1], [0.10 0.25 0.60; 0.75 0.85 0.95], linspace(0, 1, 64)');      % -20..0
     interp1([0 1], [0.95 0.95 0.95; 0.95 0.80 0.40], linspace(0, 1, 48)');      % 0..15
     interp1([0 0.5 1], [0.95 0.65 0.25; 0.80 0.20 0.20; 0.40 0.05 0.20], linspace(0, 1, 144)')];  % 15..60
end

function c = diverging(n)
x = linspace(-1, 1, n)'; c = zeros(n, 3); neg = x < 0;
c(neg, :)  = [1 + x(neg)*0.85, 1 + x(neg)*0.6, ones(nnz(neg), 1)];
c(~neg, :) = [ones(nnz(~neg), 1), 1 - x(~neg)*0.75, 1 - x(~neg)*0.85];
c = min(max(c, 0), 1);
end
