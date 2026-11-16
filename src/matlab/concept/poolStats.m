function S = poolStats(S, items)
%POOLSTATS Append one day's tie-point statistics to S.
%   items: struct array with fields TbArcIce, TbArcOcean, TbAntIce, TbAntOcean
%   (one element per orbit file). All pixels of the day are pooled, so the
%   std includes the spread between orbits and every pixel has equal weight.
map = {'Arc_ice','TbArcIce'; 'Arc_ocean','TbArcOcean'; ...
       'Ant_ice','TbAntIce'; 'Ant_ocean','TbAntOcean'};
for k = 1:size(map,1)
    v = cell2mat(arrayfun(@(x) x.(map{k,2})(:), items(:), 'UniformOutput', false));
    v = v(~isnan(v));
    if isempty(v)
        m = NaN; s = NaN;
    else
        m = mean(v); s = std(v);
    end
    S = appendField(S, [map{k,1} '_mean'], m);
    S = appendField(S, [map{k,1} '_std'],  s);
    S = appendField(S, [map{k,1} '_n'],    numel(v));
end
end

function S = appendField(S, name, val)
if ~isfield(S, name), S.(name) = []; end
S.(name)(end+1) = val;
end
