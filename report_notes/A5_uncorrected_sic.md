# A5 – Uncorrected SIC over open water (Task 1, first half)

**Report section:** Results → Task 1 (uncorrected); Method → SIC algorithm
**Code:** `src/matlab/a5_sic.m` (all of Feb 1973 in ~55 s)
**Output:** `output/A5_sic_uncorrected.csv` (per day and hemisphere), `output/A5_sic_uncorrected.png` (histogram 1 Feb + daily std)
**Status:** done 2026-11-13

## Goal
Compute SIC with uncorrected T_B and report mean and standard deviation over the open-water pixels. This is the reference that the corrected SIC (A6) must beat.

## What we did
1. **Daily tie points per hemisphere**: all orbits of one day (≈ 9–14 orbits) are pooled.
   - T_p,water = mean T_B of the A4 water mask
   - T_p,ice = mean T_B of the A4 ice mask
2. **SIC (Eq. 16):** c_ice = (T_B − T_p,water) / (T_p,ice − T_p,water)
3. Mean and std of c_ice over the water-mask pixels, **raw** (no clipping to 0–1, no 15 % open-water filter), so that the noise is visible.

## Result (Feb 1973)
| | Std of open-water SIC (mean of daily values) | Range of daily std | T_p,water | T_p,ice |
|---|---|---|---|---|
| North | **10.4 %** | 7.1 – 12.9 % | ≈ 145 K | ≈ 226 K |
| South | **11.6 %** | 9.0 – 14.5 % | ≈ 141 K | ≈ 213 K |

- **Mean = 0 by construction** (the water tie point is the mean of the same pixels). The std is the meaningful number.
- The SIC distribution is **right-skewed**: tail up to +40 %. Probably wind roughening and clouds/water vapour raising T_B over water (not yet checked → A6/B1 will show).
- 28 Feb has only one orbit → unreliable, consider excluding.
- The ice tie point is ~13 K lower in the South (thinner / younger ice? fewer pixels) – separate calibration is justified.

## Decisions and reasons
- **Tie points per day** (Tonboe). The paper additionally smooths with a 15-day running mean; we do not (one month only, and daily values let us see variability).
- **Raw SIC, no clipping**: clipping would cut the negative half of the noise and bias the std.

## For the report
- Method: Eq. 16 + how tie points are built (daily, per hemisphere, criteria from A4).
- Results: table above + histogram + daily-std time series. This is the "before" in the before/after comparison of Task 1.
- Discussion hook: the positive tail is exactly what the correction should remove.

## Open
- Next (A6): fix and vectorise the RTM (`provided/esmr_rtm.m` uses Octave `endif`, is scalar only, NaN for SST outside −5…25 °C), then corrected T_B → corrected tie points → corrected SIC std.
