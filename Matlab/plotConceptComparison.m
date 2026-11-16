% Extra plot: Axel original code vs. fixed code (branch axel-concept)
% Needs: Uncorrected.mat / Corrected.mat (first version, in this folder)
%        results_concept/*.mat (from main.m on this branch)
close all

old  = load("Corrected.mat");    oldC = old.Corrected;
oldU = load("Uncorrected.mat");  oldU = oldU.Uncorrected;
newU = load(fullfile("results_concept","Uncorrected.mat")); newU = newU.Uncorrected;
newC = load(fullfile("results_concept","Corrected.mat"));   newC = newC.Corrected;

cls    = ["Arc_ice","Arc_ocean","Ant_ice","Ant_ocean"];
titles = ["Arctic sea ice","Arctic ocean","Antarctic sea ice","Antarctic ocean"];
dOld = 1:numel(oldC.Arc_ice_mean);
dNew = 1:numel(newC.Arc_ice_mean);

for stat = ["mean","std"]
    f = figure('Color','w','Position',[50 50 1400 850]);
    tl = tiledlayout(2,2,'TileSpacing','compact','Padding','compact');
    for k = 1:4
        nexttile; hold on; grid on
        fld = cls(k) + "_" + stat;
        plot(dOld, oldU.(fld), ':',  'Color',[.6 .6 .6], 'LineWidth',1.5, 'DisplayName','Axel original code, no RTM correction')
        plot(dOld, oldC.(fld), '--', 'Color',[.85 .33 .10], 'LineWidth',2, 'DisplayName','Axel original code, with RTM correction (bugs)')
        plot(dNew, newU.(fld), '-',  'Color',[.3 .3 .3], 'LineWidth',1.5, 'DisplayName','fixed code, no RTM correction')
        plot(dNew, newC.(fld), '-',  'Color',[0 .45 .74], 'LineWidth',2.5, 'DisplayName','fixed code, with RTM correction (result)')
        title(titles(k)); xlim([1 28]); xlabel('Day in February 1973'); ylabel("Tb " + stat + " [K]")
        if k == 1, legend('Location','best','FontSize',9); end
    end
    title(tl, {"Tie-point Tb " + stat + " per day: Axel original code vs. fixed code (branch axel-concept)", "Compare grey solid vs. blue = effect of the RTM correction. Original and fixed lines use different day statistics (per-orbit average vs. all pixels pooled)."}, 'FontWeight','bold')
    exportgraphics(f, fullfile("results_concept", "compare_tiepoint_" + stat + ".png"), 'Resolution', 130)
end

% Table: std reduction by the correction (mean over days)
fprintf('\n%-20s %12s %12s %12s %12s\n','class','orig noRTM','orig RTM','fixed noRTM','fixed RTM')
for k = 1:4
    fld = cls(k) + "_std";
    fprintf('%-20s %12.2f %12.2f %12.2f %12.2f\n', titles(k), mean(oldU.(fld),'omitnan'), ...
        mean(oldC.(fld),'omitnan'), mean(newU.(fld),'omitnan'), mean(newC.(fld),'omitnan'))
end
