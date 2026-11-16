clear
close all

A = readNetCDFStruct(fullfile('..','ESMR_colocated_filtered', ...
    'Nimbus5-ESMR_1973m0201t144349_DS32.nc'));
load("spos2ia.mat")

A.variables.Tbfilt = filterTb(A);

TP = getTiePoints(A);

% Tie points of this single file (same statistics as main.m)
TPstats = poolStats(struct(), TP);

ImagescPlots;
PlotOnGlobe(A, TPstats)
