close all
clear

init;

days = 1:27;

inc = 1+4:78-4;



TPstatsUncorrected = [];
TPstatsCorrected = [];

SICStatsUncorrected = [];
SICStatsCorrected = [];

for day = days
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
    
    DataOfDay = getTiePoints2(DataOfDay);
    TPUncorrected.TbArcIce = DataOfDay.TbArcIce;
    TPUncorrected.TbArcOcean = DataOfDay.TbArcOcean;
    TPUncorrected.TbAntIce = DataOfDay.TbAntIce;
    TPUncorrected.TbAntOcean = DataOfDay.TbAntOcean;

    TPstatsUncorrected = meanAndStdTP(DataOfDay, TPstatsUncorrected);
    
    applyRTM;

    TPstatsCorrected = meanAndStdTP(TPCorrected, TPstatsCorrected);

    [UncSICArc,UncSICAnt] = calculateSIC(DataOfDay,DataOfDay.lsm, TPstatsUncorrected);
    [CorSICArc,CorSICAnt] = calculateSIC(DataOfDay,DataOfDay.lsm, TPstatsCorrected);

    SICStatsUncorrected = meanAndStdSIC(UncSICArc, UncSICAnt, SICStatsUncorrected);
    SICStatsCorrected = meanAndStdSIC(CorSICArc, CorSICAnt, SICStatsCorrected);

    fprintf('Completed Day %.0f\n', day)
    

    % PlotOnGlobeTP(TPUncorrected,DataOfDay.Latitude, DataOfDay.Longitude)
    % PlotOnGlobeTP(TPCorrected,DataOfDay.Latitude, DataOfDay.Longitude)
    % PlotOnGlobeSIC(UncSICArc, UncSICAnt,DataOfDay.Latitude, DataOfDay.Longitude)
    % PlotOnGlobeSIC(CorSICArc, CorSICAnt,DataOfDay.Latitude, DataOfDay.Longitude)
    
    clear DataOfDay
end

