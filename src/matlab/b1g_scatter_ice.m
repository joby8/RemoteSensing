% B1g: Task 2 with the real pixels, ICE side: SIC of the ice tie-point pixels vs. one ERA5 input
%  (style of Tonboe et al. 2022, Figs. 7/10: c_ice of 100 % ice vs. snow-ice interface temperature T_si).
%  Counterpart of b1f_scatter_ow.m (open water). Pixels: ice tie-point cluster (siconc > 0.8, A6b iteration 2),
%  1-27 Feb 1973. Columns: the inputs that act over ice (tornado: Ti, V, L); rows Arctic (top) / Antarctic (bottom).
%   - grey dots      = SIC without RTM correction (random subsample, all pixels are used for the lines)
%   - black line     = bin mean of the SIC without correction
%   - blue line      = bin mean of the SIC with RTM correction (ideal: flat at 100 %)
%   - orange dashed  = RTM prediction from this input alone: per pixel
%                      (RTM(x_pixel, others at cluster mean, theta_pixel, c_used) - RTM(all at mean, theta_pixel, c_used)) / contrast,
%                      bin mean, shifted to the mean of the uncorrected SIC (100 % by construction)
%                      c_used = c_ice of the pixel in that iteration (as in the correction itself)
%  Box: slope of a straight-line fit x 1 sigma of the input (Tonboe's "slope x one STD").
%  Caveats: Ti is not measured but Eq. 15 (0.4 t2m + 0.6 * 272 K), so "Ti" here is really air temperature;
%  the Antarctic ice cluster contains many low-c_ice pixels (Task 1), so its scatter is wide.
% Needs:  output/A6b_pixels.mat, output/A6b_iterative.csv (src/matlab/a6b_iterative.m)
% Run from the project root:  matlab -batch "run('src/matlab/b1g_scatter_ice.m')"
% Outputs: output/B1g_scatter_ice.png, output/B1g_scatter_ice.csv
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile('src','matlab'));
load(fullfile('output','A6b_pixels.mat'), 'P');
o = detectImportOptions(fullfile('output','A6b_iterative.csv'));
o = setvartype(o, {'day','hemi'}, 'string');
A = readtable(fullfile('output','A6b_iterative.csv'), o);
A = A(A.iter == 2 & A.day ~= "0228", :);

hemi = ["N","S"]; hn = ["Arctic","Antarctic"];
inp  = {'Ti','V','L'};
unit = {'K','kg/m^2','kg/m^2'};
name = {'ice temperature T_i (Eq. 15)','water vapour V','cloud liquid L (not corrected)'};
nb   = 30;                                     % bins over the 1-99 % range of x
NSUB = 15000;                                  % dots per panel
YL   = [40 160];                               % % SIC, same in every panel
cU = [0 0 0]; cC = [0 .45 .74]; cM = [0.93 0.55 0.10]; cD = [.72 .72 .72];
rs = RandStream('mt19937ar', 'Seed', 1);

