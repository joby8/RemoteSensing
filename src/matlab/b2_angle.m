% B2: Task 3 - std of the SIC vs. incidence angle, uncorrected and RTM-corrected, over the WHOLE swath.
%  Same method as A6b (Table 2 clusters, |lat| >= 50 deg, c_ice from ERA5, reference values mixed
%  by c_ice, L not corrected, iteration 2). Since 2026-11-24 (Tonboe) all 78 scan positions are used
%  everywhere (cfg.edge = [] in preproc_config.m), so tie points come from the whole swath, as in A6b.
%  The positions the paper cuts (1-4, 75-78, |theta| > 55.7 deg) are only marked (grey band, dashed).
%  Note: the RTM ice-emissivity table ends at 60 deg; for |theta| = 61.7 and 63.9 deg it is extrapolated.
%  std per scan position = std of all pixels of 1-27 Feb at that position (SIC relative to the daily tie points).
% Run from the project root:  matlab -batch "run('src/matlab/b2_angle.m')"
% Outputs: output/B2_angle.csv (water and ice), output/B2_std_vs_angle.png, output/B2_mean_vs_angle.png
%          (figures: open water only, as paper Fig. 5)
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile('src','matlab'));
files = dir(fullfile('ESMR_colocated_filtered','*.nc'));
fday  = string(regexp({files.name}, '1973m(\d{4})t', 'tokens', 'once'));
days  = unique(fday); days = days(days ~= "0228");       % 28 Feb: only 1 orbit
NIT   = 2;                                                % final iteration (A6b)
cfg   = preproc_config(); edge = cfg.edge;           % analysis cut (none since 2026-11-24)
pedge = [1:4, 75:78];                                 % positions the paper cuts (only marked in the plots)
cfg.edge = [];                                        % B2 preprocesses WITHOUT the edge cut (all 78 positions)
vars  = {'tb','th','sp','V','W','L','Ts','Ti','ci'};
hemi  = ["N","S"];

o = detectImportOptions(fullfile('output','A6b_iterative.csv'));
o = setvartype(o, {'day','hemi'}, 'string');
A = readtable(fullfile('output','A6b_iterative.csv'), o);
A = A(A.iter == 2, :);

% per-pixel results, collected per hemisphere and class
R = struct('sp', {}, 'th', {}, 'su', {}, 'sc', {});
for h = 1:2, for t = 1:2, R(h,t).sp = []; R(h,t).th = []; R(h,t).su = []; R(h,t).sc = []; end, end
maxdiff = 0;
for d = days(:)'
    fi = find(fday == d);
    G = repmat({struct()}, 2, 2);
    for h = 1:2, for t = 1:2, for v = vars, G{h, t}.(v{1}) = []; end, end, end
    for k = fi
        fn = fullfile(files(k).folder, files(k).name);
        q = load_orbit(fn, cfg);
        q.L  = double(ncfast(fn, 'tcw'))' - q.V;
        q.th = q.theta; q.tb = q.tb_f; q.ci = q.siconc;
        q.sp = repmat(1:78, size(q.tb, 1), 1);
        valid = q.valid;                                     % preprocessing with cfg.edge = [] (NO edge cut here)
        [mw_, mi_] = tp_masks(q, valid, q.tb, q.lsm);        % masks 2026-11-17
        m = {mw_, mi_};
        for h = 1:2
            hs = (q.lat > 0) == (h == 1);
            for t = 1:2, for v = vars, G{h, t}.(v{1}) = [G{h, t}.(v{1}); q.(v{1})(m{t} & hs)]; end, end
        end
    end
    for h = 1:2
        w = G{h, 1}; c = G{h, 2};
        c.Ts(isnan(c.Ts)) = 271.35;
        iw = ~ismember(w.sp, edge); ic = ~ismember(c.sp, edge);   % analysis pixels (all since 2026-11-24)
        Mw = means(w, iw); Mi = means(c, ic);
        tpw = mean(w.tb(iw)); tpi = mean(c.tb(ic));
        su_w = (w.tb - tpw) / (tpi - tpw); su_i = (c.tb - tpw) / (tpi - tpw);
        cw = w.ci; cc = c.ci;
        for it = 1:NIT
            dw = correction(w, cw, Mw, Mi); dc = correction(c, cc, Mw, Mi);
            tpw_c = mean(w.tb(iw) + dw(iw)); tpi_c = mean(c.tb(ic) + dc(ic));
            sc_w = (w.tb + dw - tpw_c) / (tpi_c - tpw_c);
            sc_i = (c.tb + dc - tpw_c) / (tpi_c - tpw_c);
            cw = clipc(sc_w); cc = clipc(sc_i);
        end
        % check: inner pixels must reproduce A6b iteration 2
        a = A(A.day == d & A.hemi == hemi(h), :);
        maxdiff = max([maxdiff, abs(100*std(sc_w(iw)) - a.w_sic_std_c), abs(100*std(sc_i(ic)) - a.i_sic_std_c)]);
        S = {w, su_w, sc_w; c, su_i, sc_i};
        for t = 1:2
            R(h,t).sp = [R(h,t).sp; S{t,1}.sp]; R(h,t).th = [R(h,t).th; S{t,1}.th];
            R(h,t).su = [R(h,t).su; S{t,2}];    R(h,t).sc = [R(h,t).sc; S{t,3}];
        end
    end
    fprintf('%s done (%d orbits)\n', d, numel(fi));
