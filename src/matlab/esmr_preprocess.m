function o = esmr_preprocess(o, cfg)
% Preprocessing of one orbit: outlier filters of Kolbe et al. (2024), Sect. 2.2, p. 1249, then the area masks.
% All settings in ONE struct, cfg = preproc_config(...) (see there for the fields and presets).
% Input o (from load_orbit): tb, lat, lon [lines x 78]; A [lines x 16] = Analog_0..15; sst, lsm; tb_file (DMI field).
% Output fields:
%   o.tb_f   TB after the outlier filters (analog, Eq. 1-4); NaN = removed. NOT masked by edge/latitude/land,
%            so scripts that need all positions or latitudes (b2_angle, globe) still can use it.
%   o.flag   uint8, first step (in this order) that removed the pixel:
%            0 kept | 5 analog | 1 Eq. 1 | 2 Eq. 2 | 3 Eq. 3 | 4 Eq. 4 | 6 swath edge | 7 latitude | 8 land
%            (stable code table: preproc_config.m, cfg.codes)
%            (codes 1-4 = Eq. 1-4 as before; the order of application is analog first, as in the paper)
%   o.valid  flag == 0: the pixels to use downstream
%   o.analog [lines x 1] lines flagged by the analog test with cfg.analog (also when cfg.analog.on is false)
%   o.would  struct analog/eq1/eq2/eq3/eq4/land [lines x 78]: what a DISABLED step would remove at its place in
%            the chain (eq2/eq3 'off' -> 'pixel' mode; land 'none' -> 'sst' rule); all false for enabled steps
%   o.F      diagnostics: gap, D (row-mean jump), jumps, runs, literal, cfg
%
% Eq. 2 'pixel' (our version, report_notes/A3_filters.md): a failing row pair is a "jump"; a SHORT run
% (<= lmax lines) between a jump and the jump back (opposite sign), or between a jump and a boundary
% (file start/end, data gap, row pair without valid pairs) is an offset block. Inside it only pixels that
% differ by > thr from the good lines around (linear interpolation, same position) are removed. A jump that
% brackets no short run: line i, but again only its pixels with |TB(i+1,j)-TB(i,j)| > thr.
% Eq. 2 'line' (paper as written): the whole line i of a failing pair (i, i+1) is removed.
% Eq. 3 'pixel': along track, both neighbours valid after Eq. 1-2, no gap on either side (paper).
% Eq. 3 'line' (DMI-like): tested on the RAW TB (before Eq. 1), any failing pixel removes the whole line +- pad.
% Eq. 4: sum of the win-1 |differences| of win consecutive along-track values == 0; all win removed.
% No differences across data gaps (centre distance > cfg.gap x median spacing).
if nargin < 2 || isempty(cfg), cfg = preproc_config(); end
[nl, np] = size(o.tb);
flag = zeros(nl, np, 'uint8');
switch cfg.source
    case 'raw', t = o.tb;
    case 'dmi', t = o.tb_file;
    otherwise, error('cfg.source must be ''raw'' or ''dmi''');
end

% data gaps between scan line i and i+1 (row centre = mean of the two middle positions)
clat = mean(o.lat(:, np/2:np/2+1), 2, 'omitnan'); clon = mean(o.lon(:, np/2:np/2+1), 2, 'omitnan');
ds   = gcdist(clat(1:end-1), clon(1:end-1), clat(2:end), clon(2:end));
gap  = ds > cfg.gap * median(ds, 'omitnan') | isnan(ds);        % (nl-1) x 1

% Each step: mask m of what it removes from the pixels still kept. Enabled -> applied (flag code, NaN in t);
% disabled -> only stored in o.would.<step> (what it WOULD remove at this point of the chain), for the globe.
W = struct();
% analog filter (one value per line and channel)
an = analog_lines(o.A(:, cfg.analog.channels + 1), cfg.analog);
[t, flag, W.analog] = step(t, flag, repmat(an, 1, np), 5, cfg.analog.on);

