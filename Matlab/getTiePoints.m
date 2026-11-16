function [DataOut] = getTiePoints(Data)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

DataOut = Data;

DataOut.TPnames = ["ArcIce", "ArcOcean","AntIce","AntOcean"];


box = 5; % Box filter Length
cbox = movmean(movmean(Data.variables.siconc.data, box, 1), box, 2);

% Arctic
arc_lat_max = 90;
arc_lat_min = 50; % 32
arc_c_ocean_max = 0;
arc_c_ocean_mean_max = 0.01;
arc_c_ice_min = 0.8;
arc_c_ice_mean_min = 0.8;
arc_Tb_ocean_max = 180;
arc_Tb_ocean_min = 90;
arc_Tb_ice_max = 274;
arc_Tb_ice_min = 100;
arc_sst_min = 278;

% Antarctic
ant_lat_max = -50; % -48
ant_lat_min = -90;
ant_c_ocean_max = 0;
ant_c_ocean_mean_max = 0.01;
ant_c_ice_min = 0.8;
ant_c_ice_mean_min = 0.8;
ant_Tb_ocean_max = 180;
ant_Tb_ocean_min = 90;
ant_Tb_ice_max = 274;
ant_Tb_ice_min = 100;
ant_sst_min = 278;

Tb = Data.variables.Tbfilt;
land = (Data.variables.lsm.data(5:end-5, :) > 0.5);
sic = Data.variables.siconc.data(5:end-4,:);
sst = Data.variables.sst.data(5:end-4,:);

Arc_ice = Tb;
Arc_ice(Tb < arc_Tb_ice_min | (Tb > arc_Tb_ice_max)) = NaN;
Arc_ice(Data.variables.Latitude.data(5:end-4,:) < arc_lat_min | Data.variables.Latitude.data(5:end-4,:) > arc_lat_max ) = NaN;
Arc_ice(sic < arc_c_ice_min) = NaN;
Arc_ice(isnan(sic)) = NaN;
Arc_ice(cbox(5:end-4,:) < arc_c_ice_mean_min) = NaN;
Arc_ice(isnan(cbox(5:end-4,:))) = NaN;
Arc_ice(land) = NaN;


Arc_ocean = Tb;
Arc_ocean(Tb < arc_Tb_ocean_min | (Tb > arc_Tb_ocean_max)) = NaN;
Arc_ocean(Data.variables.Latitude.data(5:end-4,:) < arc_lat_min | Data.variables.Latitude.data(5:end-4,:) > arc_lat_max ) = NaN;
Arc_ocean(sst < arc_sst_min) = NaN;
Arc_ocean(isnan(sst)) = NaN;
Arc_ocean(sic > arc_c_ocean_max) = NaN;
Arc_ocean(isnan(sic)) = NaN;
Arc_ocean(cbox(5:end-4,:) > arc_c_ocean_mean_max) = NaN;
Arc_ocean(isnan(cbox(5:end-4,:))) = NaN;
Arc_ocean(land) = NaN;

Ant_ice = Tb;
Ant_ice(Tb < ant_Tb_ice_min | (Tb > ant_Tb_ice_max)) = NaN;
Ant_ice(Data.variables.Latitude.data(5:end-4,:) < ant_lat_min | Data.variables.Latitude.data(5:end-4,:) > ant_lat_max ) = NaN;
Ant_ice(sic < ant_c_ice_min) = NaN;
Ant_ice(isnan(sic)) = NaN;
Ant_ice(cbox(5:end-4,:) < ant_c_ice_mean_min) = NaN;
Ant_ice(isnan(cbox(5:end-4,:))) = NaN;
Ant_ice(land) = NaN;


Ant_ocean = Tb;
Ant_ocean(Tb < ant_Tb_ocean_min | (Tb > ant_Tb_ocean_max)) = NaN;
Ant_ocean(Data.variables.Latitude.data(5:end-4,:) < ant_lat_min | Data.variables.Latitude.data(5:end-4,:) > ant_lat_max ) = NaN;
Ant_ocean(sst < ant_sst_min) = NaN;
Ant_ocean(isnan(sst)) = NaN;
Ant_ocean(sic > ant_c_ocean_max) = NaN;
Ant_ocean(isnan(sic)) = NaN;
Ant_ocean(cbox(5:end-4,:) > ant_c_ocean_mean_max) = NaN;
Ant_ocean(isnan(cbox(5:end-4,:))) = NaN;
Ant_ocean(land) = NaN;


DataOut.TbAntIce = Ant_ice;
DataOut.TbAntOcean = Ant_ocean;
DataOut.TbArcIce = Arc_ice;
DataOut.TbArcOcean = Arc_ocean;

DataOut.AntIce = ~isnan(Ant_ice);
DataOut.AntOcean = ~isnan(Ant_ocean);
DataOut.ArcIce = ~isnan(Arc_ice);
DataOut.ArcOcean = ~isnan(Arc_ocean);

end