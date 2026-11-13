function [Tbfilt] = filterTb(A)
% A:        struct of data from NetCDF file
% Tbfilt:   Matrix of size 78x1691 with filtered data

N = A.dimensions.obs;   % Across-track pixels
T = A.dimensions.Time;  % Along-track pixels

Tb = A.variables.Brightness_temperature.data;

% Filter: out of range values
Tb(Tb < 90) = NaN;
Tb(Tb > 273.15) = NaN;

% Filter across track
for i = 1:T-1
    n = nnz(~isnan(Tb(:,i))); % # of valid pixel
    Tsum = sum(abs(Tb(:,i+1)-Tb(:,i)))/n;
    if Tsum >= 50
        Tb(:,i) = NaN;
    end
end

% Filter Along track
for i = 2:T-1
   Tsum = abs(Tb(:,i)-Tb(:,i+1)) + abs(Tb(:,i-1)-Tb(:,i));
   Tb(Tsum >= 150,i) = NaN;
end

for i = 1:T-6
   Tsum = abs(Tb(:,i+6)-Tb(:,i+5)) + abs(Tb(:,i+5)-Tb(:,i+4)) + ...
       abs(Tb(:,i+4)-Tb(:,i+3)) + abs(Tb(:,i+3)-Tb(:,i+2)) + ...
       abs(Tb(:,i+2)-Tb(:,i+1)) + abs(Tb(:,i+1)-Tb(:,i));
   Tb(Tsum == 0,i) = NaN;
end

% Filter outer
Tbfilt = Tb(5:N-5,:);

% Check Results
% figure();
% imagesc(Tbfilt,'AlphaData',~isnan(Tb))
% c = colorbar;
% c.Label.String = "Tb in K";
% xlabel("Along Track")
% ylabel("Across track")
end