clear mask c

mask(4) = struct();
mask(1).mask = DataOfDay.ArcIce;
mask(2).mask = DataOfDay.ArcOcean;
mask(3).mask = DataOfDay.AntIce;
mask(4).mask = DataOfDay.AntOcean;

c(4) = struct();
c(1).c = 1;
c(2).c = 0;
c(3).c = 1;
c(4).c = 0;

% C(4) = struct();
% c(1).c = DataOfDay.siconc.*mask(1).mask;
% c(2).c = DataOfDay.siconc.*mask(2).mask;
% c(3).c = DataOfDay.siconc.*mask(3).mask;
% c(4).c = DataOfDay.siconc.*mask(4).mask;


clear RTMmean RTM deltaTb
RTMmean(4) = struct();
RTM(4) = struct();
deltaTb(4) = struct();

for i = 1:4

% WS = sqrt((DataOfDay.u10.*mask(i).mask).^2+(DataOfDay.v10.*mask(i).mask).^2);
% Ts = DataOfDay.sst.*mask(i).mask;
% Ti = 0.4*DataOfDay.t2m.*mask(i).mask+0.6*272;
% V =  DataOfDay.tcwv.*mask(i).mask;
% L = DataOfDay.tcw.*mask(i).mask-V;
% theta = abs(DataOfDay.incidence.*mask(i).mask);

WS = sqrt(DataOfDay.u10.^2+DataOfDay.v10.^2);
Ts = DataOfDay.sst;
Ti = 0.4*DataOfDay.t2m+0.6*272;
V =  DataOfDay.tcwv;
L = DataOfDay.tcw-V;
theta = abs(DataOfDay.incidence);

WSmean = mean(WS,'all','omitnan');
Tsmean = mean(Ts,'all','omitnan');
Timean = mean(Ti,'all','omitnan');
Vmean = mean(V,'all','omitnan');
Lmean = mean(L,'all','omitnan');

RTMmean(i).data = esmr_rtm_mod(Vmean,WSmean,Lmean,Tsmean,Timean,c(i).c,theta);
RTM(i).data = esmr_rtm_mod(V,WS,Lmean,Ts,Ti,c(i).c,theta);

deltaTb(i).data = RTMmean(i).data-RTM(i).data;
% deltaTb(i).data(isnan(deltaTb(i).data)) = 0;
end

TPCorrected.TbArcIce = DataOfDay.TbArcIce + deltaTb(1).data;
TPCorrected.TbArcOcean = DataOfDay.TbArcOcean + deltaTb(2).data;
TPCorrected.TbAntIce = DataOfDay.TbAntIce + deltaTb(3).data;
TPCorrected.TbAntOcean = DataOfDay.TbAntOcean + deltaTb(4).data;
TPCorrected.Tbfilt = sum(cat(3,TPCorrected.TbArcIce, TPCorrected.TbArcOcean, TPCorrected.TbAntIce,TPCorrected.TbAntOcean),3,'omitnan');