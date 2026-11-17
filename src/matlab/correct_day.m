function [O, TP] = correct_day(fnames, NIT, cfg, opts)
% Iterative RTM correction (A6b method) for ALL valid pixels of one day.
% fnames: cell array of the day's swath files. NIT: number of iterations (default 2 = our final A6b scheme).
%   Intentional deviation from the paper: Kolbe et al. (2024, p. 1253-1254) do ONE RTM correction, starting
%   from the uncorrected SIC (c_ice from the uncorrected TB). We start from ERA5 siconc (iteration 1) and
%   iterate once more with c from the corrected SIC (iteration 2); see report_notes/A6b_iterative.md.
% cfg: preprocessing settings (preproc_config.m; default preproc_config()). Pixels used = o.valid from load_orbit
%      (outlier filters + swath edge + |lat| >= lat_min + land rule).
% opts (optional struct): opts.extra = false (default) -> behaviour as before. opts.extra = true adds the
%      Task 2 / Task 3 outputs for the globe (globe_html.m), WITHOUT changing any number of the default:
%      - swath-edge pixels (removed only by the cfg.edge step) are corrected too (B2 method, b2_angle.m);
%        clusters, reference means Mw/Mi and tie points still come from o.valid only;
%      - dtb of iteration 1, exclusion cases (b1c_exclusion.m) and the per-pixel-L case (b1i_L_study.m (a));
%      - SIC sums per scan position (b2_angle.m) and the matching tie points / std in TP.
% Same steps as a6b_iterative.m:
%   clusters per hemisphere (tp_masks.m, |lat| >= 50): water siconc <= 0.01, sst > 278, 90 < TB < 180, lsm == 0;
%                                                      ice siconc > 0.8, 180 < TB < 274, lsm == 0
%   iteration 1: c = ERA5 siconc; reference = (1-c)*mean_water + c*mean_ice; L mean in both runs
%   tie points = cluster means of TB + dTB; new c = SIC clipped to 0..1, < 0.15 -> 0
% Returns
%   O(k): struct per orbit with fields valid, edge (swath-edge pixels corrected, all false without opts.extra),
%         corr = valid | edge (corrected pixels), dtb (NaN where not corrected),
%         c (ice fraction used in the last iteration), dV, dW, dL, dTs, dTi (part of dtb from each input,
%         dL = not applied), plus the orbit data from load_orbit (lat, lon, tb_f, siconc, sst, theta, L, Tsx ...)
%         opts.extra only: dtb1 (dtb of iteration 1), dx.V/W/Ts/Ti (dtb without that input: it gets its
%         reference value in the actual run, last-iteration c, as B1c), dx.L (actual run with the pixel's own L,
%         last-iteration c, as B1i variant a); all NaN outside corr.
%   TP.N / TP.S: water_u, ice_u, water_c, ice_c, nw, ni, w_std_u, w_std_c, i_std_u, i_std_c (std SIC in %),
%         Mw, Mi (cluster means of V, W, L, Ts, Ti: the reference is (1-c)*Mw + c*Mi)
%         opts.extra only (SIC in %, statistics over the cluster pixels = valid only):
%         w_mean_u, w_mean_c, i_mean_u, i_mean_c;
%         it1 = (water_c, ice_c, w_std_c, i_std_c, w_mean_c) of iteration 1;
%         X.without_V / without_W / without_Ts / without_Ti / L_pixel = (water_c, ice_c, w_std, i_std, w_mean),
%           tie points recomputed from the clusters' tb + dx;
%         spos = (w_n, w_s1u, w_s2u, w_s1c, w_s2c, i_n, i_s1u, i_s2u, i_s1c, i_s2c), 1 x 78 each: count, sum and
%           sum of squares of SIC raw (u, daily raw tie points) and corrected (c, last iteration) per scan
%           position, over the pixels passing the cluster criteria on corr (edge pixels included).
if nargin < 2 || isempty(NIT), NIT = 2; end
if nargin < 3 || isempty(cfg), cfg = preproc_config(); end
if nargin < 4 || isempty(opts), opts = struct(); end
if ~isfield(opts, 'extra'), opts.extra = false; end
ex = logical(opts.extra);
inp = {'V','W','L','Ts','Ti'};
for k = 1:numel(fnames)
    o = load_orbit(fnames{k}, cfg);
    o.L = double(ncread(fnames{k}, 'tcw'))' - o.V;
    [o.mw, o.mi] = tp_masks(o, o.valid, o.tb_f, o.lsm);   % masks 2026-11-17 (o.valid from esmr_preprocess)
    if ex, o.edge = edge_only(o, cfg); else, o.edge = false(size(o.valid)); end
    o.corr = o.valid | o.edge;                       % pixels we correct (o.valid already excludes land, cfg.land)
    if ex
        [o.mwc, o.mic] = tp_masks(o, o.corr, o.tb_f, o.lsm);   % cluster criteria on corr (angle statistics only)
        o.sp = repmat(1:size(o.tb, 2), size(o.tb, 1), 1);
    end
    o.Tsx = o.sst; o.Tsx(isnan(o.Tsx)) = 271.35;     % SST under ice where missing (weight ~0)
    O(k) = o; %#ok<AGROW>
