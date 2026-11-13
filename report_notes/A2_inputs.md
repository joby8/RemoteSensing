# A2 – Preparing the inputs for the correction

**Report section:** Method → input data for the RTM
**Code:** `src/matlab/load_orbit.m`, `src/matlab/a2_plot.m` (Python: `src/a2_plot.py`)
**Figure:** `output/A2_tb_latlon_matlab.png` (raw vs. filtered T_B on lat/lon)
**Status:** done 2026-11-09

## Goal
Derive every RTM input per pixel (Kolbe et al. 2024, Sect. 4.1, Eq. 13–15) from the file variables.

## What we did
| Symbol | Meaning | From | Example orbit (min / max / mean) |
|---|---|---|---|
| θ | incidence angle | `provided/spos2ia.txt`, 78 values, symmetric, ±63.86° at the edges | −63.86 … 63.86° |
| W | 10 m wind speed | √(u10² + v10²) | 0.03 / 22.75 / 6.24 m/s |
| V | water vapour | `tcwv` | 0.39 / 74.17 / 18.75 kg/m² |
| L | cloud liquid water | `tcw − tcwv` (Tonboe, meeting 2026-11-10) | – |
| T_s | sea surface temperature | `sst` | 270.4 / 305.5 / 285.5 K |
| T_i | ice (emitting layer) temperature | Eq. 15: T_i = 0.4·t2m + 0.6·272 K | 252.2 / 289.4 / 274.5 K |

- Negative θ = left side of the swath, positive = right side.
- Plotted T_B on lat/lon to check geolocation and the effect of the file's filter.

## Decisions and reasons
- **L = tcw − tcwv**: no cloud liquid in the files; difference of total column water and vapour is the best proxy (Tonboe).
- **T_i from Eq. 15** as in the paper. The 272 K is a fixed value; Tonboe said we may check better values (→ `istl1`).

## For the report
- Table above (inputs, sources, equations) is basically the method table.
- One sentence on why each variable matters: W → surface roughness/foam (raises T_B over water), V and L → atmospheric emission, T_s → water emission, T_i → ice emission.

## Open
- Ice emissivity in `provided/esmr_rtm.py` is 0.93, paper Table 1 says 0.91 (irrelevant over open water, but mention if the ice side is used).
