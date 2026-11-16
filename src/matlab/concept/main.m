clear
close all

% paths relative to this file: src/matlab/concept -> project root
here = fileparts(mfilename('fullpath'));
if isempty(here), here = pwd; end
cd(here)
root = fullfile(here,'..','..','..');
projectdir = fullfile(root,'ESMR_colocated_filtered');
dinfo = dir(fullfile(projectdir, '*.nc'));
nfiles = length(dinfo);

init;
T1rows = {};
T1pix  = struct('day',{},'hemi',{},'cls',{},'spos',{},'theta',{},'sic_u',{},'sic_c',{});

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

    % Task 1: SIC of the tie-point pixels, uncorrected and corrected
    [T1rows, T1pix] = sicTask1(T1rows, T1pix, DataOfDay, dayList{day}, spos2ia);

    fprintf('Completed day %s (%d files)\n', dayList{day}, numel(cdffiles))
end

Uncorrected.days = string(dayList);
Corrected.days   = string(dayList);

outdir = fullfile(root,'output','concept');
if ~isfolder(outdir), mkdir(outdir); end
save(fullfile(outdir,'Uncorrected.mat'), 'Uncorrected')
save(fullfile(outdir,'Corrected.mat'),   'Corrected')

T1 = cell2table(T1rows, 'VariableNames', {'day','hemi','cls','n','Tpw_u','Tpw_c','Tpi_u','Tpi_c', ...
    'sic_mean_u','sic_std_u','sic_mean_c','sic_std_c', ...
    'clip_mean_u','clip_std_u','clip_mean_c','clip_std_c'});
writetable(T1, fullfile(outdir,'D1_task1_sic.csv'))
save(fullfile(outdir,'D1_task1_pixels.mat'), 'T1pix', '-v7.3')
fprintf('saved %s\n', outdir)
