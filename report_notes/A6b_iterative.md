# A6b – Iterative correction with ERA5 c_ice (final Task 1 method)

**Report section:** Method → SIC algorithm and noise reduction; Results → Task 1
**Code:** `src/matlab/a6b_iterative.m` (uses `esmr_rtm_vec.m`; all of Feb 1973 in ~70 s, 3 iterations)
**Output:** `output/A6b_iterative.csv` (per day, hemisphere and iteration), `output/A6b_iterative.png` (daily std, water and ice, N and S), `output/A6b_pixels.mat` (per-pixel data of both clusters, last iteration)
**Status:** done 2026-11-13; replaces A6 as the main method (A6 = simple version with fixed c = 0/1, keep as comparison)

## Agreed in the feedback session (2026-11-13)
- Tie points **per day**, north and south separately.
- Tie-point selection as in **Table 2**, but keep our **|lat| ≥ 50°** cut.
- **Start with c_ice from ERA5, then iterate** (paper Sect. 4.1, steps 1–2).
- Report the **std per day, north and south, for the water and the ice tie points**.

## What we did
1. Clusters per day and hemisphere:
   - water: siconc = 0, SST > 278 K, 90 < T_B < 180 K
   - ice: **siconc > 0.8**, 100 < T_B < 274 K
   - both: |lat| ≥ 50°, scan positions 5–74
2. **Iteration 1:** c_ice = ERA5 siconc of each pixel.
3. **Reference values mixed by c_ice:** X_ref = (1 − c)·X̄_water + c·X̄_ice for V, W, L, Ts and Ti. The paper describes this as "c_ice is used as a ratio to mix the two tie-point values".
   - ΔT_B = RTM(X_ref, c, θ) − RTM(X_pixel, c, θ)
   - L is not corrected: L_ref goes into both runs.
4. Corrected tie points = cluster means of T_B + ΔT_B. Then the SIC of all cluster pixels (Eq. 16).
5. **New c_ice** = that SIC, truncated to 0–1, values below 0.15 set to 0 (paper step 1). Then repeat from step 3.

## Result (Feb 1973 without 28 Feb, mean of the daily std, iteration 2)
| | Water: std SIC before → after | Ice: std SIC before → after | Days improved (water / ice) |
|---|---|---|---|
| North | 10.5 → **8.2 %** (−23 %) | 14.6 → **13.0 %** | 27/27 / 27/27 |
| South | 14.3 → **11.0 %** (−23 %) | 44.3 → **40.5 %** | 26/27 / 27/27 |

**Convergence**, measured as mean |c_new − c_used| in % SIC:

| Iteration | Water N / S | Ice N / S |
|---|---|---|
| 1 | 1.1 / 2.1 | 6.0 / 16.7 |
| 2 | 0.3 / 0.6 | 0.5 / 1.3 |
| 3 | 0.2 / 0.4 | 0.1 / 0.4 |

- **Iteration 2 is the best.** Iteration 3 changes almost nothing; the std even goes up slightly (0.1–0.2 %). This agrees with the paper: "updates are small after one iteration". Use iteration 2.
- Tie points: T_p,water ≈ 145 K (N) and 141 K (S). It hardly changes after correction.

## Important finding: the Southern ice tie point with siconc > 0.8
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
- Method: describe steps 1–5 as the final algorithm. One sentence on A6 as a simpler variant (fixed c = 0/1) giving similar water results (−17 % with siconc ≥ 0.95).
- Results Task 1: the table and the 4-panel figure (daily std, water and ice, N and S).
- Discussion:
  - The correction reduces the open-water noise by about 23 % (about 2–3 percentage points of SIC).
  - It also reduces the ice-side noise, but less.
  - The Southern ice tie point is the weak point.

## Open / to discuss
- South: is siconc > 0.8 really the best choice, or ≥ 0.95, or add the 5×5 box? Show the numbers above to Tonboe.
- Task 2: RTM sensitivity study (agreed). Task 3: std vs. θ from `A6b_pixels.mat` (θ, sic_u, sic_c per pixel, `cls` 1 = water, 2 = ice).
