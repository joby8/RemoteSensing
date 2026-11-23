% B1i: L study (Task 2, Tonboe meeting 2026-11-17): should the cloud liquid water L be corrected?
%  Same method as a6b_iterative.m (tie points per day and hemisphere, masks from tp_masks.m,
%  reference values mixed by c_ice), two variants for the 2nd iteration:
%   (b) "mean L"      : iteration 1 and 2 with the mixed mean L in both RTM runs (= A6b method, L not corrected)
%   (a) "per-pixel L" : iteration 1 with mean L, iteration 2 with the pixel's own L (tcw - tcwv) in the
%                       "actual" RTM run (reference keeps the mixed mean L) -> L is corrected
%  Both variants start iteration 2 from the same c_ice (result of iteration 1).
%  Expectation (Tonboe): (b) better, per-pixel L over-corrects (ERA5 L is too uncertain).
% Run from the project root:  matlab -batch "run('src/matlab/b1i_L_study.m')"
% Outputs: output/B1i_L_study.csv (per day and hemisphere), output/B1i_L_study.png
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile('src','matlab'));
files = dir(fullfile('ESMR_colocated_filtered','*.nc'));
fday  = string(regexp({files.name}, '1973m(\d{4})t', 'tokens', 'once'));
days  = unique(fday);
vars = {'tb','th','V','W','L','Ts','Ti','ci'};
hemi = ["N","S"];

rows = {};
H = struct('su', {[], []}, 'sb', {[], []}, 'sa', {[], []}, 'L', {[], []}, ...
           'iu', {[], []}, 'ib', {[], []}, 'ia', {[], []}, 'iL', {[], []});   % per hemisphere, pixels of 1-27 Feb
for d = days(:)'
    fi = find(fday == d);
    G = repmat({struct()}, 2, 2);
    for h = 1:2, for t = 1:2, for v = vars, G{h, t}.(v{1}) = []; end, end, end
    for k = fi
        fn = fullfile(files(k).folder, files(k).name);
        o = load_orbit(fn);
        o.L = double(ncread(fn, 'tcw'))' - o.V;
        o.th = o.theta; o.tb = o.tb_f; o.ci = o.siconc;
        [mw_, mi_] = tp_masks(o, o.valid, o.tb, o.lsm);   % o.valid: preprocessing (preproc_config.m)
        m = {mw_, mi_};
        for h = 1:2
            hs = (o.lat > 0) == (h == 1);
            for t = 1:2, for v = vars, G{h, t}.(v{1}) = [G{h, t}.(v{1}); o.(v{1})(m{t} & hs)]; end, end
        end
    end
    for h = 1:2
        w = G{h, 1}; c = G{h, 2};
        c.Ts(isnan(c.Ts)) = 271.35;
        Mw = means(w); Mi = means(c);
        tpw = mean(w.tb); tpi = mean(c.tb);
        su_w = (w.tb - tpw) / (tpi - tpw); su_i = (c.tb - tpw) / (tpi - tpw);
        % iteration 1: mean L, c_ice from ERA5
        dw = correction(w, w.ci, Mw, Mi, false); dc = correction(c, c.ci, Mw, Mi, false);
        [sw1, si1] = sic(w.tb + dw, c.tb + dc);
        cw = clipc(sw1); cc = clipc(si1);
        % iteration 2, variant b (mean L) and variant a (per-pixel L)
        dwb = correction(w, cw, Mw, Mi, false); dcb = correction(c, cc, Mw, Mi, false);
        dwa = correction(w, cw, Mw, Mi, true);  dca = correction(c, cc, Mw, Mi, true);
        [swb, sib] = sic(w.tb + dwb, c.tb + dcb);
        [swa, sia] = sic(w.tb + dwa, c.tb + dca);
        rows(end+1, :) = {d, hemi(h), numel(w.tb), numel(c.tb), mean(w.L), std(w.L), ...
            100*std(su_w), 100*std(swb), 100*std(swa), 100*mean(swb), 100*mean(swa), ...
            100*std(su_i), 100*std(sib), 100*std(sia), 100*mean(sib), 100*mean(sia)}; %#ok<SAGROW>
        if d ~= "0228"
            H(h).su = [H(h).su; single(su_w)]; H(h).sb = [H(h).sb; single(swb)]; H(h).sa = [H(h).sa; single(swa)];
            H(h).L  = [H(h).L;  single(w.L)];
            H(h).iu = [H(h).iu; single(su_i)]; H(h).ib = [H(h).ib; single(sib)]; H(h).ia = [H(h).ia; single(sia)];
            H(h).iL = [H(h).iL; single(c.L)];
        end
    end
    fprintf('%s done (%d orbits)\n', d, numel(fi));
