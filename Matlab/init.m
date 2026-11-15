load("spos2ia.mat")

TPstats = [];
TPstatsCorrected = [];

Uncorrected.Ant_ice_mean = [];
Uncorrected.Ant_ice_std = [];
Uncorrected.Ant_ocean_mean = [];
Uncorrected.Ant_ocean_std = [];

Uncorrected.Arc_ice_mean = [];
Uncorrected.Arc_ice_std = [];
Uncorrected.Arc_ocean_mean = [];
Uncorrected.Arc_ocean_std = [];

Corrected.Ant_ice_mean = [];
Corrected.Ant_ice_std = [];
Corrected.Ant_ocean_mean = [];
Corrected.Ant_ocean_std = [];

Corrected.Arc_ice_mean = [];
Corrected.Arc_ice_std = [];
Corrected.Arc_ocean_mean = [];
Corrected.Arc_ocean_std = [];

% 2x28 Matrix: Zeile 1 = Startindex, Zeile 2 = Endindex (Tag 1 bis 28, exakt 312 Dateien)
day_indices = [ ...
    1,   13,   25,   36,   50,   61,   75,   87,   99,  110,  123,  134,  144,  154,  164,  175,  185,  201,  216,  227,  239,  250,  262,  273,  285,  295,  307,  312; ...
   12,   24,   35,   49,   60,   74,   86,   98,  109,  122,  133,  143,  153,  163,  174,  184,  200,  215,  226,  238,  249,  261,  272,  284,  294,  306,  311,  312  ...
];

structNames = [];

SIC.Ant = [];
SIC.Arc = [];
SIC.Land = [];
SIC.Lat = [];
SIC.Lon = [];

TPnames = ["ArcIce", "ArcOcean","AntIce","AntOcean"];
