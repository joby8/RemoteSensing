close all
clear

init;

days = 1:1;

inc = 1+4:78-4;

for day = days
    
    % Read all data from one day
    % name = join(["..\..\ESMR_Resampled_Grid025_Sigma025\DataOfDay",day,'.mat'],'');
    name = join(["..\..\ESMR_Matfile\DataOfDay",day,'.mat'],'');
    load(name)
    
    % Extract inital tie points from Data
    DataOfDay = getTiePoints2(DataOfDay);

    % Correct Data for athmosperic noise
    Corrected = applyRTM(DataOfDay);

    % Calculate mean and standard deviation of the tie points
    TPstatsUncorrected = meanAndStdTP(DataOfDay, TPstatsUncorrected);
    TPstatsCorrected = meanAndStdTP(Corrected, TPstatsCorrected);

    % Calculate the sea ice concentration (SIC)
    [UncSICArc,UncSICAnt] = calculateSIC(DataOfDay,DataOfDay.lsm, TPstatsUncorrected);
    [CorSICArc,CorSICAnt] = calculateSIC(Corrected,Corrected.lsm, TPstatsCorrected);

    % Calculate mean and standard deviation of SIC
    SICStatsUncorrected = meanAndStdSIC(UncSICArc(~isnan(DataOfDay.ArcOcean)), UncSICAnt(~isnan(DataOfDay.AntOcean)), SICStatsUncorrected);
    SICStatsCorrected = meanAndStdSIC(CorSICArc(~isnan(Corrected.ArcOcean)), CorSICAnt(~isnan(Corrected.AntOcean)), SICStatsCorrected);

    % Use new SIC for the next iteration
    Corrected.siconc = sum(cat(3,CorSICArc,CorSICAnt),3,'omitnan');

    Corrected2 = getTiePoints2(Corrected);

    TPstatsCorrected2 = meanAndStdTP(Corrected2, TPstatsCorrected2);
    
    Corrected2 = applyRTMfunc(Corrected2);
    [CorSICArc2,CorSICAnt2] = calculateSIC(Corrected2,Corrected2.lsm, TPstatsCorrected2);
    SICStatsCorrected2 = meanAndStdSIC(CorSICArc2(~isnan(Corrected2.ArcOcean)), CorSICAnt2(~isnan(Corrected2.AntOcean)), SICStatsCorrected2);

    fprintf('Completed Day %.0f\n', day)

    if 0
    % Plot tie points and SIC for the day on the globe
    PlotOnGlobeTP(DataOfDay,DataOfDay.Latitude, DataOfDay.Longitude)
    % PlotOnGlobeTP(Corrected,Corrected.Latitude, Corrected.Longitude)
    PlotOnGlobeTP(Corrected2,Corrected2.Latitude, Corrected2.Longitude)
    PlotOnGlobeSIC(UncSICArc, UncSICAnt,Corrected.Latitude, Corrected.Longitude, 'Uncorrected Sea Ice Concentration')
    % PlotOnGlobeSIC(CorSICArc, CorSICAnt,Corrected.Latitude, Corrected.Longitude, 'Corrected Sea Ice Concentration')
    PlotOnGlobeSIC(CorSICArc2, CorSICAnt2,Corrected2.Latitude, Corrected2.Longitude, 'Corrected Sea Ice Concentration')    
    PlotOnGlobeDeltaTb(Corrected2.ArcDelta, Corrected2.AntDelta,Corrected2.Latitude, Corrected2.Longitude, 'Delta Tb') 
    end
    clear DataOfDay Corrected Corrected2
end

