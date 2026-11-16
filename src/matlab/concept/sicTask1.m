function [rows, pix] = sicTask1(rows, pix, DataOfDay, dayKey, spos2ia)
%SICTASK1 Task 1: SIC (Eq. 16) of the tie-point pixels, uncorrected and corrected.
%   Per hemisphere the tie points of the day are the pooled means of the
%   water (Ocean) and ice clusters, once from the uncorrected and once from
%   the RTM-corrected Tb. Every cluster pixel then gets
%       SIC = (Tb - Tp_water) / (Tp_ice - Tp_water)
%   The statistics use the RAW SIC (no clipping); the clipped version
%   (calculateSIC rule: > 0.95 -> 1, < 0 -> 0) is stored for comparison.
%   Only pixels with both an uncorrected and a corrected Tb are used.
hemis = ["Arc","Ant"];  hn = ["N","S"];
cls   = ["Ocean","Ice"]; cn = ["water","ice"];
spos  = (5:78-4)';                       % scan positions kept by filterTb
for h = 1:2
    U = struct(); C = struct(); S = struct();
    for k = 1:2
        name = hemis(h) + cls(k);
        u = {}; c = {}; s = {};
        for j = 1:numel(DataOfDay)
            tu = DataOfDay(j).TP.("Tb" + name);
            tc = DataOfDay(j).Corrected.("Tb" + name);
            ok = ~isnan(tu) & ~isnan(tc);
            sp = repmat(spos, 1, size(tu,2));
            u{end+1} = tu(ok); c{end+1} = tc(ok); s{end+1} = sp(ok); %#ok<AGROW>
        end
        U.(cls(k)) = vertcat(u{:}); C.(cls(k)) = vertcat(c{:}); S.(cls(k)) = vertcat(s{:});
    end
    Tpw_u = mean(U.Ocean); Tpi_u = mean(U.Ice);
    Tpw_c = mean(C.Ocean); Tpi_c = mean(C.Ice);
    for k = 1:2
        su = (U.(cls(k)) - Tpw_u) / (Tpi_u - Tpw_u);
        sc = (C.(cls(k)) - Tpw_c) / (Tpi_c - Tpw_c);
        rows(end+1,:) = {string(dayKey), hn(h), cn(k), numel(su), Tpw_u, Tpw_c, Tpi_u, Tpi_c, ...
            100*mean(su), 100*std(su), 100*mean(sc), 100*std(sc), ...
            100*mean(clipSIC(su)), 100*std(clipSIC(su)), 100*mean(clipSIC(sc)), 100*std(clipSIC(sc))}; %#ok<AGROW>
        pix(end+1) = struct('day', string(dayKey), 'hemi', hn(h), 'cls', cn(k), ...
            'spos', uint8(S.(cls(k))), 'theta', single(reshape(spos2ia(S.(cls(k))),[],1)), ...
            'sic_u', single(su), 'sic_c', single(sc)); %#ok<AGROW>
    end
end
end

function s = clipSIC(s)
s(s > 0.95) = 1;
s(s < 0) = 0;
end
