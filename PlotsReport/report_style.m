function report_style(fig, varargin)
% REPORT_STYLE  Apply the report plot rules (report_notes/plot_rules.md) to a finished figure.
% Call it right before exportgraphics:
%   report_style(fig)                    LaTeX + font size 24 + no main title + panel labels (a), (b), ...
%   report_style(fig, 'labels', false)   same, without panel labels (single panel)
%   report_style(fig, 'fontsize', 24)    font size (default 24, rule 7)
%   report_style(fig, 'width', 'full', 'aspect', 0.6)
%                                        figure size for the final width in the one-column LaTeX report (rule 11):
%                                        'full' = 1250 px (\textwidth, 24 pt -> ~9 pt in the PDF), 'half' = 620 px,
%                                        or a number in px; aspect = height / width (default: keep the current one)
%
% What it does
%   rule 6:  all text objects, tick labels, legends and colorbars use the LaTeX interpreter.
%            Plain TeX/Unicode strings are converted (%, _, ^, \Delta, °, σ, θ, ...). Strings that already
%            contain $...$ are taken as LaTeX and only the bare % is escaped.
%   rule 7:  font size 24 everywhere (title/label multipliers set to 1).
%   rule 9:  axes titles get "(a) ", "(b) ", ... in reading order (rows top to bottom, left to right).
%            Axes without a title get the label alone. Axes with Tag 'nolabel' are skipped.
%   rule 10: sgtitle and tiledlayout titles are removed.
% Colormaps, land colour and the 50-90° map range are set in the scripts themselves (rules 1-4, 8).

p = inputParser;
p.addParameter('labels', true);
p.addParameter('fontsize', 24);
p.addParameter('width', []);
p.addParameter('aspect', []);
p.parse(varargin{:});
fs = p.Results.fontsize;

% ---- rule 11: final size ----
w = p.Results.width;
if ~isempty(w)
    if ischar(w) || isstring(w), w = struct('full', 1250, 'half', 620).(char(w)); end
    fig.Units = 'pixels'; ps = fig.Position;
    asp = p.Results.aspect; if isempty(asp), asp = ps(4) / ps(3); end
    fig.Position = [ps(1) ps(2) w round(w * asp)];
end

% ---- rule 10: no main title ----
delete(findall(fig, 'Type', 'subplottext'));
tls = findall(fig, 'Type', 'tiledlayout');
for t = tls(:)'
    t.Title.String = '';
end

% ---- axes: tick labels, fonts ----
ax = findall(fig, 'Type', 'axes');
ax = ax(~arrayfun(@(a) isa(a, 'matlab.graphics.illustration.Legend') || ...
                       isa(a, 'matlab.graphics.illustration.ColorBar'), ax));
for a = ax(:)'
    a.FontSize = fs;
    a.TitleFontSizeMultiplier = 1;
    a.LabelFontSizeMultiplier = 1;
    a.TitleFontWeight = 'normal';
    a.TickLabelInterpreter = 'latex';
    for d = 'XYZ'
        if strcmp(a.([d 'TickLabelMode']), 'manual')
            a.([d 'TickLabel']) = cellfun(@tex2latex, cellstr(a.([d 'TickLabel'])), 'UniformOutput', false);
        end
    end
end
gx = findall(fig, 'Type', 'geoaxes');
for a = gx(:)'
    a.FontSize = fs;
end

