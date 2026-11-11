% A2: prepare one orbit (theta, W, V, Ts, Ti) and plot TB on lat/lon.
% Run from the project root:  matlab -batch "run('src/matlab/a2_plot.m')"
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));   % project root (run() changes the folder)
addpath(fullfile('src','matlab'));
if ~exist('f','var') || isempty(f)
    files = dir(fullfile('ESMR_colocated_filtered','*.nc'));
    f = fullfile(files(1).folder, files(1).name);
end
o = load_orbit(f);
fprintf('theta range: %.2f .. %.2f deg\n', min(o.theta(:)), max(o.theta(:)));
for k = {'W','V','Ts','Ti'}
    x = o.(k{1});
    fprintf('%s: min %.2f  max %.2f  mean %.2f\n', k{1}, min(x(:)), max(x(:)), mean(x(:), 'omitnan'));
end
[~, name] = fileparts(f);
fig = figure('Visible','off','Position',[100 100 1800 650]);
tl = tiledlayout(1, 2, 'TileSpacing', 'compact');
fld = {'tb', 'tb_f'}; ttl = {'T_B raw', 'T_B filtered (file)'};
for i = 1:2
    ax = nexttile; hold(ax, 'on');
    scatter(o.lon(:), o.lat(:), 9, o.(fld{i})(:), 'filled', 'MarkerEdgeColor', 'none');
    clim([100 280]); colormap(ax, parula); grid(ax, 'on'); box(ax, 'on');
    title(ax, {ttl{i}, strrep(name, '_', '\_')}); xlabel(ax, 'Longitude [°E]');
    if i == 1, ylabel(ax, 'Latitude [°N]'); end
    xlim(ax, [0 360]); ylim(ax, [-90 90]);
end
cb = colorbar; cb.Layout.Tile = 'east'; cb.Label.String = 'T_B [K]';
if ~exist('output', 'dir'), mkdir('output'); end
exportgraphics(fig, fullfile('output', 'A2_tb_latlon_matlab.png'), 'Resolution', 150);
fprintf('saved output/A2_tb_latlon_matlab.png\n');
