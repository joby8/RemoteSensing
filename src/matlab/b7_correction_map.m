% B7: Where is the RTM correction largest? (Tonboe, meeting 2026-11-17)
%  Per day: correct_day.m (A6b method, NIT = 2, tie-point masks from tp_masks.m) for all ocean pixels
%  with |lat| >= 50. Per pixel:
%     SIC_u = (TB - Tpw_u) / (Tpi_u - Tpw_u)                 uncorrected, daily uncorrected tie points
%     SIC_c = (TB + dTB - Tpw_c) / (Tpi_c - Tpw_c)          corrected, daily corrected tie points
%     dSIC  = SIC_c - SIC_u  [% SIC]
%     share of each input: d<X> / (Tpi_c - Tpw_c)  (V, W, Ts, Ti; L is not corrected)
%  Gridded on a 50 km polar grid (azimuthal equidistant around the pole), mean over 1-27 Feb 1973
%  (28 Feb has 1 orbit only). Every day has the same weight: per cell first the daily mean (and daily mean of
%  dSIC^2 for the std), then the mean over the days with data in the cell. Regional numbers likewise: mean per
%  day and group, then mean over the days. Land (ERA5 lsm > 0.5 in the swath files) drawn grey.
% Run from the project root:  matlab -batch "run('src/matlab/b7_correction_map.m')"
% Outputs: output/B7_correction_map.png, output/B7_regions.csv, output/B7_grid.mat
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile('src','matlab'));
files = dir(fullfile('ESMR_colocated_filtered','*.nc'));
fday  = string(regexp({files.name}, '1973m(\d{4})t', 'tokens', 'once'));
if ~exist('days','var') || isempty(days), days = unique(fday); days(days == "0228") = []; end

RES = 50; EXT = 4500;                                  % km; grid -EXT..EXT
edges = -EXT:RES:EXT; nb = numel(edges) - 1;
inp = {'V','W','Ts','Ti'};
fld = [{'n','nd','s1','s2','land','nl'}, strcat('d', inp)];
dfl = [{'n','s1','s2'}, strcat('d', inp)];           % per-day sums, normalised per day before adding to A
for h = 1:2, for f = fld, A(h).(f{1}) = zeros(nb); end, end %#ok<SAGROW>
% pixel table for the regional numbers (subsampled per day to keep memory small)
Pt = table();

for d = days(:)'
    fi = find(fday == d);
    fn = arrayfun(@(k) fullfile(files(k).folder, files(k).name), fi, 'UniformOutput', false);
    [O, TP] = correct_day(fn, 2);
    for h = 1:2, for f = dfl, Dg(h).(f{1}) = zeros(nb); end, end %#ok<SAGROW>
    for k = 1:numel(O)
        o = O(k);
        lsm = o.lsm;                                      % display only (land background)
        for h = 1:2
            hs = (o.lat > 0) == (h == 1); hn = 'NS'; tp = TP.(hn(h));
            % land field for the background (all pixels |lat| >= 50 of this hemisphere). Display only: the
            % background must cover land too, so this deliberately does NOT use o.valid (which removes land).
            ml = hs & abs(o.lat) >= 50;
            [ix, iy, ok] = cell_of(o.lat(ml), o.lon(ml), h, edges);
            l = lsm(ml) > 0.5;
            A(h).land = A(h).land + accumarray([iy(ok) ix(ok)], l(ok), [nb nb]);
            A(h).nl   = A(h).nl   + accumarray([iy(ok) ix(ok)], 1,     [nb nb]);
            % corrected pixels
            m = hs & ~isnan(o.dtb);
            if ~any(m(:)), continue, end
            tb = o.tb_f(m); den = tp.ice_c - tp.water_c;
            su = (tb - tp.water_u) / (tp.ice_u - tp.water_u);
            sc = (tb + o.dtb(m) - tp.water_c) / den;
            ds = 100 * (sc - su);
            [ix, iy, ok] = cell_of(o.lat(m), o.lon(m), h, edges);
            sub = [iy(ok) ix(ok)];
            Dg(h).n  = Dg(h).n  + accumarray(sub, 1, [nb nb]);
            Dg(h).s1 = Dg(h).s1 + accumarray(sub, ds(ok), [nb nb]);
            Dg(h).s2 = Dg(h).s2 + accumarray(sub, ds(ok).^2, [nb nb]);
            for v = inp
                p = 100 * o.(['d' v{1}])(m) / den;
                Dg(h).(['d' v{1}]) = Dg(h).(['d' v{1}]) + accumarray(sub, p(ok), [nb nb]);
            end
            % subsample for regional statistics
            r = find(ok); r = r(1:5:end);
            la = o.lat(m); lo = o.lon(m); c = o.c(m);
            pp = cellfun(@(v) 100*o.(['d' v])(m)/den, inp, 'UniformOutput', false);
            q = table(repmat(h, numel(r), 1), repmat(d, numel(r), 1), la(r), lo(r), c(r), ds(r), 100*su(r), 100*sc(r), ...
                pp{1}(r), pp{2}(r), pp{3}(r), pp{4}(r), ...
                'VariableNames', {'h','day','lat','lon','c','dsic','sic_u','sic_c','pV','pW','pTs','pTi'});
            Pt = [Pt; q]; %#ok<AGROW>
        end
    end
    for h = 1:2                                       % daily cell means -> A (each day weighted equally)
        hd = Dg(h).n > 0; A(h).n = A(h).n + Dg(h).n; A(h).nd = A(h).nd + hd;
        for f = dfl(2:end)
            x = zeros(nb); x(hd) = Dg(h).(f{1})(hd) ./ Dg(h).n(hd); A(h).(f{1}) = A(h).(f{1}) + x;
        end
    end
    fprintf('%s done (%d orbits)\n', d, numel(fi));
