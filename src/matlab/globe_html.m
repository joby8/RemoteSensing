% Build the interactive HTML globe in output/globe/:
%   ESMR_globe.html        page (libraries + coastlines inlined, works offline by double-click)
%   days/MMDD.js           one data file per day, loaded when the day is selected
% Per pixel: lat, lon, raw TB, scan position and a code byte:
%   bits 0-1 class (0 other, 1 water tie point, 2 ice tie point; ice = siconc > 0.8 as in Table 2), bit 2 ERA5 land (sst NaN),
%   bit 3 fails Eq. 1, bit 4 swath edge (scan pos 1-4/75-78), bit 5 |lat| < 50.
%   dtb = RTM correction (A6b method, iteration 2, via correct_day.m) in 0.1 K, -32768 where not corrected.
%   Correction inputs, only for corrected pixels (dtb valid, same order as the kept pixels), uint8 / int8:
%   V 0.25 kg/m2, W 0.1 m/s, L 0.02 kg/m2, Ts 260 K + 0.2 K, Ti 230 K + 0.25 K, c 1/250;
%   parts of dtb per input (dV, dW, dL, dTs, dTi) in 0.25 K (dL 0.5 K, int8). dL = not applied (L is not corrected).
% Pixels with |lat| < 50 are thinned (every 4th scan line and position) to keep the files small.
% Daily tie points per hemisphere (Table 2 clusters, uncorrected and corrected) from correct_day.m.
% Run from the project root:  matlab -batch "run('src/matlab/globe_html.m')"
% Only some days:             matlab -batch "days=[""0201"",""0202""]; run('src/matlab/globe_html.m')"
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile('src','matlab'));
files = dir(fullfile('ESMR_colocated_filtered','*.nc'));
fday  = string(regexp({files.name}, '1973m(\d{4})t', 'tokens', 'once'));
if ~exist('days','var') || isempty(days), days = unique(fday); end
outdir = fullfile('output', 'globe'); ddir = fullfile(outdir, 'days');
if ~exist(ddir, 'dir'), mkdir(ddir); end
edge = false(1, 78); edge([1:4, 75:78]) = true;

% manifest of all days that already have a data file (so re-running for one day keeps the others)
man = struct('day', {}, 'label', {}, 'n_orbits', {}, 'tp', {});
for d = days(:)'
    fi = find(fday == d);
    fn = arrayfun(@(k) fullfile(files(k).folder, files(k).name), fi, 'UniformOutput', false);
    [O, tp] = correct_day(fn, 2);                     % A6b method, iteration 2, all valid ocean pixels
    D = struct('day', char(d), 'orbits', struct('name', {}, 'lat', {}, 'lon', {}, 'tb', {}, 'code', {}, 'spos', {}, 'dtb', {}, 'inp', {}));
    for j = 1:numel(fi)
        o = O(j);
        [nl, np] = size(o.tb);
        eq1    = ~isnan(o.tb_f);
        isedge = repmat(edge, nl, 1);
        lowlat = abs(o.lat) < 50;
        code = uint8(o.mw) + 2*uint8(o.mi) + 4*uint8(isnan(o.sst)) + 8*uint8(~eq1) + 16*uint8(isedge) + 32*uint8(lowlat);
        [L, P] = ndgrid(1:nl, 1:np);
        keep = ~isnan(o.lat) & ~isnan(o.lon) & (~lowlat | (mod(L, 4) == 1 & mod(P, 4) == 1));
        tbr = o.tb; tbr(isnan(tbr)) = -3276.8;                    % -32768 = no value
        dt  = o.dtb; dt(isnan(dt)) = -3276.8;
        ck = keep & ~isnan(o.dtb);                                 % corrected pixels among the stored ones
        u8 = @(x, a, d) b64(uint8(min(max(round((x(ck) - a) / d), 0), 255)));
        i8 = @(x, d) b64(int8(min(max(round(x(ck) / d), -127), 127)));
        inp = struct('V', u8(o.V, 0, 0.25), 'W', u8(o.W, 0, 0.1), 'L', u8(o.L, 0, 0.02), ...
            'Ts', u8(o.Tsx, 260, 0.2), 'Ti', u8(o.Ti, 230, 0.25), 'c', u8(o.c, 0, 1/250), ...
            'dV', i8(o.dV, 0.25), 'dW', i8(o.dW, 0.25), 'dL', i8(o.dL, 0.5), 'dTs', i8(o.dTs, 0.25), 'dTi', i8(o.dTi, 0.25));
        t = regexp(files(fi(j)).name, 't(\d{2})(\d{2})', 'tokens', 'once');
        D.orbits(end+1) = struct('name', sprintf('%s:%s UTC', t{1}, t{2}), ...
            'lat',  b64(int16(round(o.lat(keep) * 100))), ...
            'lon',  b64(int16(round(wrapTo180(o.lon(keep)) * 100))), ...
            'tb',   b64(int16(round(tbr(keep) * 10))), ...
            'code', b64(code(keep)), ...
            'spos', b64(uint8(P(keep))), ...
            'dtb',  b64(int16(round(max(min(dt(keep), 3000), -3276.8) * 10))), ...
            'inp',  inp);
    end
    D.tp = tp;
    fid = fopen(fullfile(ddir, [char(d) '.js']), 'w');
    fwrite(fid, ['ESMR_DAY(' jsonencode(D) ');'], 'char'); fclose(fid);
    meta = struct('day', char(d), 'label', sprintf('1973-%s-%s', extractBefore(d, 3), extractAfter(d, 2)), ...
                  'n_orbits', numel(fi), 'tp', tp);
    save(fullfile(ddir, [char(d) '.mat']), 'meta');
    fprintf('%s: %d orbits\n', d, numel(fi));
end
dm = dir(fullfile(ddir, '*.mat'));
for k = 1:numel(dm), S = load(fullfile(dm(k).folder, dm(k).name)); man(end+1) = S.meta; end %#ok<SAGROW>

% page: inline libraries, coastlines, manifest and the scan-position -> angle table
html = fileread(fullfile('src', 'web', 'globe_template.html'));
libs = {'d3-array@3.2.4/dist/d3-array.min.js', 'd3-geo@3.1.0/dist/d3-geo.min.js', 'topojson-client@3.1.0/dist/topojson-client.min.js'};
for i = 1:numel(libs)
    [~, fn, ext] = fileparts(libs{i});
    tag = sprintf('<script src="https://cdn.jsdelivr.net/npm/%s"></script>', libs{i});
    assert(contains(html, tag), 'script tag not found: %s', libs{i});
    html = strrep(html, tag, ['<script>' fileread(fullfile('src', 'web', [fn ext])) '</script>']);
end
o1 = load_orbit(fullfile(files(1).folder, files(1).name));
html = strrep(html, '/*__DAYS__*/null', jsonencode(man));
html = strrep(html, '/*__SPOS__*/null', jsonencode(round(o1.theta(1, :), 2)));
html = strrep(html, '/*__LAND__*/null', fileread(fullfile('src', 'web', 'land-50m.json')));
html = ['<!doctype html>' newline '<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">' newline html];
fid = fopen(fullfile(outdir, 'ESMR_globe.html'), 'w', 'n', 'UTF-8'); fwrite(fid, html, 'char'); fclose(fid);
fprintf('saved %s (%d days)\n', fullfile(outdir, 'ESMR_globe.html'), numel(man));

function s = b64(x)
s = matlab.net.base64encode(typecast(x(:)', 'uint8'));
end

function l = wrapTo180(l)
l = mod(l + 180, 360) - 180;
end