end
hn = 'NS';
for h = 1:2
    hs = arrayfun(@(o) (o.lat > 0) == (h == 1), O, 'UniformOutput', false);
    % gather pixel vectors of everything we correct in this hemisphere
    g = @(f, m) cell2mat(arrayfun(@(o, s) o.(f)(o.(m) & s{1}), O, hs, 'UniformOutput', false)');
    X = struct('tb', g('tb_f', 'corr'), 'th', g('theta', 'corr'), 'V', g('V', 'corr'), 'W', g('W', 'corr'), ...
               'L', g('L', 'corr'), 'Ts', g('Tsx', 'corr'), 'Ti', g('Ti', 'corr'), 'ci', g('siconc', 'corr'));
    isw = g('mw', 'corr'); isi = g('mi', 'corr');    % clusters: valid pixels only (mw, mi are inside valid)
    for v = inp, Mw.(v{1}) = mean(X.(v{1})(isw)); Mi.(v{1}) = mean(X.(v{1})(isi)); end
    tpw_u = mean(X.tb(isw)); tpi_u = mean(X.tb(isi));
    c = X.ci; c(isnan(c)) = 0;
    for it = 1:NIT
        r = @(f) (1 - c) .* Mw.(f) + c .* Mi.(f);
        Lr = r('L');
        dtb = esmr_rtm_vec(r('V'), r('W'), Lr, r('Ts'), r('Ti'), c, X.th) ...
            - esmr_rtm_vec(X.V, X.W, Lr, X.Ts, X.Ti, c, X.th);
        tpw_c = mean(X.tb(isw) + dtb(isw)); tpi_c = mean(X.tb(isi) + dtb(isi));
        sic = (X.tb + dtb - tpw_c) / (tpi_c - tpw_c);
        if ex && it == 1
            dtb1 = dtb;
            it1 = struct('water_c', tpw_c, 'ice_c', tpi_c, 'w_std_c', 100*std(sic(isw)), ...
                'i_std_c', 100*std(sic(isi)), 'w_mean_c', 100*mean(sic(isw)));
        end
        if it < NIT, c = min(max(sic, 0), 1); c(c < 0.15) = 0; end
    end
    su = (X.tb - tpw_u) / (tpi_u - tpw_u);
    TP.(hn(h)) = struct('water_u', tpw_u, 'ice_u', tpi_u, 'water_c', tpw_c, 'ice_c', tpi_c, ...
        'nw', nnz(isw), 'ni', nnz(isi), 'w_std_u', 100*std(su(isw)), 'w_std_c', 100*std(sic(isw)), ...
        'i_std_u', 100*std(su(isi)), 'i_std_c', 100*std(sic(isi)), 'Mw', Mw, 'Mi', Mi);
    % share of each input in dtb (last iteration): swap only that input from reference to pixel value.
    % L is not corrected (both runs use Lr); its part is what a correction with ERA5 L would add.
    % The parts do not add up exactly to dtb (the model is non-linear); the rest is small.
    ref = struct('V', r('V'), 'W', r('W'), 'L', Lr, 'Ts', r('Ts'), 'Ti', r('Ti'));
    T0 = esmr_rtm_vec(ref.V, ref.W, ref.L, ref.Ts, ref.Ti, c, X.th);
    part = struct();
    for v = inp
        a = ref; a.(v{1}) = X.(v{1});
        part.(v{1}) = T0 - esmr_rtm_vec(a.V, a.W, a.L, a.Ts, a.Ti, c, X.th);
    end
    if ex
        t = TP.(hn(h));
        t.w_mean_u = 100*mean(su(isw)); t.w_mean_c = 100*mean(sic(isw));
        t.i_mean_u = 100*mean(su(isi)); t.i_mean_c = 100*mean(sic(isi));
        t.it1 = it1;
        % exclusion cases (B1c) and per-pixel L (B1i (a)), last-iteration c, actual run vs. the same reference T0
        act = struct('V', X.V, 'W', X.W, 'L', Lr, 'Ts', X.Ts, 'Ti', X.Ti);
        xc = {'V','W','Ts','Ti','L'}; xn = {'without_V','without_W','without_Ts','without_Ti','L_pixel'};
        dx = struct(); t.X = struct();
        for q = 1:numel(xc)
            a = act;
            if strcmp(xc{q}, 'L'), a.L = X.L; else, a.(xc{q}) = ref.(xc{q}); end
            dx.(xc{q}) = T0 - esmr_rtm_vec(a.V, a.W, a.L, a.Ts, a.Ti, c, X.th);
            tw = mean(X.tb(isw) + dx.(xc{q})(isw)); ti = mean(X.tb(isi) + dx.(xc{q})(isi));
            s = (X.tb + dx.(xc{q}) - tw) / (ti - tw);
            t.X.(xn{q}) = struct('water_c', tw, 'ice_c', ti, 'w_std', 100*std(s(isw)), ...
                'i_std', 100*std(s(isi)), 'w_mean', 100*mean(s(isw)));
        end
        % SIC sums per scan position over the pixels passing the cluster criteria on corr (b2_angle.m)
        sp = g('sp', 'corr'); np = size(O(1).tb, 2);
        mm = {g('mwc', 'corr'), g('mic', 'corr')}; cl = 'wi';
        S = struct();
        for q = 1:2
            m = mm{q}; acc = @(y) accumarray(sp(m), y, [np 1])';
            S.([cl(q) '_n'])   = acc(ones(nnz(m), 1));
            S.([cl(q) '_s1u']) = acc(100*su(m));  S.([cl(q) '_s2u']) = acc((100*su(m)).^2);
            S.([cl(q) '_s1c']) = acc(100*sic(m)); S.([cl(q) '_s2c']) = acc((100*sic(m)).^2);
        end
        t.spos = S;
        TP.(hn(h)) = t;
    end
    % scatter dtb, c and the parts back into the orbits
    pos = 0;
    for k = 1:numel(O)
        if h == 1
            O(k).dtb = nan(size(O(k).tb_f)); O(k).c = O(k).dtb;
            for v = inp, O(k).(['d' v{1}]) = O(k).dtb; end
            if ex
                O(k).dtb1 = O(k).dtb;
                O(k).dx = struct('V', O(k).dtb, 'W', O(k).dtb, 'Ts', O(k).dtb, 'Ti', O(k).dtb, 'L', O(k).dtb);
            end
        end
        m = O(k).corr & hs{k}; n = nnz(m); ix = pos + (1:n);
        O(k).dtb(m) = dtb(ix); O(k).c(m) = c(ix);
        for v = inp, O(k).(['d' v{1}])(m) = part.(v{1})(ix); end
        if ex
            O(k).dtb1(m) = dtb1(ix);
            for q = fieldnames(dx)', O(k).dx.(q{1})(m) = dx.(q{1})(ix); end
        end
        pos = pos + n;
    end
end
end

function e = edge_only(o, cfg)
% pixels removed ONLY by the swath-edge step: flag 6 (edge is applied before latitude and land, so these
% pixels were not yet tested there) AND passing the latitude and land rules of esmr_preprocess.m.
% = the pixels that would be valid with cfg.edge = [] but are not in o.valid.
switch cfg.land
    case 'none', L = false(size(o.flag));
    case 'sst',  L = isnan(o.sst);
    case 'lsm',  L = ~(o.lsm <= cfg.lsm_max);
end
e = o.flag == 6 & abs(o.lat) >= cfg.lat_min & ~L;
end
