% B1d: Task 2 sweep (Tonboe: "sweep over different wind speeds etc.").
%  One ERA5 input is swept over its full physical range, all other inputs stay at the
%  Feb 1973 mean of the tie-point cluster (A6b, 1-27 Feb). Shown: dTB = TB(x) - TB(mean state),
%  water (c = 0, solid) and ice (c = 1, dashed) at theta = 0, 30, 50 deg.
%  White band = range observed in the tie-point pixels (5-95 %), grey = outside it, vertical line = mean.
%  L = 0 in the V, W, Ts, Ti sweeps (Tonboe 2026-11-17), so L does not influence the other inputs.
%  Right axis: the same dTB in % SIC (divided by the ice-water contrast of that hemisphere).
%  Rows: Arctic (top), Antarctic (bottom). Columns: V, W, L, Ts, Ti.
% Needs:  output/A6b_pixels.mat, output/A6b_iterative.csv (src/matlab/a6b_iterative.m)
% Run from the project root:  matlab -batch "run('src/matlab/b1d_sweep.m')"
% Outputs: output/B1d_sweep.png, output/B1d_sweep.csv (dTB between the observed 5 % and 95 % values of
%          each surface's pixels, theta = 50 deg)
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile('src','matlab'));
load(fullfile('output','A6b_pixels.mat'), 'P');
o = detectImportOptions(fullfile('output','A6b_iterative.csv'));
o = setvartype(o, {'day','hemi'}, 'string');
A = readtable(fullfile('output','A6b_iterative.csv'), o);
A = A(A.iter == 2 & A.day ~= "0228", :);

hemi = ["N","S"]; hn = ["Arctic","Antarctic"];
inp  = {'V','W','L','Ts','Ti'};
unit = {'kg/m^2','m/s','kg/m^2','K','K'};
name = {'water vapour V','wind speed W','cloud liquid L (not corrected)','SST T_s','ice temperature T_i'};
rng  = {linspace(0,30,121), linspace(0,25,101), linspace(0,1,101), linspace(271,290,96), linspace(240,273,100)};
cols = struct('V', [0.00 0.45 0.74], 'W', [0.85 0.33 0.10], 'L', [0.47 0.67 0.19], 'Ts', [0.49 0.18 0.56], 'Ti', [0.64 0.08 0.18]);
ths  = [0 30 50];
surf = ["water","ice"];
shade = [0.45 0.72 1.00];                     % lighter -> darker with theta

