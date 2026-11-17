# A4 – Tie-point masks (open water and ice)

**Report section:** Method → tie points
**Code:** `src/matlab/a4_mask.m`
**Figures:** `output/A4_masks.png`, `output/globe_A4_masks_N.png` / `_S.png`; interactive: `output/globe/ESMR_globe.html` (colour "Masks")
**Status:** done 2026-11-13; masks changed 2026-11-17 (Tonboe meeting), code now `src/matlab/tp_masks.m` (used by A4, A6b, correct_day/globe, B2)

## Goal
Select the pixels that define the open-water and the 100 % ice brightness temperature (tie points), separately for each hemisphere.

## What we did
Applied on top of the A3 filters (scan positions 5–74, |lat| ≥ 50°):

| | Open water | Ice |
|---|---|---|
| ERA5 SIC | siconc ≤ 0.01 | siconc > 0.8 |
| SST | > 278 K | – |
| T_B | 90 K < T_B < 180 K | **180 K** < T_B < 274 K |
| ERA5 land fraction | lsm = 0 | lsm = 0 |
| Latitude | \|lat\| ≥ 50° | \|lat\| ≥ 50° |

History: first version (2026-11-13) used siconc = 0 (water), siconc ≥ 0.95 and 100 K < T_B (ice), no lsm cut. A6b (2026-11-13) switched the ice cluster to Table 2's siconc > 0.8. Meeting 2026-11-17: siconc ≤ 0.01 counts as ocean, ice T_B lower limit 180 K (clear-ocean pixels at ≈ 145 K had been counted as ice; 180 K = upper water limit, no overlap), coastal pixels out (lsm = 0).

Split into North (lat > 0) and South.

## Result (orbit 1973-02-01 02:23, current masks)
| Class | Hemisphere | n | mean T_B | std |
|---|---|---|---|---|
| water | N | 3 959 | 145.79 K | 6.46 K |
| water | S | 5 143 | 139.67 K | 5.87 K |
| ice | N | 4 416 | 229.52 K | 10.99 K |
| ice | S | 1 226 | 210.01 K | 17.55 K |

(First version: water N 3 996 / S 5 341, ice N 4 204 / S 631 pixels, ice T_B std 14.6 / 24.0 K.)

Water pixels sit in the Labrador Sea / North Atlantic and the Southern Ocean; ice pixels in the central Arctic and along the Antarctic coast.

## Decisions and reasons
- **Water criteria = paper Table 2** (SST > 278 K, 90 < T_B < 180 K), with siconc ≤ 0.01 instead of = 0 (Tonboe 2026-11-17: 1 % SIC still counts as ocean). SST > 278 K keeps only water that is clearly ice-free (Tonboe: "water must be cold enough" – the only SST threshold in the paper is 278 K).
- **Ice: siconc > 0.8** (Table 2, used since A6b) and **T_B > 180 K** (Tonboe 2026-11-17, removes clear-ocean pixels). Paper Table 2 also has a 5×5-box mean > 0.8, which we skip.
- **Coastal pixels out (ERA5 lsm = 0)** for both clusters: land spill-over in the large ESMR footprint.
- **5×5-box criterion not applied** (distance from the ice edge). Simplification; could reduce ice-edge contamination of the water tie point.
- **Separate hemispheres** (Tonboe: both hemispheres, separate calibration; no local tie points).

## For the report
- Table of criteria (above) next to paper Table 2, with our deviations marked.
- Map/globe of the masks.
- Note: Antarctic ice tie point rests on few pixels (≈ 3–6 k per day vs. 40–100 k in the Arctic) and has a larger std.

## Open
- Ask Tonboe: is the 5×5 box needed? Are 95 % pixels in the South enough?
- ~~Coastal spill-over~~: solved with lsm = 0 (2026-11-17).
