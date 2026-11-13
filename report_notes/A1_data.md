# A1 – Data: reading one ESMR swath file

**Report section:** Data (ESMR L1 swath files + ERA5 collocation)
**Code:** `src/matlab/a1_inspect.m`, `src/matlab/load_orbit.m` (first version in Python: `src/a1_inspect.py`)
**Status:** done 2026-11-09

## Goal
Open one NetCDF swath file, list all variables with shape and units, and find out what has already been done to the data ("filtered" in the folder name).

## What we did
- Data set: `ESMR_colocated_filtered/`, **312 orbits, 1–28 Feb 1973**, 5.6 GB, created by DMI (W. Kolbe), collocated with ERA5 in 2021.
- Example orbit: `Nimbus5-ESMR_1973m0201t022301_DS32.nc` (1973-02-01 02:23:01–04:15:41 UTC).
- Dimensions: **Time = 1691 scan lines × obs = 78 scan positions**. MATLAB reads it as [78 × lines]; `load_orbit.m` transposes to [lines × 78].
- Variables (Kolbe et al. 2024, Appendix A1):
  - satellite: `Brightness_temperature` [K], `Latitude`, `Longitude` [deg], housekeeping (`HOT_MEAN`, `COLD_MEAN`, status bits, attitude errors, `Height`, …)
  - ERA5 (per pixel): `u10`, `v10`, `t2m`, `istl1–4` (ice temperature layers), `lsm` (land–sea mask), `msl`, `siconc`, `sst`, `skt`, `sp`, `tcw`, `tcwv`
  - `brightness_temperature_filtered`
- Values are already in K and degrees (no ÷10 scaling needed).

## Findings
- `brightness_temperature_filtered` = raw T_B with NaN outside **90 K < T_B ≤ 273.15 K** → Eq. 1 of the paper is already applied (8 % NaN in the example orbit, mostly land).
- Scan positions 1–4 and 75–78 are **not** removed yet.
- `sst` and `siconc` are NaN over land (41 % of the orbit).
- **No cloud liquid water variable** in the files; only `tcw` (total column water) and `tcwv` (water vapour). → L = `tcw − tcwv` (decided with Tonboe, see A2).
- No incidence-angle variable → from `provided/spos2ia.txt` (see A2).

## For the report
- Short description of the data set: instrument (ESMR, 19.35 GHz, H-pol, cross-track scanner), period used (Feb 1973), number of orbits, ERA5 collocation by DMI.
- Table of the variables we actually use (T_B, lat, lon, u10, v10, tcwv, tcw, sst, t2m, siconc).
- Mention: Feb 1973 lies **before the hot-load anomaly (Mar–May 1973)**, so no calibration problem expected in our month.

## Open / ideas
- `lsm` exists: could be a cleaner land mask than "sst is NaN".
- `istl1` (ERA5 ice temperature, layer 1) exists: possible alternative to the fixed Eq. 15 for T_i (Tonboe: "check whether better values exist").