% Eq. 1
[t, flag, W.eq1] = step(t, flag, ~(t > cfg.eq1.lo & t <= cfg.eq1.hi), 1, cfg.eq1.on);

% Eq. 2: row-mean jump between line i and i+1 (n = number of valid pixel pairs)
dd = t(2:end, :) - t(1:end-1, :); dd(gap, :) = NaN;
D  = mean(abs(dd), 2, 'omitnan');  S = mean(dd, 2, 'omitnan');   % NaN where no valid pair
jump = D > cfg.eq2.thr;
mode2 = cfg.eq2.mode; if strcmp(mode2, 'off'), mode2 = 'pixel'; end
[f2, runs, lit] = eq2mask(t, dd, D, S, jump, mode2, cfg.eq2);
[t, flag, W.eq2] = step(t, flag, f2, 2, ~strcmp(cfg.eq2.mode, 'off'));

% Eq. 3: along-track spikes
mode3 = cfg.eq3.mode; if strcmp(mode3, 'off'), mode3 = 'pixel'; end
f3 = eq3mask(t, o.tb, gap, mode3, cfg.eq3);
[t, flag, W.eq3] = step(t, flag, f3, 3, ~strcmp(cfg.eq3.mode, 'off'));

% Eq. 4: win consecutive identical values along track (all removed)
f4 = eq4mask(t, gap, cfg.eq4.win);
[t, flag, W.eq4] = step(t, flag, f4, 4, cfg.eq4.on);
o.tb_f = t;

% area masks (do not change tb_f)
E = false(nl, np); E(:, cfg.edge) = true;
flag(E & flag == 0) = 6;
flag(~(abs(o.lat) >= cfg.lat_min) & flag == 0) = 7;               % NaN lat -> removed
W.land = false(nl, np);
switch cfg.land
    case 'none', L = false(nl, np); W.land = isnan(o.sst) & flag == 0;   % what the 'sst' rule would remove
    case 'sst',  L = isnan(o.sst);
    case 'lsm',  L = ~(o.lsm <= cfg.lsm_max);
    otherwise, error('cfg.land must be ''sst'', ''lsm'' or ''none''');
end
flag(L & flag == 0) = 8;
o.flag  = flag;
o.valid = flag == 0;
o.analog = an;
o.would = W;                                                       % disabled steps only (else all false)
o.F = struct('gap', gap, 'D', D, 'jumps', find(jump), 'runs', runs, 'literal', lit, 'cfg', cfg);
end

function [t, flag, w] = step(t, flag, m, code, on)
m = m & flag == 0;
if on, flag(m) = code; t(m) = NaN; w = false(size(m)); else, w = m; end
end

function [f2, runs, lit] = eq2mask(t, dd, D, S, jump, mode, c)
[nl, np] = size(t); f2 = false(nl, np); runs = zeros(0, 2); lit = zeros(0, 1);
switch mode
    case 'line'
        f2(find(jump), :) = true;                                   % line i of each failing pair (i, i+1)
    case 'pixel'
        bound = isnan(D);                                           % gap or no valid pair
        brk  = [0; find(jump | bound); nl];                         % break k = between line k and k+1
        isj  = [false; jump(brk(2:end-1)); false];
        sgn  = [0; sign(S(brk(2:end-1))); 0];
        used = false(size(brk));
        for k = 1:numel(brk) - 1
            a = brk(k); b = brk(k + 1);                             % run = lines a+1 .. b
            j0 = isj(k) && ~used(k);                                % a jump that closed the previous block
            if b - a > c.lmax || ~(j0 || isj(k + 1)), continue; end %   cannot open a new one (fix 2026-11-17)
            if j0 && isj(k + 1) && sgn(k) == sgn(k + 1), continue; end
            rows = a+1:b;
            r0 = NaN(1, np); r1 = NaN(1, np);                       % good line before (a) and after (b+1)
            if j0,         r0 = t(a, :);     end
            if isj(k + 1), r1 = t(b + 1, :); end
            w = ((rows - a) / (b + 1 - a))';
            ref = (1 - w) .* r0 + w .* r1;
            only0 = isnan(r1) & ~isnan(r0); only1 = isnan(r0) & ~isnan(r1);
            ref(:, only0) = repmat(r0(only0), numel(rows), 1);
            ref(:, only1) = repmat(r1(only1), numel(rows), 1);
            f2(rows, :) = abs(t(rows, :) - ref) > c.thr;            % NaN ref or NaN pixel -> false
            used(k) = true; used(k + 1) = true; runs(end+1, :) = [a+1 b]; %#ok<AGROW>
        end
        lit = brk(isj & ~used);                                     % jumps not bracketing a short run
        for i = lit(:)', f2(i, :) = f2(i, :) | abs(dd(i, :)) > c.thr; end
    otherwise, error('cfg.eq2.mode must be ''pixel'', ''line'' or ''off''');
