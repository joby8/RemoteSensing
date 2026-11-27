# A6b – Iterative correction with ERA5 c_ice (final Task 1 method)

**Report section:** Method → SIC algorithm and noise reduction; Results → Task 1
**Code:** `src/matlab/a6b_iterative.m` (uses `esmr_rtm_vec.m`; all of Feb 1973 in ~70 s, 3 iterations)
**Output:** `output/A6b_iterative.csv` (per day, hemisphere and iteration), `output/A6b_iterative.png` (daily std; rows Arctic/Antarctic, columns water/ice), `output/A6b_hist.png` (open-water SIC histogram, Arctic top, Antarctic bottom), `output/A6b_pixels.mat` (per-pixel data of both clusters, **iteration 2**)
**Figures and means:** 1–27 Feb; 28 Feb is left out (only 1 orbit). Since 2026-11-16 the figure and the pixel file use iteration 2 (before: the figure showed iteration 3, 0.1–0.4 % higher).
**Status:** done 2026-11-13; replaces A6 as the main method (A6 = simple version with fixed c = 0/1, keep as comparison)

## Current numbers (state 2026-11-24: water SST > 272 K, all 78 scan positions) – use these in the report
Method as below, with the current masks (`tp_opt.m`): water siconc ≤ 0.01, SST > 272 K, |lat| > 55°, 90 < T_B < 180 K;
ice siconc > 0.8 (pixel and 5 × 5 box), 180 < T_B < 274 K; both lsm = 0 and ≤ 10 % land in the 5 × 5 box; all 78
scan positions; c clipped to 0..1 before each iteration, no 15 % limit. 1–27 Feb, mean of the daily values.

| | iteration | water px/day | ice px/day | T_p,water u → c [K] | T_p,ice u → c [K] | σ water SIC u → c | σ ice SIC u → c | days improved water / ice |
|---|---|---|---|---|---|---|---|---|
| N | 1 | 23 443 | 61 552 | 142.83 → 142.79 | 225.51 → 225.73 | 9.40 → 7.02 % | 12.37 → 11.49 % | 27 / 26 |
| N | **2** | | | 142.83 → **142.65** | 225.51 → **225.96** | 9.40 → **6.76 %** (−28 %) | 12.37 → **10.74 %** | 27 / 27 |
| N | 3 | | | → 142.66 | → 225.93 | → 6.79 % | → 10.79 % | 27 / 27 |
| S | 1 | 100 023 | 7 901 | 136.64 → 136.66 | 212.00 → 212.14 | 9.76 → 8.28 % | 22.85 → 22.87 % | 27 / 16 |
| S | **2** | | | 136.64 → **136.53** | 212.00 → **212.22** | 9.76 → **8.04 %** (−18 %) | 22.85 → **22.54 %** | 27 / 20 |
| S | 3 | | | → 136.55 | → 212.21 | → 8.07 % | → 22.57 % | 27 / 19 |

- Ice–water contrast (corrected): N 83.3 K, S 75.7 K.
- Convergence, mean |c_new − c_used| [% SIC], water / ice: iteration 1 N 2.7 / 5.4, S 3.1 / 8.7; iteration 2
  N 0.16 / 0.40, S 0.19 / 0.25; iteration 3 ≤ 0.04. **Iteration 2 stays the final one**; iteration 3 is 0.03 points worse.
- Mean water SIC is 0 by construction (tie point = cluster mean).
- Compared with 23 Nov (273 K, positions 5–74): +11 % (N) / +29 % (S) water pixels, σ water corrected +0.2 (N) /
  +0.7 (S) points, because the outer scan positions are the noisiest (B2). Details: `rerun_2026-11-24.md`.
- **Report sentence (Task 1):** the RTM correction lowers the open-water SIC std from 9.4 to 6.8 % in the Arctic and
  from 9.8 to 8.0 % in the Antarctic (iteration 2, 1–27 Feb 1973); the water std improves on every day.
- Everything below this section is the history of the method (older masks, older numbers).

## Agreed in the feedback session (2026-11-13)
- Tie points **per day**, north and south separately.
- Tie-point selection as in **Table 2**, but keep our **|lat| ≥ 50°** cut.
- **Start with c_ice from ERA5, then iterate** (paper Sect. 4.1, steps 1–2).
- Report the **std per day, north and south, for the water and the ice tie points**.

## What we did
1. Clusters per day and hemisphere:
   - water: **siconc ≤ 0.01**, SST > 278 K, 90 < T_B < 180 K
   - ice: **siconc > 0.8**, **180** < T_B < 274 K
   - both: |lat| ≥ 50°, scan positions 5–74, ERA5 **lsm = 0** (no coastal pixels) (version of 13–17 Nov; current masks: see the section above)
   - Code: `src/matlab/tp_masks.m`. Until 2026-11-17: siconc = 0 / 100 K / no lsm cut (Table 2 as written); changed after the Tonboe meeting, see the update section at the end.
