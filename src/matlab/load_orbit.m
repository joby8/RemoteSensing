function o = load_orbit(f, cfg)
% Read one ESMR swath file and prepare the inputs for the correction (A2).
% All fields are [scan lines x 78]. Values are already in K / degrees (no /10).
% Usage: o = load_orbit('ESMR_colocated_filtered/<file>.nc');  without argument the first file is used.
%        o = load_orbit(f, cfg);  cfg = preproc_config(...) sets the preprocessing (default: preproc_config()).
if nargin < 2 || isempty(cfg), cfg = preproc_config(); end
if nargin < 1 || isempty(f)
    root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    files = dir(fullfile(root, 'ESMR_colocated_filtered', '*.nc'));
    f = fullfile(files(1).folder, files(1).name);
end
rd = @(n) double(ncfast(f, n))';         % ncfast = ncread without attribute overhead; transpose: [78 x lines] -> [lines x 78]
o.tb      = rd('Brightness_temperature');
o.tb_file = rd('brightness_temperature_filtered');  % DMI field: Eq. 1 + whole scan lines (rebuilt by preset 'dmilike', A3b)
o.lat     = rd('Latitude');
o.lon     = rd('Longitude');
o.sst     = rd('sst');
o.siconc  = rd('siconc');
o.t2m     = rd('t2m');
o.theta   = repmat(load_spos2ia(), size(o.tb, 1), 1);  % incidence angle per scan position [deg]
o.W       = hypot(rd('u10'), rd('v10'));               % wind speed [m/s]
o.V       = rd('tcwv');                                % water vapour [kg/m2]
o.Ts      = o.sst;                                     % SST [K]
o.Ti      = 0.4 * o.t2m + 0.6 * 272;                   % Eq. 15 [K]
o.lsm     = rd('lsm');                                % ERA5 land-sea fraction
o.A       = zeros(size(o.tb, 1), 16);                  % analog housekeeping channels, one value per line
for q = 0:15, o.A(:, q+1) = double(ncfast(f, sprintf('Analog_%d', q))); end
% Preprocessing (esmr_preprocess.m, settings in preproc_config.m): Kolbe et al. 2024 outlier filters + area masks.
% o.tb_f = TB after the outlier filters (not masked by edge/lat/land), o.flag = step that removed the pixel
% (0 kept, 1-4 Eq. 1-4, 5 analog, 6 edge, 7 latitude, 8 land), o.valid = usable pixels, o.analog = analog-test lines.
o = esmr_preprocess(o, cfg);
end

function s = load_spos2ia()
root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
txt = fileread(fullfile(root, 'provided', 'spos2ia.txt'));
s = str2double(regexp(txt, '-?\d+\.\d+', 'match'));   % 78 values, negative = left side of swath
assert(numel(s) == 78, 'spos2ia should have 78 values');
end
