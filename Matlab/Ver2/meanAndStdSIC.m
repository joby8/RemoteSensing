function [Stats] = meanAndStdSIC(sic_arc,sic_ant, Stats)

if ~isfield(Stats,"ant_mean")
    Stats.ant_mean = [];
end
Stats.ant_mean = [Stats.ant_mean, mean(sic_ant,'all','omitnan')];

if ~isfield(Stats,"arc_mean")
    Stats.arc_mean = [];
end
Stats.arc_mean = [Stats.arc_mean, mean(sic_arc,'all','omitnan')];


% Standard Deviation
if ~isfield(Stats,"ant_std")
    Stats.ant_std = [];
end
Stats.ant_std = [Stats.ant_std, std(sic_ant,0,'all','omitnan')];

if ~isfield(Stats,"arc_std")
    Stats.arc_std = [];
end
Stats.arc_std = [Stats.arc_std, std(sic_arc,0,'all','omitnan')];
end