2. **Iteration 1:** c_ice = ERA5 siconc of each pixel.
3. **Reference values mixed by c_ice:** X_ref = (1 − c)·X̄_water + c·X̄_ice for V, W, L, Ts and Ti. The paper describes this as "c_ice is used as a ratio to mix the two tie-point values".
   - ΔT_B = RTM(X_ref, c, θ) − RTM(X_pixel, c, θ)
   - L is not corrected: L_ref goes into both runs.
4. Corrected tie points = cluster means of T_B + ΔT_B. Then the SIC of all cluster pixels (Eq. 16).
5. **New c_ice** = that SIC, truncated to 0–1, values below 0.15 set to 0 (paper step 1). Then repeat from step 3.

## Result of 17 Nov (history; current numbers at the top)
| | Water: std SIC before → after | Ice: std SIC before → after | Days improved (water / ice) |
|---|---|---|---|
| North | 9.6 → **7.05 %** (−27 %) | 12.5 → **10.9 %** | 27/27 / 27/27 |
| South | 11.9 → **9.3 %** (−21 %) | 24.6 → **23.7 %** | 26/27 / 24/27 |

(Old masks, before 2026-11-17: water N 10.5 → 8.2 %, S 14.3 → 11.0 %; ice N 14.6 → 13.0 %, S 44.3 → 40.5 %.)

**Convergence**, measured as mean |c_new − c_used| in % SIC:

| Iteration | Water N / S | Ice N / S |
|---|---|---|
| 1 | 0.5 / 1.4 | 5.6 / 9.2 |
| 2 | 0.2 / 0.4 | 0.5 / 0.5 |
| 3 | 0.1 / 0.3 | 0.05 / 0.06 |

- **Iteration 2 is the best.** Iteration 3 changes almost nothing; the std even goes up slightly (0.1–0.2 %). This agrees with the paper: "updates are small after one iteration". Use iteration 2.
- Tie points (corrected): T_p,water ≈ 144.5 K (N) and 140.8 K (S), hardly changed by the correction; T_p,ice 226.5 K (N), 211.2 K (S).

## Important finding: the Southern ice tie point with siconc > 0.8
(Numbers in this section are from the old masks with 100 K. With the 180 K limit (2026-11-17) the Southern T_p,ice rises to 211 K, contrast 70 K, ice T_B std 17 K, ice SIC std 23.7 %: most of the problem came from clear-ocean pixels in the ice cluster.)

| | T_p,ice | Ice–water contrast | T_B std of ice cluster |
|---|---|---|---|
| A6 (siconc ≥ 0.95) S | 214 K | 73 K | – |
| A6b (siconc > 0.8) S | 200 K | **59 K** | **26 K** |
| A6b N | 226 K | 81 K | 12 K |

- **Contrast shrinks:** In the South the > 0.8 criterion pulls in many pixels with much lower T_B, so the contrast drops from 73 to 59 K.
  - Every K of noise then means more % SIC.
  - That is why the uncorrected water std in the South rises from 11.5 % (A5/A6) to 14.3 %.
- **Ice std is very high:** 41 % in the South, growing towards the end of February.
- **Likely causes**, not tested:
  - ERA5 SIC before 1979 comes from ice charts (HadISST2, Walsh / NIC), which are less reliable in the Antarctic.
  - Late February is the Antarctic minimum, with melting ice and a wide marginal ice zone.
  - The 5×5-box criterion, which we skip, would remove ice-edge pixels.
- In the North the ice cluster is fine (std 13 %, 79 k pixels per day).

## For the report
- Task 1 figures: `A6b_iterative.png` (daily std) and `A6b_hist.png` (histogram of all pooled open-water pixels, mean 0 %; numbers from the old masks were std N 10.6 → 8.2 %, S 14.3 → 11.0 %, re-read from the new figure). Antarctic histogram: small shoulder at +12…16 % after correction. Possible cause, not tested: the c < 0.15 → 0 step of the iteration, so pixels just above 15 % get a different reference.
- Method: describe steps 1–5 as the final algorithm. One sentence on A6 as a simpler variant (fixed c = 0/1) giving similar water results (−17 % with siconc ≥ 0.95).
- Results Task 1: the table and the 4-panel figure (daily std, water and ice, N and S).
- Discussion:
  - The correction reduces the open-water noise by about 21–27 % (about 2.5 percentage points of SIC).
  - It also reduces the ice-side noise, but less.
  - The Southern ice tie point is the weak point (Antarctic summer: melt, wet snow, water vapour; meeting 2026-11-17). Raising the ice T_B limit to 180 K removed the clear-ocean pixels and halved the ice std (40.5 → 23.7 %).

