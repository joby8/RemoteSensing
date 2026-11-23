function rerun_all(from)
% Recompute every result that depends on the tie-point masks (tp_opt.m) and the SIC clipping (correct_day.m),
% in dependency order. Each script runs in its own workspace (no variables leak between scripts).
%   matlab -batch "addpath('src/matlab'); rerun_all"            all steps
%   matlab -batch "addpath('src/matlab'); rerun_all('b7')"      start at step 'b7' (after a crash)
% Not included: globe_html (day files; run it on its own, ~10 min), video_export (not used any more),
% a5_sic / a6_corrected (early steps with their own masks, superseded by A6b), sweeps a4b-a4e.
% The globe's month view (output/globe/feb1973.js) is written by c2_feb1973_books.
steps = {
    'a4',  'a4_mask',              ''        % A4 mask figure
    'a6b', 'a6b_iterative',        ''        % A6b: A6b_iterative.csv, A6b_pixels.mat (input of all B1 scripts)
    'b1',  'b1_sensitivity',       ''
    'b1b', 'b1b_tornado',          ''
    'b1c', 'b1c_exclusion',        ''
    'b1d', 'b1d_sweep',            ''
    'b1e', 'b1e_sweep_sic',        ''
    'b1f', 'b1f_scatter_ow',       ''
    'b1g', 'b1g_scatter_ice',      ''
    'b1h', 'b1h_scatter_all',      ''
    'b1i', 'b1i_L_study',          ''
    'b2',  'b2_angle',             ''
    'b7',  'b7_correction_map',    ''
    'c1',  'c1_sp459_compare',     ''        % day caches output/C1_cache are rebuilt when the masks changed
    'c2',  'c2_feb1973_books',     ''        % also output/globe/feb1973.js (globe month view)
    'a3bd','a3b_validate_filters', 'd'       % only part (d): downstream numbers per preset
    'gp',  'globe_plot',           ''        % static globe PNGs (A3/A4)
    };
k0 = 1;
if nargin && ~isempty(from), k0 = find(strcmp(steps(:,1), from)); assert(~isempty(k0), 'unknown step %s', from); end
root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
for k = k0:size(steps, 1)
    cd(root); t0 = tic;
    fprintf('\n===== %s (%s) =====\n', steps{k,1}, steps{k,2});
    runone(steps{k,2}, steps{k,3});
    close all force;
    fprintf('===== %s done in %.1f min =====\n', steps{k,1}, toc(t0)/60);
end
cd(root);
end

function runone(name, parts) %#ok<INUSD>  parts is read by a3b_validate_filters
addpath(fullfile('src', 'matlab'));
if isempty(parts), clear parts; end
eval(name);
end
