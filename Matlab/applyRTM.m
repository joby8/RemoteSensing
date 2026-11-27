function [Corrected]= applyRTM(Data)
nhemi = (Data.Latitude > 50 & Data.Latitude < 90)+0;
nhemi(nhemi == 0) = NaN;
shemi = (Data.Latitude < -50 & Data.Latitude > -90)+0;
shemi(shemi==0) = NaN; 

mask(4) = struct();
mask(1).mask = Data.ArcIce;
mask(2).mask = Data.ArcOcean;
mask(3).mask = Data.AntIce;
mask(4).mask = Data.AntOcean;


c(4) = struct();
sic_init = Data.siconc;
sic_init(Data.siconc >= 0.99) = 1;
sic_init(Data.siconc < 0.01) = 0;

c(1).c = sic_init;
c(2).c = sic_init;
c(3).c = sic_init;
c(4).c = sic_init;

WS = sqrt((Data.u10).^2+(Data.v10).^2);
Ts = Data.sst;
Ti = 0.4*Data.t2m+0.6*272;
V =  Data.tcwv;
L = Data.tcw-V;
theta = abs(Data.incidence);

for i = 1:4
WSmean(i) = mean(WS.*mask(i).mask,'all','omitnan');
Tsmean(i) = mean(Ts.*mask(i).mask,'all','omitnan');
Timean(i) = mean(Ti.*mask(i).mask,'all','omitnan');
Vmean(i) = mean(V.*mask(i).mask,'all','omitnan');
Lmean(i) = mean(L.*mask(i).mask,'all','omitnan');

end
c = sic_init;

WSArc = c*WSmean(1) + (1-c)*WSmean(2);
TsArc = c*Tsmean(1) + (1-c)*Tsmean(2);
TiArc = c*Timean(1) + (1-c)*Timean(2);
VArc = c*Vmean(1) + (1-c)*Vmean(2);
LArc = c*Lmean(1) + (1-c)*Lmean(2);

WSAnt = c*WSmean(3) + (1-c)*WSmean(4);
TsAnt = c*Tsmean(3) + (1-c)*Tsmean(4);
TiAnt = c*Timean(3) + (1-c)*Timean(4);
VAnt = c*Vmean(3) + (1-c)*Vmean(4);
LAnt = c*Lmean(3) + (1-c)*Lmean(4);

RTMmean.Arc = esmr_rtm_mod(VArc,WSArc,LArc,TsArc,TiArc,c,theta);
RTMmean.Ant = esmr_rtm_mod(VAnt,WSAnt,LAnt,TsAnt,TiAnt,c,theta);
RTM.Arc = esmr_rtm_mod(V,WS,LArc,Ts,Ti,c,theta);
RTM.Ant = esmr_rtm_mod(V,WS,LAnt,Ts,Ti,c,theta);

deltaTb.Arc = (RTMmean.Arc-RTM.Arc).*nhemi;
deltaTb.Ant = (RTMmean.Ant-RTM.Ant).*shemi;

Corrected = Data;

Corrected.ArcDelta = deltaTb.Arc;
Corrected.AntDelta = deltaTb.Ant;

Corrected.Tbfilt = Data.Tbfilt + sum(cat(3, deltaTb.Arc,deltaTb.Ant),3,'omitnan');

Corrected.TbArctic = Corrected.Tbfilt.*nhemi;
Corrected.TbAntarctic = Corrected.Tbfilt.*shemi;

Corrected.TbArcIce = Corrected.Tbfilt.*Data.ArcIce;
Corrected.TbArcOcean = Corrected.Tbfilt.*Data.ArcOcean;
Corrected.TbAntIce = Corrected.Tbfilt.*Data.AntIce;
Corrected.TbAntOcean = Corrected.Tbfilt.*Data.AntOcean;
end