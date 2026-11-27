# C3b Low pressure over the whole month (meeting 2026-11-24, point 12)

**Question (Tonboe):** "The single low (12 Feb) is good as it is. Add the whole month and interpret it."

## What we did
- Script `src/matlab/c3b_low_month.m`: `correct_day.m` for each day from 1 to 27 Feb (A6b method, 2 iterations, daily tie points; 28 Feb left out, it has only 1 orbit).
- Pixels used: every open-water pixel of the water tie-point mask (`tp_masks.m`, as in Task 1), with ERA5 msl, W, V and L.
- SIC is raw (not clipped):
  - SIC_u uses the daily uncorrected tie points.
  - SIC_c uses corrected TB and the corrected tie points.
- "Inside a low" means msl < 980 hPa.
- Figure `output/C3b_low_month.png`, Arctic top, Antarctic bottom:
  - left: daily minimum, 5 % quantile and median of msl over open water, plus the share of open water below 980 hPa (bars);
  - middle: daily std of open-water SIC, for all open water and for the part inside lows, uncorrected and corrected;
  - right: all days together, open-water SIC mean ± std in 5 hPa msl bins, with the pixel count.
- Numbers: `output/C3b_low_month_days.csv` (per day), `output/C3b_low_month_bins.csv` (per msl bin). Pixel cache `output/C3b_cache.mat`. Log `logs/c3b_low_month.log`.
- Note: the daily mean of the open-water SIC is 0 by construction (the water tie point is the mean of these same pixels). So per day only the std tells us something. A bias only shows up when the pixels are split by pressure (right column).

## What the month shows
- **The lows are different in the two hemispheres.**
  - Arctic: deep lows over open water are rare. There is one big event, 11–14 Feb (941–957 hPa, 35–39 % of open water below 980 hPa); this is the C3 case. On most other days less than 10 % of open water is below 980 hPa.
  - Antarctic: there are always lows (circumpolar trough). Every day 10–42 % of open water is below 980 hPa, the minimum is 940–967 hPa, and the share grows towards the end of the month (24–27 Feb: 34–42 %).
- **The correction works on every day.** Daily std of open-water SIC, mean over 27 days:
  - Arctic: 9.4 → 6.8 %.
  - Antarctic: 9.8 → 8.0 %.
  - The corrected curve is smoother. For example, the Arctic peak on 11 Feb (13.0 %, the day the low deepens) goes down to 7.3 %.
- **Days with many lows are not worse days.**
  - Arctic: the correlation between the daily std and the share of open water below 980 hPa is r = 0.07 uncorrected and 0.41 corrected. After the correction, low days stay slightly above the rest (12–14 Feb: 6.9–7.8 % vs. month mean 6.8 %).
  - Antarctic: r = 0.23 uncorrected and 0.02 corrected.
- **Inside the lows vs. high pressure** (all days together):

| open water | n | W | V | L | SIC_u mean / std | SIC_c mean / std | std reduction |
|---|---|---|---|---|---|---|---|
| Arctic, msl < 980 | 49 696 | 12.1 | 6.5 | 0.24 | +0.9 / 9.3 | +0.6 / 7.1 | −24 % |
| Arctic, msl ≥ 1000 | 342 240 | 10.3 | 7.6 | 0.17 | −0.5 / 9.4 | −0.7 / 6.6 | −30 % |
| Antarctic, msl < 980 | 622 632 | 9.5 | 9.3 | 0.19 | +0.0 / 8.8 | −0.7 / 7.8 | −11 % |
| Antarctic, msl ≥ 1000 | 383 685 | 8.7 | 11.1 | 0.14 | +1.7 / 10.7 | −0.4 / 8.4 | −21 % |

  - In both hemispheres the correction gains less inside the lows than under high pressure.
  - The lows have more wind and more cloud liquid L. L is not corrected (B1i), so this matches the C3 case (the rest is in the cloud band).
  - Uncorrected, the lows are not noisier than the rest, and in the Antarctic they are even less noisy. This is because the high-pressure Antarctic water has high V (11–16 kg/m²), which the correction removes well.
- **Bias vs. pressure (right column).**
  - Arctic, uncorrected: about +2 to +3 % at 975–985 hPa and down to −8 % at 1035–1040 hPa (calm, dry, cold high).
  - Arctic, corrected: the high end improves to −5 %. The overall shape stays: the correction removes part of the trend, not all of it.
  - Antarctic, uncorrected: bowl-shaped, +3.5 % in the deepest lows (945–950 hPa, L 0.35) and +4.8 % at 1015–1020 hPa (V 16).
  - Antarctic, corrected: flat within ±2.5 %. At the high-pressure end it overshoots slightly (−2.5 %).
  - The std within each msl bin is 6–9 %, much larger than these biases. Pressure explains only a small part of the open-water noise.

## For the report (5.5 Case studies)
- One figure (`C3b_low_month.png`) next to the 12 Feb case.
- Message:
  - The 12 Feb case is typical. The correction lowers the open-water noise inside lows too (Arctic −24 %, Antarctic −11 %), but less than under high pressure (−30 % / −21 %).
  - What remains in the lows fits the uncorrected cloud liquid L (B1i → Task 4).
  - Over the month, lows do not make the SIC worse after the correction: the daily std does not follow the number of lows in a clear way.
- Limits:
  - msl is only a proxy for "storm". The 980 hPa threshold is a choice.
  - ERA5 1973 places fronts with errors.
  - The Arctic has only one big event in February.
