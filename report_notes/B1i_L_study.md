# B1i: L study, cloud liquid water mean vs. per pixel (Task 2)

Script `src/matlab/b1i_L_study.m` → `output/B1i_L_study.png`, `output/B1i_L_study.csv`.

## Why
Meeting with Tonboe on 2026-11-17: do a study on how L enters the correction. We expect a worse correction with the per-pixel L, because ERA5 cloud liquid (tcw − tcwv) is too uncertain for 1973. The paper (Kolbe et al. 2024, Sect. 4.1) also does not correct for L.

## What
- Same method as A6b: daily tie points per hemisphere, |lat| ≥ 50°, and the masks from `tp_masks.m` (meeting 2026-11-17: water siconc ≤ 0.01, ice 180 K < T_B < 274 K, lsm = 0). Reference values are mixed by c_ice.
- Iteration 1 is the same for both variants: mean L in both RTM runs.
- Iteration 2 starts from the same c_ice in both variants:
  - **mean L** (= A6b method): the mixed mean L in both RTM runs, so L is not corrected.
  - **per-pixel L**: the actual run uses the pixel's own L, the reference keeps the mixed mean L, so L is corrected.
- Days 1–27 Feb 1973 (28 Feb has only 1 orbit and is left out of the statistics). Water and ice tie-point clusters.

## Results (monthly mean of the daily std of SIC, iteration 2)

| | uncorrected | mean L | per-pixel L | days mean L better |
|---|---|---|---|---|
| Arctic water | 9.61 % | **7.05 %** | 9.99 % | 27 / 27 |
| Antarctic water | 11.88 % | **9.34 %** | 13.61 % | 27 / 27 |
| Arctic ice | 12.53 % | 10.86 % | 10.85 % | 10 / 27 |
| Antarctic ice | 24.57 % | 23.70 % | 23.65 % | 9 / 27 |

- The mean SIC is 0 % (water) and 100 % (ice) in every case, because the tie points are the cluster means.
- **Water:** the per-pixel L is worse than no correction at all (N +0.4, S +1.7 percentage points vs. uncorrected). The mean L is better on every day in both hemispheres.
- **Ice:** no difference (≤ 0.05 percentage points). L hardly changes the T_B of ice (B1: < 0.4 K per σ), so L only matters on the water side.
- The mean-L numbers equal the A6b iteration 2 rerun with the new masks and the preprocessing default of 2026-11-17 (7.05 / 9.34 %), a consistency check.

## Figure `output/B1i_L_study.png` (Arctic top, Antarctic bottom)
1. Std of open-water SIC per day: the per-pixel L curve lies above the uncorrected curve on most days, and the mean L curve lies below both.
2. Histogram of all open-water SIC values: mean L gives the narrowest peak. Per-pixel L shifts the peak to about +2…+4 % and adds a long negative tail down to −40 %.
3. Mean SIC per L bin, the key panel:
   - Uncorrected SIC rises with L (≈ −4 % → +9 %): clouds make the water look like ice.
   - Mean L stays flat within ±2 %.
   - Per-pixel L turns this around, to −14 % (N) and −19 % (S) at L ≈ 0.8 kg/m². The over-correction grows with L, and cloud-free pixels get a positive bias (+4…6 %).

## For the report
- Task 2, short subsection: "Should L be corrected?" Use the table above and panel 3 of the figure as the main evidence.
- Message:
  - The RTM is very sensitive to L (B1: largest ΔT_B per σ).
  - But the ERA5 L of 1973 does not match the clouds the radiometer saw, so the per-pixel correction over-corrects cloudy pixels and adds noise.
  - Keeping L at the cluster mean (as in Kolbe et al. 2024) is the right choice.
- Task 4 recommendation: do not correct for L with ERA5 cloud liquid; correct V, W (and Ti for ice) only.

> **Update 2026-11-23:** recomputed with the 23 Nov masks (SST > 273 K, |lat| > 55°, 5 × 5 land box) and the new clipping (no 15 % filter). Numbers above are from 17 Nov; old → new values in `rerun_2026-11-23.md` (full table `output/rerun_compare.csv`).
