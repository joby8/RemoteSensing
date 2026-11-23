% B8: per-pixel SIC uncertainty, Kolbe et al. (2024) Sect. 4.2, Eq. 17-19 (meeting 2026-11-20, points 5 and 6)
% 1. ALGORITHM uncertainty per swath pixel (Eq. 18; the paper computes it on swath data):
%      delta_alg = sqrt( ((1-c) * dTp_water)^2 + (c * dTp_ice)^2 ) / (Tp_ice - Tp_water)
%    dTp_water, dTp_ice = 1 std of the day's water / ice tie point (TB std over the cluster pixels).
%    Since SIC = (TB - Tp_water) / (Tp_ice - Tp_water), dTp / (Tp_ice - Tp_water) = std of the cluster SIC,
%    which correct_day.m already returns (TP.w_std_*, TP.i_std_*, in %). So per pixel:
%      delta_alg = sqrt( ((1-c) * w_std)^2 + (c * i_std)^2 )            [% SIC],  c = pixel SIC clipped to 0..1
%    Eq. 17 (extra term dTB = 3 K instrument noise) only in the pixel CSV, for reference (paper uses Eq. 18).
% 2. Daily RESAMPLING on the 30 km polar-stereographic grid of C2 / the globe's "Daily grid mean"
%    (c2_feb1973_books.m: sphere Re = 6371 km, L = 4800 km, 320 x 320 cells): per day and cell the mean of all
%    corrected pixels of all orbits. Cell SIC = mean of the unclipped pixel SIC (as C2 / globe), then clipped to
%    0..1; cell delta_alg = mean of the pixel delta_alg.
% 3. RESAMPLING uncertainty on the daily grid: max(c) - min(c) in the 3 x 3 window around the cell (cells
%    without data, e.g. land, are left out of the window; centre cell must have data).
% 4. TOTAL (Eq. 19): delta_total = sqrt(delta_alg^2 + delta_res^2), per cell and day.
% Monthly map = mean of the daily cell values (every day the same weight), cells with data on < 3 days blank.
% uncorrected: c, tie points and std from the uncorrected TB (w_std_u, i_std_u);
% corrected:   c, tie points and std from the corrected TB, last iteration (w_std_c, i_std_c).
% Deviations from the paper: daily tie points (paper: 2-weekly); our own 30 km grid (bin mean, no interpolation).
% Same pixels and method as B7: correct_day.m (A6b, NIT = 2), all corrected pixels |lat| >= 50, 1-27 Feb 1973.
% Run from the project root:  matlab -batch "run('src/matlab/b8_uncertainty.m')"
% Outputs: output/B8_uncertainty_map.png, output/B8_uncertainty_pixels.csv (Eq. 17/18 per pixel class and day),
%          output/B8_uncertainty_cells.csv (alg / res / total per grid-cell class and day),
%          output/B8_uncertainty_mean.csv (mean over the days, cells), output/B8_grid.mat
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile('src','matlab'));
files = dir(fullfile('ESMR_colocated_filtered','*.nc'));
fday  = string(regexp({files.name}, '1973m(\d{4})t', 'tokens', 'once'));
if ~exist('days','var') || isempty(days), days = unique(fday); days(days == "0228") = []; end

