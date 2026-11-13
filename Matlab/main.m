clear
close all
 
% A = readNetCDFStruct("..\ESMR_colocated_filtered\Nimbus5-ESMR_1973m0201t022301_DS32.nc");
% load("spos2ia.mat")
% A.variables.incidence = abs(repmat(spos2ia',1, A.dimensions.Time));

readAllFiles;
projectdir = '..\ESMR_colocated_filtered';
dinfo = dir(fullfile(projectdir));
dinfo([dinfo.isdir]) = [];     %get rid of all directories including . and ..
nfiles = length(dinfo);
  
load("spos2ia.mat")

TPstats = [];

Day1 = 1:12;

for j = Day1
  filename = fullfile(projectdir, dinfo(j).name);
  Dataname = strjoin(["File", j],'');
  Data = readNetCDFStruct(filename);
  varName = "omega";
  assignin('caller', Dataname, Data);


    Data.variables.incidence = abs(repmat(spos2ia',1, Data.dimensions.Time));
  
    
    Tbfilt = filterTb(Data);
    Data.variables.Tbfilt = Tbfilt;
    
    deltaTb = applyRTM(Data);
    
    TP = getTiePoints(Data);
    
    TPstats = meanAndStdTP(TP, TPstats);

end

% ImagescPlots;