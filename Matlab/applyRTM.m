clear mask c

nhemi = (DataOfDay.Latitude > 50 & DataOfDay.Latitude < 90)+0;
nhemi(nhemi == 0) = NaN;
shemi = (DataOfDay.Latitude < -50 & DataOfDay.Latitude > -90)+0;
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
sic_init = DataOfDay.siconc;
sic_init(DataOfDay.siconc >= 0.95) = 1;
sic_init(DataOfDay.siconc < 0.15) = 0;

c(1).c = sic_init;
c(2).c = sic_init;
c(3).c = sic_init;
c(4).c = sic_init;


clear RTMmean RTM deltaTb
RTMmean(4) = struct();
RTM(4) = struct();
deltaTb(4) = struct();

for i = 1:4

WS = sqrt((DataOfDay.u10.*mask(i).mask).^2+(DataOfDay.v10.*mask(i).mask).^2);
Ts = DataOfDay.sst.*mask(i).mask;
Ti = 0.4*DataOfDay.t2m.*mask(i).mask+0.6*272;
V =  DataOfDay.tcwv.*mask(i).mask;
L = DataOfDay.tcw.*mask(i).mask-V;
theta = abs(DataOfDay.incidence.*mask(i).mask);

% WS = sqrt(DataOfDay.u10.^2+DataOfDay.v10.^2);
% Ts = DataOfDay.sst;
% Ti = 0.4*DataOfDay.t2m+0.6*272;
% V =  DataOfDay.tcwv;
% L = DataOfDay.tcw-V;
% theta = abs(DataOfDay.incidence);

WSmean = mean(WS,'all','omitnan');
Tsmean = mean(Ts,'all','omitnan');
Timean = mean(Ti,'all','omitnan');
Vmean = mean(V,'all','omitnan');
Lmean = mean(L,'all','omitnan');

RTMmean(i).data = esmr_rtm_mod(Vmean,WSmean,Lmean,Tsmean,Timean,c(i).c,theta);
RTM(i).data = esmr_rtm_mod(V,WS,Lmean,Ts,Ti,c(i).c,theta);

deltaTb(i).data = RTMmean(i).data-RTM(i).data;
end
Corrected = DataOfDay;

Corrected.TbArctic = sum(cat(3,DataOfDay.Tbfilt, deltaTb(1).data),3);
Corrected.TbAntarctic = sum(cat(3,DataOfDay.Tbfilt, deltaTb(3).data),3);
Corrected.Tbfilt = sum(cat(3,Corrected.TbArctic, Corrected.TbAntarctic),3,'omitnan');

Corrected.TbArcIce = DataOfDay.TbArcIce + deltaTb(1).data;
Corrected.TbArcOcean = DataOfDay.TbArcOcean + deltaTb(2).data;
Corrected.TbAntIce = DataOfDay.TbAntIce + deltaTb(3).data;
Corrected.TbAntOcean = DataOfDay.TbAntOcean + deltaTb(4).data;