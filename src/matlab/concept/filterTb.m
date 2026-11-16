function [Tbfilt] = filterTb(A)
% A:        struct of data from NetCDF file
% Tbfilt:   Matrix of size 70x1691 with filtered data (4 pixels cut on each side)

N = A.dimensions.obs;   % Across-track pixels
T = A.dimensions.Time;  % Along-track pixels

Tb = A.variables.Brightness_temperature.data;

% Filter: out of range values
Tb(Tb < 90) = NaN;
Tb(Tb > 273.15) = NaN;

% Filter whole scans: mean absolute change to the next scan >= 50 K
% (omitnan: a single missing pixel must not switch the test off)
for i = 1:T-1
    d = abs(Tb(:,i+1)-Tb(:,i));
    n = nnz(~isnan(d)); % # of valid pixel pairs
    if n > 0 && sum(d,'omitnan')/n >= 50
        Tb(:,i) = NaN;
    end
end

% Filter single pixels: spike against both neighbours (sum >= 150 K)
for i = 2:T-1
   Tsum = abs(Tb(:,i)-Tb(:,i+1)) + abs(Tb(:,i-1)-Tb(:,i));
   Tb(Tsum >= 150,i) = NaN;
end

% Filter stuck values: 7 identical scans in a row -> remove the whole run
stuck = false(size(Tb));
for i = 1:T-6
   Tsum = abs(Tb(:,i+6)-Tb(:,i+5)) + abs(Tb(:,i+5)-Tb(:,i+4)) + ...
       abs(Tb(:,i+4)-Tb(:,i+3)) + abs(Tb(:,i+3)-Tb(:,i+2)) + ...
       abs(Tb(:,i+2)-Tb(:,i+1)) + abs(Tb(:,i+1)-Tb(:,i));
   stuck(Tsum == 0, i:i+6) = true;
end
Tb(stuck) = NaN;

% Filter outer (symmetric: 4 pixels on each side)
Tbfilt = Tb(5:N-4,:);
end