end
end

function f3 = eq3mask(t, raw, gap, mode, c)
[nl, np] = size(t); f3 = false(nl, np);
switch mode
    case 'pixel'
        if nl >= 3
            up = t(2:end-1, :) - t(1:end-2, :); dn = t(3:end, :) - t(2:end-1, :);
            sp = abs(up) + abs(dn) > c.thr;
            sp(~(~gap(1:end-1) & ~gap(2:end)), :) = false;          % NaN -> false
            f3(2:end-1, :) = sp;
        end
    case 'line'                                                     % raw TB, as DMI
        if c.wrap
            sm = abs(raw - circshift(raw, 1, 1)) + abs(circshift(raw, -1, 1) - raw);
        else
            sm = abs([NaN(1, np); diff(raw)]) + abs([diff(raw); NaN(1, np)]);
        end
        f3 = repmat(dilate(any(sm > c.thr, 2), c.pad, c.wrap), 1, np);
    otherwise, error('cfg.eq3.mode must be ''pixel'', ''line'' or ''off''');
end
end

function f4 = eq4mask(t, gap, W)
[nl, np] = size(t); f4 = false(nl, np);
if nl < W, return; end
ad = abs(diff(t, 1, 1)); ad(gap, :) = NaN;                          % NaN breaks the run
s6 = movsum(ad, [0 W-2], 1, 'Endpoints', 'fill');                   % sum of W-1 diffs starting at line i
st = s6(1:nl-W+1, :) == 0;
for q = 0:W-1, f4(1+q:nl-W+1+q, :) = f4(1+q:nl-W+1+q, :) | st; end
end

function an = analog_lines(A, c)
% lines whose analog channels jump by more than c.thr, dilated by c.pad lines
nl = size(A, 1); an = false(nl, 1);
if nl < 2, return; end
switch c.mode
    case 'diff'                     % both lines of the pair
        g = any(abs(diff(A, 1, 1)) > c.thr, 2); an = [g; false] | [false; g];
    case 'gradient'                 % numpy.gradient: central inside, one-sided at the ends
        G = zeros(size(A));
        if nl > 2, G(2:end-1, :) = (A(3:end, :) - A(1:end-2, :)) / 2; end
        G(1, :) = A(2, :) - A(1, :); G(end, :) = A(end, :) - A(end-1, :);
        an = any(abs(G) > c.thr, 2);
    otherwise, error('cfg.analog.mode must be ''diff'' or ''gradient''');
end
an = dilate(an, c.pad, false);
end

function z = dilate(x, k, wrap)
x = double(x(:)); n = numel(x);
if k == 0 || n == 0, z = x > 0; return; end
if wrap
    y = movmax([x(max(n-k+1, 1):end); x; x(1:min(k, n))], [k k]); z = y(min(k, n)+1:min(k, n)+n) > 0;
else
    z = movmax(x, [k k]) > 0;
end
end

function d = gcdist(la1, lo1, la2, lo2)
% great-circle distance [km]
d = 6371 * 2 * asin(sqrt(sind((la2 - la1) / 2).^2 + cosd(la1) .* cosd(la2) .* sind((lo2 - lo1) / 2).^2));
end