## Open / to discuss
- South: is siconc > 0.8 really the best choice, or ≥ 0.95, or add the 5×5 box? Show the numbers above to Tonboe.
- Task 2: RTM sensitivity study (agreed). Task 3: std vs. θ from `A6b_pixels.mat` (θ, sic_u, sic_c per pixel, `cls` 1 = water, 2 = ice).

## Update 2026-11-17: tie-point masks changed (Tonboe meeting, `report_notes/meeting_2026-11-17.md`)
New shared function `src/matlab/tp_masks.m` (used by `a6b_iterative.m`, `correct_day.m`, `b2_angle.m`):
- water: siconc **≤ 0.01** (was = 0): 1 % SIC still counts as ocean.
- ice: lower T_B limit **180 K** (was 100 K): clear-ocean pixels (T_B ≈ 145 K) had been counted as ice. 180 K = upper limit of the water mask, so the two masks no longer overlap.
- both: ERA5 land-sea fraction **lsm == 0**: coastal pixels (land spill-over in the large ESMR footprint) are dropped from the tie points. Before, land only dropped out via NaN sst/siconc (ERA5 lsm > 0.5).
- Older steps A4/A5/A6 keep the original Table 2 masks (baseline, not rerun).

Effect (iteration 2, mean of 1–27 Feb):

| | water px/day | ice px/day | T_p,ice | std water SIC | std ice SIC |
|---|---|---|---|---|---|
| N old → new | 17.0k → 15.8k (15.9k*) | 79k → 60k (61k*) | 226.3 → 226.5 K | 8.15 → **7.05 %** | 13.0 → **10.9 %** |
| S old → new | 35.7k → 35.3k (35.6k*) | 12.9k → 8.9k | 201.2 → **211.2 K** | 10.97 → **9.33 %** (9.34*) | 40.5 → **23.7 %** |

Uncorrected → corrected (iteration 2, new masks): water N 9.6 → 7.05 %, S 11.9 → 9.3 %; ice N 12.5 → 10.9 %, S 24.6 → 23.7 %. Water improved on 27/27 (N) and 26/27 (S) days.
The southern ice tie point was the weak point (contrast 59 K, ice std 40 %): with ocean pixels removed it rises 10 K and the ice std almost halves. The remaining southern ice noise (~24 %) fits Antarctic summer (melt, wet snow, water vapour; meeting note 7).
(* = after the preprocessing change of 2026-11-17, below.)

## Update 2026-11-17 (later): rerun with the central preprocessing default
- `a6b_iterative.m` now uses `o.valid` from `esmr_preprocess.m` (default `preproc_config()`: raw T_B, Eq. 1, per-pixel Eq. 2, **Eq. 3 line mode ± 1 line**, Eq. 4, edge, |lat| ≥ 50°, land = SST missing; analog filter off). Before, the run used DMI's `brightness_temperature_filtered`.
- Effect on the result is ≤ 0.01 points (iteration 2, 1–27 Feb):
  - water N 9.61 → 7.05 % (unchanged), S 11.88 → 9.34 % (was 9.33)
  - ice N 12.53 → 10.86 %, S 24.57 → 23.70 % (unchanged)
- About 1 % more tie-point pixels, because DMI's analog-based line removal is gone:
  - water N 15.75k → 15.93k, S 35.34k → 35.59k per day
  - ice N 60.2k → 60.8k, S 8.86k → 8.91k per day
- Tie points (corrected): N 144.49 / 226.48 K, S 140.84 / 211.18 K. Contrast 82.0 / 70.3 K.
- Iteration 3: water N 7.12 %, S 9.45 % (≤ 0.12 points above iteration 2).
- Our iteration scheme is an **intentional deviation** from the paper:
  - The paper (p. 1253–1254) does one RTM correction, starting from the uncorrected SIC.
  - We start from ERA5 c (iteration 1) and iterate once more (iteration 2).
  - Question for Tonboe: `questions_2026-11-17.md`.

> **Update 2026-11-23 / 2026-11-24:** current numbers are in the section at the top. Update 2026-11-23: recomputed with the 23 Nov masks (SST > 273 K, |lat| > 55°, 5 × 5 land box) and the new clipping (no 15 % filter). Numbers above are from 17 Nov; old → new values in `rerun_2026-11-23.md` (full table `output/rerun_compare.csv`).
