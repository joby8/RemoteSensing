% Plot one orbit on a 3D globe with land/coastlines (no Mapping Toolbox needed: uses topo.mat).
% Two figures: filtered TB (A3) and tie-point masks (A4).
% Interactive: run in the MATLAB desktop and rotate/zoom with the mouse (rotate3d is on).
%   run('src/matlab/globe_plot.m')
% Batch: saves PNGs (north + south view) and .fig files (open later with openfig -> rotatable).
%   matlab -batch "run('src/matlab/globe_plot.m')"
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile('src','matlab'));
if ~exist('f','var') || isempty(f)
    files = dir(fullfile('ESMR_colocated_filtered','*.nc'));
    f = fullfile(files(1).folder, files(1).name);
end
o = load_orbit(f);
[~, name] = fileparts(f);

% A3 filters + A4 masks (same rules as a3_filter.m / a4_mask.m)
edge  = false(1, 78); edge([1:4, 75:78]) = true;
valid = ~isnan(o.tb_f) & ~repmat(edge, size(o.tb, 1), 1) & abs(o.lat) >= 50;
tb    = o.tb_f;
water = valid & o.siconc == 0    & o.sst > 278 & tb > 90  & tb < 180;
ice   = valid & o.siconc >= 0.95 &                tb > 100 & tb < 274;

if ~exist('output', 'dir'), mkdir('output'); end
batch = ~usejava('desktop');

% --- Figure 1: filtered TB ---
fig1 = make_globe(sprintf('T_B after A3 filters\n%s', strrep(name, '_', '\_')), batch);
[x, y, z] = sph(o.lat(valid), o.lon(valid), 1.006);
scatter3(x, y, z, 4, tb(valid), 'filled', 'MarkerEdgeColor', 'none');
colormap(parula); clim([100 280]);
cb = colorbar; cb.Label.String = 'T_B [K]';
finish(fig1, 'globe_A3_tb', batch);

% --- Figure 2: tie-point masks ---
fig2 = make_globe(sprintf('A4 tie-point masks\n%s', strrep(name, '_', '\_')), batch);
other = valid & ~water & ~ice;
[x, y, z] = sph(o.lat(other), o.lon(other), 1.006);
h1 = scatter3(x, y, z, 3, [0.65 0.65 0.65], 'filled');
[x, y, z] = sph(o.lat(water), o.lon(water), 1.007);
h2 = scatter3(x, y, z, 5, [0.10 0.35 0.80], 'filled');
[x, y, z] = sph(o.lat(ice), o.lon(ice), 1.007);
h3 = scatter3(x, y, z, 5, [0.85 0.30 0.10], 'filled');
legend([h1 h2 h3], {'valid (other)', 'water tie point', 'ice tie point'}, 'Location', 'southoutside', 'Orientation', 'horizontal');
finish(fig2, 'globe_A4_masks', batch);

% ---------------------------------------------------------------------------
function fig = make_globe(ttl, batch)
vis = 'on'; if batch, vis = 'off'; end
fig = figure('Visible', vis, 'Position', [100 100 900 900], 'Color', 'w');
ax = axes(fig); hold(ax, 'on');
S = load('topo.mat');                          % topo: 180x360, lat -89.5..89.5, lon 0.5..359.5
land = S.topo > 0;
rgb = zeros([size(land) 3]);
ocean = [0.86 0.92 0.97]; ground = [0.80 0.78 0.72];
for c = 1:3, rgb(:, :, c) = ocean(c) * ~land + ground(c) * land; end
[lo, la] = meshgrid(linspace(0, 360, 361), linspace(-90, 90, 181));
[x, y, z] = sph(la, lo, 1);
surf(ax, x, y, z, 'CData', rgb, 'FaceColor', 'texturemap', 'EdgeColor', 'none', 'HandleVisibility', 'off');
% coastlines = 0 m contour of topo
C = contourc(0.5:359.5, -89.5:89.5, double(S.topo), [0 0]);
k = 1;
while k < size(C, 2)
    n = C(2, k); seg = C(:, k+1:k+n); k = k + n + 1;
    [x, y, z] = sph(seg(2, :), seg(1, :), 1.003);
    plot3(ax, x, y, z, 'Color', [0.3 0.3 0.3], 'LineWidth', 0.5, 'HandleVisibility', 'off');
end
% graticule every 30 deg lon / 15 deg lat
for L = 0:30:330
    la = -90:2:90; [x, y, z] = sph(la, L + 0*la, 1.002);
    plot3(ax, x, y, z, ':', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
end
for B = -75:15:75
    lo = 0:2:360; [x, y, z] = sph(B + 0*lo, lo, 1.002);
    plot3(ax, x, y, z, ':', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
end
axis(ax, 'equal', 'off'); title(ax, ttl);
view(ax, 0, 60);                                % look at the Arctic
if ~batch, rotate3d(fig, 'on'); end
end

function finish(fig, base, batch)
savefig(fig, fullfile('output', [base '.fig']));
if batch
    ax = findobj(fig, 'Type', 'axes');
    view(ax, 0, 60);   exportgraphics(fig, fullfile('output', [base '_N.png']), 'Resolution', 130);
    view(ax, 180, -60); exportgraphics(fig, fullfile('output', [base '_S.png']), 'Resolution', 130);
    fprintf('saved output/%s_N.png, _S.png, .fig\n', base);
end
end

function [x, y, z] = sph(lat, lon, r)
x = r .* cosd(lat) .* cosd(lon);
y = r .* cosd(lat) .* sind(lon);
z = r .* sind(lat);
end
