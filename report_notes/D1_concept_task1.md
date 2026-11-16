# D1 – Task 1 with Axel's pipeline (bugs fixed)

**Report section:** Results → Task 1 (cross-check of A6b with an independent implementation)
**Code:** `src/matlab/concept/` (copy of branch `axel-concept`, extended by `sicTask1.m`)
**Use:** numbers only, as a cross-check. **No figures:** Task 1 is reported with one set of values, from A6b (`A6b_iterative.png`, `A6b_hist.png`).
**Run:** `matlab -batch "run('src/matlab/concept/main.m')"` (~5 min)
**Output:** `output/concept/D1_task1_sic.csv` (per day, hemisphere, class), `output/concept/D1_task1_pixels.mat` (per pixel: scan position, θ, SIC uncorrected/corrected, for Task 3)
**Status:** done 2026-11-16

## What Axel's pipeline does (differences to A6b)
- **Filter:** own filter (`filterTb.m`: Eq. 1, scan jumps, spikes, stuck values) instead of `brightness_temperature_filtered`. Scan positions 5–74.
- **Tie-point clusters:** as in Table 2 with |lat| ≥ 50°, **plus the 5×5 box** (box mean of siconc ≤ 0.01 for water, ≥ 0.8 for ice).
- **Correction:** one reference per class and day = day mean of V, W, Ts, Ti over the class. c_ice = SIC from the uncorrected tie points of the day (`calculateSIC.m`). L = day mean in both runs (not corrected). **No mixing by c_ice, no iteration** (A6b does both).
- **Task 1 statistics (new, `sicTask1.m`):**
  - Tie points per day and hemisphere = pooled mean Tb of the water and ice clusters, once from uncorrected and once from corrected Tb.
  - SIC of every cluster pixel with Eq. 16.
  - Mean and std on the **raw** SIC.

## Result (1–27 Feb 1973, mean of the daily values)
| | Axel's pipeline: std SIC no RTM → with RTM | reduction | days improved | A6b for comparison |
|---|---|---|---|---|
| N water | 9.7 → **7.4 %** | −24 % | 27/27 | 10.5 → 8.1 % |
| S water | 13.2 → **11.2 %** | −15 % | 26/27 | 14.2 → 11.0 % |
| N ice | 14.2 → 13.4 % | −6 % | 23/27 | 14.6 → 13.0 % |
| S ice | 41.5 → 41.8 % | ±0 | 10/27 | 44.3 → 40.5 % |

- **Mean open-water SIC = 0** (and ice = 100 %) by construction, because the tie point is the mean of the same pixels. So the std is the result. The histograms show a narrower peak at 0 after correction and a shorter tail towards positive SIC (wind, clouds).
- **Two independent implementations agree:**
  - Water N: −24 % (Axel's pipeline) vs. −23 % (A6b).
  - Water S: −15 % vs. −23 %.
  - Axel's pipeline has a lower Arctic level (7.4 vs. 8.1 %). The likely reason is the 5×5 box, which removes ice-edge pixels.
- **South, late February:** Axel's pipeline's corrected water std rises to 12–14 % after 20 Feb, while A6b stays at about 11–12.5 %. Possible reasons, not tested: no c_ice mixing or iteration in Axel's pipeline, and the weak Southern ice tie point (contrast).
- **Southern ice tie point:** the std is about 41 % in both pipelines and the correction does not help. This confirms that the Southern ice cluster (siconc ≥ 0.8) is the weak point (see A6b).

## Clipped SIC is not a noise measure
`calculateSIC.m` sets SIC > 0.95 to 1 and SIC < 0 to 0. This rule is kept for the SIC product. For Task 1, however, clipping removes the negative half of the open-water noise, so the std drops artificially:

| | raw | clipped |
|---|---|---|
| N water | 9.7 → 7.4 % | 6.1 → 4.6 % |
| S water | 13.2 → 11.2 % | 9.1 → 7.3 % |

Report the raw values (as in A5/A6/A6b).

## For the report
- Use as a robustness check: "A second, independently written pipeline (different filter, 5×5 box, no iteration) gives the same reduction of the open-water noise (−24 % N, −15 % S)."
- At most one sentence in the discussion. The Task 1 figures come from A6b only.
- Task 3 (std vs. θ) also uses A6b (`A6b_pixels.mat`).
