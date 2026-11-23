function opt = tp_opt(opt)
% Thresholds of the tie-point masks (tp_masks.m) and the tie-point outlier test (tp_outlier.m).
% Missing fields of opt get the defaults.
%   opt = tp_opt();          defaults = masks of 2026-11-23:
%                            water sst > 273 K (A4d), water |lat| > 55 deg; both: pixel ERA5 lsm = 0 AND mean lsm
%                            of the 5 x 5 box around the pixel <= 0.10 (no tie points next to land, A4c);
%                            no outlier test (tb_mad = 0; tried as 3 robust std in A4e, rejected 2026-11-23:
%                            it removes too much of the natural spread, Jo)
%   opt = tp_opt('nov20');   masks of 2026-11-20: as above but sst > 275 K
%   opt = tp_opt('nov17');   masks of 2026-11-17: sst > 278 K, no extra latitude limit, lsm == 0, no outlier test
% Why (report_notes/A4b_tp_sweep.md, A4e_tp_outliers.md): colder water reference for the RTM correction,
% smaller spread of the water SIC; no land spill-over; no unfiltered artefacts in the tie points.
% Fields: box (5x5 siconc box criteria, true), sst_min [K], wlat_min [deg], lsm_max [-] (pixel lsm),
%         lsm_box (box size, 0 = off), lsm_boxmax [-] (max mean lsm in the box),
%         tb_mad (outlier limit in robust std, 0 = off (default); applied in correct_day.m after iteration 1).
if nargin < 1 || isempty(opt), opt = struct(); end
if ischar(opt) || isstring(opt)
    switch lower(char(opt))
        case 'nov17', opt = struct('sst_min', 278, 'wlat_min', 0, 'lsm_max', 0, 'lsm_box', 0, 'tb_mad', 0);
        case 'nov20', opt = struct('sst_min', 275, 'tb_mad', 0);
        case 'nov23', opt = struct();
        otherwise, error('tp_opt: unknown preset "%s"', opt);
    end
end
d = struct('box', true, 'sst_min', 273, 'wlat_min', 55, 'lsm_max', 0, 'lsm_box', 5, 'lsm_boxmax', 0.10, 'tb_mad', 0);
for f = fieldnames(d)'
    if ~isfield(opt, f{1}) || isempty(opt.(f{1})), opt.(f{1}) = d.(f{1}); end
end
end
