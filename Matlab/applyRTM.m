% Differential RTM correction for one day (script, runs inside main.m).
% Needs: DataOfDay (struct array of the day's files), Uncorrected, spos2ia, TPnames
%
% Tb_corr = Tb + ( RTM(day-mean weather) - RTM(pixel weather) )
% L is NOT corrected: the day-mean L goes into both runs (paper Sect. 4.1;
% ERA5 clouds do not match the 1973 clouds pixel by pixel, see report_notes/A6).

nF   = numel(DataOfDay);
hemi = ["Arc","Arc","Ant","Ant"];      % SIC field per tie-point class

% --- 1) mean weather per file and class (fresh arrays every day) ---------
Vsingle  = NaN(nF,4);
Wsingle  = NaN(nF,4);
Lsingle  = NaN(nF,4);
Tssingle = NaN(nF,4);
Tisingle = NaN(nF,4);

for j = 1:nF
    DataOfDay(j).SIC = calculateSIC(DataOfDay(j), Uncorrected);
    wx = weatherFields(DataOfDay(j));
    for k = 1:4
        mask = DataOfDay(j).TP.(TPnames(k));
        Vsingle(j,k)  = meanOfWeather(wx.V,  mask);
        Wsingle(j,k)  = meanOfWeather(wx.W,  mask);
        Lsingle(j,k)  = meanOfWeather(wx.L,  mask);
        Tssingle(j,k) = meanOfWeather(wx.Ts, mask);
        Tisingle(j,k) = meanOfWeather(wx.Ti, mask);
    end
end

% --- 2) reference weather = mean over the day ----------------------------
Vday  = mean(Vsingle, 1,'omitnan');
Wday  = mean(Wsingle, 1,'omitnan');
Lday  = mean(Lsingle, 1,'omitnan');
Tsday = mean(Tssingle,1,'omitnan');
Tiday = mean(Tisingle,1,'omitnan');

% --- 3) correct every pixel, class by class ------------------------------
theta1 = abs(reshape(spos2ia(5:end-4), [], 1));   % same crop as filterTb

for j = 1:nF
    theta = repmat(theta1, [1, DataOfDay(j).dimensions.Time]);
    wx = weatherFields(DataOfDay(j));
    C = struct();
    for k = 1:4
        name = TPnames(k);
        mask = DataOfDay(j).TP.(name);           % logical mask
        TbTP = DataOfDay(j).TP.("Tb" + name);
        refOK = all(~isnan([Vday(k) Wday(k) Lday(k) Tsday(k) Tiday(k)]));

        if any(mask(:)) && refOK
            c = DataOfDay(j).SIC.(hemi(k));  c(~mask) = NaN;
            V = wx.V;   V(~mask)  = NaN;
            W = wx.W;   W(~mask)  = NaN;
            Ts = wx.Ts; Ts(~mask) = NaN;
            Ti = wx.Ti; Ti(~mask) = NaN;

            RTMref = esmr_rtm(Vday(k),Wday(k),Lday(k),Tsday(k),Tiday(k),c,theta);
            RTMact = esmr_rtm(V,W,Lday(k),Ts,Ti,c,theta);
            C.("Tb" + name) = TbTP + (RTMref - RTMact);
        else
            % this class has no pixels in this file (or none on this day)
            C.("Tb" + name) = NaN(size(TbTP));
        end
    end
    DataOfDay(j).Corrected = C;
end

function wx = weatherFields(D)
    v = D.variables;
    wx.V  = v.tcwv.data(5:end-4,:);                               % water vapour [mm]
    wx.W  = sqrt(v.u10.data(5:end-4,:).^2 + v.v10.data(5:end-4,:).^2); % wind [m/s]
    wx.L  = max(v.tcw.data(5:end-4,:) - v.tcwv.data(5:end-4,:), 0);  % cloud water [mm] (tcw - tcwv)
    wx.Ts = v.sst.data(5:end-4,:);                                % SST [K]
    wx.Ti = 0.4 * v.t2m.data(5:end-4,:) + 0.6*272;                % ice temperature [K]
end

function mPara = meanOfWeather(Para, Mask)
    Para(~Mask) = NaN;
    mPara = mean(Para,'all','omitnan');
end
