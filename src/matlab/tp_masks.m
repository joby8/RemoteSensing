function [mw, mi, C] = tp_masks(o, valid, tb, lsm, opt)
% Tie-point masks (Table 2 of Kolbe et al. 2024, with the changes from the meetings 2026-11-17 and 2026-11-20).
%   water: siconc <= 0.01 (1 % SIC still counts as ocean), sst > 273 K (tp_opt), |lat| > 55 deg, 90 K < TB < 180 K
%   ice:   siconc > 0.8,  180 K < TB < 274 K  (lower limit raised from 100 K: clear-ocean pixels
%          (TB ~ 145 K) were picked up as ice; 180 K = upper limit of the water mask, no overlap)
%   both:  ERA5 land-sea fraction lsm = 0 and mean lsm of the 5 x 5 box <= 0.10 (coastal pixels and pixels next to
%          the coast out: land spill-over in the ESMR footprint)
%   both (box, added 2026-11-17, Table 2 distance from the ice edge): mean ERA5 siconc of a 5 x 5 box
%          (5 scan lines x 5 scan positions, centred) < 0.01 for water, > 0.8 for ice.
%          The box is computed on the whole orbit o.siconc BEFORE any valid-masking (neighbours count whatever
%          the preprocessing did to them). Land (siconc NaN) is left out of the mean (sum / count of non-NaN
%          values); at the swath edge the box shrinks. A pixel without any siconc in its box fails the box test.
% opt (optional struct): opt.box = true (default) uses the box criteria; opt.box = false reproduces the masks
%      from before 2026-11-17 (C.w_box, C.i_box are then all true).
%   Tunable thresholds (meeting 2026-11-20: more and colder water tie-point pixels, less land spill-over),
%   defaults in tp_opt.m (masks of 2026-11-20, chosen with the A4b sweep, report_notes/A4b_tp_sweep.md):
%      opt.sst_min  = 275  water: ERA5 sst > sst_min [K]          (17 Nov masks: 278)
%      opt.wlat_min = 55   water: |lat| > wlat_min [deg]          (17 Nov masks: 0, i.e. only |lat| >= 50)
%      opt.lsm_max  = 0    both:  pixel ERA5 lsm <= lsm_max       (17 Nov masks: 0)
%      opt.lsm_box  = 5    both:  if > 0, also mean ERA5 lsm of an lsm_box x lsm_box box (scan lines x positions,
%      opt.lsm_boxmax = 0.10 centred, shrinks at the swath edge) <= lsm_boxmax: removes pixels NEXT to land
%                          (land spill-over in the large ESMR footprint), stricter than the pixel's own lsm.
%   The 17 Nov masks: tp_opt('nov17').
% o: orbit struct from load_orbit; valid: preprocessing mask; tb: TB field used; lsm: ERA5 'lsm' [lines x 78].
% Optional 3rd output C: the single criteria as logical fields (NOT combined with valid), so other code
% (globe_html.m: per-criterion view) uses the same rule:
%   C.w_sic, C.w_sst, C.w_tb, C.w_lat  water criteria;  C.i_sic, C.i_tb  ice criteria;  C.sea  lsm <= lsm_max (both)
%   mw = valid & C.sea & C.w_box & C.w_sic & C.w_sst & C.w_tb & C.w_lat,  mi = valid & C.sea & C.i_box & C.i_sic & C.i_tb
if nargin < 5 || isempty(opt), opt = struct(); end
opt = tp_opt(opt);
if opt.box
    sc = double(o.siconc); ok = ~isnan(sc); sc(~ok) = 0;
    sm = movsum(movsum(sc, 5, 1), 5, 2);                 % shrink at the swath edge
    nn = movsum(movsum(double(ok), 5, 1), 5, 2);
    bm = sm ./ nn;                                       % box mean over non-NaN siconc (NaN if none)
    C.w_box = bm < 0.01;
    C.i_box = bm > 0.8;
else
    C.w_box = true(size(o.siconc));
    C.i_box = true(size(o.siconc));
end
C.w_sic = o.siconc <= 0.01;
C.w_sst = o.sst > opt.sst_min;
C.w_lat = abs(o.lat) > opt.wlat_min;
C.w_tb  = tb > 90  & tb < 180;
C.i_sic = o.siconc > 0.8;
C.i_tb  = tb > 180 & tb < 274;
C.sea   = lsm <= opt.lsm_max;
if opt.lsm_box > 0                                       % land in the neighbourhood (spill-over from the footprint)
    n = opt.lsm_box; lf = double(lsm); okl = ~isnan(lf); lf(~okl) = 1;   % no lsm = treat as land
    lb = movsum(movsum(lf, n, 1), n, 2) ./ movsum(movsum(double(okl | true), n, 1), n, 2);
    C.sea = C.sea & lb <= opt.lsm_boxmax;
end
mw = valid & C.sea & C.w_box & C.w_sic & C.w_sst & C.w_tb & C.w_lat;
mi = valid & C.sea & C.i_box & C.i_sic & C.i_tb;
end

