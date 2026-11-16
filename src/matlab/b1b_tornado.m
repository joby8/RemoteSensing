% B1b: tornado chart of the RTM sensitivity (Task 2), main report figure (decision see report_notes/B1_sensitivity.md).
%  Same base state and perturbations as b1_sensitivity.m: mean conditions of the Feb 1973 tie-point clusters
%  (A6b, both hemispheres pooled, without 28 Feb), each input moved by -1 sigma and +1 sigma, all others at the mean.
%  One angle (theta = 50 deg, mid/outer swath). Unit = % SIC: Delta T_B divided by the ice-water tie-point
%  contrast of the corrected A6b tie points (Northern Hemisphere, last iteration, mean over the days).
%  Fixed colours per input (V blue, W orange, L green, Ts purple, Ti red); L is drawn light + dashed = not corrected.
% Needs output/A6b_pixels.mat and output/A6b_iterative.csv (run a6b_iterative.m first).
% Run from the project root:  matlab -batch "run('src/matlab/b1b_tornado.m')"
% Outputs: output/B1_tornado.png, output/B1_tornado.csv
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile('src','matlab'));
theta = 50;

% ---- ice-water contrast from the corrected tie points (A6b) ----
C = readtable(fullfile('output', 'A6b_iterative.csv'), 'TextType', 'string');
C.day = compose('%04d', C.day);
C = C(C.day ~= "0228" & C.iter == max(C.iter), :);
dTp.N = mean(C.Tpi_c(C.hemi == "N") - C.Tpw_c(C.hemi == "N"));
dTp.S = mean(C.Tpi_c(C.hemi == "S") - C.Tpw_c(C.hemi == "S"));
K2sic = 100 / dTp.N;                                   % K -> % SIC (North)

% ---- base state and sigma per cluster ----
S = load(fullfile('output', 'A6b_pixels.mat'), 'P');
P = S.P([S.P.day] ~= "0228");
inp  = {'V','W','L','Ts','Ti'};
unit = struct('V', 'kg/m^2', 'W', 'm/s', 'L', 'kg/m^2', 'Ts', 'K', 'Ti', 'K');
name = struct('V', 'water vapour V', 'W', 'wind W', 'L', 'cloud liquid L', 'Ts', 'SST T_s', 'Ti', 'ice temp. T_i');
cols = struct('V', [0.00 0.45 0.74], 'W', [0.85 0.33 0.10], 'L', [0.47 0.67 0.19], 'Ts', [0.49 0.18 0.56], 'Ti', [0.64 0.08 0.18]);
cls = {'water', 'ice'}; cval = [0 1];
active = {{'V','W','L','Ts'}, {'Ti','V','L'}};

rows = {};
R = cell(1, 2);
for t = 1:2
    s = P([P.cls] == t);
    for v = inp, X.(v{1}) = double(vertcat(s.(v{1}))); end
    X.Ts(isnan(X.Ts)) = 271.35;
    for v = inp, M.(v{1}) = mean(X.(v{1})); SD.(v{1}) = std(X.(v{1})); end
    base = esmr_rtm_vec(M.V, M.W, M.L, M.Ts, M.Ti, cval(t), theta);
    r = struct('v', {}, 'lo', {}, 'hi', {}, 'sd', {});
    for v = active{t}
        Q = M; Q.(v{1}) = max(M.(v{1}) - SD.(v{1}), 0);   % V, W, L cannot go below 0
        lo = esmr_rtm_vec(Q.V, Q.W, Q.L, Q.Ts, Q.Ti, cval(t), theta) - base;
        Q = M; Q.(v{1}) = M.(v{1}) + SD.(v{1});
        hi = esmr_rtm_vec(Q.V, Q.W, Q.L, Q.Ts, Q.Ti, cval(t), theta) - base;
        r(end+1) = struct('v', v{1}, 'lo', lo, 'hi', hi, 'sd', SD.(v{1})); %#ok<SAGROW>
        rows(end+1, :) = {cls{t}, v{1}, theta, M.(v{1}), SD.(v{1}), lo, hi, lo*K2sic, hi*K2sic}; %#ok<SAGROW>
    end
    [~, o] = sort(arrayfun(@(q) abs(q.hi - q.lo), r), 'descend');
    R{t} = r(o);
    B(t) = base; %#ok<SAGROW>
