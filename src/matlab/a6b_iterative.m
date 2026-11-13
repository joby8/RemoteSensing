% A6b: iterative RTM correction with c_ice from ERA5 as start (Kolbe et al. 2024, Sect. 4.1, steps 1-2).
%  Agreed in the feedback session 2026-11-13:
%   - tie points per day and hemisphere, selection as in Table 2 but with |lat| >= 50 deg:
%       water: siconc = 0, sst > 278 K, 90 K < TB < 180 K
%       ice:   siconc > 0.8,            100 K < TB < 274 K
%   - iteration 0: c_ice = ERA5 siconc of each pixel
%   - reference values mixed with c_ice: Xref = (1-c)*mean_water + c*mean_ice   (paper: "c_ice is used as
%     a ratio to mix the two tie-point values"), for V, W, L, Ts, Ti
%   - dTB = RTM(Xref, Lref, c, theta) - RTM(X, Lref, c, theta); L not corrected (mean L in both runs)
%   - corrected tie points -> new c_ice = SIC from corrected TB, clipped to 0..1, < 0.15 set to 0
%     -> next iteration (paper iterates once; we run NIT iterations to show convergence)
%   - std per day and hemisphere for the water AND the ice tie-point pixels (raw SIC, not clipped)
% Run from the project root:  matlab -batch "run('src/matlab/a6b_iterative.m')"
% Outputs: output/A6b_iterative.csv, output/A6b_iterative.png, output/A6b_pixels.mat
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile('src','matlab'));
files = dir(fullfile('ESMR_colocated_filtered','*.nc'));
fday  = string(regexp({files.name}, '1973m(\d{4})t', 'tokens', 'once'));
if ~exist('days','var') || isempty(days), days = unique(fday); end
if ~exist('NIT','var') || isempty(NIT), NIT = 3; end
edge = false(1, 78); edge([1:4, 75:78]) = true;
vars = {'tb','th','V','W','L','Ts','Ti','ci'};
inp  = {'V','W','L','Ts','Ti'};
hemi = ["N","S"];

rows = {}; P = struct('day', {}, 'hemi', {}, 'cls', {}, 'th', {}, 'sic_u', {}, 'sic_c', {}, 'dtb', {}, ...
                      'V', {}, 'W', {}, 'L', {}, 'Ts', {}, 'Ti', {}, 'ci', {});
for d = days(:)'
    fi = find(fday == d);
    G = repmat({struct()}, 2, 2);                       % G{h, 1} water, G{h, 2} ice
    for h = 1:2, for t = 1:2, for v = vars, G{h, t}.(v{1}) = []; end, end, end
    for k = fi
        fn = fullfile(files(k).folder, files(k).name);
        o = load_orbit(fn);
        o.L = double(ncread(fn, 'tcw'))' - o.V;
        o.th = o.theta; o.tb = o.tb_f; o.ci = o.siconc;
        valid = ~isnan(o.tb_f) & ~repmat(edge, size(o.tb_f, 1), 1) & abs(o.lat) >= 50;
        m = {valid & o.siconc == 0 & o.sst > 278 & o.tb > 90 & o.tb < 180, ...
             valid & o.siconc > 0.8 & o.tb > 100 & o.tb < 274};
        for h = 1:2
            hs = (o.lat > 0) == (h == 1);
            for t = 1:2, for v = vars, G{h, t}.(v{1}) = [G{h, t}.(v{1}); o.(v{1})(m{t} & hs)]; end, end
        end
    end
    for h = 1:2
        w = G{h, 1}; c = G{h, 2};
        c.Ts(isnan(c.Ts)) = 271.35;                     % SST under ice (weight ~0, avoids NaN)
        Mw = means(w); Mi = means(c);
        % uncorrected
        tpw = mean(w.tb); tpi = mean(c.tb);
        su_w = (w.tb - tpw) / (tpi - tpw); su_i = (c.tb - tpw) / (tpi - tpw);
        % iterations: c_ice from ERA5, then from corrected TB
        cw = w.ci; cc = c.ci;
        for it = 1:NIT
            dw = correction(w, cw, Mw, Mi); dc = correction(c, cc, Mw, Mi);
            tpw_c = mean(w.tb + dw); tpi_c = mean(c.tb + dc);
            sc_w = (w.tb + dw - tpw_c) / (tpi_c - tpw_c);
            sc_i = (c.tb + dc - tpw_c) / (tpi_c - tpw_c);
            rows(end+1, :) = {d, hemi(h), it, numel(w.tb), numel(c.tb), tpw, tpw_c, tpi, tpi_c, ...
                100*std(su_w), 100*std(sc_w), 100*mean(sc_w), std(w.tb), std(w.tb + dw), ...
                100*std(su_i), 100*std(sc_i), 100*mean(sc_i), std(c.tb), std(c.tb + dc), ...
                100*mean(abs(clipc(sc_w) - cw)), 100*mean(abs(clipc(sc_i) - cc))}; %#ok<SAGROW>
            cw_new = clipc(sc_w); cc_new = clipc(sc_i);
            cw = cw_new; cc = cc_new;
        end
        for t = 1:2
            s = G{h, t}; if t == 1, su = su_w; sc = sc_w; dt = dw; else, su = su_i; sc = sc_i; dt = dc; end
            P(end+1) = struct('day', d, 'hemi', hemi(h), 'cls', t, 'th', single(s.th), 'sic_u', single(su), ...
                'sic_c', single(sc), 'dtb', single(dt), 'V', single(s.V), 'W', single(s.W), 'L', single(s.L), ...
                'Ts', single(s.Ts), 'Ti', single(s.Ti), 'ci', single(s.ci)); %#ok<SAGROW>
        end
    end
    fprintf('%s done (%d orbits)\n', d, numel(fi));
