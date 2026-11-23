close all
clear

init;

days = 1:1;

inc = 1+4:78-4;

for day = days
    clear DataOfDay Corrected Corrected2

    % Read all data from one day
    % name = join(["..\..\ESMR_Resampled_Grid025_Sigma025\DataOfDay",day,'.mat'],'');
    name = join(["..\..\ESMR_Matfile\DataOfDay",day,'.mat'],'');
    load(name)
    
    % Extract inital tie points from Data
    DataOfDay = getTiePoints2(DataOfDay);

    % Calculate mean and standard deviation of the tie points
    TPstatsUncorrected = meanAndStdTP(DataOfDay, TPstatsUncorrected);
    
    % Calculate first SIC estimation
    [UncSICArc,UncSICAnt] = calculateSIC(DataOfDay,DataOfDay.lsm, TPstatsUncorrected);
    DataOfDay.siconc = sum(cat(3,UncSICArc,UncSICAnt),3,'omitnan');

    % Correct Data for athmosperic noise
    Corrected = applyRTM(DataOfDay);

    % Calculate mean and standard deviation of the tie points
    TPstatsCorrected = meanAndStdTP(Corrected, TPstatsCorrected);

    % Calculate the sea ice concentration (SIC)
    [CorSICArc,CorSICAnt] = calculateSIC(Corrected,Corrected.lsm, TPstatsCorrected);
    Corrected.siconc = sum(cat(3,CorSICArc,CorSICAnt),3,'omitnan');

    % Calculate mean and standard deviation of SIC
    SICStatsUncorrected = meanAndStdSIC(UncSICArc(~isnan(DataOfDay.ArcOcean)), UncSICAnt(~isnan(DataOfDay.AntOcean)), SICStatsUncorrected);
    SICStatsCorrected = meanAndStdSIC(CorSICArc(~isnan(Corrected.ArcOcean)), CorSICAnt(~isnan(Corrected.AntOcean)), SICStatsCorrected);

    % % Use new SIC for the next iteration
    % for iteration = 1:1
    % 
    %     % Corrected2 = getTiePoints2(Corrected);
    % 
    % 
    %     Corrected2 = applyRTM(Corrected);
    %     TPstatsCorrected2 = meanAndStdTP(Corrected2, TPstatsCorrected2);
    % 
    %     [CorSICArc2,CorSICAnt2] = calculateSIC(Corrected2,Corrected2.lsm, TPstatsCorrected2);
    %     Corrected2.siconc = sum(cat(3,CorSICArc2,CorSICAnt2),3,'omitnan');
    % 
    %     SICStatsCorrected2 = meanAndStdSIC(CorSICArc2(~isnan(Corrected2.ArcOcean)), CorSICAnt2(~isnan(Corrected2.AntOcean)), SICStatsCorrected2);
    % 
    %     if iteration > 1
    %     CorSICArc = CorSICArc2;
    %     CorSICAnt = CorSICAnt2;
    %     Corrected = Corrected2;
    %     end
    % end

    fprintf('Completed Day %.0f\n', day)

    if isscalar(days)
        if 1
        % Plot tie points and SIC for the day on the globe
        PlotOnGlobeTP(DataOfDay,DataOfDay.Latitude, DataOfDay.Longitude)
        PlotOnGlobeTP(Corrected,Corrected.Latitude, Corrected.Longitude)
        PlotOnGlobeTP(Corrected2,Corrected2.Latitude, Corrected2.Longitude)
    
        PlotOnGlobeSIC(UncSICArc, UncSICAnt,Corrected.Latitude, Corrected.Longitude, 'Uncorrected Sea Ice Concentration')
        PlotOnGlobeSIC(CorSICArc, CorSICAnt,Corrected.Latitude, Corrected.Longitude, 'Corrected Sea Ice Concentration')
        PlotOnGlobeSIC(CorSICArc2, CorSICAnt2,Corrected2.Latitude, Corrected2.Longitude, 'Corrected Sea Ice Concentration')    
    
        land = DataOfDay.lsm;
        land(land >0.8) = NaN;
        land(~isnan(land)) = 1;
        PlotOnGlobeDeltaTb(Corrected.ArcDelta.*land, Corrected.AntDelta.*land,Corrected.Latitude, Corrected.Longitude, 'Delta Tb') 
        end
    end
end

if length(day)>1
    save('TPUncorrected.mat','TPstatsUncorrected')
    save('TPCorrected.mat','TPstatsCorrected')
    save('SICUncorrected.mat','SICStatsUncorrected')
    save('SICCorrected.mat','SICStatsCorrected')
end
