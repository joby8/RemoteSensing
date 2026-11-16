% B1h: Task 2 with the real pixels, ALL five ERA5 inputs for water AND ice (complete version of b1f/b1g).
%  Two figures, each 2 x 5 panels: rows Arctic (top) / Antarctic (bottom), columns V, W, L, Ts, Ti.
%   output/B1h_scatter_water.png : open-water tie-point pixels (ideal SIC = 0 %)
%   output/B1h_scatter_ice.png   : ice tie-point pixels, siconc > 0.8 (ideal SIC = 100 %)
%  Inputs without an effect on that surface are shown on purpose (e.g. Ti over water, W over ice): the RTM
%  line is then flat, and any slope in the data comes from correlation with other inputs.
%  Lines as in b1f/b1g:
%   - grey dots      = SIC without RTM correction (random subsample, all pixels are used for the lines)
%   - black line     = bin mean of the SIC without correction
%   - blue line      = bin mean of the SIC with RTM correction
%   - orange dashed  = RTM prediction from this input alone: per pixel
%                      (RTM(x_pixel, others at cluster mean, theta_pixel, c) - RTM(all at mean, theta_pixel, c)) / contrast,
%                      bin mean, shifted to the mean of the uncorrected SIC; c = 0 for water, c_used for ice
%  Box: slope of a straight-line fit x 1 sigma of the input (Tonboe et al. 2022: "slope x one STD").
%  ERA5 SST under ice is constant at the freezing point (> 95 % of the pixels within 0.1 K) -> no fit, a note instead.
% Needs:  output/A6b_pixels.mat, output/A6b_iterative.csv (src/matlab/a6b_iterative.m)
% Run from the project root:  matlab -batch "run('src/matlab/b1h_scatter_all.m')"
% Outputs: output/B1h_scatter_water.png, output/B1h_scatter_ice.png, output/B1h_scatter_all.csv
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
name = {'water vapour V','wind speed W','cloud liquid L (not corrected)','SST T_s','ice temperature T_i (Eq. 15)'};
surfN = ["water","ice"]; fileN = ["B1h_scatter_water","B1h_scatter_ice"];
YLs  = {[-40 60], [40 160]}; ideal = [0 100];
nb   = 30; NSUB = 15000;
cU = [0 0 0]; cC = [0 .45 .74]; cM = [0.93 0.55 0.10]; cD = [.72 .72 .72];