end

T = cell2table(rows, 'VariableNames', {'day','hemi','n_water','n_ice','w_L_mean','w_L_std', ...
    'w_std_u','w_std_meanL','w_std_pixL','w_mean_meanL','w_mean_pixL', ...
    'i_std_u','i_std_meanL','i_std_pixL','i_mean_meanL','i_mean_pixL'});
if ~exist('output', 'dir'), mkdir('output'); end
writetable(T, fullfile('output', 'B1i_L_study.csv'));
ok = T.day ~= "0228";
fprintf('\nMonthly mean of the daily values, 1-27 Feb 1973 (iteration 2). SIC in %%.\n');
fprintf('%-4s | %-40s | %-40s\n', 'hemi', 'water std: uncorr / mean L / per-pixel L', 'ice std: uncorr / mean L / per-pixel L');
for hh = hemi
    s = T(T.hemi == hh & ok, :);
    fprintf('%-4s | %7.2f / %7.2f / %7.2f  (mean %5.2f / %5.2f) | %7.2f / %7.2f / %7.2f  (mean %6.2f / %6.2f)\n', hh, ...
        mean(s.w_std_u), mean(s.w_std_meanL), mean(s.w_std_pixL), mean(s.w_mean_meanL), mean(s.w_mean_pixL), ...
        mean(s.i_std_u), mean(s.i_std_meanL), mean(s.i_std_pixL), mean(s.i_mean_meanL), mean(s.i_mean_pixL));
    fprintf('     days mean L better: water %d of %d, ice %d of %d\n', nnz(s.w_std_meanL < s.w_std_pixL), height(s), ...
        nnz(s.i_std_meanL < s.i_std_pixL), height(s));
end

