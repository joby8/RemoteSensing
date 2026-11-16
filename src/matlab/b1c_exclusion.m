% B1c: Task 2 "evaluate by exclusion which ERA5 parameters are most important for the correction".
%  Same correction as A6b (iteration 2, reference values mixed by c_ice, L not corrected),
%  but one ERA5 input at a time is EXCLUDED: in the "actual" RTM run it is set to its
%  reference value, so it no longer corrects anything. Then the std of the corrected SIC
%  per day and hemisphere is compared with the full correction.
%  Also "only X": correction with a single input (all others at the reference).
%  Check: the case "all inputs" must reproduce A6b iteration 2 exactly.
% Needs:  output/A6b_pixels.mat (src/matlab/a6b_iterative.m), output/A6b_iterative.csv
% Run from the project root:  matlab -batch "run('src/matlab/b1c_exclusion.m')"
% Outputs: output/B1c_exclusion.csv (per day/hemisphere/case), output/B1c_exclusion.png
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile('src','matlab'));
load(fullfile('output','A6b_pixels.mat'), 'P');

inp   = {'V','W','Ts','Ti'};                      % corrected inputs (L is never corrected)
cases = [{'none'}, {'all'}, strcat('without_', inp), strcat('only_', inp)];
use   = containers.Map();                         % which inputs are taken per pixel
use('none') = {}; use('all') = inp;
for k = 1:numel(inp)
    use(['without_' inp{k}]) = setdiff(inp, inp(k), 'stable');
    use(['only_' inp{k}])    = inp(k);
end

days = unique([P.day]); days = days(days ~= "0228");   % 28 Feb: only 1 orbit
hemi = ["N","S"];
rows = {};
for d = days
    for h = 1:2
        w = P([P.day] == d & [P.hemi] == hemi(h) & [P.cls] == 1);
        c = P([P.day] == d & [P.hemi] == hemi(h) & [P.cls] == 2);
        w = todouble(w); c = todouble(c);
        c.Ts(isnan(c.Ts)) = 271.35;                     % as in A6b (SST under ice)
        Mw = means(w); Mi = means(c);
        for k = 1:numel(cases)
            u = use(cases{k});
            if isempty(u) && strcmp(cases{k}, 'none')
                dw = 0; dc = 0;
            else
                dw = correction(w, Mw, Mi, u); dc = correction(c, Mw, Mi, u);
            end
            tpw = mean(w.tb + dw); tpi = mean(c.tb + dc);
            sw = (w.tb + dw - tpw) / (tpi - tpw);
            si = (c.tb + dc - tpw) / (tpi - tpw);
            rows(end+1,:) = {d, hemi(h), string(cases{k}), 100*std(sw), 100*std(si), ...
                std(w.tb + dw), std(c.tb + dc), tpi - tpw}; %#ok<SAGROW>
        end
    end
end
T = cell2table(rows, 'VariableNames', {'day','hemi','case','w_sic_std','i_sic_std','w_tb_std','i_tb_std','contrast'});
writetable(T, fullfile('output','B1c_exclusion.csv'));

% ---- check against A6b iteration 2 ----
o = detectImportOptions(fullfile('output','A6b_iterative.csv'));
o = setvartype(o, {'day','hemi'}, 'string');
A = readtable(fullfile('output','A6b_iterative.csv'), o);
A = A(A.iter == 2 & A.day ~= "0228", :);
ref = T(T.case == "all", :); non = T(T.case == "none", :);
dAll  = max(abs(sortrows(ref,{'hemi','day'}).w_sic_std - sortrows(A,{'hemi','day'}).w_sic_std_c));
dNone = max(abs(sortrows(non,{'hemi','day'}).w_sic_std - sortrows(A,{'hemi','day'}).w_sic_std_u));
fprintf('check vs. A6b: max |diff| water std, all = %.4f %%, none = %.4f %%\n', dAll, dNone);

