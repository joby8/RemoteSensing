% A6: RTM correction of TB (Kolbe et al. 2024, Eq. 13-14) and corrected open-water SIC (Task 1).
%  For every day and hemisphere:
%   1. tie-point pixels as in A4 (water: c_ice = 0, ice: c_ice = 1)
%   2. reference = daily means over the tie-point cluster: Vm, Wm, Lm, Tsm, Tim
%   3. dTB = RTM(Vm, Wm, Lm, Tsm, Tim, c, theta) - RTM(V, W, Lm, Ts, Ti, c, theta)  (Eq. 14)
%      L is NOT corrected: the mean L goes into both runs (paper Sect. 4.1). For comparison the
%      variant with per-pixel L in the actual run is also computed (column sic_std_cL).
%      TB_corr = TB + dTB                                                         (Eq. 13)
%   4. corrected tie points = mean TB_corr over the clusters
%   5. SIC (Eq. 16) over the water pixels, uncorrected and corrected: mean and std (raw, not clipped)
%  Inputs per pixel: V = tcwv, W = |u10,v10|, L = tcw - tcwv, Ts = sst, Ti = 0.4 t2m + 0.6*272 (Eq. 15),
%  theta from spos2ia (same theta in both runs).
% Run from the project root:  matlab -batch "run('src/matlab/a6_corrected.m')"
% Outputs: output/A6_sic_corrected.csv, output/A6_sic_corrected.png, output/A6_water_pixels.mat (for Task 2/3)
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile('src','matlab'));
files = dir(fullfile('ESMR_colocated_filtered','*.nc'));
fday  = string(regexp({files.name}, '1973m(\d{4})t', 'tokens', 'once'));
if ~exist('days','var') || isempty(days), days = unique(fday); end
edge = false(1, 78); edge([1:4, 75:78]) = true;
vars = {'tb','th','V','W','L','Ts','Ti'};
hemi = ["N","S"];

rows = {}; P = struct('day', {}, 'hemi', {}, 'th', {}, 'sic_u', {}, 'sic_c', {}, 'dtb', {}, 'V', {}, 'W', {}, 'L', {}, 'Ts', {}, 'Ti', {});
for d = days(:)'
    fi = find(fday == d);
    wat = repmat({struct()}, 1, 2); ice = wat;
    for h = 1:2, for v = vars, wat{h}.(v{1}) = []; ice{h}.(v{1}) = []; end, end
    for k = fi
        o = load_orbit(fullfile(files(k).folder, files(k).name));
        o.L = double(ncread(fullfile(files(k).folder, files(k).name), 'tcw'))' - o.V;
        o.th = o.theta; o.tb = o.tb_f;
        valid = ~isnan(o.tb_f) & ~repmat(edge, size(o.tb_f, 1), 1) & abs(o.lat) >= 50;
        mw = valid & o.siconc == 0    & o.sst > 278 & o.tb > 90  & o.tb < 180;
        mi = valid & o.siconc >= 0.95 &                o.tb > 100 & o.tb < 274;
        for h = 1:2
            hs = (o.lat > 0) == (h == 1);
            for v = vars
                wat{h}.(v{1}) = [wat{h}.(v{1}); o.(v{1})(mw & hs)];
                ice{h}.(v{1}) = [ice{h}.(v{1}); o.(v{1})(mi & hs)];
            end
        end
    end
    for h = 1:2
        w = wat{h}; c = ice{h};
        c.Ts(isnan(c.Ts)) = 271.35;                      % SST under ice (not used when c_ice = 1, avoids NaN)
        w.dtb = correction(w, 0, false); c.dtb = correction(c, 1, false);
        dL = correction(w, 0, true); dLi = correction(c, 1, true);          % variant: per-pixel L
        tpw_u = mean(w.tb);          tpi_u = mean(c.tb);
        tpw_c = mean(w.tb + w.dtb);  tpi_c = mean(c.tb + c.dtb);
        sic_u = (w.tb - tpw_u) / (tpi_u - tpw_u);
        sic_c = (w.tb + w.dtb - tpw_c) / (tpi_c - tpw_c);
        sic_cL = (w.tb + dL - mean(w.tb + dL)) / (mean(c.tb + dLi) - mean(w.tb + dL));
        rows(end+1, :) = {d, hemi(h), numel(w.tb), numel(c.tb), tpw_u, tpw_c, tpi_u, tpi_c, ...
            100*mean(sic_u), 100*std(sic_u), 100*mean(sic_c), 100*std(sic_c), 100*std(sic_cL), std(w.tb), std(w.tb + w.dtb), ...
            mean(w.V), mean(w.W), mean(w.L), mean(w.Ts)}; %#ok<SAGROW>
        P(end+1) = struct('day', d, 'hemi', hemi(h), 'th', single(w.th), 'sic_u', single(sic_u), 'sic_c', single(sic_c), ...
            'dtb', single(w.dtb), 'V', single(w.V), 'W', single(w.W), 'L', single(w.L), 'Ts', single(w.Ts), 'Ti', single(w.Ti)); %#ok<SAGROW>
    end
    fprintf('%s done (%d orbits)\n', d, numel(fi));
