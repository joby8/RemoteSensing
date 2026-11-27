function x = ncfast(f, name)
% Fast replacement for ncread(f, name) on the ESMR swath files (numeric variables only).
% ncread opens the file and reads all attributes on every call (~80 % of the run time of correct_day,
% profiled 2026-11-24). ncfast keeps the last file open and reads with the low-level netcdf library.
% Same result as ncread for these files: all variables are double with _FillValue = NaN, no scale/offset.
persistent fid fname
f = char(f);
if isempty(fid) || ~strcmp(fname, f)
    if ~isempty(fid), try netcdf.close(fid); catch, end, end
    fid = netcdf.open(f, 'NOWRITE'); fname = f;
end
x = netcdf.getVar(fid, netcdf.inqVarID(fid, name));
end
