% A1: open one ESMR swath file, list variables, shapes, attributes.
% Run from the project root:  matlab -batch "run('src/matlab/a1_inspect.m')"
cd(fileparts(fileparts(fileparts(mfilename('fullpath')))));   % project root (run() changes the folder)
if ~exist('f','var') || isempty(f)
    files = dir(fullfile('ESMR_colocated_filtered','*.nc'));
    f = fullfile(files(1).folder, files(1).name);
end
info = ncinfo(f);
fprintf('%s\n', f);
fprintf('dimensions:');
for i = 1:numel(info.Dimensions)
    fprintf('  %s = %d', info.Dimensions(i).Name, info.Dimensions(i).Length);
end
fprintf('\n\nglobal attributes:\n');
for i = 1:numel(info.Attributes)
    a = info.Attributes(i).Value;
    if isnumeric(a), a = num2str(a); end
    fprintf('  %-24s %s\n', info.Attributes(i).Name, strtrim(strrep(string(a), newline, ' ')));
end
fprintf('\n%-34s %-14s %-9s %s\n', 'variable', 'shape (MATLAB)', 'type', 'units');
for i = 1:numel(info.Variables)
    v = info.Variables(i);
    u = '';
    if ~isempty(v.Attributes)          % e.g. 'obs' has no attributes
        k = find(strcmp({v.Attributes.Name}, 'units'), 1);
        if ~isempty(k), u = char(string(v.Attributes(k).Value)); end
    end
    fprintf('%-34s %-14s %-9s %s\n', v.Name, mat2str(v.Size), v.Datatype, u);
end
fprintf('\nNote: MATLAB reads (Time,obs) as [obs x Time] = [78 x scan lines]; load_orbit.m transposes to [scan lines x 78].\n');
