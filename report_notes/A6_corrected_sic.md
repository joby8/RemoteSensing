# A6 – RTM correction and corrected open-water SIC (Task 1)

**Report section:** Method → geophysical noise reduction; Results → Task 1 (before/after)
**Code:** `src/matlab/esmr_rtm_vec.m` (vectorised RTM), `src/matlab/a6_corrected.m` (all of Feb 1973 in ~70 s)
**Output:** `output/A6_sic_corrected.csv` (per day and hemisphere), `output/A6_sic_corrected.png` (pooled histogram + daily std before/after), `output/A6_water_pixels.mat` (per-pixel θ, SIC, ΔT_B and ERA5 inputs of all water tie-point pixels, for Task 2/3)
**Status:** done 2026-11-13

## Goal
Correct the measured T_B for the influence of water vapour, wind, SST and ice temperature with the RTM and ERA5, then compare mean and std of the open-water SIC before and after (Task 1).

## What we did
1. **RTM in MATLAB:** `provided/esmr_rtm.m` is scalar-only and uses Octave syntax (`endif`). Rewritten as `esmr_rtm_vec.m` with the same physics and coefficients, but element-wise. Other changes:
   - |θ| for the ice-emissivity table, because the original returns NaN for negative angles
   - SST clipped to −5…25 °C for the permittivity table only
   
   **Check:** 8 test cases against the provided Python RTM, max. difference 0.0005 K. It comes from the rounding of the deg→rad constant.
2. **Clusters:** per day and hemisphere the A4 tie-point pixels (water: c_ice = 0, ice: c_ice = 1).
3. **Reference values** = cluster means V̄ (tcwv), W̄ (|u10, v10|), L̄ (tcw − tcwv), T̄s (sst), T̄i (Eq. 15).
4. **Eq. 14:** ΔT_B = RTM(V̄, W̄, L̄, T̄s, T̄i, c, θ) − RTM(V, W, **L̄**, Ts, Ti, c, θ). θ is the pixel's own angle in both runs.
   **Eq. 13:** T_B,corr = T_B + ΔT_B.
5. Corrected tie points = mean T_B,corr of the clusters. SIC (Eq. 16) over the water pixels, raw and not clipped.

## Result (Feb 1973, without 28 Feb = 1 orbit)
| | std SIC uncorrected | std SIC corrected | reduction | std T_B (K) before → after | days improved |
|---|---|---|---|---|---|
| North | 10.6 % | **8.7 %** | 17 % | 8.5 → 7.0 | 27 / 27 |
| South | 11.5 % | **9.6 %** | 17 % | 8.4 → 7.0 | 26 / 27 |

- Mean open-water SIC stays 0 (by construction).
- The water tie point moves up by about 0.1–1 K after correction, the ice tie point hardly moves (< 0.1 K).
- The histogram gets narrower; most of the positive tail (wind, water vapour) is gone.
- Only day with a higher std after correction: 1 Feb, South (9.0 → 10.5 %).

## Key decision: L is not corrected
- **Paper (Sect. 4.1):** "TB is not corrected for the cloud liquid water, L, so the mean L is input to both the reference and the actual simulation."
- **Our test confirms it.** Using the pixel L (tcw − tcwv) in the actual run makes the result **worse than no correction**: std SIC 11.5 % (N) and 13.7 % (S).
- **Diagnosis (1 and 5 Feb):** L alone produces 6–9 K of ΔT_B, which is more than the total T_B std of 7–9 K, and it correlates only weakly with the measured T_B.
  - Likely reasons: tcw − tcwv also contains cloud ice and snow, and ERA5 clouds do not match the real 1973 clouds pixel by pixel.
  - V and W alone each lower the T_B std. Ts alone has almost no effect (ΔT_B std ≈ 0.2 K).
- Tonboe's "L = tcw − tcwv" is therefore used for the **mean L** of the cluster, not per pixel.

## For the report
- Method: Eq. 13–14 with our choices (cluster = daily tie-point pixels per hemisphere, L̄ in both runs, θ per pixel).
- Mention the RTM port and its validation against the provided Python version in one sentence.
- Results: table above + `A6_sic_corrected.png`. This answers Task 1: the correction reduces the open-water SIC noise by about 17 % (≈ 2 percentage points).
- Discussion: why not L (with our numbers). Remaining std ≈ 9 % is instrument noise, unmodelled clouds, ice-edge contamination (no 5×5 box) and coastal spill-over.

## Open
- **Task 2 (B1):** exclusion test with the same code. Keep one of V, W, Ts at its mean and see how much the std grows. The diagnosis already suggests V > W ≫ Ts.
- **Task 3 (B2):** std vs. θ from `A6_water_pixels.mat`. It already contains θ, sic_u and sic_c per pixel.
- Paper uses a 15-day running mean of the tie points. We use daily values; mention it.
