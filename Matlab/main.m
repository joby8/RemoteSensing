clear
close all
 
init;


% DataOfDay(length(cdffiles)) = struct();
for day = 1:1
cdffiles = day_indices(1,day):day_indices(2,day);     
fileindex = 1;
for j = cdffiles
  % Read single NetCDF File  
  filename = fullfile(projectdir, dinfo(j).name);
  Data = readNetCDFStruct(filename);

  % Add Incidence Angle to Data Struct
  Data.variables.incidence = abs(repmat(spos2ia',1, Data.dimensions.Time));
   
  % Initial Filtering
  Tbfilt = filterTb(Data);
  Data.variables.Tbfilt = Tbfilt;
    
  % Determine Tie Points
  TP = getTiePoints2(Data);
  Data.TP = TP;
  
  % Calculate Mean and STD of 4 Tie Points
  TPstats = meanAndStdTP(TP, TPstats);

  DataOfDay(fileindex) = Data;
  clear Data
  fileindex = fileindex+1;
end

% Calculate Mean and STD of complete Day for uncorrected Data
Uncorrected.Ant_ice_mean(end+1) = mean(TPstats.ant_ice_mean,'omitnan');
Uncorrected.Arc_ice_mean(end+1) = mean(TPstats.arc_ice_mean,'omitnan');
Uncorrected.Ant_ocean_mean(end+1) = mean(TPstats.ant_ocean_mean,'omitnan');
Uncorrected.Arc_ocean_mean(end+1) = mean(TPstats.arc_ocean_mean,'omitnan');

Uncorrected.Ant_ice_std(end+1) = mean(TPstats.ant_ice_std,'omitnan');
Uncorrected.Arc_ice_std(end+1) = mean(TPstats.arc_ice_std,'omitnan');
Uncorrected.Ant_ocean_std(end+1) = mean(TPstats.ant_ocean_std,'omitnan');
Uncorrected.Arc_ocean_std(end+1) = mean(TPstats.arc_ocean_std,'omitnan');


% Correct Data with Differential RTM
applyRTM;

for j = 1:length(cdffiles)
    TPstatsCorrected = meanAndStdTP(DataOfDay(j).Corrected, TPstatsCorrected);
end

% Calculate Mean and STD of complete Day for Corrected Data
Corrected.Ant_ice_mean(end+1) = mean(TPstatsCorrected.ant_ice_mean,'omitnan');
Corrected.Arc_ice_mean(end+1) = mean(TPstatsCorrected.arc_ice_mean,'omitnan');
Corrected.Ant_ocean_mean(end+1) = mean(TPstatsCorrected.ant_ocean_mean,'omitnan');
Corrected.Arc_ocean_mean(end+1) = mean(TPstatsCorrected.arc_ocean_mean,'omitnan');

Corrected.Ant_ice_std(end+1) = mean(TPstatsCorrected.ant_ice_std,'omitnan');
Corrected.Arc_ice_std(end+1) = mean(TPstatsCorrected.arc_ice_std,'omitnan');
Corrected.Ant_ocean_std(end+1) = mean(TPstatsCorrected.ant_ocean_std,'omitnan');
Corrected.Arc_ocean_std(end+1) = mean(TPstatsCorrected.arc_ocean_std,'omitnan');

clear TPstats TPstatsCorrected;
clear DataOfDay

fprintf('Completed Day %.0f\n', day)
end
fprintf('\n')