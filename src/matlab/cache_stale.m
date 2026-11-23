function tf = cache_stale(cf, key)
% True if the day cache file cf is missing or was built with another key (tie-point masks tp_opt() and
% preprocessing preproc_config()). Used by c1_sp459_compare.m and c2_feb1973_books.m, so a change of the masks
% (e.g. 2026-11-23) recomputes the caches instead of reusing old results.
tf = true;
if ~exist(cf, 'file'), return, end
w = whos('-file', cf);
if ~any(strcmp({w.name}, 'ckey')), return, end
S = load(cf, 'ckey');
tf = ~isequal(S.ckey, key);
end
