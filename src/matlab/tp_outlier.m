function [keep, lo, hi] = tp_outlier(tb, k)
% Tie-point outlier test (2026-11-23): keep cluster pixels with |TB - median| <= k * 1.4826 * MAD.
%  tb: corrected TB (iteration 1, correct_day.m) of ALL pixels of one cluster (water or ice) of one day and
%      hemisphere (all orbits together). Corrected, so the weather signal (wind, vapour) does not count as outlier.
%  k:  number of robust standard deviations (tp_opt tb_mad, default 3); k <= 0 or empty -> keep all.
%  1.4826 * MAD = standard deviation for normal data, but outliers do not widen the limits themselves.
%  Reason: artefacts the preprocessing misses (e.g. 7 Feb 1973, orbit 08:30: 5 scan lines offset by -30 K over the
%  Norwegian Sea) must not enter the tie points. report_notes/A4e_tp_outliers.md.
if nargin < 2 || isempty(k) || k <= 0 || isempty(tb)
    keep = true(size(tb)); lo = -Inf; hi = Inf; return
end
m = median(tb, 'omitnan');
s = 1.4826 * median(abs(tb - m), 'omitnan');
lo = m - k * s; hi = m + k * s;
keep = tb >= lo & tb <= hi;
end