fig = figure('Visible','off','Color','w','Position',[50 50 1500 900]);
tl = tiledlayout(2, numel(inp), 'TileSpacing','compact','Padding','compact');
rows = {};
for h = 1:2
    q = P([P.hemi] == hemi(h) & [P.cls] == 2 & [P.day] ~= "0228");
    X = struct();
    for v = {'V','W','L','Ts','Ti','th','sic_u','sic_c','c_used'}, X.(v{1}) = double(vertcat(q.(v{1}))); end
    X.Ts(isnan(X.Ts)) = 271.35;
    n = numel(X.sic_u);
    su = 100 * X.sic_u; sc = 100 * X.sic_c;
    M = struct('V', mean(X.V), 'W', mean(X.W), 'L', mean(X.L), 'Ts', mean(X.Ts), 'Ti', mean(X.Ti));
    contrast = mean(A.Tpi_c(A.hemi == hemi(h)) - A.Tpw_c(A.hemi == hemi(h)));
    tb0 = esmr_rtm_vec(M.V, M.W, M.L, M.Ts, M.Ti, X.c_used, X.th);
    sub = randperm(rs, n, min(NSUB, n));
    for k = 1:numel(inp)
        f = inp{k}; x = X.(f);
        Q = M; Q.(f) = x;
        sm = 100 * (esmr_rtm_vec(Q.V, Q.W, Q.L, Q.Ts, Q.Ti, X.c_used, X.th) - tb0) / contrast;
        sm = sm - mean(sm) + mean(su);
        nexttile; hold on; grid on; box on
        scatter(x(sub), su(sub), 3, cD, 'filled', 'MarkerFaceAlpha', .35, 'HandleVisibility','off');
        ed = linspace(prctile(x, 1), prctile(x, 99), nb + 1);
        bi = discretize(x, ed); ok = ~isnan(bi);
        cnt = accumarray(bi(ok), 1, [nb 1]);
        xc  = accumarray(bi(ok), x(ok),  [nb 1]) ./ cnt;
        mu_u = accumarray(bi(ok), su(ok), [nb 1]) ./ cnt;
        mu_c = accumarray(bi(ok), sc(ok), [nb 1]) ./ cnt;
        mu_m = accumarray(bi(ok), sm(ok), [nb 1]) ./ cnt;
        g = cnt >= 200;                                    % only bins with enough pixels
        plot(xc(g), mu_u(g), '-', 'Color', cU, 'LineWidth', 2, 'DisplayName', 'no RTM correction (bin mean)');
        plot(xc(g), mu_c(g), '-', 'Color', cC, 'LineWidth', 2.4, 'DisplayName', 'with RTM correction (bin mean)');
        plot(xc(g), mu_m(g), '--', 'Color', cM, 'LineWidth', 2, 'DisplayName', 'RTM, this input alone');
        yline(100, 'k:', 'HandleVisibility','off');
        sd = std(x);
        pu = polyfit(x, su, 1); pc = polyfit(x, sc, 1); pm = polyfit(x, sm, 1);
        cu_ = corrcoef(x, su); cc_ = corrcoef(x, sc); r_u = cu_(1,2); r_c = cc_(1,2);
        text(0.03, 0.97, {sprintf('slope \\times 1\\sigma (\\sigma = %.3g %s):', sd, unit{k}), ...
            sprintf('no corr.  %+.1f %%  (r = %.2f)', pu(1)*sd, r_u), ...
            sprintf('corrected %+.1f %%  (r = %.2f)', pc(1)*sd, r_c), ...
            sprintf('RTM alone %+.1f %%', pm(1)*sd)}, 'Units','normalized', ...
            'VerticalAlignment','top', 'FontSize', 9, 'BackgroundColor', [1 1 1 .85], 'EdgeColor', [.7 .7 .7]);
        rows(end+1,:) = {hemi(h), string(f), n, mean(x), sd, std(su), mean(X.c_used), pu(1), pc(1), pm(1), ...
            pu(1)*sd, pc(1)*sd, pm(1)*sd, r_u, r_c}; %#ok<SAGROW>
        xlim(prctile(x, [0.5 99.5])); ylim(YL);
        xlabel(sprintf('%s [%s]', name{k}, unit{k}));
        if k == 1, ylabel(sprintf('%s (%d pixels)\nice SIC [%%]', hn(h), n), 'FontWeight','bold'); end
        if h == 1 && k == numel(inp), legend('Location','southeast','FontSize',8); end
    end
end
title(tl, {'Task 2 with the real data, ice side: SIC of the ice tie-point pixels (siconc > 0.8) vs. one ERA5 input, 1-27 Feb 1973', ...
    'grey dots = SIC without correction (subsample); lines = bin means of all pixels; orange = RTM prediction from this input alone (pixel \theta and c_{ice}, others at the mean)', ...
    'Ideal after the correction: flat at 100 %. T_i is Eq. 15 (from 2 m air temperature), not measured. x range = 0.5-99.5 % of the pixels.'}, ...
    'FontWeight','bold');
exportgraphics(fig, fullfile('output','B1g_scatter_ice.png'), 'Resolution', 140);

T = cell2table(rows, 'VariableNames', {'hemi','input','n','x_mean','x_sigma','sic_std_u','c_used_mean', ...
    'slope_u','slope_c','slope_rtm','sig_u_pct','sig_c_pct','sig_rtm_pct','r_u','r_c'});
writetable(T, fullfile('output','B1g_scatter_ice.csv'));
disp(T)
fprintf('saved output/B1g_scatter_ice.png, output/B1g_scatter_ice.csv\n');
