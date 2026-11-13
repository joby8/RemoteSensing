function [O, TP] = correct_day(fnames, NIT)
% Iterative RTM correction (A6b method) for ALL valid pixels of one day.
% fnames: cell array of the day's swath files. NIT: number of iterations (default 2 = paper).
% Same steps as a6b_iterative.m:
%   clusters per hemisphere (Table 2, |lat| >= 50): water siconc = 0, sst > 278, 90 < TB < 180;
%                                                   ice siconc > 0.8, 100 < TB < 274
%   iteration 1: c = ERA5 siconc; reference = (1-c)*mean_water + c*mean_ice; L mean in both runs
%   tie points = cluster means of TB + dTB; new c = SIC clipped to 0..1, < 0.15 -> 0
% Returns
%   O(k): struct per orbit with fields valid, dtb (NaN where not corrected: invalid or ERA5 land), plus
%         the orbit data from load_orbit (lat, lon, tb_f, siconc, sst, theta, ...)
%   TP.N / TP.S: water_u, ice_u, water_c, ice_c, nw, ni, w_std_u, w_std_c, i_std_u, i_std_c (std SIC in %)
if nargin < 2 || isempty(NIT), NIT = 2; end
edge = false(1, 78); edge([1:4, 75:78]) = true;
inp = {'V','W','L','Ts','Ti'};
for k = 1:numel(fnames)
    o = load_orbit(fnames{k});
    o.L = double(ncread(fnames{k}, 'tcw'))' - o.V;
    o.valid = ~isnan(o.tb_f) & ~repmat(edge, size(o.tb_f, 1), 1) & abs(o.lat) >= 50;
    o.mw = o.valid & o.siconc == 0 & o.sst > 278 & o.tb_f > 90 & o.tb_f < 180;
    o.mi = o.valid & o.siconc > 0.8 & o.tb_f > 100 & o.tb_f < 274;
    o.corr = o.valid & ~isnan(o.sst);                % pixels we correct (ocean)
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
    isw = g('mw', 'corr'); isi = g('mi', 'corr');
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
        if it < NIT, c = min(max(sic, 0), 1); c(c < 0.15) = 0; end
    end
    su = (X.tb - tpw_u) / (tpi_u - tpw_u);
    TP.(hn(h)) = struct('water_u', tpw_u, 'ice_u', tpi_u, 'water_c', tpw_c, 'ice_c', tpi_c, ...
        'nw', nnz(isw), 'ni', nnz(isi), 'w_std_u', 100*std(su(isw)), 'w_std_c', 100*std(sic(isw)), ...
        'i_std_u', 100*std(su(isi)), 'i_std_c', 100*std(sic(isi)));
    % scatter dtb back into the orbits
    pos = 0;
    for k = 1:numel(O)
        if h == 1, O(k).dtb = nan(size(O(k).tb_f)); end
        m = O(k).corr & hs{k}; n = nnz(m);
        O(k).dtb(m) = dtb(pos + (1:n)); pos = pos + n;
    end
end
end