fig = figure('Visible','off','Color','w','Position',[50 50 2000 850]);
tl = tiledlayout(2, numel(inp), 'TileSpacing','compact','Padding','compact');
rows = {};
for h = 1:2
    sel = [P.hemi] == hemi(h) & [P.day] ~= "0228";
    W_ = pool(P(sel & [P.cls] == 1)); I_ = pool(P(sel & [P.cls] == 2));
    I_.Ts(isnan(I_.Ts)) = 271.35;
    base = {means(W_), means(I_)};             % water, ice base states
    contrast = mean(A.Tpi_c(A.hemi == hemi(h)) - A.Tpw_c(A.hemi == hemi(h)));
    for k = 1:numel(inp)
        f = inp{k}; x = rng{k};
        nexttile; hold on; grid on; box on
        % observed range: water pixels, for Ti the ice pixels
        if strcmp(f,'Ti'), obs = I_.(f); else, obs = W_.(f); end
        q = prctile(obs, [5 95]); mu = mean(obs);
        ylim([-30 30]);                        % fixed first, so the band covers the panel
        % observed 5-95 % range stays WHITE, outside it GREY (Tonboe 2026-11-17: inverse shading)
        ga = [x(1) min(max(q(1), x(1)), x(end))]; gb = [max(min(q(2), x(end)), x(1)) x(end)];
        for g = {ga, gb}
            g = g{1}; if diff(g) > 0
                patch([g(1) g(2) g(2) g(1)], [-1e3 -1e3 1e3 1e3], [.88 .88 .88], 'EdgeColor','none', 'HandleVisibility','off');
            end
        end
        xline(mu, '-', 'Color', [.4 .4 .4], 'HandleVisibility','off');
        yline(0, 'k:', 'HandleVisibility','off');
        for t = 1:2                            % 1 water, 2 ice
            b = base{t}; cice = t - 1;
            if ~strcmp(f, 'L'), b.L = 0; end   % L = 0 in the other sweeps (Tonboe 2026-11-17): no influence from L
            for j = 1:numel(ths)
                X = b; X.(f) = x;
                tb  = esmr_rtm_vec(X.V, X.W, X.L, X.Ts, X.Ti, cice, ths(j));
                tb0 = esmr_rtm_vec(b.V, b.W, b.L, b.Ts, b.Ti, cice, ths(j));
                cc = cols.(f) * shade(j) + [1 1 1] * (1 - shade(j));
                ls = '-'; if t == 2, ls = '--'; end
                plot(x, tb - tb0, ls, 'Color', cc, 'LineWidth', 1 + 0.6*j, ...
                    'DisplayName', sprintf('%s, \\theta = %d°', surf(t), ths(j)));
                if ths(j) == 50                % table: observed range of THIS surface's pixels
                    if t == 1, o_ = W_.(f); else, o_ = I_.(f); end
                    qt = prctile(o_, [5 95]); mt = mean(o_, 'omitnan');
                    v = interp1(x, tb - tb0, qt, 'linear', 'extrap');
                    rows(end+1,:) = {hemi(h), string(f), surf(t), qt(1), qt(2), mt, ...
                        v(1), v(2), v(2) - v(1), 100*(v(2) - v(1))/contrast}; %#ok<SAGROW>
                end
            end
        end
        xlim([x(1) x(end)]);
        xlabel(sprintf('%s [%s]', name{k}, unit{k}));
        if k == 1, ylabel(sprintf('%s\n\\DeltaT_B vs. mean state [K]', hn(h)), 'FontWeight','bold'); end
        yyaxis right
        ylim([-30 30] / contrast * 100);
        set(gca, 'YColor', [.35 .35 .35]);
        if k == numel(inp), ylabel(sprintf('[%% SIC]  (1 %% = %.2f K)', contrast/100)); end
        yyaxis left
        set(gca, 'YColor', 'k');
        if h == 1 && k == 1
            legend('Location','northwest','FontSize',8);
        end
    end
end
title(tl, {'Task 2: RTM sweep - one ERA5 input over its full range, all others at the Feb 1973 mean of the tie-point cluster', ...
    'solid = water (c = 0), dashed = ice (c = 1); light -> dark = \theta 0°, 30°, 50°; each curve is 0 at the mean of its own cluster; L = 0 in the V, W, T_s, T_i sweeps (L sweep: others at the mean)', 'white band / grey line = observed 5-95 % range (grey = outside) / mean of the water pixels (T_i: ice pixels)'}, ...
    'FontWeight','bold');
exportgraphics(fig, fullfile('output','B1d_sweep.png'), 'Resolution', 140);

T = cell2table(rows, 'VariableNames', {'hemi','input','surface','x_p5','x_p95','x_mean', ...
    'dTB_at_p5','dTB_at_p95','dTB_range_K','dTB_range_pct_SIC'});
writetable(T, fullfile('output','B1d_sweep.csv'));
disp(T(abs(T.dTB_range_K) > 0.05, :))
fprintf('saved output/B1d_sweep.png, output/B1d_sweep.csv\n');

% ---------------------------------------------------------------------------
function s = pool(p)
f = {'V','W','L','Ts','Ti'};
for k = 1:numel(f), s.(f{k}) = double(vertcat(p.(f{k}))); end
end

function M = means(s)
M = struct('V', mean(s.V), 'W', mean(s.W), 'L', mean(s.L), 'Ts', mean(s.Ts,'omitnan'), 'Ti', mean(s.Ti));
end
