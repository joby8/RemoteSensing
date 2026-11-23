function [Stats] = meanAndStdSIC(sic_arc,sic_ant, Stats)

owaterlimit = 0.8;

arc_owater = sic_arc.*(sic_arc<owaterlimit);
arc_owater(sic_arc>owaterlimit) = NaN;

ant_owater = sic_ant.*(sic_ant<owaterlimit);
ant_owater(sic_arc > owaterlimit) = NaN;

if ~isfield(Stats,"ant_mean")
    Stats.ant_mean = [];
end
Stats.ant_mean = [Stats.ant_mean, mean(ant_owater,'all','omitnan')];

if ~isfield(Stats,"arc_mean")
    Stats.arc_mean = [];
end
Stats.arc_mean = [Stats.arc_mean, mean(arc_owater,'all','omitnan')];


% Standard Deviation
if ~isfield(Stats,"ant_std")
    Stats.ant_std = [];
end
Stats.ant_std = [Stats.ant_std, std(ant_owater,0,'all','omitnan')];

if ~isfield(Stats,"arc_std")
    Stats.arc_std = [];
end
Stats.arc_std = [Stats.arc_std, std(arc_owater,0,'all','omitnan')];
end