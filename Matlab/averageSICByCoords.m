function [sicAvg, latUnique, lonUnique, sicGrid] = averageSICByCoords(SIC, Latitude, Longitude, decimals)
% AVERAGESICBYCOORDS Mittelt SIC-Werte an identischen (Latitude, Longitude)-Koordinaten.
%
% Eingaben:
%   SIC       : Matrix oder Vektor der Meereiskonzentration
%   Latitude  : Matrix oder Vektor der Breitengrade (gleiche Größe wie SIC)
%   Longitude : Matrix oder Vektor der Längengrade (gleiche Größe wie SIC)
%   decimals  : (Optional) Nachkommastellen zum Runden der Koordinaten
%               (Standard = 4; Inf = exakter Vergleich ohne Runden)
%
% Ausgaben:
%   sicAvg    : Spaltenvektor der gemittelten SIC-Werte pro eindeutiger Koordinate
%   latUnique : Spaltenvektor der eindeutigen Breitengrade
%   lonUnique : Spaltenvektor der eindeutigen Längengrade
%   sicGrid   : Matrix derselben Größe wie SIC, in der jeder gültige Punkt
%               durch den Mittelwert seiner Koordinate ersetzt ist

    if nargin < 4 || isempty(decimals)
        decimals = 4;
    end

    if ~isequal(size(SIC), size(Latitude), size(Longitude))
        error('SIC, Latitude und Longitude müssen dieselbe Dimension haben.');
    end

    % In Spaltenvektoren umwandeln
    sicVec = SIC(:);
    latVec = Latitude(:);
    lonVec = Longitude(:);

    % Nur Punkte mit gültigen Koordinaten berücksichtigen
    validCoords = isfinite(latVec) & isfinite(lonVec);

    if isfinite(decimals)
        latKey = round(latVec(validCoords), decimals);
        lonKey = round(lonVec(validCoords), decimals);
    else
        latKey = latVec(validCoords);
        lonKey = lonVec(validCoords);
    end

    sicValid = sicVec(validCoords);

    % Gruppen anhand eindeutiger (lat, lon)-Paare bilden
    [groupIdx, latUnique, lonUnique] = findgroups(latKey, lonKey);

    % Mittelwert pro Gruppe unter Ignorieren von NaN berechnen
    % (wenn alle Werte einer Gruppe NaN sind, bleibt das Ergebnis NaN)
    sicAvg = splitapply(@(x) mean(x, 'omitnan'), sicValid, groupIdx);

    % Optional: Gemittelte Werte zurück in die ursprüngliche Matrixform bringen
    sicGrid = NaN(size(SIC));
    validIndices = find(validCoords);
    sicGrid(validIndices) = sicAvg(groupIdx);
end