end

% ---- figure ----
fig = figure('Visible','off','Position',[100 100 1500 520], 'Color', 'w');
tl = tiledlayout(1, 2, 'TileSpacing', 'loose', 'Padding', 'compact');
xl = max(cellfun(@(r) max(abs([r.lo r.hi])), R)) * K2sic * 1.5;
for t = 1:2
    r = R{t}; n = numel(r); lab = cell(1, n);
    ax = nexttile; hold on;
    for k = 1:n
        y = n + 1 - k;                                      % largest on top
        c = cols.(r(k).v);
        if strcmp(r(k).v, 'L')
            fc = 0.55*c + 0.45; ls = '--'; tag = ' (not corrected)';
        else
            fc = c; ls = '-'; tag = '';
        end
        for side = [r(k).lo r(k).hi]
            x = side * K2sic;
            a = 1; if side == r(k).lo, a = 0.45; end         % -1 sigma lighter
            x0 = min(0, x); x1 = x0 + abs(x);
            patch([x0 x1 x1 x0], y + 0.32*[-1 -1 1 1], fc, 'FaceAlpha', a, ...
                'EdgeColor', c, 'LineStyle', ls, 'LineWidth', 1.2);
            al = 'left'; dx = 0.25; if x < 0, al = 'right'; dx = -0.25; end
            text(x + dx, y, sprintf('%+.1f %%  (%+.1f K)', x, side), 'HorizontalAlignment', al, ...
                'FontSize', 10, 'Color', [0.2 0.2 0.2]);
        end
        lab{k} = sprintf('\\bf%s\\rm%s  (1\\sigma = %.2g %s)', name.(r(k).v), tag, r(k).sd, unit.(r(k).v)); %#ok<SAGROW>
    end
    xline(0, 'k-', 'LineWidth', 1.2);
    set(ax, 'YTick', 1:n, 'YTickLabel', flip(lab(:)), 'TickLabelInterpreter', 'tex', 'FontSize', 10, ...
        'YLim', [0.4 n + 0.6], 'XLim', [-xl xl], 'XGrid', 'on', 'Box', 'on', 'Layer', 'top');
    xlabel('\Delta SIC for -1\sigma (light) / +1\sigma (dark) of one input [% SIC]');
    title(sprintf('%s (c_{ice} = %d), \\theta = %d°, mean-state T_B = %.0f K', cls{t}, cval(t), theta, B(t)));
    if t == 2
        text(-xl*0.95, 0.55, 'W and T_s have no effect at c_{ice} = 1', 'FontSize', 9, ...
            'Color', [0.4 0.4 0.4], 'VerticalAlignment', 'bottom');
    end
end
title(tl, sprintf(['RTM sensitivity at mean Feb 1973 tie-point weather: \\pm1\\sigma of each input ' ...
    '(1 %% SIC = %.2f K, ice-water contrast %.0f K, North)'], 1/K2sic, dTp.N), 'FontSize', 12);
exportgraphics(fig, fullfile('output', 'B1_tornado.png'), 'Resolution', 150);

T = cell2table(rows, 'VariableNames', {'surface','input','theta','mean','sigma', ...
    'dTB_minus_sigma','dTB_plus_sigma','dSIC_minus_sigma','dSIC_plus_sigma'});
writetable(T, fullfile('output', 'B1_tornado.csv'));
fprintf('ice-water contrast (corrected tie points): N %.1f K, S %.1f K -> 1 %% SIC = %.2f K (N)\n', dTp.N, dTp.S, 1/K2sic);
disp(T);
fprintf('saved output/B1_tornado.png, output/B1_tornado.csv\n');
