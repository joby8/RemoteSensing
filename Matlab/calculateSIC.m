function [SICArc, SICAnt] = calculateSIC(Data,land,Stats)
    land(land>0) = NaN;
    % land(land>=0.1) = 1;
    
    SICArc = (Data.Tbfilt - Stats.arc_ocean_mean(end))/(Stats.arc_ice_mean(end) - Stats.arc_ocean_mean(end));
    SICAnt = (Data.Tbfilt - Stats.ant_ocean_mean(end))/(Stats.ant_ice_mean(end) - Stats.ant_ocean_mean(end));

    SICArc(isnan(land)) = NaN;
    SICArc(SICArc < 0.01) = 0;
    SICArc(Data.Latitude < 50) = NaN;
    SICArc(Data.Latitude > 90) = NaN;
    SICArc(SICArc > 0.99) = 1;

    SICAnt(isnan(land)) = NaN;
    SICAnt(SICAnt < 0.01) = 0;
    SICAnt(SICAnt > 0.99) = 1;
    SICAnt(Data.Latitude> -50) = NaN;
    SICAnt(Data.Latitude< -90) = NaN;
end