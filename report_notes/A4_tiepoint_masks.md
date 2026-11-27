# A4 – Tie-point masks (open water and ice)

**Report section:** Method → tie points
**Code:** `src/matlab/a4_mask.m`
**Figures:** `output/A4_masks.png`, `output/globe_A4_masks_N.png` / `_S.png`; interactive: `output/globe/ESMR_globe.html` (colour "Masks")
**Status:** done 2026-11-13; masks changed 2026-11-17 (Tonboe meeting), code now `src/matlab/tp_masks.m` (used by A4, A6b, correct_day/globe, B2)

## Goal
Select the pixels that define the open-water and the 100 % ice brightness temperature (tie points), separately for each hemisphere.

## What we did
Applied on top of the A3 filters (**all 78 scan positions** since 2026-11-24, before: 5–74; |lat| ≥ 50°):

| | Open water | Ice |
|---|---|---|
| ERA5 SIC | siconc ≤ 0.01 | siconc > 0.8 |
| SST | **> 272 K** (24 Nov, Tonboe: near the freezing point of sea water; 23 Nov: 273 K; 20 Nov: 275 K; before: 278 K) | – |
| T_B | 90 K < T_B < 180 K | **180 K** < T_B < 274 K |
| ERA5 land fraction | lsm = 0 **and ≤ 10 % land in the 5 × 5 box** (box new 20 Nov) | same |
| Latitude | **\|lat\| > 55°** (until 20 Nov: ≥ 50°) | \|lat\| ≥ 50° |

History: first version (2026-11-13) used siconc = 0 (water), siconc ≥ 0.95 and 100 K < T_B (ice), no lsm cut. A6b (2026-11-13) switched the ice cluster to Table 2's siconc > 0.8. Meeting 2026-11-17: siconc ≤ 0.01 counts as ocean, ice T_B lower limit 180 K (clear-ocean pixels at ≈ 145 K had been counted as ice; 180 K = upper water limit, no overlap), coastal pixels out (lsm = 0). Meeting 2026-11-20: water SST > 275 K and |lat| > 55° (more and colder water pixels), both lsm = 0 and ≤ 10 % land in the 5 × 5 box (no tie points next to the coast); thresholds in `tp_opt.m`, the 17 Nov masks are `tp_opt('nov17')`. Why: see `A4b_tp_sweep.md`. 2026-11-23: SST > 273 K (A4d); a tie-point outlier test was tried and rejected (`A4e_tp_outliers.md`); 20 Nov masks = `tp_opt('nov20')`. 2026-11-24 (Tonboe): SST > 272 K and all 78 scan positions; 23 Nov masks = `tp_opt('nov23')`.

Split into North (lat > 0) and South.

## Result (orbit 1973-02-01 02:23, masks of 2026-11-24)
| Class | Hemisphere | n | mean T_B | std |
|---|---|---|---|---|
| water | N | 5 012 | 145.99 K | 7.00 K |
| water | S | 8 764 | 141.56 K | 8.17 K |
| ice | N | 4 500 | 228.75 K | 11.28 K |
| ice | S | 1 030 | 211.00 K | 17.33 K |

Month (A6b, 1–27 Feb, mean per day): water N 23 443 / S 100 023 pixels, ice N 61 552 / S 7 901 pixels.
(17 Nov masks for this orbit: water N 3 959 / S 5 143, ice N 4 416 / S 1 226. First version: water N 3 996 / S 5 341, ice N 4 204 / S 631 pixels, ice T_B std 14.6 / 24.0 K.)

Water pixels sit in the Labrador Sea / North Atlantic and the Southern Ocean; ice pixels in the central Arctic and along the Antarctic coast.