Re = 6371; dx = 30; L = 4800; g = (-L + dx/2):dx:(L - dx/2); n = numel(g);   % grid of C2 (row 1 = bottom)
vu = {'sic_u','sic_c','alg_u','alg_c','res_u','res_c','tot_u','tot_c'};
for h = 1:2, for f = [vu, {'nd','np','nl'}], A(h).(f{1}) = zeros(n); end, end %#ok<SAGROW>
pcl = ["open water (c<0.15)", "ice edge (0.15<=c<0.8)", "ice (c>=0.8)", "all"];
RP = table(); RC = table();
dTB = 3;                                              % K, instrument noise (Eq. 17 only)
hn = 'NS';
for d = days(:)'
    fi = find(fday == d);
    fn = arrayfun(@(k) fullfile(files(k).folder, files(k).name), fi, 'UniformOutput', false);
    [O, TP] = correct_day(fn, 2);
    for h = 1:2
        tp = TP.(hn(h));
        G = struct('n', zeros(n), 'su', zeros(n), 'sc', zeros(n), 'au', zeros(n), 'ac', zeros(n), 'nl', zeros(n));
        P = [];
        for k = 1:numel(O)
            o = O(k);
            if h == 1, hm = o.lat > 45; else, hm = o.lat < -45; end
            ml = hm & isnan(o.sst);                   % ERA5 land (display only)
            [r, q, ok] = cellidx(h, o.lat(ml), o.lon(ml), Re, L, dx, n);
            G.nl = G.nl + accumarray([r(ok) q(ok)], 1, [n n]);
            m = hm & ~isnan(o.dtb);
            if ~any(m(:)), continue, end
            tb = o.tb_f(m);
            su = (tb - tp.water_u) / (tp.ice_u - tp.water_u);
            sc = (tb + o.dtb(m) - tp.water_c) / (tp.ice_c - tp.water_c);
            cu = min(max(su, 0), 1); cc = min(max(sc, 0), 1);
            au = sqrt(((1 - cu) * tp.w_std_u).^2 + (cu * tp.i_std_u).^2);        % Eq. 18, % SIC
            ac = sqrt(((1 - cc) * tp.w_std_c).^2 + (cc * tp.i_std_c).^2);
            ku = 100 * dTB / (tp.ice_u - tp.water_u); kc = 100 * dTB / (tp.ice_c - tp.water_c);
            P = [P; cc, au, ac, sqrt(au.^2 + ku^2), sqrt(ac.^2 + kc^2)]; %#ok<AGROW>
            [r, q, ok] = cellidx(h, o.lat(m), o.lon(m), Re, L, dx, n); sub = [r(ok) q(ok)];
            G.n  = G.n  + accumarray(sub, 1, [n n]);
            G.su = G.su + accumarray(sub, 100 * su(ok), [n n]);
            G.sc = G.sc + accumarray(sub, 100 * sc(ok), [n n]);
            G.au = G.au + accumarray(sub, au(ok), [n n]);
            G.ac = G.ac + accumarray(sub, ac(ok), [n n]);
        end
        % pixel statistics (algorithm uncertainty only, Eq. 17 / 18)
        sel = {P(:,1) < 0.15, P(:,1) >= 0.15 & P(:,1) < 0.8, P(:,1) >= 0.8, true(size(P,1), 1)};
        for q = 1:4
            s = sel{q};
            RP = [RP; table(d, string(hn(h)), pcl(q), nnz(s), mean(P(s,2)), mean(P(s,3)), mean(P(s,4)), mean(P(s,5)), ...
                tp.w_std_u, tp.w_std_c, tp.i_std_u, tp.i_std_c, ...
                'VariableNames', {'day','hemi','class','n','alg_u','alg_c','eq17_u','eq17_c', ...
                'w_std_u','w_std_c','i_std_u','i_std_c'})]; %#ok<AGROW>
        end
        % daily grid: cell means, resampling and total uncertainty
        hd = G.n > 0; nan0 = nan(n);
        cu = nan0; cu(hd) = min(max(G.su(hd) ./ G.n(hd), 0), 100);       % clipped cell SIC [%]
        cc = nan0; cc(hd) = min(max(G.sc(hd) ./ G.n(hd), 0), 100);
        au = nan0; au(hd) = G.au(hd) ./ G.n(hd);
        ac = nan0; ac(hd) = G.ac(hd) ./ G.n(hd);
        ru = range3(cu); rc = range3(cc);
        D = struct('sic_u', cu, 'sic_c', cc, 'alg_u', au, 'alg_c', ac, 'res_u', ru, 'res_c', rc, ...
                   'tot_u', sqrt(au.^2 + ru.^2), 'tot_c', sqrt(ac.^2 + rc.^2));
        for f = vu, x = D.(f{1}); x(~hd) = 0; A(h).(f{1}) = A(h).(f{1}) + x; end
        A(h).nd = A(h).nd + hd; A(h).np = A(h).np + G.n; A(h).nl = A(h).nl + G.nl;
        sel = {hd & cc < 15, hd & cc >= 15 & cc < 80, hd & cc >= 80, hd};
        for q = 1:4
            s = sel{q};
            RC = [RC; table(d, string(hn(h)), pcl(q), nnz(s), mean(au(s)), mean(ac(s)), mean(ru(s)), mean(rc(s)), ...
                mean(D.tot_u(s)), mean(D.tot_c(s)), ...
                'VariableNames', {'day','hemi','class','n_cells','alg_u','alg_c','res_u','res_c','tot_u','tot_c'})]; %#ok<AGROW>
        end
    end
    fprintf('%s done (%d orbits)\n', d, numel(fi));
end
writetable(RP, fullfile('output','B8_uncertainty_pixels.csv'));
writetable(RC, fullfile('output','B8_uncertainty_cells.csv'));
save(fullfile('output','B8_grid.mat'), 'A', 'g', 'days', '-v7.3');
MP = groupsummary(RP, {'hemi','class'}, 'mean', {'alg_u','alg_c','eq17_u','eq17_c'});
MC = groupsummary(RC, {'hemi','class'}, 'mean', {'n_cells','alg_u','alg_c','res_u','res_c','tot_u','tot_c'});
MC.pix_alg_u = MP.mean_alg_u; MC.pix_alg_c = MP.mean_alg_c; MC.pix_eq17_c = MP.mean_eq17_c; MC.GroupCount = [];
MC.Properties.VariableNames = regexprep(MC.Properties.VariableNames, '^mean_', '');
for v = MC.Properties.VariableNames, if isfloat(MC.(v{1})), MC.(v{1}) = round(MC.(v{1}), 2); end, end
writetable(MC, fullfile('output','B8_uncertainty_mean.csv'));
disp(MC);