end
fprintf('check vs. A6b (analysis scan positions): max |diff| of the daily std = %.4f %% SIC\n', maxdiff);

% ---- statistics per scan position ----
cn = ["water","ice"];
rows = {};
for h = 1:2
    for t = 1:2
        for p = 1:78
            s = R(h,t).sp == p;
            th = R(h,t).th(find(s, 1)); if isempty(th), th = NaN; end
            rows(end+1,:) = {hemi(h), cn(t), p, th, ismember(p, pedge), nnz(s), ...
                100*mean(R(h,t).su(s)), 100*std(R(h,t).su(s)), 100*mean(R(h,t).sc(s)), 100*std(R(h,t).sc(s))}; %#ok<SAGROW>
        end
    end
end
T = cell2table(rows, 'VariableNames', {'hemi','cls','spos','theta','edge','n','mean_u','std_u','mean_c','std_c'});
writetable(T, fullfile('output','B2_angle.csv'));

% summary: inner swath by angle band, and the edge
fprintf('\nstd of SIC [%%], 1-27 Feb, pooled pixels: no RTM -> with RTM\n');
bands = [0 20; 20 40; 40 50; 50 55.7; 55.7 64];
for h = 1:2
    for t = 1:2
        line = sprintf('%-2s %-5s |', hemi(h), cn(t));
        for b = 1:size(bands,1)
            s = abs(R(h,t).th) >= bands(b,1) & abs(R(h,t).th) < bands(b,2);
            line = [line sprintf(' %2.0f-%2.0f°: %5.1f -> %5.1f |', bands(b,1), bands(b,2), ...
                100*std(R(h,t).su(s)), 100*std(R(h,t).sc(s)))]; %#ok<AGROW>
        end
        fprintf('%s\n', line);
    end
end

