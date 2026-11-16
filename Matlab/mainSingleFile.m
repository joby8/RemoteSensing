clear
close all
 
init;

filename = fullfile(projectdir, dinfo(40).name);
A = readNetCDFStruct(filename);
A.variables.incidence = abs(repmat(spos2ia',1, A.dimensions.Time));

TPstats = [];

A.variables.incidence = abs(repmat(spos2ia',1, A.dimensions.Time));

Tbfilt = filterTb(A);
A.variables.Tbfilt = Tbfilt;

TP = getTiePoints2(A);
A.TP = TP;
TPstats = meanAndStdTP(TP, TPstats);


Uncorrected.Ant_ice_mean = mean(TPstats.ant_ice_mean,'omitnan');
Uncorrected.Arc_ice_mean = mean(TPstats.arc_ice_mean,'omitnan');
Uncorrected.Ant_ocean_mean = mean(TPstats.ant_ocean_mean,'omitnan');
Uncorrected.Arc_ocean_mean = mean(TPstats.arc_ocean_mean,'omitnan');

A.SIC = calculateSIC(A, Uncorrected);



PlotImagesc;
PlotOnGlobe(A)

PlotOnGlobeSIC(A)