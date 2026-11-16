% B1e: Task 2 sweep in % SIC (alternative to b1d_sweep.m, style of Tonboe et al. 2022, Figs. 12/13).
%  Same model runs as b1d: one ERA5 input swept over its physical range, all others at the Feb 1973 mean
%  of the tie-point cluster (A6b, 1-27 Feb), water (c = 0, solid) and ice (c = 1, dashed), theta = 0/30/50 deg.
%  Changes vs. b1d (Tonboe style):
%   1. main y axis = Delta SIC [%] (Delta T_B / ice-water contrast of that hemisphere), same range in every
%      panel, so Arctic and Antarctic compare directly; K on the right axis (scale differs per hemisphere)
%   2. +-1 sigma of the observed pixels marked on the x axis (dotted lines), and the "sensitivity x 1 sigma"
%      at theta = 50 deg printed in each panel (Tonboe: "slope x one STD"; same measure as the tornado chart:
%      half of dTB(mean+sigma) - dTB(mean-sigma), V/W/L not below 0)
% Needs:  output/A6b_pixels.mat, output/A6b_iterative.csv (src/matlab/a6b_iterative.m)
% Run from the project root:  matlab -batch "run('src/matlab/b1e_sweep_sic.m')"
% Outputs: output/B1e_sweep_sic.png, output/B1e_sweep_sic.csv (+-1 sigma in % SIC per hemisphere/input/surface/theta)
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
YL = [-45 45];                                % % SIC, same in every panel

fig = figure('Visible','off','Color','w','Position',[50 50 2000 850]);
tl = tiledlayout(2, numel(inp), 'TileSpacing','compact','Padding','compact');
rows = {};
for h = 1:2
    sel = [P.hemi] == hemi(h) & [P.day] ~= "0228";
    W_ = pool(P(sel & [P.cls] == 1)); I_ = pool(P(sel & [P.cls] == 2));
    I_.Ts(isnan(I_.Ts)) = 271.35;
    obsS = {W_, I_};
    base = {means(W_), means(I_)};
    contrast = mean(A.Tpi_c(A.hemi == hemi(h)) - A.Tpw_c(A.hemi == hemi(h)));
    k2s = 100 / contrast;                     % K -> % SIC
    for k = 1:numel(inp)
        f = inp{k}; x = rng{k};
        nexttile; hold on; grid on; box on
        if strcmp(f,'Ti'), obs = I_.(f); else, obs = W_.(f); end
        q = prctile(obs, [5 95]); mu = mean(obs); sd = std(obs);
        ylim(YL);
        patch([q(1) q(2) q(2) q(1)], [-1e3 -1e3 1e3 1e3], [.90 .90 .90], 'EdgeColor','none', 'HandleVisibility','off');
        xline(mu, '-', 'Color', [.4 .4 .4], 'HandleVisibility','off');
        xline(max(mu - sd, x(1)), ':', 'Color', [.25 .25 .25], 'LineWidth', 1.2, 'HandleVisibility','off');
        xline(mu + sd, ':', 'Color', [.25 .25 .25], 'LineWidth', 1.2, 'HandleVisibility','off');
        yline(0, 'k:', 'HandleVisibility','off');
        txt = strings(0);
        for t = 1:2
            b = base{t}; cice = t - 1;
            o_ = obsS{t}.(f); m_ = mean(o_, 'omitnan'); s_ = std(o_, 'omitnan');
            for j = 1:numel(ths)
                X = b; X.(f) = x;
                tb  = esmr_rtm_vec(X.V, X.W, X.L, X.Ts, X.Ti, cice, ths(j));
                tb0 = esmr_rtm_vec(b.V, b.W, b.L, b.Ts, b.Ti, cice, ths(j));
                cc = cols.(f) * shade(j) + [1 1 1] * (1 - shade(j));
                ls = '-'; if t == 2, ls = '--'; end
                plot(x, (tb - tb0) * k2s, ls, 'Color', cc, 'LineWidth', 1 + 0.6*j, ...
                    'DisplayName', sprintf('%s, \\theta = %d°', surf(t), ths(j)));
                % sensitivity x 1 sigma of THIS surface's pixels (as in the tornado chart)
                lo = b; lo.(f) = m_ - s_; if any(strcmp(f, {'V','W','L'})), lo.(f) = max(lo.(f), 0); end
                hi = b; hi.(f) = m_ + s_;
                dlo = esmr_rtm_vec(lo.V, lo.W, lo.L, lo.Ts, lo.Ti, cice, ths(j)) - tb0;
                dhi = esmr_rtm_vec(hi.V, hi.W, hi.L, hi.Ts, hi.Ti, cice, ths(j)) - tb0;
                one = (dhi - dlo) / 2;
                rows(end+1,:) = {hemi(h), string(f), surf(t), ths(j), m_, s_, one, one * k2s}; %#ok<SAGROW>
                if ths(j) == 50 && abs(one * k2s) >= 0.05
                    txt(end+1) = sprintf('%s: %+.1f %%', surf(t), one * k2s); %#ok<SAGROW>
                end
            end
        end
        if isempty(txt), txt = "both: < 0.1 %"; end
        text(0.97, 0.04, ["1\sigma at \theta = 50°:"; txt(:)], 'Units','normalized', ...
            'HorizontalAlignment','right', 'VerticalAlignment','bottom', 'FontSize', 9, ...
            'BackgroundColor', [1 1 1 .85], 'EdgeColor', [.7 .7 .7]);
        xlim([x(1) x(end)]);
        xlabel(sprintf('%s [%s]', name{k}, unit{k}));
        if k == 1, ylabel(sprintf('%s\n\\DeltaSIC vs. mean state [%%]', hn(h)), 'FontWeight','bold'); end
        yyaxis right
        ylim(YL / k2s);
        set(gca, 'YColor', [.35 .35 .35]);
        if k == numel(inp), ylabel(sprintf('\\DeltaT_B [K]  (1 %% SIC = %.2f K)', contrast/100)); end
        yyaxis left
        set(gca, 'YColor', 'k');
        if h == 1 && k == 1
            legend('Location','northwest','FontSize',8);
        end
    end
end
title(tl, {'Task 2: RTM sweep in % SIC - one ERA5 input over its full range, all others at the Feb 1973 mean of the tie-point cluster', ...
    'solid = water (c = 0), dashed = ice (c = 1); light -> dark = \theta 0°, 30°, 50°; each curve is 0 at the mean of its own cluster', ...
    'grey band / grey line / dotted lines = observed 5-95 % range / mean / \pm1\sigma of the water pixels (T_i: ice pixels); box = SIC change per 1\sigma of that surface''s pixels'}, ...
    'FontWeight','bold');
exportgraphics(fig, fullfile('output','B1e_sweep_sic.png'), 'Resolution', 140);

T = cell2table(rows, 'VariableNames', {'hemi','input','surface','theta','x_mean','x_sigma','dTB_1sigma_K','dSIC_1sigma_pct'});
writetable(T, fullfile('output','B1e_sweep_sic.csv'));
disp(T(T.theta == 50 & abs(T.dSIC_1sigma_pct) >= 0.05, :))
fprintf('saved output/B1e_sweep_sic.png, output/B1e_sweep_sic.csv\n');

% ---------------------------------------------------------------------------
function s = pool(p)
f = {'V','W','L','Ts','Ti'};
for k = 1:numel(f), s.(f{k}) = double(vertcat(p.(f{k}))); end
end

function M = means(s)
M = struct('V', mean(s.V), 'W', mean(s.W), 'L', mean(s.L), 'Ts', mean(s.Ts,'omitnan'), 'Ti', mean(s.Ti));
end
