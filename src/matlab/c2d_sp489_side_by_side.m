% C2d - Arctic side by side, as C1 for the Antarctic: SP-489 Fig. 4-19a (scan) next to our mean SIC February 1973,
%       painted in the SP-489 legend colours (first-year column, F_MY = 0) in the same projection and frame as the scan.
%       Reads output/C2_results.mat (c2_feb1973_books.m: SIC, land mask, georeference) and the scan + legend.
%   Every scan pixel -> grid cell by the inverse affine georeference -> our SIC -> SP-489 class (lower bounds 14, 18, ..., 98 %)
%   -> legend colour. SIC < 14 %: open-water colour of the map; land (ERA5): land colour of the map; no data / |lat| < 50: white.
% OUTPUT: output/C2_sp489_side_by_side.png
% Run from the project root:  matlab -batch "run('src/matlab/c2d_sp489_side_by_side.m')"
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));
D = load(fullfile('output', 'C2_results.mat'));
img = imread(fullfile('docs', 'sp489', 'fig_feb1973.jpg')); [H, W, ~] = size(img);
A = D.A{1}; t = D.t{1}; Re = D.Re; L = D.L; dx = D.dx; n = D.n; nc = D.nc; LO = D.LO;

%% legend colours (as in c2_feb1973_books.m: legend first-year column, median of a 13 x 53 px patch per class)
leg = imread(fullfile('docs', 'sp489', 'legend.jpg')); y14 = 1370; ppp = (1370 - 85)/86;
sw = zeros(nc, 3);
for k = 1:nc
    if k == nc, lo = 98; hi = 100; else, lo = 10 + 4*k; hi = lo + 4; end
    yc = round(y14 - ((lo + hi)/2 - 14)*ppp);
    sw(k, :) = squeeze(median(median(leg(yc-6:yc+6, 233:285, :), 1), 2))';
end
ptc = @(x, y) squeeze(median(median(double(img(y-3:y+3, x-3:x+3, :)), 1), 2))';
waterC = ptc(900, 1400); landC = ptc(1100, 350);          % open water and land as printed in the map

%% our SIC in the scan geometry
[qx, qy] = meshgrid(1:W, 1:H); XY = A \ [qx(:)' - t(1); qy(:)' - t(2)];
U = 2*Re*XY(1, :)'; V = -2*Re*XY(2, :)';
cc = floor((U + L)/dx) + 1; rr = floor((V + L)/dx) + 1; ok = cc >= 1 & cc <= n & rr >= 1 & rr <= n;
idx = zeros(H*W, 1); idx(ok) = sub2ind([n n], rr(ok), cc(ok));
SIC = D.SICh(:,:,1); land = D.landO(:,:,1); LAT = D.LATh{1};
v = nan(H*W, 1); v(ok) = SIC(idx(ok)); lo_ = false(H*W, 1); lo_(ok) = land(idx(ok));
inR = false(H*W, 1); inR(ok) = LAT(idx(ok)) >= 50;
out = 255*ones(H*W, 3);
m = inR & v < 0.14; out(m, :) = repmat(waterC, sum(m), 1);
m = inR & v >= 0.14; j = sum(100*v(m) >= LO, 2); out(m, :) = sw(j, :);
m = inR & lo_; out(m, :) = repmat(landC, sum(m), 1);
out = uint8(reshape(out, H, W, 3));

%% figure
f = figure('Visible', 'off', 'Position', [0 0 1500 790], 'Color', 'w');
tiledlayout(f, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile; image(img); axis image off; title('NASA SP-489, Fig. 4-19a: February 1973 (Parkinson et al. 1987)', 'FontWeight', 'normal');
nexttile; image(out); axis image off; hold on; grat(A, t, [0.15 0.15 0.15]); xlim([0.5 W + 0.5]); ylim([0.5 H + 0.5]);
title('This work: mean SIC February 1973 (A6b, ERA5-corrected), same colour classes', 'FontWeight', 'normal');
text(W - 20, 60, {'white = no data', 'dark grey = land (ERA5)'}, 'HorizontalAlignment', 'right', 'FontSize', 9, 'Color', [0.32 0.32 0.31]);
exportgraphics(f, fullfile('output', 'C2_sp489_side_by_side.png'), 'Resolution', 150); close(f);
fprintf('saved output/C2_sp489_side_by_side.png\n');

function grat(A, t, c)
lp = @(lat, lon) t + A*[tand((90 - lat)/2).*sind(lon); tand((90 - lat)/2).*cosd(lon)];
for la = 50:10:80, p = lp(la*ones(1, 361), 0:360); plot(p(1, :), p(2, :), '-', 'Color', c, 'LineWidth', 0.5); end
for lo = 0:45:315, p = lp(50:0.5:89, lo*ones(1, 79)); plot(p(1, :), p(2, :), '-', 'Color', c, 'LineWidth', 0.5); end
end
