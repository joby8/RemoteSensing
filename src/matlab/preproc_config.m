function cfg = preproc_config(name)
% Settings of the preprocessing step (esmr_preprocess.m), one struct for all filters and masks.
% Steps in the paper's order (Kolbe et al. 2024, Sect. 2.2, p. 1249): analog filter -> Eq. 1 -> 2 -> 3 -> 4
% -> swath edges; then our area masks: latitude, land.
%   cfg = preproc_config();           % default (= what load_orbit uses without a cfg)
%   cfg = preproc_config('paper');    % literal paper: analog filter on, Eq. 2 removes whole lines
%   cfg = preproc_config('dmilike');  % our rebuild of DMI's 'brightness_temperature_filtered' (see A3b notes)
%   cfg = preproc_config('dmi');      % DMI's prefiltered field itself, no own outlier filters
% Change single fields afterwards, e.g. cfg.eq2.mode = 'off'; o = load_orbit(f, cfg);
%
% o.flag code table (stable; = first step that removed the pixel, steps applied in this order):
%   step order  code  step                     cfg field
%   0           0     kept (o.valid)           -
%   1           5     analog filter            cfg.analog
%   2           1     Eq. 1  TB range          cfg.eq1
%   3           2     Eq. 2  scan-line jump    cfg.eq2
%   4           3     Eq. 3  along-track spike cfg.eq3
%   5           4     Eq. 4  stuck values      cfg.eq4
%   6           6     swath edge               cfg.edge
%   7           7     latitude                 cfg.lat_min
%   8           8     land                     cfg.land
% Codes 1-4 = Eq. 1-4 (unchanged since 2026-11-17). cfg.codes holds this table (code -> name, in step order).
% A disabled step still reports what it WOULD remove in o.would.<step> (esmr_preprocess.m), not applied.
if nargin < 1 || isempty(name), name = 'default'; end
cfg.name   = char(name);
cfg.codes  = struct('code', {0, 5, 1, 2, 3, 4, 6, 7, 8}, ...
    'step', {'kept', 'analog', 'eq1', 'eq2', 'eq3', 'eq4', 'edge', 'lat', 'land'}, ...
    'label', {'kept', 'analog filter', 'Eq. 1 TB outside range', 'Eq. 2 scan-line jump', ...
              'Eq. 3 along-track spike', 'Eq. 4 stuck values', 'swath edge', 'low latitude', 'land'});
cfg.source = 'raw';            % 'raw' = Brightness_temperature, 'dmi' = brightness_temperature_filtered
% analog filter: |gradient| of the analog housekeeping channels Analog_<k> > thr removes the whole scan line
cfg.analog = struct('on', false, ...
    'thr', 10, ...
    'mode', 'diff', ...        % 'diff' = A(i+1)-A(i), both lines of the pair; 'gradient' = central (numpy.gradient)
    'channels', 0:15, ...      % which Analog_<k> are tested
    'pad', 0);                 % extra lines removed on each side of a flagged line
% Eq. 1: lo < TB <= hi
cfg.eq1 = struct('on', true, 'lo', 90, 'hi', 273.15);
% Eq. 2: row mean |TB(i+1,j) - TB(i,j)| > thr
%   'pixel' = only the shifted pixels of short offset blocks (our version), 'line' = remove line i (paper), 'off'
cfg.eq2 = struct('mode', 'pixel', 'thr', 50, 'lmax', 20);   % lmax: longest offset block [lines] ('pixel' only)
% Eq. 3: |p(i)-p(i-1)| + |p(i+1)-p(i)| > thr along track
%   'pixel' = single pixel, after Eq. 1-2 (paper), 'line' = DMI-like: test on the raw TB, remove whole lines +- pad,
%   'off'. wrap = compare the last and first line of the file (DMI does this, numpy.roll), only for 'line'.
cfg.eq3 = struct('mode', 'line', 'thr', 150, 'pad', 1, 'wrap', false);   % default 2026-11-17 (Jo): spike + ±1 line buffer (degraded neighbour lines), no wrap
% Eq. 4: win consecutive identical values along track (all win removed)
cfg.eq4 = struct('on', true, 'win', 7);
cfg.gap = 2.5;                 % data gap: centre distance of consecutive lines > gap x median (no differences across)
cfg.edge = [];                 % scan positions removed: none (Tonboe 2026-11-24: keep the outer positions);
                               % paper: [1:4, 75:78] (preset 'paper')
cfg.lat_min = 50;              % keep |lat| >= lat_min (meeting 2026-11-10; paper Table 2: 32 N / 48 S)
cfg.land = 'sst';              % 'sst' = ERA5 SST missing, 'lsm' = ERA5 lsm > lsm_max, 'none'
cfg.lsm_max = 0;

switch lower(cfg.name)
    case 'default'
    case 'paper'
        cfg.analog.on = true; cfg.analog.mode = 'gradient';
        cfg.eq2.mode = 'line'; cfg.eq3.mode = 'pixel';
        cfg.edge = [1:4, 75:78];
    case 'dmilike'
        cfg.analog = struct('on', true, 'thr', 10, 'mode', 'gradient', 'channels', 0:14, 'pad', 5);
        cfg.eq2.mode = 'off';
        cfg.eq3 = struct('mode', 'line', 'thr', 150, 'pad', 1, 'wrap', true);
    case 'dmi'
        cfg.source = 'dmi';    % Eq. 1 then only marks DMI's NaNs (DMI already applied Eq. 1)
        cfg.eq2.mode = 'off'; cfg.eq3.mode = 'off'; cfg.eq4.on = false;
    otherwise
        error('preproc_config: unknown preset "%s"', name);
end
end
