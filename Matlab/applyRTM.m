function [deltaTb] = applyRTM(A)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
V = A.variables.tcw.data; % column water in kg/m^2 = mm
L = V - A.variables.tcwv.data ; % cloud water vaper = total column water - total water vapor in kg/m^2 = mm 
WS = sqrt(abs(A.variables.v10.data).^2 + abs(A.variables.u10.data).^2); % wind speed in m/s
SST = A.variables.sst.data; % Sea surface Temp in K
Ti = 0.4 * A.variables.t2m.data + 0.6*272; % Ice Temperature in K % Emitting Ice Layer Temp in K
c_ice = A.variables.siconc.data; % sea ice concentration
theta = A.variables.incidence; % incidence angle in deg

RTMactual = esmr_rtm(V,WS,L,SST,Ti,c_ice,theta);


deltaTb = RTMactual;
end