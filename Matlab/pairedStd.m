function R = pairedStd(DataOfDay, fld)
% Vergleicht STD vor/nach Korrektur auf IDENTISCHER Punktmenge und pro Einfallswinkel
% (wie Fig. 5 im Paper). fld z.B. 'TbArcOcean'.
TbU = []; TbC = [];
for j = 1:numel(DataOfDay)
    u = DataOfDay(j).TP.(fld);
    c = DataOfDay(j).Corrected.(fld);
    ok = isfinite(u) & isfinite(c);
    u(~ok) = NaN;  c(~ok) = NaN;
    TbU = [TbU, u];  TbC = [TbC, c];   %#ok<AGROW>
end
R.n      = sum(isfinite(TbU),2);                 % Punkte pro Scanposition
R.stdU   = std(TbU,0,2,'omitnan');               % STD je Winkel, unkorrigiert
R.stdC   = std(TbC,0,2,'omitnan');               % STD je Winkel, korrigiert
bad = R.n < 30;  R.stdU(bad) = NaN;  R.stdC(bad) = NaN;
R.meanStdU = mean(R.stdU,'omitnan');
R.meanStdC = mean(R.stdC,'omitnan');
R.pooledU  = std(TbU(:),'omitnan');              % deine bisherige Kennzahl, aber gleiche Punkte
R.pooledC  = std(TbC(:),'omitnan');
R.nTotal   = sum(R.n);
end