% ---------------------------------------------------------------- figure
cU = [0.45 0.45 0.45]; cB = [0.00 0.45 0.74]; cA = [0.85 0.33 0.10];
fig = figure('Visible','off','Color','w','Position',[100 100 1500 820]);
tl = tiledlayout(2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
hname = ["Arctic", "Antarctic"];
for h = 1:2
    s = T(T.hemi == hemi(h) & ok, :);
    dn = str2double(extractAfter(string(s.day), 2));
    % (1) daily std of open-water SIC
    ax = nexttile; hold(ax, 'on'); box on; grid on;
    plot(dn, s.w_std_u, '-o', 'Color', cU, 'MarkerFaceColor', cU, 'MarkerSize', 4, 'LineWidth', 1.2);
    plot(dn, s.w_std_meanL, '-o', 'Color', cB, 'MarkerFaceColor', cB, 'MarkerSize', 4, 'LineWidth', 1.6);
    plot(dn, s.w_std_pixL, '-o', 'Color', cA, 'MarkerFaceColor', cA, 'MarkerSize', 4, 'LineWidth', 1.6);
    xlim([0.5 27.5]); xlabel('day of February 1973'); ylabel('std of open-water SIC [%]');
    title(sprintf('%s: open-water noise per day', hname(h)), 'FontWeight', 'normal');
    legend({sprintf('uncorrected (%.1f %%)', mean(s.w_std_u)), sprintf('mean L (%.1f %%)', mean(s.w_std_meanL)), ...
            sprintf('per-pixel L (%.1f %%)', mean(s.w_std_pixL))}, 'Location', 'northwest', 'Box', 'off');
    yl = ylim; ylim([0 yl(2) * 1.25]);
    % (2) histogram of open-water SIC
    ax = nexttile; hold(ax, 'on'); box on; grid on;
    e = -40:1:60;
    histogram(100*H(h).su, e, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', cU, 'LineWidth', 1.2);
    histogram(100*H(h).sb, e, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', cB, 'LineWidth', 1.6);
    histogram(100*H(h).sa, e, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', cA, 'LineWidth', 1.6);
    xline(0, ':k');
    xlabel('open-water SIC [%]'); ylabel('probability density [1/%]');
    title(sprintf('%s: SIC of all open-water tie-point pixels', hname(h)), 'FontWeight', 'normal');
    legend({'uncorrected', 'mean L', 'per-pixel L'}, 'Location', 'northeast', 'Box', 'off');
    xlim([-40 60]);
    % (3) SIC per L bin: per-pixel L over-corrects cloudy pixels
    ax = nexttile; hold(ax, 'on'); box on; grid on;
    Lb = 0:0.05:0.8; Lc = Lb(1:end-1) + 0.025;
    [mu, mb, ma, n] = deal(nan(size(Lc)));
    for k = 1:numel(Lc)
        q = H(h).L >= Lb(k) & H(h).L < Lb(k+1); n(k) = nnz(q);
        if n(k) >= 200, mu(k) = 100*mean(H(h).su(q)); mb(k) = 100*mean(H(h).sb(q)); ma(k) = 100*mean(H(h).sa(q)); end
    end
    yline(0, ':k');
    plot(Lc, mu, '-o', 'Color', cU, 'MarkerFaceColor', cU, 'MarkerSize', 4, 'LineWidth', 1.2);
    plot(Lc, mb, '-o', 'Color', cB, 'MarkerFaceColor', cB, 'MarkerSize', 4, 'LineWidth', 1.6);
    plot(Lc, ma, '-o', 'Color', cA, 'MarkerFaceColor', cA, 'MarkerSize', 4, 'LineWidth', 1.6);
    xlabel('cloud liquid water L = tcw - tcwv [kg/m^2]'); ylabel('mean open-water SIC in L bin [%]');
    title(sprintf('%s: bias vs. cloud liquid water (ideal: 0)', hname(h)), 'FontWeight', 'normal');
    legend({'', 'uncorrected', 'mean L', 'per-pixel L'}, 'Location', 'southwest', 'Box', 'off');
    xlim([0 0.8]);
end
title(tl, {'L study (Task 2): cloud liquid water as mean value vs. per-pixel ERA5 value in the 2nd iteration, 1-27 Feb 1973', ...
    'open-water tie-point pixels; daily tie points per hemisphere; numbers in the legend = monthly mean of the daily std'}, 'FontSize', 12);
exportgraphics(fig, fullfile('output', 'B1i_L_study.png'), 'Resolution', 200);
close(fig);
fprintf('saved output/B1i_L_study.csv, output/B1i_L_study.png\n');

function M = means(s)
M = struct('V', mean(s.V), 'W', mean(s.W), 'L', mean(s.L), 'Ts', mean(s.Ts), 'Ti', mean(s.Ti));
end

function dtb = correction(s, c, Mw, Mi, pixL)
% Eq. 14 with reference values mixed by c_ice. pixL = false: mixed mean L in both runs (L not corrected);
% pixL = true: the pixel's own L in the actual run (L corrected).
r = @(f) (1 - c) .* Mw.(f) + c .* Mi.(f);
Lr  = r('L');
ref = esmr_rtm_vec(r('V'), r('W'), Lr, r('Ts'), r('Ti'), c, s.th);
if pixL, La = s.L; else, La = Lr; end
act = esmr_rtm_vec(s.V, s.W, La, s.Ts, s.Ti, c, s.th);
dtb = ref - act;
end

function [sw, si] = sic(tbw, tbi)
tpw = mean(tbw); tpi = mean(tbi);
sw = (tbw - tpw) / (tpi - tpw); si = (tbi - tpw) / (tpi - tpw);
end

function c = clipc(sic)
c = min(max(sic, 0), 1);
end
