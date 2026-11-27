function rerun_all(from, mode)
% Recompute every result that depends on the tie-point masks (tp_opt.m), the preprocessing (preproc_config.m)
% and the SIC clipping (correct_day.m), in dependency order. Each script runs in its own workspace.
%   matlab -batch "addpath('src/matlab'); rerun_all"                 all steps, PARALLEL (default)
%   matlab -batch "addpath('src/matlab'); rerun_all('', 'serial')"   all steps one after the other
%   matlab -batch "addpath('src/matlab'); rerun_all('b7')"           serial, start at step 'b7' (after a crash)
%   rerun_all({'b2','c3'})                                           only these steps, serial
% Parallel mode (2026-11-24): stage 1 (a4, a6b) runs here; all later steps only need A6b_pixels.mat /
% A6b_iterative.csv or nothing, so they run in parallel as separate MATLAB processes (`matlab -batch`, no
% Parallel Computing Toolbox needed). Logs: logs/rerun_<group>.log.
% Not included: video_export (not used any more), a5_sic / a6_corrected (superseded by A6b), sweeps a4b-a4e.
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
    'c2b', 'c2b_prof_figures',     ''        % presentation figures C2b_*.png (reads output/C2_results.mat)
    'c2c', 'c2c_image_analysis',   ''        % image-analysis figures C2c_*.png (reads output/C2_results.mat)
    'c2d', 'c2d_sp489_side_by_side', ''      % Arctic side by side C2_sp489_side_by_side.png
    'a3bd','a3b_validate_filters', 'd'       % only part (d): downstream numbers per preset
    'gp',  'globe_plot',           ''        % static globe PNGs (A3/A4)
    'b8',  'b8_uncertainty',       ''        % uncertainty maps (30 km grid)
    'c3',  'c3_low_case',          ''        % low-pressure example, 12 Feb
    'gh',  'globe_html',           ''        % interactive globe, day files output/globe/days
    'a2',  'a2_plot',              ''        % A2 TB maps
    'a3',  'a3_filter',            ''        % A3 filtered TB map (depends on cfg.edge)
    'a3babc','a3b_validate_filters','abc'    % A3b parts (a)-(c): filter validation figures
    };
% parallel groups after stage 1 (balanced by run time)
groups = {
    {'b1','b1b','b1c','b1d','b1e','b1f','b1g','b1h','b1i'}
    {'b2','c3','gp'}
    {'b7'}
    {'c1'}
    {'c2','c2b','c2c','c2d'}
    {'a3bd'}
    {'a2','a3','a3babc'}
    {'b8'}
    {'gh'}
    };
root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
if nargin < 1, from = ''; end
if nargin < 2 || isempty(mode), mode = 'parallel'; end
if iscell(from), runsteps(steps, find(ismember(steps(:,1), from))', root); return, end
if ~isempty(from), mode = 'serial'; end
t0 = tic;
switch mode
    case 'serial'
        k0 = 1;
        if ~isempty(from), k0 = find(strcmp(steps(:,1), from)); assert(~isempty(k0), 'unknown step %s', from); end
        runsteps(steps, k0:size(steps, 1), root);
    case 'parallel'
        runsteps(steps, find(ismember(steps(:,1), {'a4','a6b'}))', root);
        ldir = fullfile(root, 'logs'); if ~exist(ldir, 'dir'), mkdir(ldir); end
        mexe = fullfile(matlabroot, 'bin', 'matlab');
        done = strings(numel(groups), 1); pid = zeros(numel(groups), 1); cmdl = cell(numel(groups), 1);
        for g = 1:numel(groups)
            name = strjoin(groups{g}, '_');
            done(g) = fullfile(ldir, "rerun_" + name + ".done");
            if exist(done(g), 'file'), delete(done(g)); end
            % one small runner script per group (no quoting of MATLAB code on the shell command line)
            runner = fullfile(ldir, "rerun_" + name + "_runner.m");
            lst = "{" + strjoin("'" + string(groups{g}) + "'", ',') + "}";
            fid = fopen(runner, 'w');
            fprintf(fid, 'cd(''%s''); addpath(fullfile(''src'', ''matlab'')); s = 0;\n', root);
            fprintf(fid, 'try, rerun_all(%s); catch e, disp(getReport(e)); s = 1; end\n', lst);
            fprintf(fid, 'fid = fopen(''%s'', ''w''); fprintf(fid, ''%%d'', s); fclose(fid);\n', done(g));
            fclose(fid);
            [~, out] = system(sprintf('"%s" -batch "run(''%s'')" > "%s" 2>&1 & echo $!', mexe, runner, ...
                fullfile(ldir, "rerun_" + name + ".log")));
            pid(g) = str2double(strtrim(out)); cmdl{g} = sprintf('"%s" -batch "run(''%s'')" >> "%s" 2>&1 & echo $!', ...
                mexe, runner, fullfile(ldir, "rerun_" + name + ".log"));
            fprintf('started group %d (pid %d): %s\n', g, pid(g), name);
            pause(4);                                     % stagger the starts: 8 MATLABs starting at once can crash one
        end
        retried = false(numel(groups), 1);
        fail = false(numel(groups), 1);
        while true
            alive = arrayfun(@(p) system(sprintf('kill -0 %d 2>/dev/null', p)) == 0, pid);
            ok = arrayfun(@(f) exist(f, 'file') == 2, done);   % after 'alive': a done file written just before exit counts
            crashed = ~ok & ~alive & ~fail;               % process gone without a done file = crashed
            first = crashed & ~retried;
            fail = fail | (crashed & retried);            % crashed a second time
            for g = find(first)'                          % MATLAB crashed (e.g. at startup): start once more
                [~, out] = system(cmdl{g}); pid(g) = str2double(strtrim(out)); retried(g) = true;
                fprintf('group %s crashed, restarted (pid %d)\n', strjoin(groups{g}, '_'), pid(g));
            end
            if all(ok | fail), break, end
            pause(2);
        end
        for g = find(ok)', fail(g) = strtrim(fileread(done(g))) ~= "0"; delete(done(g)); end
        for g = find(fail)', fprintf(2, 'group %s FAILED, see logs/rerun_%s.log\n', strjoin(groups{g}, '_'), strjoin(groups{g}, '_')); end
        for g = 1:numel(groups), r = fullfile(ldir, "rerun_" + strjoin(groups{g}, '_') + "_runner.m"); if exist(r, 'file'), delete(r); end, end
    otherwise
        error('rerun_all: unknown mode %s', mode);
end
fprintf('\nrerun_all (%s) done in %.1f min\n', mode, toc(t0)/60);
end

function runsteps(steps, ks, root)
for k = ks
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
