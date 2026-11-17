function [mw, mi, C] = tp_masks(o, valid, tb, lsm)
% Tie-point masks (Table 2 of Kolbe et al. 2024, with the changes from the meeting 2026-11-17).
%   water: siconc <= 0.01 (1 % SIC still counts as ocean), sst > 278 K, 90 K < TB < 180 K
%   ice:   siconc > 0.8,  180 K < TB < 274 K  (lower limit raised from 100 K: clear-ocean pixels
%          (TB ~ 145 K) were picked up as ice; 180 K = upper limit of the water mask, no overlap)
%   both:  ERA5 land-sea fraction lsm == 0 (coastal pixels out, land spill-over in the ESMR footprint)
% o: orbit struct from load_orbit; valid: preprocessing mask; tb: TB field used; lsm: ERA5 'lsm' [lines x 78].
% Optional 3rd output C: the single criteria as logical fields (NOT combined with valid), so other code
% (globe_html.m: per-criterion view) uses the same rule:
%   C.w_sic, C.w_sst, C.w_tb  water criteria;  C.i_sic, C.i_tb  ice criteria;  C.sea  lsm == 0 (both)
%   mw = valid & C.w_sic & C.w_sst & C.w_tb & C.sea,  mi = valid & C.i_sic & C.i_tb & C.sea
C.w_sic = o.siconc <= 0.01;
C.w_sst = o.sst > 278;
C.w_tb  = tb > 90  & tb < 180;
C.i_sic = o.siconc > 0.8;
C.i_tb  = tb > 180 & tb < 274;
C.sea   = lsm == 0;
mw = valid & C.sea & C.w_sic & C.w_sst & C.w_tb;
mi = valid & C.sea & C.i_sic & C.i_tb;
end
