% B1: RTM sensitivity study (Task 2, agreed with Tonboe 2026-11-13).
%  Static report version of the animation in the learning page (Sect. 4): the theta sweep becomes the x axis.
%  Base state = mean conditions of the tie-point clusters in Feb 1973 (from A6b, both hemispheres pooled).
%  Perturbation = realistic +1 sigma of each input in the same clusters (so the curves show the noise each
%  input really adds), plus a table of the sensitivity per unit.
%  Water: c_ice = 0, inputs V, W, L, Ts. Ice: c_ice = 1, inputs V, W, L, Ti (W and Ts have no effect at c = 1).
% Needs output/A6b_pixels.mat (run a6b_iterative.m first).
% Run from the project root:  matlab -batch "run('src/matlab/b1_sensitivity.m')"
% Outputs: output/B1_sensitivity.png, output/B1_sensitivity.csv
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile('src','matlab'));
S = load(fullfile('output', 'A6b_pixels.mat'), 'P');
P = S.P([S.P.day] ~= "0228");
inp  = {'V','W','L','Ts','Ti'};
unit = struct('V', 'kg/m^2', 'W', 'm/s', 'L', 'kg/m^2', 'Ts', 'K', 'Ti', 'K');
cols = struct('V', [0.00 0.45 0.74], 'W', [0.85 0.33 0.10], 'L', [0.47 0.67 0.19], 'Ts', [0.49 0.18 0.56], 'Ti', [0.64 0.08 0.18]);
th = 0:0.5:64;
cls = {'water', 'ice'}; cval = [0 1];
active = {{'V','W','L','Ts'}, {'V','L','Ti'}};

rows = {};
fig = figure('Visible','off','Position',[100 100 1500 560]);
tiledlayout(1, 2, 'TileSpacing', 'compact');
for t = 1:2
    s = P([P.cls] == t);
    for v = inp, X.(v{1}) = double(vertcat(s.(v{1}))); end
    X.Ts(isnan(X.Ts)) = 271.35;
    for v = inp, M.(v{1}) = mean(X.(v{1})); SD.(v{1}) = std(X.(v{1})); end
    base = esmr_rtm_vec(M.V, M.W, M.L, M.Ts, M.Ti, cval(t), th);
    nexttile; hold on;
    yline(0, 'k-', 'HandleVisibility', 'off');
    lg = {}; hl = []; ymax = 1; ymin = -1;
    for v = active{t}
        Q = M; Q.(v{1}) = M.(v{1}) + SD.(v{1});
        d1 = esmr_rtm_vec(Q.V, Q.W, Q.L, Q.Ts, Q.Ti, cval(t), th) - base;          % +1 sigma
        Q = M; Q.(v{1}) = M.(v{1}) + 1;
        du = esmr_rtm_vec(Q.V, Q.W, Q.L, Q.Ts, Q.Ti, cval(t), th) - base;          % +1 unit
        ls = '-'; note = ''; if strcmp(v{1}, 'L'), ls = '--'; note = ', not corrected'; end
        hl(end+1) = plot(th, d1, ls, 'LineWidth', 2, 'Color', cols.(v{1})); %#ok<SAGROW>
        ymax = max(ymax, max(d1)); ymin = min(ymin, min(d1));
        lg{end+1} = sprintf('%s +1\\sigma (%.2g %s%s)', v{1}, SD.(v{1}), unit.(v{1}), note); %#ok<SAGROW>
        for a = [0 30 50 55.5]
            [~, i] = min(abs(th - a));
            rows(end+1, :) = {cls{t}, v{1}, a, M.(v{1}), SD.(v{1}), du(i), d1(i)}; %#ok<SAGROW>
        end
    end
    xlabel('incidence angle \theta [deg]'); ylabel('\DeltaT_B for +1\sigma of one input [K]');
    title(sprintf('%s (c_{ice} = %d): T_B at mean weather %.0f K (nadir) to %.0f K (55.7°)', ...
        cls{t}, cval(t), base(1), base(th == 55.5)));
    yl = [ymin - 0.5, ymax * 1.15];
    patch([55.67 64 64 55.67], yl([1 1 2 2]), [0.92 0.92 0.92], 'EdgeColor', 'none', 'HandleVisibility', 'off');
    ch = get(gca, 'Children'); set(gca, 'Children', [ch(2:end); ch(1)]);   % patch to the back
    legend(hl, lg, 'Location', 'northwest'); grid on; box on; xlim([0 64]); ylim(yl);
    text(56.2, yl(2) - 0.05*diff(yl), {'removed', '(scan pos.', '1-4, 75-78)'}, 'FontSize', 8, 'Color', [0.4 0.4 0.4]);
    if t == 2, text(2, yl(1) + 0.08*diff(yl), 'W and T_s have no effect at c_{ice} = 1', 'FontSize', 9, 'Color', [0.4 0.4 0.4]); end
end
exportgraphics(fig, fullfile('output', 'B1_sensitivity.png'), 'Resolution', 150);
T = cell2table(rows, 'VariableNames', {'surface','input','theta','mean','sigma','dTB_per_unit','dTB_per_sigma'});
writetable(T, fullfile('output', 'B1_sensitivity.csv'));
fprintf('Sensitivity at theta = 0 / 30 / 50 deg   (dTB per unit | dTB per +1 sigma) [K]\n');
for t = 1:2
    for v = active{t}
        s = T(strcmp(T.surface, cls{t}) & strcmp(T.input, v{1}), :);
        fprintf('%-5s %-2s mean %7.2f sigma %5.2f | %6.2f %6.2f %6.2f | %6.2f %6.2f %6.2f\n', cls{t}, v{1}, s.mean(1), s.sigma(1), ...
            s.dTB_per_unit(1:3), s.dTB_per_sigma(1:3));
    end
end
fprintf('saved output/B1_sensitivity.png, output/B1_sensitivity.csv\n');
