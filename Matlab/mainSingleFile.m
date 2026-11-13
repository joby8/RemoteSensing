clear
close all
 
A = readNetCDFStruct("..\ESMR_colocated_filtered\Nimbus5-ESMR_1973m0201t022301_DS32.nc");
load("spos2ia.mat")
A.variables.incidence = abs(repmat(spos2ia',1, A.dimensions.Time));

TPstats = [];

A.variables.incidence = abs(repmat(spos2ia',1, A.dimensions.Time));


Tbfilt = filterTb(A);
A.variables.Tbfilt = Tbfilt;

deltaTb = applyRTM(A);

TP = getTiePoints(A);

TPstats = meanAndStdTP(TP, TPstats);

ImagescPlots;