% ---- rule 9: panel labels (a), (b), ... ----
if p.Results.labels
    lab = ax(arrayfun(@(a) ~strcmp(a.Tag, 'nolabel') && strcmp(a.Visible, 'on') || ...
                           (~strcmp(a.Tag, 'nolabel') && ~isempty(a.Title.String)), ax));
    pos = zeros(numel(lab), 2);
    for k = 1:numel(lab)
        u = lab(k).Units; lab(k).Units = 'normalized';
        pp = getpos(lab(k)); lab(k).Units = u;
        pos(k, :) = [-(pp(2) + pp(4)), pp(1)];          % top edge (descending), then left edge
    end
    % rows: top edges within 5 % of the figure height count as one row
    [~, o] = sort(pos(:, 1)); row = zeros(numel(lab), 1); r = 0; last = -inf;
    for k = o(:)'
        if pos(k, 1) - last > 0.05, r = r + 1; last = pos(k, 1); end
        row(k) = r;
    end
    [~, o] = sortrows([row, pos(:, 2)]);
    for k = 1:numel(o)
        a = lab(o(k));
        s = a.Title.String;
        if iscell(s), s = strjoin(s, ' '); end
        s = strtrim(char(s));
        if isempty(s)
            a.Title.String = sprintf('(%c)', 'a' + k - 1);
        else
            a.Title.String = sprintf('(%c) %s', 'a' + k - 1, s);
        end
    end
end

% ---- rule 6/7: all text objects ----
tx = findall(fig, 'Type', 'text');
for t = tx(:)'
    if ~isprop(t, 'Interpreter'), continue; end
    s = t.String;
    if iscell(s)
        s = cellfun(@tex2latex, s, 'UniformOutput', false);
    elseif ~isempty(s)
        s = tex2latex(char(s));
    end
    set(t, 'String', s, 'Interpreter', 'latex', 'FontSize', fs);
end

% ---- legends ----
lg = findall(fig, 'Type', 'legend');
for l = lg(:)'
    set(l, 'String', cellfun(@tex2latex, l.String, 'UniformOutput', false), 'Interpreter', 'latex', 'FontSize', fs);
    if ~isempty(l.Title.String)
        l.Title.Interpreter = 'latex';
        l.Title.String = tex2latex(char(l.Title.String));
    end
end

% ---- colorbars ----
cb = findall(fig, 'Type', 'colorbar');
for c = cb(:)'
    c.FontSize = fs;
    c.TickLabelInterpreter = 'latex';
    if strcmp(c.TickLabelsMode, 'manual')
        c.TickLabels = cellfun(@tex2latex, cellstr(c.TickLabels), 'UniformOutput', false);
    end
    set(c.Label, 'String', tex2latex(char(c.Label.String)), 'Interpreter', 'latex', 'FontSize', fs);
end
end

% -------------------------------------------------------------------------------------------------
function pp = getpos(a)
pp = a.Position;
end

function s = tex2latex(s)
% Convert a TeX/Unicode string to one the MATLAB LaTeX interpreter renders.
if isstring(s), s = char(s); end
if isempty(s), return; end
if contains(s, '$')                                    % already LaTeX: only escape the bare %
    s = regexprep(s, '(?<!\\)%', '\\%');
    return
end
% Unicode -> TeX commands
uni = {'°', '^\circ'; 'σ', '\sigma'; 'θ', '\theta'; 'Δ', '\Delta'; '≥', '\geq'; '≤', '\leq'; ...
       '×', '\times'; '±', '\pm'; '−', '-'; '–', '--'; '→', '\rightarrow'; 'µ', '\mu'; 'μ', '\mu'; ...
       '≈', '\approx'; '·', '\cdot'};
for k = 1:size(uni, 1)
    s = strrep(s, uni{k, 1}, uni{k, 2});
end
s = regexprep(s, '(?<!\\)([%&#])', '\\$1');            % LaTeX special characters
% math pieces: \cmd, ^x, ^{..}, _x, _{..}, < >, | -> $...$
cmd = '\\(Delta|delta|theta|sigma|Sigma|mu|alpha|beta|gamma|lambda|epsilon|phi|rho|tau|nu|pi|circ|geq|leq|times|pm|rightarrow|approx|cdot|sim|infty|partial|nabla)';
s = regexprep(s, ['([\^_]' cmd '|' cmd '|[\^_](\{[^}]*\}|[^\s{}\\])|[<>|])'], '\$$1\$');
s = strrep(s, '$$', '');                               % merge neighbouring math pieces
s = strrep(s, '~', '$\sim$');
end
