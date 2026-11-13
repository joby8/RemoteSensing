function [TPstats] = meanAndStdTP(TP, TPstats)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

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

TPstats.ant_ice_std = std(TP.TbAntIce,0, 'all','omitnan');
TPstats.ant_ocean_std = std(TP.TbAntOcean,0, 'all','omitnan');
TPstats.arc_ice_std = std(TP.TbArcIce, 0,'all','omitnan');
TPstats.arc_ocean_std = std(TP.TbArcOcean,0, 'all','omitnan');
% 
% TPstats.ant_ice_std_inc = std(TP.TbAntIce,0, 2,'omitnan');
% TPstats.ant_ocean_std_inc = std(TP.TbAntOcean,0, 2,'omitnan');
% TPstats.arc_ice_std_inc = std(TP.TbArcIce, 0,2,'omitnan');
% TPstats.arc_ocean_std_inc = std(TP.TbArcOcean,0, 2,'omitnan');
end