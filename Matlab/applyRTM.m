V = zeros(length(cdffiles),4);
W = zeros(length(cdffiles),4);
L = zeros(length(cdffiles),4);
Ts = zeros(length(cdffiles),4);
Ti = zeros(length(cdffiles),4);


for j = 1:length(cdffiles)    
    DataOfDay(j).SIC = calculateSIC(DataOfDay(j), Uncorrected);
    ArcIce = DataOfDay(j).TP.ArcIce;
    ArcOcean = DataOfDay(j).TP.ArcOcean;
    AntIce = DataOfDay(j).TP.AntIce;
    AntOcean = DataOfDay(j).TP.AntOcean;

    
    % Water vapor
    V = DataOfDay(j).variables.tcwv.data(5:end-5,:);
    Vsingle(j,1) = meanOfWeather(V,ArcIce);
    Vsingle(j,2) = meanOfWeather(V,ArcOcean);
    Vsingle(j,3) = meanOfWeather(V,AntIce);
    Vsingle(j,4) = meanOfWeather(V,AntOcean);
    
    % Wind speed
    W = sqrt(DataOfDay(j).variables.v10.data(5:end-5,:).^2 + DataOfDay(j).variables.u10.data(5:end-5,:).^2);
    Wsingle(j,1) = meanOfWeather(W,ArcIce);
    Wsingle(j,2) = meanOfWeather(W,ArcOcean);
    Wsingle(j,3) = meanOfWeather(W,AntIce);
    Wsingle(j,4) = meanOfWeather(W,AntOcean);

    % Cloud Liquid Water
    L = V- DataOfDay(j).variables.tcw.data(5:end-5,:);
    Lsingle(j,1) = meanOfWeather(L,ArcIce);
    Lsingle(j,2) = meanOfWeather(L,ArcOcean);
    Lsingle(j,3) = meanOfWeather(L,AntIce);
    Lsingle(j,4) = meanOfWeather(L,AntOcean);
    
    % Sea Surface Temperature
    Ts = DataOfDay(j).variables.sst.data(5:end-5,:);
    Tssingle(j,1) = meanOfWeather(Ts,ArcIce);
    Tssingle(j,2) = meanOfWeather(Ts,ArcOcean);
    Tssingle(j,3) = meanOfWeather(Ts,AntIce);
    Tssingle(j,4) = meanOfWeather(Ts,AntOcean);

    % Ice Temperature
    Ti = 0.4 * DataOfDay(j).variables.t2m.data(5:end-5,:) + 0.6*272;
    Tisingle(j,1) = meanOfWeather(Ti,ArcIce);
    Tisingle(j,2) = meanOfWeather(Ti,ArcOcean);
    Tisingle(j,3) = meanOfWeather(Ti,AntIce);
    Tisingle(j,4) = meanOfWeather(Ti,AntOcean);    
end

% Calculate mean of weather paramters for the day

ignore = (isnan(Vsingle) | isnan(Wsingle) | isnan(Tssingle) | isnan(Tisingle));

Vday = mean(Vsingle, 1,'omitnan');
Wday = mean(Wsingle, 1,'omitnan');
Lday = mean(Lsingle, 1,'omitnan');
Tsday = mean(Tssingle, 1,'omitnan');
Tiday = mean(Tisingle,1,'omitnan');

