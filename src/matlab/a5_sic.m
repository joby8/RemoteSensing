% A5: uncorrected SIC (Eq. 16) over open water, daily tie points per hemisphere.
%  Tp,water = mean TB of the water mask (A4), Tp,ice = mean TB of the ice mask (siconc >= 0.95),
%  both from all orbits of one day, separately for N and S.
%  SIC = (TB - Tp,water) / (Tp,ice - Tp,water), raw (no clipping to 0..1, no 15 % filter).
%  Mean and std of SIC over the water-mask pixels. The mean is 0 by construction
%  (same pixels as Tp,water), so the std is the number that matters.
% Run from the project root:  matlab -batch "run('src/matlab/a5_sic.m')"
% Set days before running to choose, e.g. days = "0201"; default = all of Feb 1973.
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile('src','matlab'));
files = dir(fullfile('ESMR_colocated_filtered','*.nc'));
fday  = string(regexp({files.name}, '1973m(\d{4})t', 'tokens', 'once'));   % "0201", ...
if ~exist('days','var') || isempty(days), days = unique(fday); end

edge = false(1, 78); edge([1:4, 75:78]) = true;
hemi = ["N", "S"];
rows = {};
for d = days(:)'
    fi = find(fday == d);
    w = struct('tb', {[], []}, 'th', {[], []});   % water pixels per hemisphere (TB, theta)
    ic = {[], []};                                 % ice pixel TB per hemisphere
    for k = fi
        o = load_orbit(fullfile(files(k).folder, files(k).name));
        valid = ~isnan(o.tb_f) & ~repmat(edge, size(o.tb, 1), 1) & abs(o.lat) >= 50;
        tb    = o.tb_f;
        water = valid & o.siconc == 0    & o.sst > 278 & tb > 90  & tb < 180;
        ice   = valid & o.siconc >= 0.95 &                tb > 100 & tb < 274;
        for h = 1:2
            hs = (o.lat > 0) == (h == 1);
            w(h).tb = [w(h).tb; tb(water & hs)];
            w(h).th = [w(h).th; o.theta(water & hs)];
            ic{h}   = [ic{h};   tb(ice & hs)];
        end
    end
    for h = 1:2
        tpw = mean(w(h).tb); tpi = mean(ic{h});
        sic = (w(h).tb - tpw) / (tpi - tpw);
        rows(end+1, :) = {d, hemi(h), numel(fi), numel(w(h).tb), numel(ic{h}), ...
                          tpw, tpi, mean(sic), std(sic)}; %#ok<SAGROW>
        if d == days(1), sic1{h} = sic; th1{h} = w(h).th; end %#ok<SAGROW>
    end
    fprintf('%s done (%d orbits)\n', d, numel(fi));
end

T = cell2table(rows, 'VariableNames', {'day','hemi','n_orbits','n_water','n_ice', ...
                                       'Tp_water','Tp_ice','sic_mean','sic_std'});
T.sic_mean = 100 * T.sic_mean; T.sic_std = 100 * T.sic_std;   % in % SIC
disp(T);
for h = hemi
    s = T(T.hemi == h, :);
    fprintf('%s: mean daily std = %.2f %% SIC (min %.2f, max %.2f), Tp,water %.1f K, Tp,ice %.1f K\n', ...
        h, mean(s.sic_std), min(s.sic_std), max(s.sic_std), mean(s.Tp_water), mean(s.Tp_ice));
end
if ~exist('output', 'dir'), mkdir('output'); end
writetable(T, fullfile('output', 'A5_sic_uncorrected.csv'));
fprintf('saved output/A5_sic_uncorrected.csv\n');

% Figure: histogram of open-water SIC on the first day + daily std (if more than one day)
fig = figure('Visible','off','Position',[100 100 1500 550]);
tiledlayout(1, 2, 'TileSpacing', 'compact');
nexttile; hold on;
for h = 1:2
    histogram(100 * sic1{h}, -40:1:40, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'LineWidth', 1.5);
end
legend(compose('%s (std %.1f %%)', hemi', [std(sic1{1}) std(sic1{2})]' * 100), 'Location', 'northeast');
xlabel('SIC uncorrected [%]'); ylabel('pdf'); grid on; box on;
title(sprintf('Open-water SIC, 1973-%s-%s', extractBefore(days(1), 3), extractAfter(days(1), 2)));
nexttile; hold on;
for h = hemi
    s = T(T.hemi == h, :);
    plot(datetime(1973, str2double(extractBefore(s.day, 3)), str2double(extractAfter(s.day, 2))), ...
         s.sic_std, 'o-', 'LineWidth', 1.2);
end
legend(hemi, 'Location', 'best'); ylabel('std of open-water SIC [%]'); grid on; box on;
title('Daily std, uncorrected');
exportgraphics(fig, fullfile('output', 'A5_sic_uncorrected.png'), 'Resolution', 150);
fprintf('saved output/A5_sic_uncorrected.png\n');