rows = {};
for t = 1:2
    rs = RandStream('mt19937ar', 'Seed', 1);
    fig = figure('Visible','off','Color','w','Position',[50 50 2300 900]);
    tl = tiledlayout(2, numel(inp), 'TileSpacing','compact','Padding','compact');
    for h = 1:2
        q = P([P.hemi] == hemi(h) & [P.cls] == t & [P.day] ~= "0228");
        X = struct();
        for v = {'V','W','L','Ts','Ti','th','sic_u','sic_c','c_used'}, X.(v{1}) = double(vertcat(q.(v{1}))); end
        X.Ts(isnan(X.Ts)) = 271.35;
        if t == 1, c = zeros(size(X.th)); else, c = X.c_used; end
        n = numel(X.sic_u);
        su = 100 * X.sic_u; sc = 100 * X.sic_c;
        M = struct('V', mean(X.V), 'W', mean(X.W), 'L', mean(X.L), 'Ts', mean(X.Ts), 'Ti', mean(X.Ti));
        contrast = mean(A.Tpi_c(A.hemi == hemi(h)) - A.Tpw_c(A.hemi == hemi(h)));
        tb0 = esmr_rtm_vec(M.V, M.W, M.L, M.Ts, M.Ti, c, X.th);
        sub = randperm(rs, n, min(NSUB, n));
        for k = 1:numel(inp)
            f = inp{k}; x = X.(f); sd = std(x);
            nexttile; hold on; grid on; box on
            ylim(YLs{t}); yline(ideal(t), 'k:', 'HandleVisibility','off');
            xlabel(sprintf('%s [%s]', name{k}, unit{k}));
            if k == 1
                ylabel(sprintf('%s (%d pixels)\n%s SIC [%%]', hn(h), n, surfN(t)), 'FontWeight','bold');
            end
            fc = mean(abs(x - median(x)) < 0.1);                % ERA5 SST under ice: constant (freezing point)
            if fc > 0.95
                scatter(x(sub), su(sub), 3, cD, 'filled', 'MarkerFaceAlpha', .35, 'HandleVisibility','off');
                xlim(median(x) + [-1 1]);
                text(0.5, 0.92, {sprintf('ERA5 %s is constant here', f), sprintf('(%.0f %% of the pixels at %.2f K):', 100*fc, median(x)), 'no variation, so no effect can be seen'}, ...
                    'Units','normalized', 'HorizontalAlignment','center', 'VerticalAlignment','top', 'FontSize', 9, ...
                    'BackgroundColor', [1 1 1 .85], 'EdgeColor', [.7 .7 .7]);
                rows(end+1,:) = {surfN(t), hemi(h), string(f), n, mean(x), sd, NaN, NaN, NaN, NaN, NaN}; %#ok<SAGROW>
                continue
            end
            Q = M; Q.(f) = x;
            sm = 100 * (esmr_rtm_vec(Q.V, Q.W, Q.L, Q.Ts, Q.Ti, c, X.th) - tb0) / contrast;
            sm = sm - mean(sm) + mean(su);
            scatter(x(sub), su(sub), 3, cD, 'filled', 'MarkerFaceAlpha', .35, 'HandleVisibility','off');
            ed = linspace(prctile(x, 1), prctile(x, 99), nb + 1);
            bi = discretize(x, ed); ok = ~isnan(bi);
            cnt = accumarray(bi(ok), 1, [nb 1]);
            xc   = accumarray(bi(ok), x(ok),  [nb 1]) ./ cnt;
            mu_u = accumarray(bi(ok), su(ok), [nb 1]) ./ cnt;
            mu_c = accumarray(bi(ok), sc(ok), [nb 1]) ./ cnt;
            mu_m = accumarray(bi(ok), sm(ok), [nb 1]) ./ cnt;
            g = cnt >= 200;
            plot(xc(g), mu_u(g), '-', 'Color', cU, 'LineWidth', 2, 'DisplayName', 'no RTM correction (bin mean)');
            plot(xc(g), mu_c(g), '-', 'Color', cC, 'LineWidth', 2.4, 'DisplayName', 'with RTM correction (bin mean)');
            plot(xc(g), mu_m(g), '--', 'Color', cM, 'LineWidth', 2, 'DisplayName', 'RTM, this input alone');
            pu = polyfit(x, su, 1); pc = polyfit(x, sc, 1); pm = polyfit(x, sm, 1);
            cu_ = corrcoef(x, su); cc_ = corrcoef(x, sc);
            text(0.03, 0.97, {sprintf('slope \\times 1\\sigma (\\sigma = %.3g %s):', sd, unit{k}), ...
                sprintf('no corr.  %+.1f %%  (r = %.2f)', pu(1)*sd, cu_(1,2)), ...
                sprintf('corrected %+.1f %%  (r = %.2f)', pc(1)*sd, cc_(1,2)), ...
                sprintf('RTM alone %+.1f %%', pm(1)*sd)}, 'Units','normalized', ...
                'VerticalAlignment','top', 'FontSize', 8.5, 'BackgroundColor', [1 1 1 .85], 'EdgeColor', [.7 .7 .7]);
            rows(end+1,:) = {surfN(t), hemi(h), string(f), n, mean(x), sd, pu(1)*sd, pc(1)*sd, pm(1)*sd, cu_(1,2), cc_(1,2)}; %#ok<SAGROW>
            xlim(prctile(x, [0.5 99.5]));
            if h == 1 && k == numel(inp), legend('Location','southeast','FontSize',8); end
        end
    end
    if t == 1
        l2 = 'Open-water tie-point pixels (siconc = 0, SST > 278 K). Ideal after the correction: flat at 0 %.';
    else
        l2 = 'Ice tie-point pixels (siconc > 0.8). Ideal after the correction: flat at 100 %. RTM line uses the pixel''s c_{ice}.';
    end
    title(tl, {sprintf('Task 2 with the real data: %s SIC vs. each ERA5 input, 1-27 Feb 1973', surfN(t)), l2, ...
        'grey dots = SIC without correction (subsample); lines = bin means of all pixels; orange = RTM prediction from this input alone (others at the mean). Flat orange = no effect in the model.'}, ...
        'FontWeight','bold');
    exportgraphics(fig, fullfile('output', fileN(t) + ".png"), 'Resolution', 130);
end

T = cell2table(rows, 'VariableNames', {'surface','hemi','input','n','x_mean','x_sigma', ...
    'sig_u_pct','sig_c_pct','sig_rtm_pct','r_u','r_c'});
writetable(T, fullfile('output','B1h_scatter_all.csv'));
disp(T)
fprintf('saved output/B1h_scatter_water.png, output/B1h_scatter_ice.png, output/B1h_scatter_all.csv\n');