end
save(fullfile('output','B7_grid.mat'), 'A', 'edges', 'days', '-v7.3');

%% regional numbers
cls = strings(height(Pt), 1);
cls(Pt.c == 0) = "open water"; cls(Pt.c > 0 & Pt.c < 0.8) = "ice edge (0<c<0.8)"; cls(Pt.c >= 0.8) = "ice (c>=0.8)";
band = strings(height(Pt), 1);
al = abs(Pt.lat); band(al < 60) = "50-60"; band(al >= 60 & al < 70) = "60-70"; band(al >= 70) = ">=70";
reg = strings(height(Pt), 1); lo = mod(Pt.lon + 180, 360) - 180;
N = Pt.h == 1;
reg(N & lo >= -60 & lo < 60)  = "Atlantic sector (60W-60E)";
reg(N & (lo >= 120 | lo < -120)) = "Pacific sector (120E-120W)";
reg(N & reg == "") = "other (Siberia/Canada)";
reg(~N & lo >= -70 & lo < 20)  = "Weddell (70W-20E)";
reg(~N & lo >= 20 & lo < 160)  = "Indian / E Antarctic (20E-160E)";
reg(~N & (lo >= 160 | lo < -130)) = "Ross (160E-130W)";
reg(~N & lo >= -130 & lo < -70) = "Amundsen-Bellingshausen (130W-70W)";
hm = ["Arctic","Antarctic"]';
vn = {'sic_u','sic_c','dsic','abs_dsic','V','W','Ts','Ti'};
G = daymean(table(hm(Pt.h), Pt.day, reg, cls, band, Pt.sic_u, Pt.sic_c, Pt.dsic, abs(Pt.dsic), Pt.pV, Pt.pW, Pt.pTs, Pt.pTi, ...
    'VariableNames', [{'hemi','day','region','class','lat_band'}, vn]), {'hemi','region','class'}, vn);
G2 = daymean(table(hm(Pt.h), Pt.day, cls, band, Pt.sic_u, Pt.sic_c, Pt.dsic, abs(Pt.dsic), Pt.pV, Pt.pW, Pt.pTs, Pt.pTi, ...
    'VariableNames', [{'hemi','day','class','lat_band'}, vn]), {'hemi','class','lat_band'}, vn);
G.lat_band = repmat("all", height(G), 1); G2.region = repmat("all", height(G2), 1);
R = [G2(:, [1 end 2 3 4:end-1]); G(:, [1 2 3 end 4:end-1])];
R.Properties.VariableNames = regexprep(R.Properties.VariableNames, '^mean_', 'mean_');
for v = R.Properties.VariableNames, if isfloat(R.(v{1})), R.(v{1}) = round(R.(v{1}), 2); end, end
writetable(R, fullfile('output','B7_regions.csv'));
disp(R);

