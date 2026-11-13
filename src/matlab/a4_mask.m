% A4: tie-point masks on one orbit (after the A3 filters).
%  Water (Table 2): siconc = 0, sst > 278 K, 90 K < TB < 180 K.
%  Ice: siconc >= 0.95 (Tonboe: treat 95 % as 100 %), 100 K < TB < 274 K (Table 2).
%  Both: |lat| >= 50 deg, scan positions 5..74. The 5x5-box criterion is not applied.
% Run from the project root:  matlab -batch "run('src/matlab/a4_mask.m')"
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile('src','matlab'));
if ~exist('f','var') || isempty(f)
    files = dir(fullfile('ESMR_colocated_filtered','*.nc'));
    f = fullfile(files(1).folder, files(1).name);
end
o = load_orbit(f);

edge  = false(1, 78); edge([1:4, 75:78]) = true;
valid = ~isnan(o.tb_f) & ~repmat(edge, size(o.tb, 1), 1) & abs(o.lat) >= 50;
tb    = o.tb_f;
water = valid & o.siconc == 0    & o.sst > 278 & tb > 90  & tb < 180;
ice   = valid & o.siconc >= 0.95 &                tb > 100 & tb < 274;
N = o.lat > 0;

fprintf('%-6s %-5s %7s %9s %7s\n', 'class', 'hemi', 'n', 'mean TB', 'std');
cls = {'water', water; 'ice', ice};
for c = 1:2
    for h = {'N', N; 'S', ~N}'
        sel = cls{c, 2} & h{2};
        fprintf('%-6s %-5s %7d %9.2f %7.2f\n', cls{c, 1}, h{1}, nnz(sel), mean(tb(sel)), std(tb(sel)));
    end
end

[~, name] = fileparts(f);
fig = figure('Visible','off','Position',[100 100 1000 650]); hold on;
scatter(o.lon(valid), o.lat(valid), 6, [0.8 0.8 0.8], 'filled');
scatter(o.lon(water), o.lat(water), 9, [0.10 0.35 0.80], 'filled');
scatter(o.lon(ice),   o.lat(ice),   9, [0.85 0.30 0.10], 'filled');
legend({'valid (other)', 'water tie-point pixels', 'ice tie-point pixels'}, 'Location', 'southoutside', 'Orientation', 'horizontal');
grid on; box on; xlim([0 360]); ylim([-90 90]);
xlabel('Longitude [°E]'); ylabel('Latitude [°N]');
title({'A4 tie-point masks', strrep(name, '_', '\_')});
if ~exist('output', 'dir'), mkdir('output'); end
exportgraphics(fig, fullfile('output', 'A4_masks.png'), 'Resolution', 150);
fprintf('saved output/A4_masks.png\n');
