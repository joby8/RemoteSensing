# A4 – Tie-point masks (open water and ice)

**Report section:** Method → tie points
**Code:** `src/matlab/a4_mask.m`
**Figures:** `output/A4_masks.png`, `output/globe_A4_masks_N.png` / `_S.png`; interactive: `output/globe/ESMR_globe.html` (colour "Masks")
**Status:** done 2026-11-13

## Goal
Select the pixels that define the open-water and the 100 % ice brightness temperature (tie points), separately for each hemisphere.

## What we did
Applied on top of the A3 filters (scan positions 5–74, |lat| ≥ 50°):

| | Open water | Ice |
|---|---|---|
| ERA5 SIC | siconc = 0 | siconc ≥ 0.95 (treated as 100 %) |
| SST | > 278 K | – |
| T_B | 90 K < T_B < 180 K | 100 K < T_B < 274 K |
| Latitude | \|lat\| ≥ 50° | \|lat\| ≥ 50° |

Split into North (lat > 0) and South.

## Result (orbit 1973-02-01 02:23)
| Class | Hemisphere | n | mean T_B | std |
|---|---|---|---|---|
| water | N | 3 996 | 145.85 K | 6.49 K |
| water | S | 5 341 | 139.96 K | 6.48 K |
| ice | N | 4 204 | 228.51 K | 14.58 K |
| ice | S | 631 | 212.02 K | 23.99 K |

Water pixels sit in the Labrador Sea / North Atlantic and the Southern Ocean; ice pixels in the central Arctic and along the Antarctic coast.

## Decisions and reasons
- **Water criteria = paper Table 2** (siconc = 0, SST > 278 K, 90 < T_B < 180 K). SST > 278 K keeps only water that is clearly ice-free (Tonboe: "water must be cold enough" – the only SST threshold in the paper is 278 K).
- **Ice: siconc ≥ 0.95 → treated as 100 %** (Tonboe). Paper Table 2 uses > 0.8 plus a 5×5-box mean > 0.8; we are stricter on the pixel and skip the box.
- **5×5-box criterion not applied** (distance from the ice edge). Simplification; could reduce ice-edge contamination of the water tie point.
- **Separate hemispheres** (Tonboe: both hemispheres, separate calibration; no local tie points).

## For the report
- Table of criteria (above) next to paper Table 2, with our deviations marked.
- Map/globe of the masks.
- Note: Antarctic ice tie point rests on few pixels (≈ 3–6 k per day vs. 40–100 k in the Arctic) and has a larger std.

## Open
- Ask Tonboe: is the 5×5 box needed? Are 95 % pixels in the South enough?
- Coastal spill-over: some water pixels next to land may still be warm (visible on the globe with land cut out).
