function [mw, mi] = tp_masks(o, valid, tb, lsm)
% Tie-point masks (Table 2 of Kolbe et al. 2024, with the changes from the meeting 2026-11-17).
%   water: siconc <= 0.01 (1 % SIC still counts as ocean), sst > 278 K, 90 K < TB < 180 K
%   ice:   siconc > 0.8,  180 K < TB < 274 K  (lower limit raised from 100 K: clear-ocean pixels
%          (TB ~ 145 K) were picked up as ice; 180 K = upper limit of the water mask, no overlap)
%   both:  ERA5 land-sea fraction lsm == 0 (coastal pixels out, land spill-over in the ESMR footprint)
% o: orbit struct from load_orbit; valid: preprocessing mask; tb: TB field used; lsm: ERA5 'lsm' [lines x 78].
sea = lsm == 0;
mw = valid & sea & o.siconc <= 0.01 & o.sst > 278 & tb > 90  & tb < 180;
mi = valid & sea & o.siconc >  0.8  &                tb > 180 & tb < 274;
end
