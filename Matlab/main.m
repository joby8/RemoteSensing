clear
close all

projectdir = fullfile('..','ESMR_colocated_filtered');
dinfo = dir(fullfile(projectdir, '*.nc'));
nfiles = length(dinfo);

init;

% Day of every file from its name (..._1973mMMDDtHHMMSS_...)
tok = regexp({dinfo.name}, '\d{4}m(\d{4})t', 'tokens', 'once');
dayKey = cellfun(@(c) c{1}, tok, 'UniformOutput', false);
[dayList, ~, dayOfFile] = unique(dayKey);
nDays = numel(dayList);

for day = 1:nDays
    cdffiles = find(dayOfFile == day)';
    clear DataOfDay
    fileindex = 1;
    for j = cdffiles
        % Read single NetCDF File
        filename = fullfile(projectdir, dinfo(j).name);
        Data = readNetCDFStruct(filename);

        % Initial Filtering
        Data.variables.Tbfilt = filterTb(Data);

        % Determine Tie Points
        Data.TP = getTiePoints(Data);

        DataOfDay(fileindex) = Data; %#ok<SAGROW>
        clear Data
        fileindex = fileindex+1;
    end

    % Day statistics of the uncorrected tie points (all pixels pooled)
    Uncorrected = poolStats(Uncorrected, [DataOfDay.TP]);

    % Correct Data with Differential RTM
    applyRTM;

    % Day statistics of the corrected tie points
    Corrected = poolStats(Corrected, [DataOfDay.Corrected]);

    fprintf('Completed day %s (%d files)\n', dayList{day}, numel(cdffiles))
end

Uncorrected.days = string(dayList);
Corrected.days   = string(dayList);

outdir = 'results_concept';
if ~isfolder(outdir), mkdir(outdir); end
save(fullfile(outdir,'Uncorrected.mat'), 'Uncorrected')
save(fullfile(outdir,'Corrected.mat'),   'Corrected')
