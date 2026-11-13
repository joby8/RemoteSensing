function Tb = esmr_rtm_vec(V, W, L, Ts, Ti, c_ice, theta)
% Vectorised MATLAB version of provided/esmr_rtm.m (same physics, same coefficients).
% 19.35 GHz H-pol, Wentz (1997) ocean model modified for 0-60 deg and sea ice.
% All inputs are arrays of the same size or scalars (implicit expansion).
%   V [kg/m2 = mm] water vapour, W [m/s] 10 m wind, L [kg/m2 = mm] cloud liquid,
%   Ts [K] SST, Ti [K] ice emitting-layer temperature, c_ice [0-1], theta [deg]
% Changes vs. the provided scalar code (no change of the physics):
%   - element-wise operators, if/else -> masks, Octave 'endif' removed
%   - |theta| for the ice emissivity table (provided code gives NaN for negative angles)
%   - Ts clipped to -5..25 degC for the permittivity table only (provided code gives NaN outside)
%   - interp1 with extrapolation for the ice emissivity above 60 deg (not used after A3 filter)
theta  = abs(theta);
thetar = 0.0174533 .* theta;

% ice emissivity vs. incidence angle (MEMLS, 19H, winter mean)
x = [0 5 10 15 20 25 30 35 40 45 50 55 60];
e = [0.9318 0.9316 0.9309 0.9296 0.9278 0.9254 0.9222 0.9180 0.9126 0.9058 0.8994 0.8883 0.8713];
e_ice = interp1(x, e, theta, 'linear', 'extrap');

% atmospheric coefficients, 19H (Wentz 1997, Table 1)
c0 = 240.0; c1 = 305.96E-2; c2 = -764.41E-4; c3 = 885.95E-6; c4 = -40.80E-7;
c5 = 0.60; c6 = -0.16; c7 = -2.13E-2; a0 = 11.80; av1 = 2.23E-3; av2 = 0.0;
Xi = 0.688;                                   % Table 2

c_ice = min(max(c_ice, 0), 1);

Tv = 273.16 + 0.8337 .* V - 3.029E-5 .* V.^3.33;          % eq 18a
Tv(V > 48) = 301.16;                                      % eq 18b
if isscalar(Tv) && V > 48, Tv = 301.16; end
Tl   = (Ts + 273.0) ./ 2.0;                               % eq 22 + 23
Al37 = 0.208 .* (1 - 0.026 .* (Tl - 283)) .* L;
Al   = 0.2858 .* Al37;
TBC  = 2.7;                                               % cosmic background
TD   = c0 + c1.*V + c2.*V.^2 + c3.*V.^3 + c4.*V.^4 + c5.*(Ts - Tv);   % eq 17a
TU   = TD + c6 + c7.*V;                                   % eq 17b
A0   = (a0 ./ TD).^1.4;                                   % eq 20
Av   = av1.*V + av2.*V.^2;                                % eq 21
tau  = exp((-1.0 ./ cos(thetar)) .* (A0 + Av + Al));      % eq 19
TBU  = TU .* (1.0 - tau);                                 % eq 16a
TBD  = TD .* (1.0 - tau);                                 % eq 16b

% sea water permittivity at 19.35 GHz, 34 psu (Ulaby et al. 1986, E64a)
temp   = -5:25;
permre = [15.3 15.9 16.5 17.1 17.8 18.5 19.2 20.0 20.7 21.5 22.3 23.2 24.0 24.9 25.7 26.6 ...
          27.5 28.4 29.3 30.2 31.1 31.9 32.8 33.6 34.5 35.3 36.1 36.8 37.6 38.3 39.0];
permim = [28.0 28.6 29.1 29.7 30.3 30.9 31.4 31.9 32.4 32.9 33.4 33.8 34.2 34.6 35.0 35.3 ...
          35.6 35.9 36.1 36.3 36.4 36.6 36.7 36.7 36.8 36.8 36.7 36.7 36.6 36.5 36.4];
tc    = min(max(Ts - 273.15, -5), 25);
e_w_r = interp1(temp, permre, tc);
e_w_i = interp1(temp, permim, tc);

% Fresnel reflectivity, H-pol (Schanda 1986, eq 1.52)
s2  = sin(thetar).^2;
p   = (1/sqrt(2)) .* (sqrt((e_w_r - s2).^2 + e_w_i.^2) + (e_w_r - s2)).^0.5;
q   = (1/sqrt(2)) .* (sqrt((e_w_r - s2).^2 + e_w_i.^2) - (e_w_r - s2)).^0.5;
rih = ((p - cos(thetar)).^2 + q.^2) ./ ((p + cos(thetar)).^2 + q.^2);
E0  = 1.0 - abs(rih);

Ew = (0.0094 .* theta + 0.3) .* W ./ Ts;                  % wind-induced emissivity (Meissner & Wentz 2012)
sigma = sqrt(min(5.22E-3 .* Xi .* W, 0.07));              % eq 29, slope variance capped at 0.07
omega = 1.0 + 6.1 .* (sigma.^2 - 68.0 .* sigma.^6) .* tau.^2;   % eq 28
emissivity = E0 + Ew;                                     % eq 24

Tb = TBU + tau .* ((1.0 - c_ice) .* emissivity .* Ts + c_ice .* e_ice .* Ti + ...
     (1.0 - c_ice) .* (1.0 - emissivity) .* (omega .* TBD + tau .* TBC) + ...
     c_ice .* (1.0 - e_ice) .* (TBD + tau .* TBC));       % eq 16
end