% ---- monthly means ----
fprintf('\nMean of the daily std of SIC [%%], 1-27 Feb. "increase" = vs. full correction.\n');
fprintf('%-14s | %-22s | %-22s | %-22s | %-22s\n', 'case', 'Arctic water', 'Arctic ice', 'Antarctic water', 'Antarctic ice');
S = struct();
for k = 1:numel(cases)
    line = sprintf('%-14s |', cases{k});
    for h = 1:2
        s = T(T.case == cases{k} & T.hemi == hemi(h), :);
        a = T(T.case == "all" & T.hemi == hemi(h), :);
        S.(cases{k})(h,:) = [mean(s.w_sic_std), mean(s.i_sic_std)];
        line = [line sprintf(' %6.2f (%+5.2f)        | %6.2f (%+5.2f)        |', ...
            mean(s.w_sic_std), mean(s.w_sic_std) - mean(a.w_sic_std), ...
            mean(s.i_sic_std), mean(s.i_sic_std) - mean(a.i_sic_std))]; %#ok<AGROW>
    end
    fprintf('%s\n', line);
end

% ---- figure: rows Arctic (top) / Antarctic (bottom), columns water / ice ----
cols = struct('V', [0.00 0.45 0.74], 'W', [0.85 0.33 0.10], 'Ts', [0.49 0.18 0.56], 'Ti', [0.64 0.08 0.18]);
show  = [{'none','all'}, strcat('without_', inp)];
names = ["no RTM correction", "full correction (V, W, Ts, Ti)", ...
         "without V (water vapour)", "without W (wind)", "without Ts (SST)", "without Ti (ice temp.)"];
hn = ["Arctic","Antarctic"]; cn = ["water tie points","ice tie points"];
fig = figure('Visible','off','Color','w','Position',[100 100 1500 900]);
tl = tiledlayout(2,2,'TileSpacing','compact','Padding','compact');
for h = 1:2
    for t = 1:2
        nexttile; hold on; box on; grid on
        v = cellfun(@(cs) S.(cs)(h,t), show);
        full = S.all(h,t);
        for k = 1:numel(show)
            if k == 1, cc = [.6 .6 .6]; elseif k == 2, cc = [.15 .15 .15]; else, cc = cols.(inp{k-2}); end
            barh(k, v(k), 0.7, 'FaceColor', cc, 'EdgeColor', 'none');
            if k == 2
                lab = sprintf('%.1f %%', v(k));
            else
                lab = sprintf('%.1f %%  (%+.2f)', v(k), v(k) - full);
            end
            text(v(k) + 0.01*max(v), k, lab, 'VerticalAlignment','middle', 'FontSize', 10);
        end
        xline(full, '--', 'Color', [.15 .15 .15], 'HandleVisibility','off');
        set(gca, 'YDir','reverse', 'YTick', 1:numel(show), 'YTickLabel', names, 'FontSize', 10);
        xlim([0 max(v)*1.25]);
        xlabel('std of SIC [%] (mean of the daily values)');
        title(sprintf('%s: %s', hn(h), cn(t)));
    end
end
title(tl, {'Task 2: exclusion test - correction with one ERA5 input left out (1-27 Feb 1973)', ...
    'number in brackets = increase of the std compared with the full correction; L is never corrected'}, 'FontWeight','bold');
exportgraphics(fig, fullfile('output','B1c_exclusion.png'), 'Resolution', 150);
fprintf('saved output/B1c_exclusion.csv, output/B1c_exclusion.png\n');

% ---------------------------------------------------------------------------
function s = todouble(p)
f = {'tb','th','V','W','L','Ts','Ti','c_used'};
for k = 1:numel(f), s.(f{k}) = double(p.(f{k})); end
end

function M = means(s)
M = struct('V', mean(s.V), 'W', mean(s.W), 'L', mean(s.L), 'Ts', mean(s.Ts), 'Ti', mean(s.Ti));
end

function dtb = correction(s, Mw, Mi, use)
% As A6b: dTB = RTM(Xref) - RTM(Xact). Inputs not in "use" get Xact = Xref (excluded).
c = s.c_used;
r = @(f) (1 - c) .* Mw.(f) + c .* Mi.(f);
X = struct();
for f = {'V','W','Ts','Ti'}
    if any(strcmp(use, f{1})), X.(f{1}) = s.(f{1}); else, X.(f{1}) = r(f{1}); end
end
Lr  = r('L');
ref = esmr_rtm_vec(r('V'), r('W'), Lr, r('Ts'), r('Ti'), c, s.th);
act = esmr_rtm_vec(X.V, X.W, Lr, X.Ts, X.Ti, c, s.th);
dtb = ref - act;
end