end

T = cell2table(rows, 'VariableNames', {'day','hemi','n_water','n_ice','Tpw_u','Tpw_c','Tpi_u','Tpi_c', ...
    'sic_mean_u','sic_std_u','sic_mean_c','sic_std_c','sic_std_cL','tb_std_u','tb_std_c','Vm','Wm','Lm','Tsm'});
disp(T(:, {'day','hemi','n_water','Tpw_u','Tpw_c','Tpi_u','Tpi_c','sic_std_u','sic_std_c','sic_std_cL'}));
ok = T.day ~= "0228";                                   % 28 Feb: one orbit only
fprintf('\nWithout 28 Feb (1 orbit):\n');
for h = hemi
    s = T(T.hemi == h & ok, :);
    fprintf('%s: std SIC uncorrected %.2f %% -> corrected %.2f %% (%.0f %% less); std TB %.2f -> %.2f K; mean SIC corr %.1e %%\n', ...
        h, mean(s.sic_std_u), mean(s.sic_std_c), 100*(1 - mean(s.sic_std_c)/mean(s.sic_std_u)), ...
        mean(s.tb_std_u), mean(s.tb_std_c), mean(s.sic_mean_c));
    fprintf('   variant with per-pixel L: std SIC %.2f %%; days with lower std after correction: %d of %d\n', ...
        mean(s.sic_std_cL), nnz(s.sic_std_c < s.sic_std_u), height(s));
end
if ~exist('output', 'dir'), mkdir('output'); end
writetable(T, fullfile('output', 'A6_sic_corrected.csv'));
save(fullfile('output', 'A6_water_pixels.mat'), 'P', '-v7.3');
fprintf('saved output/A6_sic_corrected.csv, output/A6_water_pixels.mat\n');

% ---- figure: histogram (all days pooled) + daily std before/after ----
fig = figure('Visible','off','Position',[100 100 1500 550]);
tiledlayout(1, 2, 'TileSpacing', 'compact');
nexttile; hold on;
col = [0.10 0.35 0.80; 0.85 0.30 0.10];
for h = 1:2
    s = P([P.hemi] == hemi(h) & [P.day] ~= "0228");
    u = 100 * double(vertcat(s.sic_u)); c = 100 * double(vertcat(s.sic_c));
    histogram(u, -40:1:40, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'LineWidth', 1.0, 'EdgeColor', col(h,:), 'LineStyle', ':');
    histogram(c, -40:1:40, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'LineWidth', 1.6, 'EdgeColor', col(h,:));
end
legend({'N uncorrected', 'N corrected', 'S uncorrected', 'S corrected'}, 'Location', 'northeast');
xlabel('Open-water SIC [%]'); ylabel('pdf'); grid on; box on; title('Open-water SIC, Feb 1973 (all days pooled)');
nexttile; hold on;
for h = 1:2
    s = T(T.hemi == hemi(h) & ok, :);
    t = datetime(1973, 2, str2double(extractAfter(s.day, 2)));
    plot(t, s.sic_std_u, ':o', 'Color', col(h,:), 'LineWidth', 1.0);
    plot(t, s.sic_std_c, '-o', 'Color', col(h,:), 'LineWidth', 1.6, 'MarkerFaceColor', col(h,:));
end
legend({'N uncorrected', 'N corrected', 'S uncorrected', 'S corrected'}, 'Location', 'best');
ylabel('std of open-water SIC [%]'); grid on; box on; title('Daily std before and after RTM correction');
exportgraphics(fig, fullfile('output', 'A6_sic_corrected.png'), 'Resolution', 150);
fprintf('saved output/A6_sic_corrected.png\n');

% ---------------------------------------------------------------------------
function dtb = correction(s, c, pixelL)
% Eq. 14: reference run with the cluster means, actual run with the pixel values, same theta.
% L: cluster mean in both runs (paper), unless pixelL = true (variant for comparison).
Lact = mean(s.L); if pixelL, Lact = s.L; end
ref = esmr_rtm_vec(mean(s.V), mean(s.W), mean(s.L), mean(s.Ts), mean(s.Ti), c, s.th);
act = esmr_rtm_vec(s.V, s.W, Lact, s.Ts, s.Ti, c, s.th);
dtb = ref - act;
end
