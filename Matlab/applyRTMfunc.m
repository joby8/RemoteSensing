function [Corrected]= applyRTMfunc(Data)
nhemi = (Data.Latitude > 50 & Data.Latitude < 90)+0;
nhemi(nhemi == 0) = NaN;
shemi = (Data.Latitude < -50 & Data.Latitude > -90)+0;
shemi(shemi==0) = NaN; 

mask(4) = struct();
mask(1).mask = nhemi;
mask(2).mask = nhemi;
mask(3).mask = shemi;
mask(4).mask = shemi;

c(4) = struct();
c(1).c = 1;
c(2).c = 0;
c(3).c = 1;
c(4).c = 0;

C(4) = struct();
sic_init = Data.siconc;
sic_init(Data.siconc >= 0.95) = 1;
sic_init(Data.siconc < 0.15) = 0;

c(1).c = sic_init;
c(2).c = sic_init;
c(3).c = sic_init;
c(4).c = sic_init;

RTMmean(4) = struct();
RTM(4) = struct();
deltaTb(4) = struct();

for i = 1:4

WS = sqrt((Data.u10.*mask(i).mask).^2+(Data.v10.*mask(i).mask).^2);
Ts = Data.sst.*mask(i).mask;
Ti = 0.4*Data.t2m.*mask(i).mask+0.6*272;
V =  Data.tcwv.*mask(i).mask;
L = Data.tcw.*mask(i).mask-V;
theta = abs(Data.incidence.*mask(i).mask);

WSmean = mean(WS,'all','omitnan');
Tsmean = mean(Ts,'all','omitnan');
Timean = mean(Ti,'all','omitnan');
Vmean = mean(V,'all','omitnan');
Lmean = mean(L,'all','omitnan');

RTMmean(i).data = esmr_rtm_mod(Vmean,WSmean,Lmean,Tsmean,Timean,c(i).c,theta);
RTM(i).data = esmr_rtm_mod(V,WS,Lmean,Ts,Ti,c(i).c,theta);

deltaTb(i).data = RTMmean(i).data-RTM(i).data;

end
Corrected = Data;

Corrected.ArcDelta = deltaTb(1).data;
Corrected.AntDelta = deltaTb(3).data;

Corrected.TbArctic = sum(cat(3,Data.Tbfilt, deltaTb(1).data),3);
Corrected.TbAntarctic = sum(cat(3,Data.Tbfilt, deltaTb(3).data),3);
Corrected.Tbfilt = sum(cat(3,Corrected.TbArctic, Corrected.TbAntarctic),3,'omitnan');
Corrected.Tbfilt(Corrected.Tbfilt == 0) = NaN;

Corrected.TbArcIce = Data.TbArcIce + deltaTb(1).data;
Corrected.TbArcOcean = Data.TbArcOcean + deltaTb(2).data;
Corrected.TbAntIce = Data.TbAntIce + deltaTb(3).data;
Corrected.TbAntOcean = Data.TbAntOcean + deltaTb(4).data;
end