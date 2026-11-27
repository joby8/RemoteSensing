% close all
% clear

load("Results_FullSwath\TPCorrected.mat")
% load("Results_FullSwath\TPCorrected2.mat")
% TPstatsCorrected = TPstatsCorrected2;
load("Results_FullSwath\TPUncorrected.mat")

% load("TPCorrected2_L.mat")
% TPstatsUncorrected = TPstatsCorrected2;

figure('Position',[25,50, 1200,600])
hold on
plot(TPstatsCorrected.arc_ice_mean, 'LineStyle','-',"DisplayName","Arctic Sea Ice", 'LineWidth',2,'Color','b')
plot(TPstatsCorrected.arc_ocean_mean, 'LineStyle','-',"DisplayName","Arctic Ocean", 'LineWidth',2,'Color','r')
plot(TPstatsCorrected.ant_ice_mean, 'LineStyle','-',"DisplayName","Antarctic Sea Ice", "LineWidth",2,'Color','green')
plot(TPstatsCorrected.ant_ocean_mean, 'LineStyle','-',"DisplayName","Antarctic Ocean", "LineWidth",2,'Color','magenta')
plot(TPstatsUncorrected.arc_ice_mean, 'LineStyle','--',"DisplayName","Arctic Sea Ice", "LineWidth",2,'Color','b')
plot(TPstatsUncorrected.arc_ocean_mean, 'LineStyle','--',"DisplayName","Arctic Ocean", 'LineWidth',2,'Color','r')
plot(TPstatsUncorrected.ant_ice_mean, 'LineStyle','--',"DisplayName","Antarctic Sea Ice", "LineWidth",2,'Color','green')
plot(TPstatsUncorrected.ant_ocean_mean, 'LineStyle','--',"DisplayName","Antarctic Ocean", 'LineWidth',2,'Color','magenta')
title("Mean of Uncorrected (--) and Corrected (-) Tie Point Tb")
xlabel("Days in February 1973")
ylabel("Tb")
set(gca, "FontSize",24)
xlim([1,27])
% ylim([222,231])
legend("NumColumns",2,'FontSize',18)
grid


figure('Position',[25,50, 1200,600])
hold on
plot(TPstatsCorrected.arc_ice_std, 'LineStyle','-',"DisplayName","Arctic Sea Ice", 'LineWidth',2,'Color','b')
plot(TPstatsCorrected.arc_ocean_std, 'LineStyle','-',"DisplayName","Arctic Ocean", 'LineWidth',2,'Color','r')
plot(TPstatsCorrected.ant_ice_std, 'LineStyle','-',"DisplayName","Antarctic Sea Ice", "LineWidth",2,'Color','green')
plot(TPstatsCorrected.ant_ocean_std, 'LineStyle','-',"DisplayName","Antarctic Ocean", 'LineWidth',2,'Color','magenta')
plot(TPstatsUncorrected.arc_ice_std, 'LineStyle','--',"DisplayName","Arctic Sea Ice", "LineWidth",2,'Color','b')
plot(TPstatsUncorrected.arc_ocean_std, 'LineStyle','--',"DisplayName","Arctic Ocean", 'LineWidth',2,'Color','r')
plot(TPstatsUncorrected.ant_ice_std, 'LineStyle','--',"DisplayName","Antarctic Sea Ice", "LineWidth",2,'Color','green')
plot(TPstatsUncorrected.ant_ocean_std, 'LineStyle','--',"DisplayName","Antarctic Ocean", 'LineWidth',2,'Color','magenta')
title("STD of Uncorrected (--) and Corrected (-) Tie Point Tb")
xlabel("Days in February 1973")
ylabel("Tb")
set(gca, "FontSize",24)
xlim([1,27])
legend("NumColumns",2,'FontSize',18)
grid

load("Results_FullSwath\SICCorrected.mat")
% load("Results_FullSwath\SICCorrected2.mat")
% SICStatsCorrected = SICStatsCorrected2;
load("Results_FullSwath\SICUncorrected.mat")

% load("SICCorrected2_L.mat")
% SICStatsUncorrected = SICStatsCorrected2;

figure('Position',[25,50, 1200,600])
hold on
plot(SICStatsCorrected.arc_mean, 'LineStyle','-',"DisplayName","Arctic Corrected", 'LineWidth',2,'Color','b')
plot(SICStatsCorrected.ant_mean, 'LineStyle','-',"DisplayName","Antarctic Corrected", 'LineWidth',2,'Color','r')
plot(SICStatsUncorrected.arc_mean, 'LineStyle','-',"DisplayName","Arctic Uncorrected", "LineWidth",2,'Color','b','LineStyle','--')
plot(SICStatsUncorrected.ant_mean, 'LineStyle','-',"DisplayName","Antarctic Uncorrected", "LineWidth",2,'Color','r','LineStyle','--')

title("Mean of SIC")
xlabel("Days in February 1973")
ylabel("Sea Ice Concentration")
set(gca, "FontSize",24)
xlim([1,27])
% ylim([0,1])
legend("NumColumns",2,'FontSize',18)
grid

figure('Position',[25,50, 1200,600])
hold on
plot(SICStatsCorrected.arc_std, 'LineStyle','-',"DisplayName","Arctic Corrected", 'LineWidth',2,'Color','b')
plot(SICStatsCorrected.ant_std, 'LineStyle','-',"DisplayName","Antarctic Corrected", 'LineWidth',2,'Color','r')
plot(SICStatsUncorrected.arc_std, 'LineStyle','-',"DisplayName","Arctic Uncorrected", "LineWidth",2,'Color','b','LineStyle','--')
plot(SICStatsUncorrected.ant_std, 'LineStyle','-',"DisplayName","Antarctic Uncorrected", "LineWidth",2,'Color','r','LineStyle','--')

title("STD of SIC")
xlabel("Days in February 1973")
ylabel("Sea Ice Concentration")
set(gca, "FontSize",24)
xlim([1,27])
% ylim([0,1])
legend("NumColumns",2,'FontSize',18)
grid
