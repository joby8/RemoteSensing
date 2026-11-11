function o = load_orbit(f)
% Read one ESMR swath file and prepare the inputs for the correction (A2).
% All fields are [scan lines x 78]. Values are already in K / degrees (no /10).
% Usage: o = load_orbit('ESMR_colocated_filtered/<file>.nc');  without argument the first file is used.
if nargin < 1 || isempty(f)
    root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    files = dir(fullfile(root, 'ESMR_colocated_filtered', '*.nc'));
    f = fullfile(files(1).folder, files(1).name);
end
rd = @(n) double(ncread(f, n))';          % transpose: [78 x lines] -> [lines x 78]
o.tb      = rd('Brightness_temperature');
o.tb_f    = rd('brightness_temperature_filtered');   % NaN outside 90 K < TB <= 273.15 K (Eq. 1)
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
end

function s = load_spos2ia()
root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
txt = fileread(fullfile(root, 'provided', 'spos2ia.txt'));
s = str2double(regexp(txt, '-?\d+\.\d+', 'match'));   % 78 values, negative = left side of swath
assert(numel(s) == 78, 'spos2ia should have 78 values');
end