%% figure
fig = figure('Visible','off','Color','w','Position',[50 50 1600 1050]);
tl = tiledlayout(fig, 2, 3, 'TileSpacing','compact','Padding','compact');
cen = (edges(1:end-1) + edges(2:end)) / 2 / 1000;     % 1000 km
bwr = diverging(256);
catc = [0.12 0.47 0.71; 0.85 0.37 0.01; 0.46 0.44 0.70; 0.75 0.10 0.30];
names = ["Arctic","Antarctic"];
for h = 1:2
    n = A(h).n; nd = A(h).nd; mn = A(h).s1 ./ nd; sd = sqrt(max(A(h).s2 ./ nd - mn.^2, 0));   % day-weighted
    few = n < 20; mn(few) = NaN; sd(few) = NaN;
    P = cat3(A(h), inp) ./ nd;                           % mean share per input
    [~, dom] = max(abs(P), [], 3); dom = double(dom); dom(few) = NaN;
    land = A(h).land ./ A(h).nl > 0.5;
    panels = {mn, sd, dom};
    ttl = {'mean \DeltaSIC = corrected - uncorrected [% SIC]', 'std of \DeltaSIC over the month [% SIC]', ...
           'input with the largest mean share of the correction'};
    for p = 1:3
        ax = nexttile(tl); hold(ax, 'on');
        Z = panels{p};
        im = imagesc(ax, cen, cen, Z); set(im, 'AlphaData', ~isnan(Z));
        image(ax, cen, cen, repmat(0.62, [size(land) 3]), 'AlphaData', double(land));   % land grey
        set(ax, 'YDir', 'normal'); axis(ax, 'equal'); xlim(ax, [-4.5 4.5]); ylim(ax, [-4.5 4.5]);
        rings(ax);
        if p == 1, colormap(ax, bwr); clim(ax, [-8 8]); cb = colorbar(ax); cb.Label.String = '\DeltaSIC [%]';
        elseif p == 2, colormap(ax, parula(256)); clim(ax, [0 8]); cb = colorbar(ax); cb.Label.String = 'std [%]';
        else, colormap(ax, catc); clim(ax, [0.5 4.5]); cb = colorbar(ax, 'Ticks', 1:4, 'TickLabels', {'V','W','T_s','T_i'}); cb.Label.String = 'dominant input';
        end
        title(ax, sprintf('%s: %s', names(h), ttl{p}), 'FontWeight', 'normal', 'FontSize', 11);
        xlabel(ax, 'x [1000 km]'); ylabel(ax, 'y [1000 km]'); box(ax, 'on');
    end
end
title(tl, {'Where does the RTM correction change the SIC? 1-27 Feb 1973, A6b method (iteration 2), all ocean pixels |lat| \geq 50°', ...
    'polar grid 50 km, cells with < 20 pixels blank, land (ERA5) grey, circles every 10° latitude, 0° longitude at the bottom (Arctic) / top (Antarctic)'}, ...
    'FontSize', 12);
exportgraphics(fig, fullfile('output','B7_correction_map.png'), 'Resolution', 150);
fprintf('saved output/B7_correction_map.png, output/B7_regions.csv\n');

%% helpers
function G = daymean(T, grp, vn)
% mean per (group, day), then mean over the days: every day has the same weight. GroupCount = number of pixels.
G1 = groupsummary(T, [grp, {'day'}], 'mean', vn);
G1.Properties.VariableNames(end-numel(vn)+1:end) = vn;
G  = groupsummary(G1, grp, 'mean', vn);
Gc = groupsummary(T, grp);
G.GroupCount = Gc.GroupCount;
end

function [ix, iy, ok] = cell_of(lat, lon, h, edges)
% azimuthal equidistant around the pole; Arctic: 0 deg lon points down, Antarctic: 0 deg lon points up
rho = (90 - abs(lat)) * 111.2;
if h == 1, x = rho .* sind(lon); y = -rho .* cosd(lon);
else,      x = rho .* sind(lon); y =  rho .* cosd(lon); end
ix = discretize(x, edges); iy = discretize(y, edges);
ok = ~isnan(ix) & ~isnan(iy);
ix(~ok) = 1; iy(~ok) = 1;
end

function P = cat3(a, inp)
P = zeros([size(a.n) numel(inp)]);
for k = 1:numel(inp), P(:, :, k) = a.(['d' inp{k}]); end
end

function rings(ax)
t = linspace(0, 2*pi, 361);
for la = [50 60 70 80]
    r = (90 - la) * 0.1112;
    plot(ax, r*cos(t), r*sin(t), ':', 'Color', [0.4 0.4 0.4], 'LineWidth', 0.6);
end
end

function c = diverging(n)
% blue - white - red
x = linspace(-1, 1, n)';
c = zeros(n, 3);
neg = x < 0;
c(neg, :)  = [1 + x(neg)*0.85, 1 + x(neg)*0.6, ones(nnz(neg), 1)];
c(~neg, :) = [ones(nnz(~neg), 1), 1 - x(~neg)*0.75, 1 - x(~neg)*0.85];
c = min(max(c, 0), 1);
end