% ---- figures: open water only, as paper Fig. 5 (Arctic top, Antarctic bottom); ice stays in the csv ----
hn = ["Arctic","Antarctic"];
cU = [.25 .25 .25]; cC = [0 .45 .74]; cFill = [.72 .85 .96];
for what = ["std","mean"]
    fig = figure('Visible','off','Color','w','Position',[50 50 1300 950]);
    tl = tiledlayout(2,1,'TileSpacing','compact','Padding','compact');
    for h = 1:2
        for t = 1
            nexttile; hold on; grid on; box on
            s = T(T.hemi == hemi(h) & T.cls == cn(t), :);
            yu = s.(what + "_u"); yc = s.(what + "_c"); x = s.theta; in = ~s.edge;
            % excluded edge: grey band
            yl = [min([yu; yc]) max([yu; yc])]; yl = yl + [-1 1]*0.08*diff(yl);
            if what == "std", yl = [max(0, floor(min(yc)) - 2), ceil(max(yu)) + 1]; end
            for sd = [-1 1]
                patch(sd*[55.7 64.5 64.5 55.7], [yl(1) yl(1) yl(2) yl(2)], [.92 .92 .92], ...
                    'EdgeColor','none','HandleVisibility','off');
            end
            if what == "mean", yline(0,'k:','HandleVisibility','off'); end
            L = 1:5; Rr = 74:78;                        % edge segments incl. the first inner position
            if what == "std"
                % area between the curves = noise removed by the RTM correction
                patch([x(in); flipud(x(in))], [yu(in); flipud(yc(in))], cFill, 'EdgeColor','none', ...
                    'DisplayName', 'noise removed by the RTM correction');
                for seg = {L, Rr}
                    g = seg{1};
                    patch([x(g); flipud(x(g))], [yu(g); flipud(yc(g))], cFill, 'FaceAlpha', 0.45, ...
                        'EdgeColor','none', 'HandleVisibility','off');
                end
            end
            % inner swath solid, edge dashed (left and right edge separately, joined to the inner line)
            plot(x(in), yu(in), '-o', 'Color', cU, 'LineWidth', 2.0, 'MarkerSize', 3, 'MarkerFaceColor', cU, ...
                'DisplayName', 'no RTM correction');
            plot(x(in), yc(in), '-o', 'Color', cC, 'LineWidth', 2.2, 'MarkerSize', 3, 'MarkerFaceColor', cC, ...
                'DisplayName', 'with RTM correction');
            for seg = {L, Rr}
                g = seg{1};
                plot(x(g), yu(g), '--o', 'Color', cU, 'LineWidth', 2.0, 'MarkerSize', 3, 'HandleVisibility','off');
                plot(x(g), yc(g), '--o', 'Color', cC, 'LineWidth', 2.2, 'MarkerSize', 3, 'HandleVisibility','off');
            end
            plot(nan, nan, '--', 'Color', [.3 .3 .3], 'LineWidth', 1.4, ...
                'DisplayName', 'swath edge cut by Kolbe et al. 2024 (pos. 1-4, 75-78), kept here');
            xlim([-64.5 64.5]); ylim(yl);
            xlabel('incidence angle \theta [°]  (negative = left side of the swath)');
            if what == "std", ylabel('std of SIC [%]'); else, ylabel('mean SIC [%]'); end
            title(sprintf('%s: open water (Table 2 ocean pixels)', hn(h)));
            if h == 1 && t == 1, legend('Location','north','FontSize',9); end
        end
    end
    if what == "std"
        title(tl, {'Task 3: std of the open-water SIC vs. incidence angle, 1-27 Feb 1973 (as Kolbe et al. Fig. 5, but in % SIC)', ...
            'blue area = noise removed by the RTM correction; grey bands / dashed = swath edge (|\theta| > 55.7°), cut by Kolbe et al. 2024, kept here'}, 'FontWeight','bold');
    else
        title(tl, {'Task 3 (extra): mean open-water SIC vs. incidence angle, 1-27 Feb 1973', ...
            'tie point = mean over the whole swath, so a per-angle offset shows an angle dependence of T_B that the correction does not remove'}, 'FontWeight','bold');
    end
    exportgraphics(fig, fullfile('output', "B2_" + what + "_vs_angle.png"), 'Resolution', 140);
end
fprintf('saved output/B2_angle.csv, output/B2_std_vs_angle.png, output/B2_mean_vs_angle.png\n');

% ---------------------------------------------------------------------------
function M = means(s, i)
M = struct('V', mean(s.V(i)), 'W', mean(s.W(i)), 'L', mean(s.L(i)), 'Ts', mean(s.Ts(i)), 'Ti', mean(s.Ti(i)));
end

function dtb = correction(s, c, Mw, Mi)
% as A6b: reference values mixed by c_ice, L not corrected (reference L in both runs)
r = @(f) (1 - c) .* Mw.(f) + c .* Mi.(f);
Lr  = r('L');
ref = esmr_rtm_vec(r('V'), r('W'), Lr, r('Ts'), r('Ti'), c, s.th);
act = esmr_rtm_vec(s.V, s.W, Lr, s.Ts, s.Ti, c, s.th);
dtb = ref - act;
end

function c = clipc(sic)
c = min(max(sic, 0), 1);
end