%% figure: Arctic top, Antarctic bottom
fig = figure('Visible','off','Color','w','Position',[50 50 2300 1000]);
tl = tiledlayout(fig, 2, 5, 'TileSpacing','compact','Padding','compact');
gk = g / 1000; names = ["Arctic","Antarctic"];
ttl = {'mean SIC, corrected', 'algorithm uncertainty (Eq. 18)', 'resampling uncertainty (3x3 max-min)', ...
       'total uncertainty (Eq. 19)', 'total: corrected - uncorrected'};
fl = {'sic_c','alg_c','res_c','tot_c'};
for h = 1:2
    few = A(h).nd < 3; land = A(h).nl > A(h).np & few;
    for p = 1:5
        ax = nexttile(tl); hold(ax, 'on');
        if p < 5, z = A(h).(fl{p}) ./ A(h).nd; else, z = (A(h).tot_c - A(h).tot_u) ./ A(h).nd; end
        z(few) = NaN;
        im = imagesc(ax, gk, gk, z); set(im, 'AlphaData', ~isnan(z));
        image(ax, gk, gk, repmat(0.62, [n n 3]), 'AlphaData', double(land));
        set(ax, 'YDir', 'normal'); axis(ax, 'equal'); xlim(ax, [-4.7 4.7]); ylim(ax, [-4.7 4.7]);
        rings(ax, Re);
        if p == 5, colormap(ax, diverging(256)); clim(ax, [-5 5]);
        elseif p == 1, colormap(ax, parula(256)); clim(ax, [0 100]);
        else, colormap(ax, parula(256)); clim(ax, [0 30]); end
        cb = colorbar(ax); cb.Label.String = '% SIC';
        title(ax, sprintf('%s: %s', names(h), ttl{p}), 'FontWeight', 'normal', 'FontSize', 11);
        xlabel(ax, 'x [1000 km]'); ylabel(ax, 'y [1000 km]'); box(ax, 'on');
    end
end
title(tl, {'SIC uncertainty as in Kolbe et al. (2024) Sect. 4.2, corrected data (A6b, iteration 2), monthly mean of the daily values 1-27 Feb 1973', ...
    'daily 30 km polar-stereographic grid (as C2 / globe daily grid mean), daily tie-point std; cells with data on < 3 days blank, land (ERA5) grey, circles every 10° latitude'}, ...
    'FontSize', 12);
exportgraphics(fig, fullfile('output','B8_uncertainty_map.png'), 'Resolution', 150);
fprintf('saved output/B8_uncertainty_map.png and CSVs\n');

%% helpers
function [r, q, ok] = cellidx(h, lat, lon, Re, L, dx, n)
% grid cell of c2_feb1973_books.m (row 1 = bottom; North 0 deg lon down, South 0 deg lon up)
if h == 1, rad = 2*Re*tand((90 - lat)/2); r = floor((-rad.*cosd(lon) + L)/dx) + 1;
else,      rad = 2*Re*tand((90 + lat)/2); r = floor(( rad.*cosd(lon) + L)/dx) + 1; end
q = floor((rad.*sind(lon) + L)/dx) + 1;
ok = r >= 1 & r <= n & q >= 1 & q <= n;
end

function R = range3(Z)
% max - min in the 3 x 3 window (NaN cells left out); NaN where the centre cell is NaN
mx = movmax(movmax(Z, 3, 1, 'omitnan'), 3, 2, 'omitnan');
mn = movmin(movmin(Z, 3, 1, 'omitnan'), 3, 2, 'omitnan');
R = mx - mn; R(isnan(Z)) = NaN;
end

function rings(ax, Re)
t = linspace(0, 2*pi, 361);
for la = [50 60 70 80]
    r = 2*Re*tand((90 - la)/2) / 1000;
    plot(ax, r*cos(t), r*sin(t), ':', 'Color', [0.4 0.4 0.4], 'LineWidth', 0.6);
end
end

function c = diverging(n)
x = linspace(-1, 1, n)';
c = zeros(n, 3);
neg = x < 0;
c(neg, :)  = [1 + x(neg)*0.85, 1 + x(neg)*0.6, ones(nnz(neg), 1)];
c(~neg, :) = [ones(nnz(~neg), 1), 1 - x(~neg)*0.75, 1 - x(~neg)*0.85];
c = min(max(c, 0), 1);
end
