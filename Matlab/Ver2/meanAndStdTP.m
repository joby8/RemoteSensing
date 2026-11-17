function [TPstats] = meanAndStdTP(TP, TPstats)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

% Mean Value
if ~isfield(TPstats,"ant_ice_mean")
    TPstats.ant_ice_mean = [];
end
TPstats.ant_ice_mean = [TPstats.ant_ice_mean, mean(TP.TbAntIce,'all','omitnan')];

if ~isfield(TPstats,"ant_ocean_mean")
    TPstats.ant_ocean_mean = [];
end
TPstats.ant_ocean_mean = [TPstats.ant_ocean_mean, mean(TP.TbAntOcean,'all','omitnan')];

if ~isfield(TPstats,"arc_ice_mean")
    TPstats.arc_ice_mean = [];
end
TPstats.arc_ice_mean = [TPstats.arc_ice_mean, mean(TP.TbArcIce,'all','omitnan')];

if ~isfield(TPstats,"arc_ocean_mean")
    TPstats.arc_ocean_mean = [];
end
TPstats.arc_ocean_mean = [TPstats.arc_ocean_mean, mean(TP.TbArcOcean,'all','omitnan')];


% Standard Deviation
if ~isfield(TPstats,"ant_ice_std")
    TPstats.ant_ice_std = [];
end
TPstats.ant_ice_std = [TPstats.ant_ice_std, std(TP.TbAntIce,0,'all','omitnan')];

if ~isfield(TPstats,"ant_ocean_std")
    TPstats.ant_ocean_std = [];
end
TPstats.ant_ocean_std = [TPstats.ant_ocean_std, std(TP.TbAntOcean,0,'all','omitnan')];

if ~isfield(TPstats,"arc_ice_std")
    TPstats.arc_ice_std = [];
end
TPstats.arc_ice_std = [TPstats.arc_ice_std, std(TP.TbArcIce,0,'all','omitnan')];

if ~isfield(TPstats,"arc_ocean_std")
    TPstats.arc_ocean_std = [];
end
TPstats.arc_ocean_std = [TPstats.arc_ocean_std, std(TP.TbArcOcean,0,'all','omitnan')];
end