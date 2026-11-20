close all
clear

init;

days = 2:2;

inc = 1+4:78-4;

for day = days
    % Init struct that contains all data of a day
    cdffiles = day_indices(1,day):day_indices(2,day);     
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

    % Read all data from one day
    for j = cdffiles
        filename = fullfile(projectdir, dinfo(j).name);
        Data = readNetCDFStruct(filename);

        Tbfilt = filterTb(Data);
        DataOfDay.Tbfilt = cat(2, DataOfDay.Tbfilt, Tbfilt(inc,:),NaN(length(inc),2));
        DataOfDay.Latitude = cat(2, DataOfDay.Latitude, Data.variables.Latitude.data(inc,:),NaN(length(inc),2));
        DataOfDay.Longitude = cat(2, DataOfDay.Longitude, Data.variables.Longitude.data(inc,:),NaN(length(inc),2));
        DataOfDay.lsm = cat(2, DataOfDay.lsm, Data.variables.lsm.data(inc,:),NaN(length(inc),2));
        DataOfDay.u10 = cat(2, DataOfDay.u10, Data.variables.u10.data(inc,:),NaN(length(inc),2));
        DataOfDay.v10 = cat(2, DataOfDay.v10, Data.variables.v10.data(inc,:),NaN(length(inc),2));
        DataOfDay.t2m = cat(2, DataOfDay.t2m, Data.variables.t2m.data(inc,:),NaN(length(inc),2));
        DataOfDay.siconc = cat(2, DataOfDay.siconc, Data.variables.siconc.data(inc,:),NaN(length(inc),2));
        DataOfDay.sst = cat(2, DataOfDay.sst, Data.variables.sst.data(inc,:),NaN(length(inc),2));
        DataOfDay.tcw = cat(2, DataOfDay.tcw, Data.variables.tcw.data(inc,:),NaN(length(inc),2));
        DataOfDay.tcwv = cat(2, DataOfDay.tcwv, Data.variables.tcwv.data(inc,:),NaN(length(inc),2));
        DataOfDay.incidence = cat(2, DataOfDay.incidence, repmat(spos2ia(inc)', [1,Data.dimensions.Time]),NaN(length(inc),2));
    end
    
    % Extract inital tie points from Data
    DataOfDay = getTiePoints2(DataOfDay);

    % Correct Data for athmosperic noise
    Corrected = applyRTMfunc(DataOfDay);

    % Calculate mean and standard deviation of the tie points
    TPstatsUncorrected = meanAndStdTP(DataOfDay, TPstatsUncorrected);
    TPstatsCorrected = meanAndStdTP(Corrected, TPstatsCorrected);

    % Calculate the sea ice concentration (SIC)
    [UncSICArc,UncSICAnt] = calculateSIC(DataOfDay,DataOfDay.lsm, TPstatsUncorrected);
    [CorSICArc,CorSICAnt] = calculateSIC(Corrected,Corrected.lsm, TPstatsCorrected);

    % Calculate mean and standard deviation of SIC
    SICStatsUncorrected = meanAndStdSIC(UncSICArc, UncSICAnt, SICStatsUncorrected);
    SICStatsCorrected = meanAndStdSIC(CorSICArc, CorSICAnt, SICStatsCorrected);

    % Use new SIC for the next iteration
    Corrected.siconc = sum(cat(3,CorSICArc,CorSICAnt),3,'omitnan');

    Corrected2 = getTiePoints2(Corrected);

    TPstatsCorrected2 = meanAndStdTP(Corrected2, TPstatsCorrected2);
    
    Corrected2 = applyRTMfunc(Corrected2);
    [CorSICArc2,CorSICAnt2] = calculateSIC(Corrected2,Corrected2.lsm, TPstatsCorrected2);
    SICStatsCorrected2 = meanAndStdSIC(CorSICArc2, CorSICAnt2, SICStatsCorrected2);

    fprintf('Completed Day %.0f\n', day)

    % Plot tie points and SIC for the day on the globe
    PlotOnGlobeTP(DataOfDay,DataOfDay.Latitude, DataOfDay.Longitude)
    % PlotOnGlobeTP(Corrected,Corrected.Latitude, Corrected.Longitude)
    PlotOnGlobeTP(Corrected2,Corrected2.Latitude, Corrected2.Longitude)
    PlotOnGlobeSIC(UncSICArc, UncSICAnt,Corrected.Latitude, Corrected.Longitude, 'Uncorrected Sea Ice Concentration')
    % PlotOnGlobeSIC(CorSICArc, CorSICAnt,Corrected.Latitude, Corrected.Longitude, 'Corrected Sea Ice Concentration')
    PlotOnGlobeSIC(CorSICArc2, CorSICAnt2,Corrected2.Latitude, Corrected2.Longitude, 'Corrected Sea Ice Concentration')    
    PlotOnGlobeDeltaTb(Corrected2.ArcDelta, Corrected2.AntDelta,Corrected2.Latitude, Corrected2.Longitude, 'Delta Tb')    
    clear DataOfDay Corrected Corrected2
end

