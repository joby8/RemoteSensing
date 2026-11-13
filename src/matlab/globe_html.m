% Build the interactive HTML globe in output/globe/:
%   ESMR_globe.html        page (libraries + coastlines inlined, works offline by double-click)
%   days/MMDD.js           one data file per day, loaded when the day is selected
% Per pixel: lat, lon, raw TB, scan position and a code byte:
%   bits 0-1 class (0 other, 1 water tie point, 2 ice tie point), bit 2 ERA5 land (sst NaN),
%   bit 3 fails Eq. 1, bit 4 swath edge (scan pos 1-4/75-78), bit 5 |lat| < 50.
% Pixels with |lat| < 50 are thinned (every 4th scan line and position) to keep the files small.
% Daily tie points per hemisphere as in a5_sic.m.
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
    D = struct('day', char(d), 'orbits', struct('name', {}, 'lat', {}, 'lon', {}, 'tb', {}, 'code', {}, 'spos', {}));
    wtb = {[], []}; itb = {[], []};
    for k = fi
        o = load_orbit(fullfile(files(k).folder, files(k).name));
        [nl, np] = size(o.tb);
        eq1   = ~isnan(o.tb_f);
        isedge = repmat(edge, nl, 1);
        lowlat = abs(o.lat) < 50;
        valid = eq1 & ~isedge & ~lowlat;
        tb    = o.tb_f;
        water = valid & o.siconc == 0    & o.sst > 278 & tb > 90  & tb < 180;
        ice   = valid & o.siconc >= 0.95 &                tb > 100 & tb < 274;
        for h = 1:2
            hs = (o.lat > 0) == (h == 1);
            wtb{h} = [wtb{h}; tb(water & hs)];
            itb{h} = [itb{h}; tb(ice & hs)];
        end
        code = uint8(water) + 2*uint8(ice) + 4*uint8(isnan(o.sst)) + 8*uint8(~eq1) + 16*uint8(isedge) + 32*uint8(lowlat);
        [L, P] = ndgrid(1:nl, 1:np);
        keep = ~isnan(o.lat) & ~isnan(o.lon) & (~lowlat | (mod(L, 4) == 1 & mod(P, 4) == 1));
        tbr = o.tb; tbr(isnan(tbr)) = -3276.8;                    % -32768 = no value
        t = regexp(files(k).name, 't(\d{2})(\d{2})', 'tokens', 'once');
        D.orbits(end+1) = struct('name', sprintf('%s:%s UTC', t{1}, t{2}), ...
            'lat',  b64(int16(round(o.lat(keep) * 100))), ...
            'lon',  b64(int16(round(wrapTo180(o.lon(keep)) * 100))), ...
            'tb',   b64(int16(round(tbr(keep) * 10))), ...
            'code', b64(code(keep)), ...
            'spos', b64(uint8(P(keep))));
    end
    for h = 'NS'
        j = (h == 'S') + 1;
        tp.(h) = struct('water', mean(wtb{j}), 'ice', mean(itb{j}), 'nw', numel(wtb{j}), 'ni', numel(itb{j}), ...
                        'sic_std', 100 * std((wtb{j} - mean(wtb{j})) / (mean(itb{j}) - mean(wtb{j}))));
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
