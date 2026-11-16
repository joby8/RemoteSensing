% B1f: Task 2 with the real pixels: open-water SIC vs. one ERA5 input (style of Tonboe et al. 2022, Figs. 12/13).
%  Tonboe plots c_ice of SIMULATED open water against WV and CLW (one panel per algorithm, same y range).
%  Here: the real open-water tie-point pixels of 1-27 Feb 1973 (A6b, iteration 2), one panel per input
%  (V, W, L, Ts), rows Arctic (top) / Antarctic (bottom).
%   - grey dots      = SIC without RTM correction (random subsample, all pixels are used for the lines)
%   - black line     = bin mean of the SIC without correction
%   - blue line      = bin mean of the SIC with RTM correction (ideal: flat at 0)
%   - orange dashed  = what the RTM predicts from this input alone: for every pixel
%                      (RTM(x_pixel, others at cluster mean, theta_pixel, c = 0) - RTM(all at mean, theta_pixel)) / contrast,
%                      bin mean, shifted to mean 0 (same as the SIC, which has mean 0 by construction)
%  Box: slope of a straight-line fit x 1 sigma of the input (Tonboe's "slope x one STD"), for the three lines.
%  Caveat: in the real data V, L and W are correlated (and theta varies), so a data slope is not a clean
%  single-input sensitivity; the RTM line is.
% Needs:  output/A6b_pixels.mat, output/A6b_iterative.csv (src/matlab/a6b_iterative.m)
% Run from the project root:  matlab -batch "run('src/matlab/b1f_scatter_ow.m')"
% Outputs: output/B1f_scatter_ow.png, output/B1f_scatter_ow.csv
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile('src','matlab'));
load(fullfile('output','A6b_pixels.mat'), 'P');
o = detectImportOptions(fullfile('output','A6b_iterative.csv'));
o = setvartype(o, {'day','hemi'}, 'string');
A = readtable(fullfile('output','A6b_iterative.csv'), o);
A = A(A.iter == 2 & A.day ~= "0228", :);

hemi = ["N","S"]; hn = ["Arctic","Antarctic"];
inp  = {'V','W','L','Ts'};
unit = {'kg/m^2','m/s','kg/m^2','K'};
name = {'water vapour V','wind speed W','cloud liquid L (not corrected)','SST T_s'};
xr   = {[0 30], [0 22], [0 1], [278 285]};
nb   = 30;                                     % bins over the 1-99 % range of x
NSUB = 15000;                                  % dots per panel
YL   = [-40 60];                               % % SIC, same in every panel
cU = [0 0 0]; cC = [0 .45 .74]; cM = [0.93 0.55 0.10]; cD = [.72 .72 .72];
rs = RandStream('mt19937ar', 'Seed', 1);

fig = figure('Visible','off','Color','w','Position',[50 50 1900 900]);
tl = tiledlayout(2, numel(inp), 'TileSpacing','compact','Padding','compact');
rows = {};
for h = 1:2
    q = P([P.hemi] == hemi(h) & [P.cls] == 1 & [P.day] ~= "0228");
    X = struct();
    for v = [inp, {'th','sic_u','sic_c'}], X.(v{1}) = double(vertcat(q.(v{1}))); end
    X.Ti = double(vertcat(q.Ti));
    n = numel(X.sic_u);
    su = 100 * X.sic_u; sc = 100 * X.sic_c;
    M = struct('V', mean(X.V), 'W', mean(X.W), 'L', mean(X.L), 'Ts', mean(X.Ts), 'Ti', mean(X.Ti));
    contrast = mean(A.Tpi_c(A.hemi == hemi(h)) - A.Tpw_c(A.hemi == hemi(h)));
    tb0 = esmr_rtm_vec(M.V, M.W, M.L, M.Ts, M.Ti, 0, X.th);
    sub = randperm(rs, n, min(NSUB, n));
    for k = 1:numel(inp)
        f = inp{k}; x = X.(f);
        Q = M; Q.(f) = x;
        sm = 100 * (esmr_rtm_vec(Q.V, Q.W, Q.L, Q.Ts, Q.Ti, 0, X.th) - tb0) / contrast;
        sm = sm - mean(sm);
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
        yline(0, 'k:', 'HandleVisibility','off');
        sd = std(x);
        pu = polyfit(x, su, 1); pc = polyfit(x, sc, 1); pm = polyfit(x, sm, 1);
        cu_ = corrcoef(x, su); cc_ = corrcoef(x, sc); r_u = cu_(1,2); r_c = cc_(1,2);
        text(0.03, 0.97, {sprintf('slope \\times 1\\sigma (\\sigma = %.3g %s):', sd, unit{k}), ...
            sprintf('no corr.  %+.1f %%  (r = %.2f)', pu(1)*sd, r_u), ...
            sprintf('corrected %+.1f %%  (r = %.2f)', pc(1)*sd, r_c), ...
            sprintf('RTM alone %+.1f %%', pm(1)*sd)}, 'Units','normalized', ...
            'VerticalAlignment','top', 'FontSize', 9, 'BackgroundColor', [1 1 1 .85], 'EdgeColor', [.7 .7 .7]);
        rows(end+1,:) = {hemi(h), string(f), n, mean(x), sd, pu(1), pc(1), pm(1), ...
            pu(1)*sd, pc(1)*sd, pm(1)*sd, r_u, r_c}; %#ok<SAGROW>
        xlim(xr{k}); ylim(YL);
        xlabel(sprintf('%s [%s]', name{k}, unit{k}));
        if k == 1, ylabel(sprintf('%s (%d pixels)\nopen-water SIC [%%]', hn(h), n), 'FontWeight','bold'); end
        if h == 1 && k == numel(inp), legend('Location','northeast','FontSize',8); end
    end
end
title(tl, {'Task 2 with the real data: SIC of the open-water tie-point pixels vs. one ERA5 input, 1-27 Feb 1973', ...
    'grey dots = SIC without correction (subsample); lines = bin means of all pixels; orange = RTM prediction from this input alone (pixel \theta, others at the mean)', ...
    'Ideal after the correction: flat at 0. L is not corrected (Kolbe et al. 2024), so its slope remains. Data slopes mix correlated inputs.'}, ...
    'FontWeight','bold');
exportgraphics(fig, fullfile('output','B1f_scatter_ow.png'), 'Resolution', 140);

T = cell2table(rows, 'VariableNames', {'hemi','input','n','x_mean','x_sigma', ...
    'slope_u','slope_c','slope_rtm','sig_u_pct','sig_c_pct','sig_rtm_pct','r_u','r_c'});
writetable(T, fullfile('output','B1f_scatter_ow.csv'));
disp(T)
fprintf('saved output/B1f_scatter_ow.png, output/B1f_scatter_ow.csv\n');