## Decisions and reasons
- **Water criteria:** paper Table 2 uses SST > 278 K and 90 < T_B < 180 K. We keep the T_B range, use siconc ≤ 0.01 instead of = 0 (Tonboe 2026-11-17: 1 % SIC still counts as ocean) and **SST > 272 K** (Tonboe 2026-11-24). Reason for the report: 272 K is just above the freezing point of sea water (≈ 271.4 K at S = 35), so the water reference is as cold as the open water next to the ice, where the SIC matters (A4b/A4d). |lat| > 55° and the 5 × 5 land box keep the cluster away from warm low-latitude water and the coast.
- **Ice: siconc > 0.8** (Table 2, used since A6b) and **T_B > 180 K** (Tonboe 2026-11-17, removes clear-ocean pixels). The 5×5-box mean > 0.8 of Table 2 was added later the same day (see section 5×5 box).
- **Coastal pixels out (ERA5 lsm = 0)** for both clusters: land spill-over in the large ESMR footprint.
- **5×5-box criterion applied since 2026-11-17** (distance from the ice edge, see section below).
- **Separate hemispheres** (Tonboe: both hemispheres, separate calibration; no local tie points).

## For the report
- Table of criteria (above) next to paper Table 2, with our deviations marked.
- Map/globe of the masks.
- Note: Antarctic ice tie point rests on few pixels (≈ 3–6 k per day vs. 40–100 k in the Arctic) and has a larger std.

## Open
- Ask Tonboe: are 95 % pixels in the South enough?
- ~~Coastal spill-over~~: solved with lsm = 0 (2026-11-17).

## Rerun 2026-11-17 with the central preprocessing (`o.valid`, default `preproc_config()`)
- `a4_mask.m` now uses `o.valid` instead of its own edge and latitude cuts. `o.valid` also removes land (ERA5 SST missing), which the masks already exclude via lsm = 0.
- The orbit 02:23 numbers in the table above are unchanged (identical pixel counts).

## 5×5 box (2026-11-17)
**Rule (paper Table 2, distance from the ice edge):** mean ERA5 siconc of a 5 × 5 box > 0.8 for ice and < 0.01 for open water, in addition to the pixel's own siconc criterion.

**Implementation (`tp_masks.m`):**
- Box = 5 scan lines × 5 scan positions, centred on the pixel, on the swath grid of one orbit.
- Mean = sum / count of non-NaN siconc (`movsum`, two passes). Land (NaN) does not count. At the swath edge the box shrinks. No siconc in the box means the test fails.
- The box is computed on the whole orbit siconc before any valid-masking, so neighbours count whatever the preprocessing removed.
- New criteria `C.w_box`, `C.i_box`, included in `mw` / `mi`.
- Switch: 5th argument `opt.box` (default true). `opt.box = false` reproduces the old masks.
- Globe: the box is folded into the siconc bits (bit 0 = siconc ≤ 0.01 and box < 0.01; bit 4 = siconc > 0.8 and box > 0.8); the assert against `o.mw` / `o.mi` passes.

**Comparison, 1–27 Feb, mean of the daily values, A6b iteration 2:**

| | N off | N on | S off | S on |
|---|---|---|---|---|
| n water pixels / day | 15 930 | 15 909 | 35 591 | 35 591 |
| n ice pixels / day | 60 809 | 60 329 | 8 913 | 7 950 |
| T_p,water raw / corr [K] | 144.38 / 144.49 | 144.38 / 144.49 | 140.79 / 140.84 | 140.79 / 140.85 |
| T_p,ice raw / corr [K] | 225.97 / 226.48 | 226.03 / 226.54 | 210.62 / 211.18 | 211.97 / 212.53 |
| σ SIC water raw → corr [%] | 9.61 → 7.05 | 9.60 → 7.04 | 11.88 → 9.34 | 11.65 → 9.18 |
| σ SIC ice raw → corr [%] | 12.53 → 10.86 | 12.45 → 10.74 | 24.57 → 23.70 | 24.02 → 23.18 |

**Reading:** the box has almost no effect on the water tie point (SST > 278 K already keeps the water far from the ice edge; the Southern Ocean count is identical). It removes ≈ 1 % of the Arctic and 11 % of the Antarctic ice pixels (thin or broken ice near the edge), raises the Antarctic ice tie point by ≈ 1.3 K and lowers the ice σ by 0.1–0.6 points. Task 1 numbers do not change materially.