end

T = cell2table(rows, 'VariableNames', {'day','hemi','iter','n_water','n_ice','Tpw_u','Tpw_c','Tpi_u','Tpi_c', ...
    'w_sic_std_u','w_sic_std_c','w_sic_mean_c','w_tb_std_u','w_tb_std_c', ...
    'i_sic_std_u','i_sic_std_c','i_sic_mean_c','i_tb_std_u','i_tb_std_c', ...
    'w_dc_mean','i_dc_mean'});
ok = T.day ~= "0228";
fprintf('\nMonthly mean of the daily values (without 28 Feb, 1 orbit). dc = mean |c_new - c_used| in %% SIC.\n');
fprintf('%-4s %-4s | %-26s | %-26s | %s\n', 'hemi', 'iter', 'water: std SIC u -> c [%]', 'ice: std SIC u -> c [%]', 'dc water / ice');
for h = hemi
    for it = 1:NIT
        s = T(T.hemi == h & T.iter == it & ok, :);
        fprintf('%-4s %-4d | %8.2f -> %8.2f      | %8.2f -> %8.2f      | %.2f / %.2f\n', h, it, ...
            mean(s.w_sic_std_u), mean(s.w_sic_std_c), mean(s.i_sic_std_u), mean(s.i_sic_std_c), mean(s.w_dc_mean), mean(s.i_dc_mean));
    end
    s = T(T.hemi == h & T.iter == NIT & ok, :);
    fprintf('     days improved (last iter): water %d of %d, ice %d of %d; n ice pixels/day %.0f\n', ...
        nnz(s.w_sic_std_c < s.w_sic_std_u), height(s), nnz(s.i_sic_std_c < s.i_sic_std_u), height(s), mean(s.n_ice));
end
if ~exist('output', 'dir'), mkdir('output'); end
writetable(T, fullfile('output', 'A6b_iterative.csv'));
save(fullfile('output', 'A6b_pixels.mat'), 'P', 'NIT', '-v7.3');
fprintf('saved output/A6b_iterative.csv, output/A6b_pixels.mat\n');

% ---- figure: daily std per hemisphere, water and ice tie points, before/after (last iteration) ----
fig = figure('Visible','off','Position',[100 100 1500 900]);
tiledlayout(2, 2, 'TileSpacing', 'compact');
col = [0.10 0.35 0.80; 0.85 0.30 0.10];
lbl = {'water tie points', 'ice tie points'};
for t = 1:2
    for h = 1:2
        nexttile; hold on;
        s = T(T.hemi == hemi(h) & T.iter == NIT & ok, :);
        tt = datetime(1973, 2, str2double(extractAfter(s.day, 2)));
        if t == 1, u = s.w_sic_std_u; c = s.w_sic_std_c; else, u = s.i_sic_std_u; c = s.i_sic_std_c; end
        plot(tt, u, ':o', 'Color', col(h,:), 'LineWidth', 1.0);
        plot(tt, c, '-o', 'Color', col(h,:), 'LineWidth', 1.6, 'MarkerFaceColor', col(h,:));
        legend({sprintf('uncorrected (mean %.1f %%)', mean(u)), sprintf('corrected (mean %.1f %%)', mean(c))}, 'Location', 'best');
        ylabel('std of SIC [%]'); grid on; box on;
        hn = ["Northern","Southern"];
        title(sprintf('%s, %s hemisphere', lbl{t}, hn(h)));
    end
end
exportgraphics(fig, fullfile('output', 'A6b_iterative.png'), 'Resolution', 150);
fprintf('saved output/A6b_iterative.png\n');

% ---------------------------------------------------------------------------
function M = means(s)
M = struct('V', mean(s.V), 'W', mean(s.W), 'L', mean(s.L), 'Ts', mean(s.Ts), 'Ti', mean(s.Ti));
end

function dtb = correction(s, c, Mw, Mi)
% Eq. 14 with reference values mixed by c_ice; L: mixed mean in both runs (not corrected).
r = @(f) (1 - c) .* Mw.(f) + c .* Mi.(f);
Lr  = r('L');
ref = esmr_rtm_vec(r('V'), r('W'), Lr, r('Ts'), r('Ti'), c, s.th);
act = esmr_rtm_vec(s.V, s.W, Lr, s.Ts, s.Ti, c, s.th);
dtb = ref - act;
end

function c = clipc(sic)
% paper step 1: truncate to 0..1, open-water filter: c < 0.15 -> 0
c = min(max(sic, 0), 1);
c(c < 0.15) = 0;
end
