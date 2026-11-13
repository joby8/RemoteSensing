% Export the data for the explainer video (video/): one example day (default 5 Feb 1973), Northern Hemisphere.
%   - every pixel of the orbit with the most tie-point pixels: inputs, filter flags, clusters,
%     dTB and SIC for iteration 1 and 2 (A6b method, same code path as correct_day.m)
%   - day statistics: cluster means/std of the RTM inputs, tie points per iteration, SIC histograms
%   - month: daily water/ice std (A6b_iterative.csv, iteration 2) and the B1 sensitivity sweep
% Run from the project root:  matlab -batch "run('src/matlab/video_export.m')"
% Output: output/video/video_data.js  (VIDEO_DATA = {...})
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile('src','matlab'));
if ~exist('vday','var') || isempty(vday), vday = "0205"; end
files = dir(fullfile('ESMR_colocated_filtered','*.nc'));
fday  = string(regexp({files.name}, '1973m(\d{4})t', 'tokens', 'once'));
fi = find(fday == vday);
fn = arrayfun(@(k) fullfile(files(k).folder, files(k).name), fi, 'UniformOutput', false);

[O1, T1] = correct_day(fn, 1);           % iteration 1 (c = ERA5 siconc)
[O2, T2] = correct_day(fn, 2);           % iteration 2 (c from iteration 1) = final
N = 'N';

% orbit with the most northern tie-point pixels
cnt = arrayfun(@(o) nnz((o.mw | o.mi) & o.lat > 0), O2);
[~, k] = max(cnt);
o = O2(k); o1 = O1(k);
edge = false(1, 78); edge([1:4, 75:78]) = true;
isedge = repmat(edge, size(o.tb, 1), 1);
north = o.lat > 0;
sic_u = (o.tb_f - T2.(N).water_u) / (T2.(N).ice_u - T2.(N).water_u);
sic1  = (o.tb_f + o1.dtb - T1.(N).water_c) / (T1.(N).ice_c - T1.(N).water_c);
sic2  = (o.tb_f + o.dtb  - T2.(N).water_c) / (T2.(N).ice_c - T2.(N).water_c);
c1 = min(max(sic1, 0), 1); c1(c1 < 0.15) = 0;            % c used in iteration 2
flags = uint8(~isnan(o.tb_f) == 0) + 2*uint8(isedge) + 4*uint8(abs(o.lat) < 50) + 8*uint8(isnan(o.sst)) ...
      + 16*uint8(o.mw) + 32*uint8(o.mi) + 64*uint8(north);
