"""A1: open one ESMR swath file, list variables, shapes, attributes."""
import sys, glob
import netCDF4 as nc

f = sys.argv[1] if len(sys.argv) > 1 else sorted(glob.glob("ESMR_colocated_filtered/*.nc"))[0]
ds = nc.Dataset(f)
print(f)
print("dimensions:", {k: len(v) for k, v in ds.dimensions.items()})
print("global attrs:", {k: ds.getncattr(k) for k in ds.ncattrs()})
print(f"\n{'variable':28s}{'shape':16s}{'dtype':9s}units / scale")
for n, v in ds.variables.items():
    extra = {a: v.getncattr(a) for a in v.ncattrs() if a in ("units", "scale_factor", "add_offset", "_FillValue", "long_name")}
    print(f"{n:28s}{str(v.shape):16s}{str(v.dtype):9s}{extra}")
