close all

load("Uncorrected3.mat")
load("Corrected3.mat")

figure('Position',[25,50, 1200,600])
hold on
plot(Corrected.Arc_ice_mean, 'LineStyle','-',"DisplayName","Arctic Sea Ice", 'LineWidth',2,'Color','b')
plot(Corrected.Arc_ocean_mean, 'LineStyle','-',"DisplayName","Arctic Ocean", 'LineWidth',2,'Color','r')
plot(Corrected.Ant_ice_mean, 'LineStyle','-',"DisplayName","Antarctic Sea Ice", "LineWidth",2,'Color','green')
plot(Corrected.Ant_ocean_mean, 'LineStyle','-',"DisplayName","Antarctic Ocean", "LineWidth",2,'Color','magenta')
plot(Uncorrected.Arc_ice_mean, 'LineStyle','--',"DisplayName","Arctic Sea Ice", "LineWidth",2,'Color','b')
plot(Uncorrected.Arc_ocean_mean, 'LineStyle','--',"DisplayName","Arctic Ocean", 'LineWidth',2,'Color','r')
plot(Uncorrected.Ant_ice_mean, 'LineStyle','--',"DisplayName","Antarctic Sea Ice", "LineWidth",2,'Color','green')
plot(Uncorrected.Ant_ocean_mean, 'LineStyle','--',"DisplayName","Antarctic Ocean", 'LineWidth',2,'Color','magenta')
title("Mean of Uncorrected (--) and Corrected (-) Tie Point Tb")
xlabel("Days in February 1973")
ylabel("Tb")
set(gca, "FontSize",24)
xlim([1,27])
legend("NumColumns",2,'FontSize',18)
grid

figure('Position',[25,50, 1200,600])
hold on
plot(Corrected.Arc_ice_std, 'LineStyle','-',"DisplayName","Arctic Sea Ice", 'LineWidth',2,'Color','b')
plot(Corrected.Arc_ocean_std, 'LineStyle','-',"DisplayName","Arctic Ocean", 'LineWidth',2,'Color','r')
plot(Corrected.Ant_ice_std, 'LineStyle','-',"DisplayName","Antarctic Sea Ice", "LineWidth",2,'Color','green')
plot(Corrected.Ant_ocean_std, 'LineStyle','-',"DisplayName","Antarctic Ocean", 'LineWidth',2,'Color','magenta')
plot(Uncorrected.Arc_ice_std, 'LineStyle','--',"DisplayName","Arctic Sea Ice", "LineWidth",2,'Color','b')
plot(Uncorrected.Arc_ocean_std, 'LineStyle','--',"DisplayName","Arctic Ocean", 'LineWidth',2,'Color','r')
plot(Uncorrected.Ant_ice_std, 'LineStyle','--',"DisplayName","Antarctic Sea Ice", "LineWidth",2,'Color','green')
plot(Uncorrected.Ant_ocean_std, 'LineStyle','--',"DisplayName","Antarctic Ocean", 'LineWidth',2,'Color','magenta')
title("STD of Uncorrected (--) and Corrected (-) Tie Point Tb")
xlabel("Days in February 1973")
ylabel("Tb")
set(gca, "FontSize",24)
xlim([1,27])
legend("NumColumns",2,'FontSize',18)
grid