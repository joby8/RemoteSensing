% Build the interactive HTML globe in output/globe/:
%   ESMR_globe.html        page (libraries + coastlines inlined, works offline by double-click)
%   days/MMDD.js           one data file per day, loaded when the day is selected
% Day file (format of 2026-11-17, v3): ESMR_DAY({day, cfg, tp, orbits}); arrays are base64 typed arrays.
%   cfg    = the preprocessing settings used (preproc_config.m), the page builds its step captions from it.
%   tp     = daily tie points per hemisphere (tp_masks.m clusters, uncorrected and corrected) from correct_day.m
%            with opts.extra = true (v3): tp.N/S also has w_mean_u/c, i_mean_u/c [% SIC]; it1 (iteration 1:
%            water_c, ice_c [K], w_std_c, i_std_c, w_mean_c [%]); X.without_V/W/Ts/Ti, X.L_pixel (water_c, ice_c [K],
%            w_std, i_std, w_mean [%]; Task 2, = b1c_exclusion.m / b1i_L_study.m); spos (Task 3, = b2_angle.m):
%            w_n, w_s1u, w_s2u, w_s1c, w_s2c, i_n, ... = 1x78 count, sum, sum of squares of SIC [%] raw (u) and
%            corrected (c) per scan position over the cluster-criteria pixels incl. the swath edge.
%            The same tp is in the manifest (days/*.mat meta), so the page can average over days.
%   orbit  = {name, lpc, lat, lon, tb, spos, flag, bits, dtb, inp, la, lao, l2, l3, l3o [, would, p3]}
%   Pixels are stored ROW-MAJOR (scan line by scan line); lpc (uint8, one per scan line) = number of stored pixels
%   of that line, so the page recovers the line number of every pixel.
%   Per pixel:
%     lat, lon   int16, 0.01 deg            tb    int16, raw TB in 0.1 K (-32768 = none)   spos uint8 1..78
%     flag       uint8 = o.flag of esmr_preprocess.m (step that removed the pixel; table cfg.codes:
%                0 kept, 5 analog, 1 Eq. 1, 2 Eq. 2, 3 Eq. 3, 4 Eq. 4, 6 swath edge, 7 latitude, 8 land)
%     bits       uint8: bits 0-5 = tie-point criteria of tp_masks.m (3rd output), only set for o.valid pixels:
%                0 water siconc <= 0.01 and 5x5 box mean < 0.01, 1 water sst > 278 K, 2 water 90 < TB < 180 K, 3 lsm == 0 (both),
%                4 ice siconc > 0.8 and 5x5 box mean > 0.8, 5 ice 180 < TB < 274 K;  water cluster = bits 0-3, ice = bits 3-5 (= o.mw/o.mi)
%                bit 6 thinned (|lat| < cfg.lat_min, stored every 4th line and position, counts x 16),
%                bit 7 ERA5 sst missing (= land for cfg.land 'sst')
%     would      uint8 (only if any bit set): what a DISABLED step would remove (o.would): bit 0 analog, 1 Eq. 1,
%                2 Eq. 2, 3 Eq. 3, 4 Eq. 4, 5 land
%     dtb        int16, RTM correction (A6b method, iteration 2, via correct_day.m) in 0.1 K, -32768 = not corrected.
%                v3: also set for swath-edge pixels (flag 6) that pass latitude and land (B2 method: corrected with
%                the inner-swath clusters/tie points); edge-corrected pixel = flag == 6 && dtb != -32768.
%   Per scan line (reason values for the hover card, int16 0.1 units, -32768 = none; int8 offsets):
%     la/lao     analog test: largest housekeeping jump of the line that triggered (+ its offset in lines, pad)
%     l2         Eq. 2: row-mean jump D [K] of the jump(s) that removed this line / bracket its offset block
%     l3/l3o     Eq. 3 'line' mode: largest raw along-track spike of the triggering line, offset (+-pad) to it
%     p3         (only Eq. 3 'pixel' mode) spike [0.1 K] per pixel with flag 3 or would-Eq. 3, in stored order
%   Correction inputs, only for corrected pixels (dtb valid, same order as the stored pixels), uint8 / int8:
%   V 0.25 kg/m2, W 0.1 m/s, L 0.02 kg/m2, Ts 260 K + 0.2 K, Ti 230 K + 0.25 K, c 1/250;
%   parts of dtb per input (dV, dW, dL, dTs, dTi) in 0.25 K (dL 0.5 K, int8). dL = not applied (L is not corrected).
%   v3, also in inp (int8, clipped to +-127, same order): d1 = (dtb iteration 1 - dtb) in 0.25 K;
%   xV, xW, xTs, xTi = (dtb without that input - dtb) in 0.25 K (exclusion test, b1c_exclusion.m);
%   xL = (dtb with the pixel's own L - dtb) in 0.5 K (L study variant a, b1i_L_study.m). Decode: dtb + q*step.
% Preprocessing settings: variable cfg (default preproc_config()), e.g. cfg = preproc_config('paper'); before run().
% Run from the project root:  matlab -batch "run('src/matlab/globe_html.m')"
% Only some days:             matlab -batch "days=[""0201"",""0202""]; run('src/matlab/globe_html.m')"
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile('src','matlab'));
files = dir(fullfile('ESMR_colocated_filtered','*.nc'));
fday  = string(regexp({files.name}, '1973m(\d{4})t', 'tokens', 'once'));
if ~exist('days','var') || isempty(days), days = unique(fday); end
outdir = fullfile('output', 'globe'); ddir = fullfile(outdir, 'days');
if ~exist(ddir, 'dir'), mkdir(ddir); end
if ~exist('cfg', 'var') || isempty(cfg), cfg = preproc_config(); end

% manifest of all days that already have a data file (so re-running for one day keeps the others)
man = struct('day', {}, 'label', {}, 'n_orbits', {}, 'tp', {});
for d = days(:)'
    fi = find(fday == d);
    fn = arrayfun(@(k) fullfile(files(k).folder, files(k).name), fi, 'UniformOutput', false);
    [O, tp] = correct_day(fn, 2, cfg, struct('extra', true));   % A6b method, iteration 2, valid + swath-edge pixels
    D = struct('day', char(d), 'cfg', cfg, 'orbits', {{}});
    for j = 1:numel(fi)
        o = O(j);
        [nl, np] = size(o.tb);
        v = o.valid;
        [mw, mi, C] = tp_masks(o, v, o.tb_f, o.lsm);           % same call as correct_day.m
        assert(isequal(mw, o.mw) && isequal(mi, o.mi), 'tp_masks criteria differ from correct_day clusters');
        lowlat = abs(o.lat) < cfg.lat_min;
        bits = uint8(C.w_sic & C.w_box & v) + 2*uint8(C.w_sst & v) + 4*uint8(C.w_tb & v) + 8*uint8(C.sea & v) ...
             + 16*uint8(C.i_sic & C.i_box & v) + 32*uint8(C.i_tb & v) + 64*uint8(lowlat) + 128*uint8(isnan(o.sst));
        Wd = o.would;
        would = uint8(Wd.analog) + 2*uint8(Wd.eq1) + 4*uint8(Wd.eq2) + 8*uint8(Wd.eq3) + 16*uint8(Wd.eq4) + 32*uint8(Wd.land);
        [L, P] = ndgrid(1:nl, 1:np);
        keep = ~isnan(o.lat) & ~isnan(o.lon) & (~lowlat | (mod(L, 4) == 1 & mod(P, 4) == 1));
        R = @(x) rsel(x, keep);                                    % row-major selection of the stored pixels
        tbr = o.tb; tbr(isnan(tbr)) = -3276.8;                     % -32768 = no value
        dt  = o.dtb; dt(isnan(dt)) = -3276.8;
        ck = keep & ~isnan(o.dtb);                                 % corrected pixels among the stored ones (incl. edge)
        u8 = @(x, a, d) b64(uint8(min(max(round((rsel(x, ck) - a) / d), 0), 255)));
        i8 = @(x, d) b64(int8(min(max(round(rsel(x, ck) / d), -127), 127)));
        inp = struct('V', u8(o.V, 0, 0.25), 'W', u8(o.W, 0, 0.1), 'L', u8(o.L, 0, 0.02), ...
            'Ts', u8(o.Tsx, 260, 0.2), 'Ti', u8(o.Ti, 230, 0.25), 'c', u8(o.c, 0, 1/250), ...
            'dV', i8(o.dV, 0.25), 'dW', i8(o.dW, 0.25), 'dL', i8(o.dL, 0.5), 'dTs', i8(o.dTs, 0.25), 'dTi', i8(o.dTi, 0.25), ...
            'd1', i8(o.dtb1 - o.dtb, 0.25), 'xV', i8(o.dx.V - o.dtb, 0.25), 'xW', i8(o.dx.W - o.dtb, 0.25), ...
            'xTs', i8(o.dx.Ts - o.dtb, 0.25), 'xTi', i8(o.dx.Ti - o.dtb, 0.25), 'xL', i8(o.dx.L - o.dtb, 0.5));
        rs = reasons(o, cfg);
        t = regexp(files(fi(j)).name, 't(\d{2})(\d{2})', 'tokens', 'once');
        ob = struct('name', sprintf('%s:%s UTC', t{1}, t{2}), ...
            'lpc',  b64(uint8(sum(keep, 2))), ...
            'lat',  b64(int16(round(R(o.lat) * 100))), ...
            'lon',  b64(int16(round(wrapTo180(R(o.lon)) * 100))), ...
            'tb',   b64(int16(round(R(tbr) * 10))), ...
            'spos', b64(uint8(R(P))), ...
            'flag', b64(uint8(R(o.flag))), ...
            'bits', b64(uint8(R(bits))), ...
            'dtb',  b64(int16(round(max(min(R(dt), 3000), -3276.8) * 10))), ...
            'inp',  inp, ...
            'la', b64(q16(rs.la)), 'lao', b64(int8(rs.lao)), 'l2', b64(q16(rs.l2)), ...
            'l3', b64(q16(rs.l3)), 'l3o', b64(int8(rs.l3o)));
        if any(would(keep)), ob.would = b64(uint8(R(would))); end
        if isfield(rs, 'p3')                                        % Eq. 3 pixel mode: spike per removed pixel
            m3 = keep & (o.flag == 3 | Wd.eq3);
            ob.p3 = b64(q16(rsel(rs.p3, m3)));
        end
        D.orbits{end+1} = ob;
    end
    D.tp = tp;
    fid = fopen(fullfile(ddir, [char(d) '.js']), 'w');
    fwrite(fid, ['ESMR_DAY(' jsonencode(D) ');'], 'char'); fclose(fid);
    meta = struct('day', char(d), 'label', sprintf('1973-%s-%s', extractBefore(d, 3), extractAfter(d, 2)), ...
                  'n_orbits', numel(fi), 'tp', tp);
    save(fullfile(ddir, [char(d) '.mat']), 'meta');
    fprintf('%s: %d orbits, flag counts (code 0..8): %s\n', d, numel(fi), ...
        num2str(sum(cell2mat(arrayfun(@(o) histcounts(double(o.flag(:)), -0.5:1:8.5), O(:), 'UniformOutput', false)), 1)));
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

function v = rsel(x, m)
% values of x at mask m, scan line by scan line (row-major)
xt = x.'; v = xt(m.');
end

function r = reasons(o, cfg)
% Values behind each outlier step, per scan line, for the hover card. Recomputed from esmr_preprocess outputs
% (o.F) and the same formulas; they explain the flag, they do not decide it.
[nl, np] = size(o.tb);
% analog: largest channel jump of each line (both lines of a pair in 'diff' mode), nearest triggering line
A = o.A(:, cfg.analog.channels + 1); g = NaN(nl, 1);
if nl >= 2
    switch cfg.analog.mode
        case 'diff'
            dA = max(abs(diff(A, 1, 1)), [], 2); g = max([dA; -Inf], [-Inf; dA]);
        otherwise
            G = zeros(size(A));
            if nl > 2, G(2:end-1, :) = (A(3:end, :) - A(1:end-2, :)) / 2; end
            G(1, :) = A(2, :) - A(1, :); G(end, :) = A(end, :) - A(end-1, :);
            g = max(abs(G), [], 2);
    end
end
[r.la, r.lao] = trig(g, cfg.analog.thr, cfg.analog.pad, false);
% Eq. 2: row-mean jump D of pair (i, i+1); offset blocks get the larger of their bracketing jumps
Dd = o.F.D; r.l2 = NaN(nl, 1);
if strcmp(cfg.eq2.mode, 'line')
    r.l2(o.F.jumps) = Dd(o.F.jumps);
else
    for k = 1:size(o.F.runs, 1)
        a = o.F.runs(k, 1) - 1; b = o.F.runs(k, 2); e = [];
        if a >= 1, e(end+1) = Dd(a); end %#ok<AGROW>
        if b <= nl - 1, e(end+1) = Dd(b); end %#ok<AGROW>
        r.l2(a+1:b) = max([e, NaN]);
    end
    r.l2(o.F.literal) = Dd(o.F.literal);
end
% Eq. 3
c3 = cfg.eq3; r.l3 = NaN(nl, 1); r.l3o = zeros(nl, 1);
if strcmp(c3.mode, 'line')
    raw = o.tb;
    if c3.wrap, sm = abs(raw - circshift(raw, 1, 1)) + abs(circshift(raw, -1, 1) - raw);
    else,       sm = abs([NaN(1, np); diff(raw)]) + abs([diff(raw); NaN(1, np)]); end
    [r.l3, r.l3o] = trig(max(sm, [], 2), c3.thr, c3.pad, c3.wrap);
else                                                % 'pixel' (or 'off' -> what pixel mode would remove)
    t = o.tb; if strcmp(cfg.source, 'dmi'), t = o.tb_file; end
    t(ismember(o.flag, [5 1 2])) = NaN;             % TB entering Eq. 3 = after analog, Eq. 1, Eq. 2
    gap = o.F.gap; p3 = NaN(nl, np);
    if nl >= 3
        sp = abs(t(2:end-1, :) - t(1:end-2, :)) + abs(t(3:end, :) - t(2:end-1, :));
        sp(~(~gap(1:end-1) & ~gap(2:end)), :) = NaN;
        p3(2:end-1, :) = sp;
    end
    r.p3 = p3;
end
end

function [val, off] = trig(lm, thr, pad, wrap)
% for each line: value of the nearest line within +-pad whose lm > thr (own line first), and its offset
n = numel(lm); val = NaN(n, 1); off = zeros(n, 1); ok = lm > thr;
for dd = [0, reshape([-(1:pad); 1:pad], 1, [])]
    jj = (1:n)' + dd; if wrap, jj = mod(jj - 1, n) + 1; end
    in = jj >= 1 & jj <= n; cand = false(n, 1); cand(in) = ok(jj(in));
    u = cand & isnan(val); val(u) = lm(jj(u)); off(u) = dd;
end
end

function y = q16(x)
% int16 in 0.1 units, NaN -> -32768
y = int16(round(min(max(x, -3276.7), 3276.7) * 10)); y(isnan(x)) = -32768;
end

function s = b64(x)
s = matlab.net.base64encode(typecast(x(:)', 'uint8'));
end

function l = wrapTo180(l)
l = mod(l + 180, 360) - 180;
end