for j = 1:length(cdffiles)
    ArcIce = DataOfDay(j).TP.ArcIce;
    ArcOcean = DataOfDay(j).TP.ArcOcean;
    AntIce = DataOfDay(j).TP.AntIce;
    AntOcean = DataOfDay(j).TP.AntOcean;

    theta = spos2ia(5:end-5);
    theta = repmat(abs(theta'), [1,DataOfDay(j).dimensions.Time]);

    SIC_ArcIce = DataOfDay(j).SIC.Arc;
    % SIC_ArcIce = 1;
    SIC_ArcIce(isnan(ArcIce)) = NaN;
    SIC_ArcOcean = DataOfDay(j).SIC.Arc;
    % SIC_ArcOcean = 0;
    SIC_ArcOcean(isnan(ArcOcean)) = NaN;
    SIC_AntIce = DataOfDay(j).SIC.Ant;
    % SIC_AntIce = 1;
    SIC_AntIce(isnan(AntIce)) = NaN;
    SIC_AntOcean = DataOfDay(j).SIC.Ant;
    % SIC_AntOcean = 0;
    SIC_AntOcean(isnan(AntOcean)) = NaN;

    V = DataOfDay(j).variables.tcwv.data(5:end-5,:);
    VArcIce = V;
    VArcIce(isnan(ArcIce)) = NaN;
    VArcOcean = V;
    VArcOcean(isnan(ArcOcean)) = NaN;  
    VAntIce = V;
    VAntIce(isnan(ArcIce)) = NaN;  
    VAntOcean = V;
    VAntOcean(isnan(AntOcean)) = NaN;

    W = sqrt(DataOfDay(j).variables.v10.data(5:end-5,:).^2 + DataOfDay(j).variables.u10.data(5:end-5,:).^2);
    WArcIce = W;
    WArcIce(isnan(ArcIce)) = NaN;
    WArcOcean = W;
    WArcOcean(isnan(ArcOcean)) = NaN;  
    WAntIce = W;
    WAntIce(isnan(ArcIce)) = NaN;  
    WAntOcean = W;
    WAntOcean(isnan(AntOcean)) = NaN;

    Ts = DataOfDay(j).variables.sst.data(5:end-5,:);
    TsArcIce = Ts;
    TsArcIce(isnan(ArcIce)) = NaN;
    TsArcOcean = Ts;
    TsArcOcean(isnan(ArcOcean)) = NaN;  
    TsAntIce = Ts;
    TsAntIce(isnan(ArcIce)) = NaN;  
    TsAntOcean = Ts;
    TsAntOcean(isnan(AntOcean)) = NaN;

    Ti = 0.4 * DataOfDay(j).variables.t2m.data(5:end-5,:) + 0.6*272;
    TiArcIce = Ti;
    TiArcIce(isnan(ArcIce)) = NaN;
    TiArcOcean = Ti;
    TiArcOcean(isnan(ArcOcean)) = NaN;  
    TiAntIce = Ti;
    TiAntIce(isnan(ArcIce)) = NaN;  
    TiAntOcean = Ti;
    TiAntOcean(isnan(AntOcean)) = NaN;

    % Model for whole day
    RTMday_ArcIce = esmr_rtm(Vday(1),Wday(1),Lday(1),Tsday(1),Tiday(1),SIC_ArcIce,theta);
    RTMday_ArcOcean = esmr_rtm(Vday(2),Wday(2),Lday(2),Tsday(2),Tiday(2),SIC_ArcOcean,theta);
    RTMday_AntIce = esmr_rtm(Vday(3),Wday(3),Lday(3),Tsday(3),Tiday(3),SIC_AntIce,theta);
    RTMday_AntOcean = esmr_rtm(Vday(4),Wday(4),Lday(4),Tsday(4),Tiday(4),SIC_AntOcean,theta);

    % Model for individual measurement
    if ~any(ignore(j,:))
    RTM_ArcIce = esmr_rtm(VArcIce,WArcIce, Lday(1),TsArcIce,TiArcIce,SIC_ArcIce,theta);
    RTM_ArcOcean = esmr_rtm(VArcOcean,WArcOcean,Lday(2),TsArcOcean,TiArcOcean,SIC_ArcOcean,theta);
    RTM_AntIce = esmr_rtm(VAntIce,WAntIce,Lday(3),TsAntIce,TiAntIce,SIC_AntIce,theta);
    RTM_AntOcean = esmr_rtm(VAntOcean,WAntOcean,Lday(4),TsAntOcean,TiAntOcean,SIC_AntOcean,theta);

    % DeltaTb
    DeltaTb_ArcIce = RTMday_ArcIce - RTM_ArcIce;
    DeltaTb_ArcOcean = RTMday_ArcOcean - RTM_ArcOcean;
    DeltaTb_AntIce = RTMday_AntIce - RTM_AntIce;
    DeltaTb_AntOcean = RTMday_AntOcean - RTM_AntOcean;

    % Correct Tb
    DataOfDay(j).Corrected.TbArcIce = DataOfDay(j).TP.TbArcIce + DeltaTb_ArcIce;
    DataOfDay(j).Corrected.TbArcOcean = DataOfDay(j).TP.TbArcOcean + DeltaTb_ArcOcean;
    DataOfDay(j).Corrected.TbAntIce = DataOfDay(j).TP.TbAntIce + DeltaTb_AntIce;
    DataOfDay(j).Corrected.TbAntOcean = DataOfDay(j).TP.TbAntOcean + DeltaTb_AntOcean;
    else
    DataOfDay(j).Corrected.TbArcIce = NaN;
    DataOfDay(j).Corrected.TbArcOcean = NaN;
    DataOfDay(j).Corrected.TbAntIce = NaN;
    DataOfDay(j).Corrected.TbAntOcean = NaN;
    end

end

function mPara = meanOfWeather(Para, Mask)

    Para(~Mask) = NaN;
    mPara = mean(mean(Para,'omitnan'),'omitnan');

end