t = regexp(files(fi(k)).name, 't(\d{2})(\d{2})', 'tokens', 'once');
P = struct('name', sprintf('1973-02-%s %s:%s UTC', extractAfter(vday, 2), t{1}, t{2}), ...
    'nl', size(o.tb, 1), 'np', 78, ...
    'lat', b64(o.lat, 100), 'lon', b64(mod(o.lon + 180, 360) - 180, 100), ...
    'tb', b64(o.tb, 10), 'theta', b64(o.theta, 100), ...
    'V', b64(o.V, 10), 'W', b64(o.W, 10), 'L', b64(o.L, 1000), 'Ts', b64(o.sst, 10), 'Ti', b64(o.Ti, 10), ...
    'ci', b64(o.siconc, 1000), 'flags', matlab.net.base64encode(reshape(flags', 1, [])), ...
    'dtb1', b64(o1.dtb, 10), 'dtb2', b64(o.dtb, 10), ...
    'sic_u', b64(100*sic_u, 10), 'sic1', b64(100*sic1, 10), 'sic2', b64(100*sic2, 10), 'c1', b64(c1, 1000));

% day statistics, Northern Hemisphere, all orbits
g = @(f, m) cell2mat(arrayfun(@(q) q.(f)(q.(m) & q.lat > 0), O2, 'UniformOutput', false)');
inp = {'V','W','L','Tsx','Ti'};
for v = inp
    xw = g(v{1}, 'mw'); xi = g(v{1}, 'mi');
    nm = strrep(v{1}, 'Tsx', 'Ts');
    D.mean_w.(nm) = mean(xw); D.std_w.(nm) = std(xw);
    D.mean_i.(nm) = mean(xi); D.std_i.(nm) = std(xi);
end
D.tp = struct('water_u', T2.(N).water_u, 'ice_u', T2.(N).ice_u, 'water_1', T1.(N).water_c, 'ice_1', T1.(N).ice_c, ...
              'water_2', T2.(N).water_c, 'ice_2', T2.(N).ice_c);
D.nw = T2.(N).nw; D.ni = T2.(N).ni; D.n_orbits = numel(O2);
D.std = struct('w_u', T2.(N).w_std_u, 'w_1', T1.(N).w_std_c, 'w_2', T2.(N).w_std_c, ...
               'i_u', T2.(N).i_std_u, 'i_1', T1.(N).i_std_c, 'i_2', T2.(N).i_std_c);
% SIC histograms over the water cluster (all orbits of the day)
tbw = g('tb_f', 'mw');
dw1 = cell2mat(arrayfun(@(q) q.dtb(q.mw & q.lat > 0), O1, 'UniformOutput', false)');
dw2 = cell2mat(arrayfun(@(q) q.dtb(q.mw & q.lat > 0), O2, 'UniformOutput', false)');
edges = -40:2:60;
D.hist_edges = edges;
D.hist_u = histcounts(100*(tbw - T2.(N).water_u) / (T2.(N).ice_u - T2.(N).water_u), edges);
D.hist_2 = histcounts(100*(tbw + dw2 - T2.(N).water_c) / (T2.(N).ice_c - T2.(N).water_c), edges);
D.hist_1 = histcounts(100*(tbw + dw1 - T1.(N).water_c) / (T1.(N).ice_c - T1.(N).water_c), edges);

% month and sensitivity
M = readtable(fullfile('output', 'A6b_iterative.csv'), 'TextType', 'string', 'Delimiter', ',');
M.day = string(M.day);
M = M(M.iter == 2, :);
mon = struct('day', cellstr(M.day), 'hemi', cellstr(M.hemi), 'w_u', num2cell(M.w_sic_std_u), 'w_c', num2cell(M.w_sic_std_c), ...
             'i_u', num2cell(M.i_sic_std_u), 'i_c', num2cell(M.i_sic_std_c));
B = readtable(fullfile('output', 'B1_sensitivity.csv'), 'TextType', 'string');
sens = struct('surface', cellstr(B.surface), 'input', cellstr(B.input), 'theta', num2cell(B.theta), ...
              'per_sigma', num2cell(B.dTB_per_sigma), 'sigma', num2cell(B.sigma), 'mean', num2cell(B.mean));

% full theta sweep, same base state and sigma as b1_sensitivity.m (Feb 1973 clusters, both hemispheres, w/o 28 Feb)
A = load(fullfile('output', 'A6b_pixels.mat'), 'P'); A = A.P([A.P.day] ~= "0228");
th = 0:1:64; sw = struct();
active = {{'V','W','L','Ts'}, {'V','L','Ti'}}; cls = {'water','ice'};
for c = 1:2
    s = A([A.cls] == c);
    for v = {'V','W','L','Ts','Ti'}, X.(v{1}) = double(vertcat(s.(v{1}))); end
    X.Ts(isnan(X.Ts)) = 271.35;
    for v = {'V','W','L','Ts','Ti'}, Mn.(v{1}) = mean(X.(v{1})); SD.(v{1}) = std(X.(v{1})); end
    base = esmr_rtm_vec(Mn.V, Mn.W, Mn.L, Mn.Ts, Mn.Ti, c - 1, th);
    sw.(cls{c}).base = round(base, 2); sw.(cls{c}).mean = Mn; sw.(cls{c}).sigma = SD;
    for v = active{c}
        Q = Mn; Q.(v{1}) = Mn.(v{1}) + SD.(v{1});
        sw.(cls{c}).(v{1}) = round(esmr_rtm_vec(Q.V, Q.W, Q.L, Q.Ts, Q.Ti, c - 1, th) - base, 3);
    end
end
sw.theta = th;

% one example water pixel of the orbit with a large correction: inputs, reference state, both RTM runs
cand = find(o.mw & north & abs(o.dtb) > 7 & abs(o.dtb) < 12 & sic_u > 0.08);
[~, j] = min(abs(sic2(cand))); j = cand(j);              % clear case: raw SIC too high, corrected close to 0
[r, q] = ind2sub(size(o.tb), j);
cj = c1(j); Mw = D.mean_w; Mi = D.mean_i;
ref = @(f) (1 - cj) * Mw.(f) + cj * Mi.(f);
ex = struct('line', r, 'pos', q, 'lat', o.lat(j), 'lon', o.lon(j), 'theta', o.theta(j), 'tb', o.tb_f(j), ...
    'V', o.V(j), 'W', o.W(j), 'L', o.L(j), 'Ts', o.sst(j), 'Ti', o.Ti(j), 'ci', o.siconc(j), 'c', cj, ...
    'ref', struct('V', ref('V'), 'W', ref('W'), 'L', ref('L'), 'Ts', ref('Ts'), 'Ti', ref('Ti')));
ex.rtm_ref = esmr_rtm_vec(ref('V'), ref('W'), ref('L'), ref('Ts'), ref('Ti'), cj, o.theta(j));
ex.rtm_pix = esmr_rtm_vec(o.V(j), o.W(j), ref('L'), o.sst(j), o.Ti(j), cj, o.theta(j));
ex.dtb = o.dtb(j); ex.sic_u = 100*sic_u(j); ex.sic2 = 100*sic2(j);

S = struct('orbit', P, 'day', D, 'month', mon, 'sens', sens, 'sweep', sw, 'example', ex);
outdir = fullfile('output', 'video'); if ~exist(outdir, 'dir'), mkdir(outdir); end
fid = fopen(fullfile(outdir, 'video_data.js'), 'w');
fwrite(fid, ['VIDEO_DATA = ' jsonencode(S) ';'], 'char'); fclose(fid);
fprintf('orbit %s: %d lines, %d N tie-point pixels; saved %s\n', P.name, P.nl, cnt(k), fullfile(outdir, 'video_data.js'));

function s = b64(x, scale)
% int16, row-major [line, position]; NaN -> -32768
y = round(x' * scale); y(isnan(y)) = -32768; y = max(min(y, 32767), -32768);
s = matlab.net.base64encode(typecast(int16(y(:))', 'uint8'));
end
