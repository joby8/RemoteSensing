% A3: filters on one orbit.
%  - Eq. 1 (90 K < TB <= 273.15 K) is already applied in brightness_temperature_filtered.
%  - Drop scan positions 1-4 and 75-78 (swath edge, largest incidence angles).
%  - Keep only |lat| >= 50 deg (meeting 2026-11-10).
% Run from the project root:  matlab -batch "run('src/matlab/a3_filter.m')"
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile('src','matlab'));
if ~exist('f','var') || isempty(f)
    files = dir(fullfile('ESMR_colocated_filtered','*.nc'));
    f = fullfile(files(1).folder, files(1).name);
end
o = load_orbit(f);

n_all  = numel(o.tb);
eq1    = ~isnan(o.tb_f);
edge   = false(1, 78); edge([1:4, 75:78]) = true;
noedge = ~repmat(edge, size(o.tb, 1), 1);
hilat  = abs(o.lat) >= 50;
valid  = eq1 & noedge & hilat;

fprintf('pixels total            %7d\n', n_all);
fprintf('after Eq. 1 (file)      %7d (%.1f %%)\n', nnz(eq1), 100*nnz(eq1)/n_all);
fprintf('+ scan pos 5..74        %7d (%.1f %%)\n', nnz(eq1 & noedge), 100*nnz(eq1 & noedge)/n_all);
fprintf('+ |lat| >= 50           %7d (%.1f %%)\n', nnz(valid), 100*nnz(valid)/n_all);
fprintf('theta range kept: %.2f .. %.2f deg\n', min(o.theta(valid)), max(o.theta(valid)));

tbc = o.tb_f; tbc(~valid) = NaN;
[~, name] = fileparts(f);
fig = figure('Visible','off','Position',[100 100 1000 650]);
scatter(o.lon(:), o.lat(:), 9, tbc(:), 'filled', 'MarkerEdgeColor', 'none');
clim([100 280]); colormap(parula); grid on; box on;
cb = colorbar; cb.Label.String = 'T_B [K]';
title({'T_B after A3 filters (Eq. 1, scan pos 5-74, |lat| \geq 50°)', strrep(name, '_', '\_')});
xlabel('Longitude [°E]'); ylabel('Latitude [°N]'); xlim([0 360]); ylim([-90 90]);
if ~exist('output', 'dir'), mkdir('output'); end
exportgraphics(fig, fullfile('output', 'A3_tb_filtered.png'), 'Resolution', 150);
fprintf('saved output/A3_tb_filtered.png\n');
