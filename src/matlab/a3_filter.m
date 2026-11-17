% A3: preprocessing of one orbit (esmr_preprocess.m, settings in preproc_config.m, called by load_orbit).
%  Steps in this order (Kolbe et al. 2024, Sect. 2.2, p. 1249, + our area masks), default since 2026-11-17:
%    analog filter (off) -> Eq. 1 (90 K < TB <= 273.15 K) -> Eq. 2 (per-pixel offset blocks) ->
%    Eq. 3 ('line': spike on the raw TB removes its line +-1 line, no wrap) -> Eq. 4 (7 stuck values) ->
%    swath edge (positions 1-4, 75-78) -> |lat| >= 50 deg -> land (ERA5 SST missing).
%  Source = raw Brightness_temperature (not DMI's brightness_temperature_filtered).
%  Prints the pixels removed per step (o.flag = first step that removed the pixel) and plots o.valid.
% Run from the project root:  matlab -batch "run('src/matlab/a3_filter.m')"
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile('src','matlab'));
if ~exist('f','var') || isempty(f)
    files = dir(fullfile('ESMR_colocated_filtered','*.nc'));
    f = fullfile(files(1).folder, files(1).name);
end
o = load_orbit(f);

n_all = numel(o.tb);
valid = o.valid;                                            % preprocessing (esmr_preprocess.m)
cf = preproc_config(); cd_ = cf.codes;                      % code table in step order
fprintf('%-26s %8s %8s %8s\n', 'step (flag code)', 'removed', 'left', 'left %');
left = n_all;
fprintf('%-26s %8s %8d %7.1f %%\n', 'all pixels', '', left, 100);
for i = 2:numel(cd_)                                        % skip code 0 (kept)
    nr = nnz(o.flag == cd_(i).code); left = left - nr;
    fprintf('%-26s %8d %8d %7.1f %%\n', sprintf('%s (%d)', cd_(i).label, cd_(i).code), nr, left, 100*left/n_all);
end
fprintf('theta range kept: %.2f .. %.2f deg\n', min(o.theta(valid)), max(o.theta(valid)));

tbc = o.tb_f; tbc(~valid) = NaN;
[~, name] = fileparts(f);
fig = figure('Visible','off','Position',[100 100 1000 650]);
scatter(o.lon(:), o.lat(:), 9, tbc(:), 'filled', 'MarkerEdgeColor', 'none');
clim([100 280]); colormap(parula); grid on; box on;
cb = colorbar; cb.Label.String = 'T_B [K]';
title({'T_B after preprocessing (Eq. 1-4, scan pos 5-74, |lat| \geq 50°, ocean)', strrep(name, '_', '\_')});
xlabel('Longitude [°E]'); ylabel('Latitude [°N]'); xlim([0 360]); ylim([-90 90]);
if ~exist('output', 'dir'), mkdir('output'); end
exportgraphics(fig, fullfile('output', 'A3_tb_filtered.png'), 'Resolution', 150);
fprintf('saved output/A3_tb_filtered.png\n');
