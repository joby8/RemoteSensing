function [SIC] = calculateSIC(DataStruct, DayStats)
Arc_ocean_mean = DayStats.Arc_ocean_mean(end);
Arc_ice_mean = DayStats.Arc_ice_mean(end);
Ant_ocean_mean = DayStats.Ant_ocean_mean(end);
Ant_ice_mean = DayStats.Ant_ice_mean(end);


% land = isnan(DataStruct.variables.sst.data(5:end-4,:));
land = (DataStruct.variables.lsm.data(5:end-4, :) > 0.5);

Latitude = DataStruct.variables.Latitude.data(5:end-4,:);
Longitude = DataStruct.variables.Longitude.data(5:end-4,:);

sic_arc = (DataStruct.variables.Tbfilt - Arc_ocean_mean)/(Arc_ice_mean - Arc_ocean_mean);
sic_arc(sic_arc>0.95) = 1;
sic_arc(sic_arc<0) = 0;
sic_arc(DataStruct.variables.Latitude.data(5:end-4,:) < 50) = NaN;
sic_arc(DataStruct.variables.Latitude.data(5:end-4,:) > 90) = NaN;
sic_arc(land) = NaN;

sic_ant = (DataStruct.variables.Tbfilt - Ant_ocean_mean)/(Ant_ice_mean - Ant_ocean_mean);
sic_ant(sic_ant>0.95) = 1;
sic_ant(sic_ant<0) = 0;
sic_ant(DataStruct.variables.Latitude.data(5:end-4,:)> -50) = NaN;
sic_ant(DataStruct.variables.Latitude.data(5:end-4,:)< -90) = NaN;
sic_ant(land) = NaN;

SIC.Ant = sic_ant;
SIC.Arc = sic_arc;
SIC.land = land;
SIC.Lat = Latitude;
SIC.Lon = Longitude;
end