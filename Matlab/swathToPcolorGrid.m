function [LonGrid, LatGrid, ValGrid] = swathToPcolorGrid(Val,Lon, Lat, roundDecimals)
% Wandelt Schwad-Daten (Lon, Lat, Val) in ein Gitter für pcolor um.
% Mehrfachwerte auf exakt denselben Koordinaten werden gemittelt (ohne NaN).
%
% Optional: roundDecimals (z. B. 2 für 0.01°-Genauigkeit), falls Koordinaten
% durch Fließkomma-Rundung minimal abweichen. Standard: [] (exakt).

    if nargin < 4
        roundDecimals = [];
    end

    % 1. Alle Arrays in Spaltenvektoren umwandeln
    lonVec = Lon(:);
    latVec = Lat(:);
    valVec = Val(:);

    % 2. Ungültige Koordinaten oder Werte entfernen
    valid = isfinite(lonVec) & isfinite(latVec) & ~isnan(valVec);
    lonVec = lonVec(valid);
    latVec = latVec(valid);
    valVec = valVec(valid);

    % Optional: Koordinaten leicht runden, falls identische Punkte minimal driften
    if ~isempty(roundDecimals)
        lonVec = round(lonVec, roundDecimals);
        latVec = round(latVec, roundDecimals);
    end

    % 3. Eindeutige Koordinatenpaare finden und Mittelwert pro Gruppe bilden
    [uniquePairs, ~, groupIdx] = unique([lonVec, latVec], 'rows', 'sorted');
    meanVals = accumarray(groupIdx, valVec, [], @(x) mean(x, 'omitnan'));

    % 4. Eindeutige Lon- und Lat-Achsen sortiert aufbauen
    lonAxis = unique(uniquePairs(:, 1), 'sorted');
    latAxis = unique(uniquePairs(:, 2), 'sorted');

    [LonGrid, LatGrid] = meshgrid(lonAxis, latAxis);
    ValGrid = NaN(size(LonGrid));

    % 5. Mittelwerte ins 2D-Gitter einsortieren
    [~, colIdx] = ismember(uniquePairs(:, 1), lonAxis);
    [~, rowIdx] = ismember(uniquePairs(:, 2), latAxis);
    linIdx = sub2ind(size(ValGrid), rowIdx, colIdx);
    ValGrid(linIdx) = meanVals;
end