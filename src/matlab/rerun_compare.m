% Compare the key numbers before / after the recompute of 2026-11-23 (rerun_all.m).
%  old = output/archive_nov17/*.csv (17 Nov masks, c < 0.15 -> 0 before iteration 2)
%  new = output/*.csv (23 Nov masks: water SST > 273 K, |lat| > 55, lsm = 0 + 5x5 box land <= 10 %; c only clipped)
%  Output: output/rerun_compare.csv (step, key, metric, old, new) and a printout.
%  Run from the repo root: matlab -batch "addpath('src/matlab'); rerun_compare"
A = fullfile('output', 'archive_nov17'); B = 'output';
rd = @(d, f) readtable(fullfile(d, f), 'TextType', 'string', 'Delimiter', ',', 'VariableNamingRule', 'preserve');
R = {};
add = @(R, step, key, met, o, n) [R; {step, key, met, o, n}];

% A6b: daily means, iteration 2 (28 Feb left out: 1 orbit)
for f = {'A6b_iterative.csv'}
    To = rd(A, f{1}); Tn = rd(B, f{1});
    for h = ["N" "S"]
        so = To(To.hemi == h & To.iter == 2 & To.day ~= 228, :); sn = Tn(Tn.hemi == h & Tn.iter == 2 & Tn.day ~= 228, :);
        for m = ["n_water" "n_ice" "Tpw_c" "Tpi_c" "w_sic_std_u" "w_sic_std_c" "i_sic_std_u" "i_sic_std_c" "w_sic_mean_c"]
            R = add(R, "A6b", h, m, mean(so.(m)), mean(sn.(m)));
        end
    end
end
% B1 tornado: dSIC for +-1 sigma
To = rd(A, 'B1_tornado.csv'); Tn = rd(B, 'B1_tornado.csv');
for i = 1:height(Tn)
    j = find(To.surface == Tn.surface(i) & To.input == Tn.input(i), 1);
    k = Tn.surface(i) + " " + Tn.input(i);
    R = add(R, "B1 tornado", k, "dSIC_plus_sigma", ifn(j, To, 'dSIC_plus_sigma'), Tn.dSIC_plus_sigma(i));
    R = add(R, "B1 tornado", k, "sigma_input", ifn(j, To, 'sigma'), Tn.sigma(i));
end
% B1c exclusion: mean over days of water / ice SIC std per case
To = rd(A, 'B1c_exclusion.csv'); Tn = rd(B, 'B1c_exclusion.csv');
for h = ["N" "S"], for c = unique(Tn.('case'))'
    so = To(To.hemi == h & To.('case') == c & To.day ~= 228, :); sn = Tn(Tn.hemi == h & Tn.('case') == c & Tn.day ~= 228, :);
    R = add(R, "B1c", h + " " + c, "w_sic_std", mean(so.w_sic_std), mean(sn.w_sic_std));
    R = add(R, "B1c", h + " " + c, "i_sic_std", mean(so.i_sic_std), mean(sn.i_sic_std));
end, end
% B1i: mean L vs pixel L
To = rd(A, 'B1i_L_study.csv'); Tn = rd(B, 'B1i_L_study.csv');
for h = ["N" "S"], for m = ["w_std_meanL" "w_std_pixL" "i_std_meanL" "i_std_pixL"]
    R = add(R, "B1i", h, m, mean(To.(m)(To.hemi == h & To.day ~= 228)), mean(Tn.(m)(Tn.hemi == h & Tn.day ~= 228)));
end, end
% B2: SIC std, corrected, inner swath (positions 5-74) and swath edge, pixel-weighted
To = rd(A, 'B2_angle.csv'); Tn = rd(B, 'B2_angle.csv');
for h = ["N" "S"], for c = ["water" "ice"], for e = [0 1]
    so = To(To.hemi == h & To.cls == c & To.edge == e, :); sn = Tn(Tn.hemi == h & Tn.cls == c & Tn.edge == e, :);
    w = @(s, f) sum(s.n .* s.(f)) / sum(s.n);
    en = ["inner" "edge"]; k = h + " " + c + " " + en(e + 1);
    R = add(R, "B2", k, "std_c", w(so, 'std_c'), w(sn, 'std_c'));
    R = add(R, "B2", k, "mean_c", w(so, 'mean_c'), w(sn, 'mean_c'));
end, end, end
% B7: mean SIC change by the correction per region / class
To = rd(A, 'B7_regions.csv'); Tn = rd(B, 'B7_regions.csv');
for i = 1:height(Tn)
    j = find(To.hemi == Tn.hemi(i) & To.region == Tn.region(i) & To.class == Tn.class(i) & To.lat_band == Tn.lat_band(i), 1);
    if Tn.region(i) ~= "all", continue, end
    R = add(R, "B7", Tn.hemi(i) + " " + Tn.class(i) + " " + Tn.lat_band(i), "mean_dsic", ifn(j, To, 'mean_dsic'), Tn.mean_dsic(i));
end
% C1, C2: extent and agreement with the books
To = rd(A, 'C1_sp459_extent.csv'); Tn = rd(B, 'C1_sp459_extent.csv');
for i = 1:height(Tn)
    j = find(To.region == Tn.region(i), 1);
    for m = ["extent_ours" "both_ice" "only_ours" "only_SP459"]
        R = add(R, "C1", Tn.region(i), m, ifn(j, To, m), Tn.(m)(i));
    end
end
To = rd(A, 'C2_feb1973_books.csv'); Tn = rd(B, 'C2_feb1973_books.csv');
for i = 1:height(Tn)
    j = find(To.hemisphere == Tn.hemisphere(i), 1);
    for m = ["extent_ours" "extent_book" "agree_pct" "area_ours" "mean_diff" "tp_water" "tp_ice"]
        R = add(R, "C2", Tn.hemisphere(i) + " " + Tn.book(i), m, ifn(j, To, m), Tn.(m)(i));
    end
end
% A3b downstream (part d): per preset
To = rd(A, 'A3b_downstream_mean.csv'); Tn = rd(B, 'A3b_downstream_mean.csv');
for i = 1:height(Tn)
    j = find(To.preset == Tn.preset(i) & To.hemi == Tn.hemi(i), 1);
    for m = ["mean_n_water" "mean_w_std_c" "mean_i_std_c"]
        R = add(R, "A3b", Tn.preset(i) + " " + Tn.hemi(i), m, ifn(j, To, m), Tn.(m)(i));
    end
end
T = cell2table(R, 'VariableNames', {'step', 'key', 'metric', 'old', 'new'});
T.diff = T.new - T.old;
writetable(T, fullfile('output', 'rerun_compare.csv'));
for i = 1:height(T)
    fprintf('%-10s %-32s %-18s %10.3f -> %10.3f  (%+.3f)\n', T.step(i), T.key(i), T.metric(i), T.old(i), T.new(i), T.diff(i));
end

function v = ifn(j, T, f)
if isempty(j), v = NaN; else, v = T.(char(f))(j); end
end
