% C2c - Image-analysis view of the book reading in C2: what the algorithm reads from the scanned atlas maps vs. the original.
%       Reads output/C2_results.mat (written by c2_feb1973_books.m) and the scans; no recomputation of the classification.
% OUTPUT (output/):
%   C2c_image_analysis.png  rows Arctic (SP-489) / Antarctic (SP-459); columns:
%                           (1) original scan + fitted graticule (affine georeference)
%                           (2) every pixel replaced by its nearest legend colour (CIE Lab), lines/text black
%                           (3) colour distance Delta E between pixel and matched legend colour (reading confidence)
%                           (4) the 30 km grid-cell result drawn back into the scan geometry, in the legend colours
%                           bottom: the legend colours used (reference swatches)
%   C2c_zoom.png            same four steps for one ice-edge window per hemisphere (pixel level)
% Run from the project root:  matlab -batch "run('src/matlab/c2c_image_analysis.m')"
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));
D = load(fullfile('output', 'C2_results.mat'));
img = {imread(fullfile('docs', 'sp489', 'fig_feb1973.jpg')), imread(fullfile('docs', 'sp459', 'fig5-2a_feb1973.jpg'))};
book = {'SP-489 Fig. 4-19a (Arctic)', 'SP-459 Fig. 5-2a (Antarctic)'};
rmsTxt = {sprintf('rms %.1f px = %.0f km', D.rmsN.px, D.rmsN.km), sprintf('rms %.1f px = %.0f km', D.rmsS.px, D.rmsS.km)};
nc = D.nc; n = D.n; dx = D.dx; L = D.L; Re = D.Re;
zc = {[76 32], [-68 -40]}; zh = 85;                         % zoom windows: centre (lat, lon), half size [px]
fs = 12; gc = [1 0 1];
dEcm = interp1([0 0.35 0.7 1], [1 1 1; 0.98 0.80 0.45; 0.85 0.33 0.10; 0.35 0.05 0.05], linspace(0, 1, 128)');

%% per hemisphere: nearest legend colour, Delta E, cell result in scan geometry
P = struct();
for h = 1:2
    I = img{h}; [H, W, ~] = size(I); pal = double(D.pal{h}); grp = D.grp{h}; pc = D.PC{h};
    lab = rgb2lab_(double(reshape(I, [], 3))); labp = rgb2lab_(pal);
    dmin = inf(H*W, 1); jn = zeros(H*W, 1);
    for j = 1:size(labp, 1)
        d = sum((lab - labp(j, :)).^2, 2); b = d < dmin; dmin(b) = d(b); jn(b) = j;
    end
    rec = pal(jn, :)/255; isLine = pc(:) == nc + 3; rec(isLine, :) = 0;
    P(h).rec = reshape(rec, H, W, 3); P(h).dE = reshape(sqrt(dmin), H, W);
    % colour of each group (first palette entry of the group)
    gcol = nan(nc + 3, 3); for k = 1:nc + 3, j = find(grp == k, 1); if ~isempty(j), gcol(k, :) = pal(j, :)/255; end, end
    for k = find(isnan(gcol(:, 1)))', gcol(k, :) = (gcol(k - 1, :) + gcol(k + 1, :))/2; end   % North class 26-30 % is not used (C2 fix 1)
    P(h).gcol = gcol;
    % grid cell of every scan pixel (inverse affine)
    [px, py] = meshgrid(1:W, 1:H); XY = D.A{h} \ [px(:)' - D.t{h}(1); py(:)' - D.t{h}(2)];
    U = 2*Re*XY(1, :)'; V = -2*Re*XY(2, :)';
    cc = floor((U + L)/dx) + 1; rr = floor((V + L)/dx) + 1; ok = cc >= 1 & cc <= n & rr >= 1 & rr <= n;
    idx = zeros(H*W, 1); idx(ok) = sub2ind([n n], rr(ok), cc(ok));
    cls = D.CLS(:,:,h); bcl = D.BCL(:,:,h);
    cat = zeros(H*W, 1); cat(ok) = cls(idx(ok));            % 0 not read, 1 ice, 2 water, 3 land
    cel = ones(H*W, 3);                                      % white = outside the read region
    m = cat == 2; cel(m, :) = repmat(gcol(nc + 1, :), sum(m), 1);
    m = cat == 3; cel(m, :) = repmat(gcol(nc + 2, :), sum(m), 1);
    m = cat == 1; j = bcl(idx(m)); j(j == 0) = 1; cel(m, :) = gcol(j, :);
    inReg = ok & idx > 0; inReg(inReg) = (h == 1 & D.LATh{1}(idx(inReg)) >= 50) | (h == 2 & D.LATh{2}(idx(inReg)) <= -50);
    m = inReg & cat == 0; cel(m, :) = repmat([0.6 0.6 0.6], sum(m), 1);   % unreadable (book land / lines only)
    P(h).cel = reshape(cel, H, W, 3);
    % pixel vs cell agreement (pixels that are not line, in read cells)
    pcat = zeros(H*W, 1); pcat(pc(:) <= nc) = 1; pcat(pc(:) == nc + 1) = 2; pcat(pc(:) == nc + 2) = 3;
    use = inReg & cat > 0 & pcat > 0;
    P(h).agreeCat = 100*mean(pcat(use) == cat(use));
    ui = use & cat == 1 & pcat == 1; jc = zeros(H*W, 1); jc(ui) = bcl(idx(ui));
    P(h).agreeCls = 100*mean(abs(pc(ui) - jc(ui)) <= 1);     % same class or neighbour class
    P(h).fracLine = 100*mean(isLine(inReg));
    P(h).medDE = median(sqrt(dmin(inReg & ~isLine)));
    % georeference overlay and zoom box
    P(h).lp = @(lat, lon) ll2px(lat, lon, h, D.A{h}, D.t{h});
    zp = P(h).lp(zc{h}(1), zc{h}(2)); P(h).zx = round(zp(1)) + (-zh:zh); P(h).zy = round(zp(2)) + (-zh:zh);
    fprintf('%s: pixel/cell agreement ice-water-land %.1f %%, ice class within +-1 class %.1f %%, line pixels %.1f %%, median dE %.1f\n', ...
        book{h}, P(h).agreeCat, P(h).agreeCls, P(h).fracLine, P(h).medDE);
end

%% figure 1: the four steps, both hemispheres
f = figure('Visible', 'off', 'Position', [0 0 2000 1150], 'Color', 'w');
tl = tiledlayout(f, 7, 4, 'TileSpacing', 'compact', 'Padding', 'compact');
for h = 1:2
    r0 = 3*(h - 1);
    ax = nexttile(tl, 4*r0 + 1, [3 1]); image(ax, img{h}); axis(ax, 'image', 'off'); hold(ax, 'on');
    grat(ax, P(h).lp, h, gc); box_(ax, P(h).zx, P(h).zy);
    title(ax, {['1  Original scan, ' book{h}], ['fitted graticule (magenta), ' rmsTxt{h}]}, 'FontWeight', 'normal', 'FontSize', fs);
    ax = nexttile(tl, 4*r0 + 2, [3 1]); image(ax, P(h).rec); axis(ax, 'image', 'off'); hold(ax, 'on'); box_(ax, P(h).zx, P(h).zy);
    title(ax, {'2  Each pixel \rightarrow nearest legend colour (CIE Lab)', sprintf('black: lines and text (%.0f %% of pixels)', P(h).fracLine)}, ...
        'FontWeight', 'normal', 'FontSize', fs);
    ax = nexttile(tl, 4*r0 + 3, [3 1]); imagesc(ax, min(P(h).dE, 30)); axis(ax, 'image', 'off'); colormap(ax, dEcm); clim(ax, [0 30]);
    hold(ax, 'on'); box_(ax, P(h).zx, P(h).zy);
    cb = colorbar(ax, 'eastoutside'); cb.Label.String = '\DeltaE to matched colour'; cb.FontSize = fs - 2;
    title(ax, {'3  Colour distance (reading confidence)', sprintf('median \\DeltaE %.1f; large on lines and class borders', P(h).medDE)}, ...
        'FontWeight', 'normal', 'FontSize', fs);
    ax = nexttile(tl, 4*r0 + 4, [3 1]); image(ax, P(h).cel); axis(ax, 'image', 'off'); hold(ax, 'on'); box_(ax, P(h).zx, P(h).zy);
    title(ax, {'4  Result on 30 km cells, drawn back on the scan', sprintf('pixels agree with their cell: %.1f %% (ice/water/land)', P(h).agreeCat)}, ...
        'FontWeight', 'normal', 'FontSize', fs);
end
% legend swatch strips
for h = 1:2
    ax = nexttile(tl, 25 + 2*(h - 1), [1 2]); gcol = P(h).gcol;
    sw = reshape([gcol(nc + 1, :); gcol(1:nc, :); gcol(nc + 2, :)], 1, nc + 2, 3);
    image(ax, sw); axis(ax, 'off'); hold(ax, 'on');
    labs = [{'water'}, arrayfun(@(x) sprintf('%d', x), D.LO, 'UniformOutput', false), {'land'}];
    for k = 1:nc + 2, text(ax, k, 1.75, labs{k}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontSize', fs - 4); end
    title(ax, sprintf('%s legend colours used (ice classes: lower bound in %%)', strtok(book{h}, ' ')), 'FontWeight', 'normal', 'FontSize', fs - 1);
    ylim(ax, [0.5 2.3]);
end
title(tl, 'Reading the 1970s NASA atlas maps: from the scanned page to 30 km grid cells', 'FontSize', fs + 4, 'FontWeight', 'bold');
exportgraphics(f, fullfile('output', 'C2c_image_analysis.png'), 'Resolution', 150); close(f);

%% figure 2: zoom on one ice-edge window per hemisphere
f = figure('Visible', 'off', 'Position', [0 0 1700 900], 'Color', 'w');
tl = tiledlayout(f, 2, 4, 'TileSpacing', 'compact', 'Padding', 'compact');
nm = {'original scan', 'nearest legend colour', '\DeltaE', '30 km cells'};
for h = 1:2
    zx = P(h).zx; zy = P(h).zy;
    for k = 1:4
        ax = nexttile;
        switch k
            case 1, image(ax, img{h}(zy, zx, :));
            case 2, image(ax, P(h).rec(zy, zx, :));
            case 3, imagesc(ax, min(P(h).dE(zy, zx), 30)); colormap(ax, dEcm); clim(ax, [0 30]);
            case 4, image(ax, P(h).cel(zy, zx, :));
        end
        axis(ax, 'image', 'off');
        if k == 1
            title(ax, sprintf('%s: %s (%.0f%s, %.0f%s)', strtok(book{h}, ' '), nm{k}, abs(zc{h}(1)), ns(zc{h}(1), 'NS'), abs(zc{h}(2)), ns(zc{h}(2), 'EW')), ...
                'FontWeight', 'normal', 'FontSize', fs);
        else
            title(ax, nm{k}, 'FontWeight', 'normal', 'FontSize', fs);
        end
        if k == 3, cb = colorbar(ax, 'eastoutside'); cb.FontSize = fs - 2; end
    end
end
title(tl, sprintf('Zoom on the ice edge, %d x %d scan pixels (one 30 km cell = about 5 pixels)', 2*zh + 1, 2*zh + 1), 'FontSize', fs + 2, 'FontWeight', 'bold');
exportgraphics(f, fullfile('output', 'C2c_zoom.png'), 'Resolution', 150); close(f);
fprintf('saved output/C2c_image_analysis.png, C2c_zoom.png\n');

%% helpers
function s = ns(x, c)
if x >= 0, s = c(1); else, s = c(2); end
end
function p = ll2px(lat, lon, h, A, t)
r = tand((90 - abs(lat))/2); X = r.*sind(lon); Y = r.*cosd(lon); if h == 2, Y = -Y; end
p = t + A*[X(:)'; Y(:)'];
end
function grat(ax, lp, h, c)
if h == 1, las = 50:10:80; else, las = -50:-10:-80; end
for la = las, p = lp(la*ones(1, 361), 0:360); plot(ax, p(1, :), p(2, :), '-', 'Color', [c 0.55], 'LineWidth', 0.5); end
s = sign(las(1));
for lo = 0:45:315, p = lp(s*(50:0.5:89), lo*ones(1, 79)); plot(ax, p(1, :), p(2, :), '-', 'Color', [c 0.55], 'LineWidth', 0.5); end
end
function box_(ax, zx, zy)
plot(ax, zx([1 end end 1 1]), zy([1 1 end end 1]), '-', 'Color', [0 0.75 0.2], 'LineWidth', 1.8);
end
function lab = rgb2lab_(rgb)                                % sRGB 0..255 -> CIE Lab (D65)
c = rgb/255; lin = ((c + 0.055)/1.055).^2.4; lin(c <= 0.04045) = c(c <= 0.04045)/12.92;
XYZ = lin * [0.4124 0.2126 0.0193; 0.3576 0.7152 0.1192; 0.1805 0.0722 0.9505];
XYZ = XYZ ./ [0.95047 1 1.08883]; f = XYZ.^(1/3); sm = XYZ <= 0.008856; f(sm) = 7.787*XYZ(sm) + 16/116;
lab = [116*f(:,2) - 16, 500*(f(:,1) - f(:,2)), 200*(f(:,2) - f(:,3))];
end
