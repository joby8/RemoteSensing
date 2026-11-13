function Tb=esmr_rtm(V,W,L,Ts,Ti,c_ice,theta)
%"""---------------------------------------------------------------------------
%Wentz: a well calibrated ocean algorithm for ssm/i. JGR 102(C4), 8703-8718, 1997
%with modifications to work at incidence angles between nadir and 60 deg and over sea ice
%computes the brightness temperature of the ocean surface at 19 GHz horisontal polarisation
%Tb=f(V,W,L,Ts,Ti,c_ice,theta)
%V: columnar water vapor [mm]
%W: windspeed over water [m/s], 10m
%L: columnar cloud liquid water [mm]
%Ts: sea surface temperature [K, i.e. SST
%Ti: ice surface temperature [K], i.e. emitting layer temperature
%c_ice: ice concentration [0-1]
%theta: incidence angle [deg]
%-------------------------------------------------------------------------------"""
  
    thetar=0.0174533.*theta;
    %#the ice emissivity as a function of incidence angle, based MEMLS simulations for 19h, avg. for winter months Nov-Mar
    x=[0.00, 5.00, 10.0, 15.0, 20.0, 25.0, 30.0, 35.0, 40.0, 45.0, 50.0, 55.0, 60.0];
    e=[0.9318, 0.9316, 0.9309, 0.9296, 0.9278, 0.9254, 0.9222, 0.9180, 0.9126, 0.9058, 0.8994, 0.8883, 0.8713];
    %#linear interpolation
    e_ice=interp1(x,e,theta);

    %#table 1: atmospheric coefficients for 19h
    c0=240.0E+0;
    c1=305.96E-2;
    c2=-764.41E-4;
    c3=885.95E-6;
    c4=-40.80E-7;
    c5=0.60E+0;
    c6=-0.16E+0;
    c7=-2.13E-2;
    a0=11.80E+0;
    av1=2.23E-3;
    av2=0.00E-5;

    %#table 2: water surface scattering, reflected downwelling for 19h
    Xi=0.688;

    %#ice concentration between 0 and 1
    if (c_ice < 0.0)
      c_ice=0.0;
    end
    if (c_ice > 1.0) 
      c_ice=1.0;
    end %if
    
    %#the isotropic Tb radiative transfer equation eq 15
    %#Tb=TBU+tau*(emissivity*Ts+(1-emissivity)*(omega*TBD+tau*TBC))
    %#eq 18a
    if (V <= 48.0) 
      Tv=273.16+0.8337.*V-3.029E-5.*(V.^3.33);
    %#eq 18b
    else  
      Tv=301.16;
    end %if
    %#eq 22 + 23
    Tl=(Ts+273.0)./2.0;
    Al37=0.208.*(1-0.026*(Tl-283)).*L;
    Al=0.2858.*Al37;

    %#cosmic background
    TBC=2.7;

    %#eq17a
    TD=c0+c1.*V+c2*(V.^2)+c3.*(V.^3)+c4*(V.^4)+c5.*(Ts-Tv);
    %#eq17b
    TU=TD+c6+c7.*V;
    %#eq 20
    A0=(a0./TD).^1.4;
    %#eq 21
    Av=av1.*V+av2.*(V.^2);
            
    %#eq 19 transmitance through the atmosphere
    tau=exp((-1.0./cos(thetar)).*(A0+Av+Al));
    %#eq 16a up-welling Tb
    TBU=TU.*(1.0-tau);
    %#eq 16b down-welling Tb
    TBD=TD.*(1.0-tau);


    %#water permittivity as a function of temperature, Ulaby et al. 1986 E64a
    temp=[-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,...
          16,17,18,19,20,21,22,23,24,25];

    permre=[15.3,15.9,16.5,17.1,17.8,18.5,19.2,20.0,20.7,21.5,...
           22.3,23.2,24.0,24.9,25.7,26.6,27.5,28.4,29.3,30.2,31.1,...
           31.9,32.8,33.6,34.5,35.3,36.1,36.8,37.6,38.3,39.0];

    permim=[28.0,28.6,29.1,29.7,30.3,30.9,31.4,31.9,32.4,32.9,...
           33.4,33.8,34.2,34.6,35.0,35.3,35.6,35.9,36.1,36.3,36.4,...
           36.6,36.7,36.7,36.8,36.8,36.7,36.7,36.6,36.5,36.4];

    %#linear interpolation
    %#real part of the water permittivity at 19.35GHz, 34psu and temperature
    e_w_r=interp1(temp,permre, Ts-273.15);

    %#imag part of the water permittivity at 19.35GHz, 34psu and temperature
    e_w_i=interp1(temp,permim, Ts-273.15);

    %#eq.1.52 in Schanda: physical fundamentals of remote sensing 1986.
    p=(1/sqrt(2)).*(((e_w_r - sin(thetar).^2).^2 + e_w_i.^2).^0.5 + (e_w_r - sin(thetar).^2)).^0.5;
    q=(1/sqrt(2)).*(((e_w_r - sin(thetar).^2).^2 + e_w_i.^2).^0.5 - (e_w_r - sin(thetar).^2)).^0.5;
    rih=((p - cos(thetar)).^2 + q.^2)./((p + cos(thetar)).^2 + q.^2);

    E0=(1.0-abs(rih));

    %#Ulaby+ Meissner and Wentz 2012        
    Ew=(0.0094.*theta+0.3).*W./Ts;

    %#eq 29 sea surface slope variance: sigma**2
    sigma=sqrt(5.22E-3.*Xi.*W);
    if (sigma.^2 > 0.07) 
      sigma=sqrt(0.07);
    end %if
    %#eq 28 reflection reduction factor due to surface roughness, used only
    %for the downwelling
    omega=1.0+6.1.*(sigma.^2-68.0.*sigma.^6).*tau.^2;
    %#eq 24 ocean surface emissivity a combination of fresnel 
    %and a windinduced roughness correction
    emissivity=E0+Ew;
    %#eq 16 the radiative transfer equation
    Tb=TBU+tau.*((1.0-c_ice).*emissivity.*Ts+c_ice.*e_ice.*Ti+...
                (1.0-c_ice).*(1.0-emissivity).*(omega.*TBD+tau.*TBC)...
                    +c_ice.*(1.0-e_ice).*(TBD+tau.*TBC));
end %function
