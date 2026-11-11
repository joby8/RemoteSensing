"""A2: prepare one orbit (θ, W, V, Ts, Ti) and plot T_B on lat/lon."""
import sys, glob, re
import numpy as np
import netCDF4 as nc
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

def load_spos2ia(path="provided/spos2ia.txt"):
    txt = open(path).read()
    return np.array([float(x) for x in re.findall(r"-?\d+\.\d+", txt)])

def load_orbit(f):
    d = nc.Dataset(f)
    g = lambda n: np.ma.filled(d[n][:], np.nan).astype(float)
    o = dict(tb=g("Brightness_temperature"), tb_f=g("brightness_temperature_filtered"),
             lat=g("Latitude"), lon=g("Longitude"), sst=g("sst"), siconc=g("siconc"), t2m=g("t2m"))
    o["theta"] = np.broadcast_to(load_spos2ia(), o["tb"].shape)       # incidence angle per scan position
    o["W"] = np.hypot(g("u10"), g("v10"))                             # wind speed
    o["V"] = g("tcwv")                                                # water vapour
    o["Ts"] = o["sst"]
    o["Ti"] = 0.4 * o["t2m"] + 0.6 * 272.0                            # Eq. 15
    return o

if __name__ == "__main__":
    f = sys.argv[1] if len(sys.argv) > 1 else sorted(glob.glob("ESMR_colocated_filtered/*.nc"))[0]
    o = load_orbit(f)
    print("spos2ia length:", load_spos2ia().size, "| theta range:", o["theta"].min(), o["theta"].max())
    for k in ("W", "V", "Ts", "Ti"):
        print(f"{k}: min {np.nanmin(o[k]):.2f}  max {np.nanmax(o[k]):.2f}  mean {np.nanmean(o[k]):.2f}")
    fig, ax = plt.subplots(1, 2, figsize=(14, 5), sharex=True, sharey=True)
    for a, key, t in zip(ax, ("tb", "tb_f"), ("T_B raw", "T_B filtered (file)")):
        sc = a.scatter(o["lon"].ravel(), o["lat"].ravel(), c=o[key].ravel(), s=1, cmap="viridis", vmin=100, vmax=280)
        a.set(title=f"{t}\n{f.split('/')[-1]}", xlabel="Longitude [°E]"); a.grid(alpha=.3)
    ax[0].set_ylabel("Latitude [°N]")
    fig.colorbar(sc, ax=ax, label="T_B [K]", shrink=.85)
    import os; os.makedirs("output", exist_ok=True)
    fig.savefig("output/A2_tb_latlon.png", dpi=130, bbox_inches="tight")
    print("saved output/A2_tb_latlon.png")
