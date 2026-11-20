load("spos2ia.mat")

projectdir = '..\..\ESMR_colocated_filtered';
if ~exist(projectdir, 'dir')
    if exist('..\ESMR_colocated_filtered', 'dir')
        projectdir = '..\ESMR_colocated_filtered';
    elseif exist('ESMR_colocated_filtered', 'dir')
        projectdir = 'ESMR_colocated_filtered';
    end
end

dinfo = dir(fullfile(projectdir, '*.nc'));
if isempty(dinfo)
    dinfo = dir(fullfile(projectdir));
    dinfo([dinfo.isdir]) = [];
end
[~, sortIdx] = sort({dinfo.name});
dinfo = dinfo(sortIdx);
nfiles = length(dinfo);

% Dynamische Bestimmung der Start- und Endindizes für jeden Tag im Ordner:
% Zeile 1: Startindex (erste Datei des Tages)
% Zeile 2: Endindex (letzte Datei des Tages)
if ~isempty(dinfo)
    fileDates = regexp({dinfo.name}, '\d{4}m\d{4}', 'match', 'once');
    first_indices = find([true, ~strcmp(fileDates(1:end-1), fileDates(2:end))]);
    last_indices  = [first_indices(2:end) - 1, nfiles];
    day_indices = [first_indices; last_indices];
else
    % Fallback: Korrigierte statische 2x28 Matrix für Februar 1973 (Tag 1 bis 28)
    day_indices = [ ...
        1,   13,   25,   36,   50,   61,   74,   85,   97,  109,  122,  133,  145,  154,  163,  174,  186,  197,  211,  222,  235,  245,  257,  268,  280,  290,  302,  312; ...
       12,   24,   35,   49,   60,   73,   84,   96,  108,  121,  132,  144,  153,  162,  173,  185,  196,  210,  221,  234,  244,  256,  267,  279,  289,  301,  311,  312  ...
    ];
end


DataOfDay = struct( ...
    'Tbfilt',[], ...
    'Latitude',[],...
    'Longitude',[], ...
    'lsm',[], ...
    'u10',[],...
    'v10',[], ...
    't2m',[], ...
    'siconc',[], ...
    'sst',[], ...
    'tcw',[], ...
    'tcwv',[], ...
    'incidence',[]); 

TPstatsUncorrected = [];
TPstatsCorrected = [];
TPstatsCorrected2 = [];

SICStatsUncorrected = [];
SICStatsCorrected = [];
SICStatsCorrected2 = [];
