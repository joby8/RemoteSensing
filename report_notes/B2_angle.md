# B2 – Std of the SIC vs. incidence angle (Task 3)

**Report section:** Results → Task 3 (incidence angle); Discussion → outer scan positions (Task 4)
**Code:** `src/matlab/b2_angle.m` (~80 s)
**Output:** `output/B2_std_vs_angle.png` (main figure), `output/B2_mean_vs_angle.png` (extra), `output/B2_angle.csv` (per hemisphere, class and scan position: θ, n, mean and std of SIC, uncorrected and corrected; water and ice)
**Figures: open water only, Arctic top / Antarctic bottom**, as paper Fig. 5 ("only ocean points which fulfill the ERA5 SIC and SST criteria"). The research question is about open water. The ice side is not plotted; it is kept in the csv and in one sentence below.
**Status:** done 2026-11-16; numbers updated 2026-11-27 (state 2026-11-24)

## What we did (state 2026-11-24)
- **Same method as A6b:** current tie-point masks (`tp_opt.m`: water SST > 272 K, |lat| > 55°, 5 × 5 land box),
  c_ice from ERA5, reference values mixed by c_ice, L not corrected, iteration 2. 1–27 Feb; 28 Feb left out (1 orbit).
- **Whole swath everywhere** (Tonboe 2026-11-24): tie points, reference weather, SIC and correction use all 78
  positions. The check against A6b is 0.0000 %.
- Positions 1–4 and 75–78 (|θ| > 55.7°), which Kolbe et al. (2024) cut, are drawn dashed on a grey band
  ("cut by Kolbe et al. 2024, kept here"); csv column `edge` = 1 for them.
- **Std per scan position** = std of all pixels of the month at that position. The SIC is computed relative to the daily tie points.
- At |θ| = 61.7° and 63.9° the RTM ice emissivity is extrapolated, because its table ends at 60°. This only matters for the outer positions.
- (Until 23 Nov the tie points came only from positions 5–74 and the edge was cut in all other steps.)

## Result: std of SIC [%], no RTM → with RTM (pooled pixels, 1–27 Feb)
| |θ| | 0–20° | 20–40° | 40–50° | 50–55.7° | 55.7–64° (cut by Kolbe) |
|---|---|---|---|---|---|
| Arctic water | 8.8 → 6.6 (−25 %) | 8.8 → 6.5 (−26 %) | 9.4 → 6.5 (−31 %) | 10.6 → 7.2 (−32 %) | 12.5 → 8.2 (−34 %) |
| Antarctic water | 7.9 → 6.5 (−18 %) | 8.6 → 7.1 (−17 %) | 9.7 → 7.7 (−21 %) | 11.5 → 9.3 (−19 %) | 14.1 → 11.5 (−18 %) |
| Arctic ice | 11.8 → 10.3 | 12.0 → 10.4 | 12.8 → 11.2 | 13.2 → 11.4 | 13.8 → 11.8 |
| Antarctic ice | 22.5 → 22.3 | 22.8 → 22.6 | 22.8 → 22.5 | 22.9 → 22.2 | 24.1 → 23.0 |

Inner swath (positions 5–74) vs. outer positions, corrected, pixel-weighted: water N 6.34 vs. 7.38 %, S 6.87 vs. 9.28 %;
ice N 10.18 vs. 11.38 %, S 22.04 vs. 18.58 %.

## Interpretation
- **Open water: the noise is flat up to about 40° and then rises towards the edge.**
  - Uncorrected it rises from 8.8 to 12.5 % (Arctic) and from 7.9 to 14.1 % (Antarctic); the outermost position
    reaches 13–14.5 %.
  - This matches the sweep (B1d): all water sensitivities grow with θ (longer path 1/cos θ, lower H-pol emissivity → more reflected sky).
- **The correction helps at every angle, and most at large angles:**
  - Arctic: −25 % near nadir, −32 to −34 % beyond 50°. After correction the Arctic curve is almost flat
    (6.5 % to 40°, 7.2 % at 50–56°, 8.2 % at the outer positions).
  - Antarctic: −17 to −21 % at all angles; the rise towards the edge stays (6.5 → 9.3 → 11.5 %).
  - This fits the sweep: the weather terms grow with θ, so there is more to correct at the edge. What remains
    (uncorrected L, angle effects not in the RTM) also grows with θ.
- **Ice: hardly any angle dependence** (Arctic 10.3–11.8 %, Antarctic 22–23 % corrected). This matches B1d: over
  ice only Ti matters, and it does not depend on θ. One sentence in the text is enough.
- **Keeping the outer positions (Tonboe 2026-11-24) is defensible:** after correction the Arctic outer positions
  (8.2 %) are about as noisy as the uncorrected nadir (8.8 %). In the Antarctic they stay the noisiest part of the
  swath (11.5 %). They add 8 of 78 positions (+11 % pixels) and raise the monthly water σ by 0.2 (N) / 0.7 (S) points
  (`rerun_2026-11-24.md`).
- **Task 4 trade-off:** an angle cut would lower the noise (Antarctic beyond 50°: 9–11.5 % vs. 6.5–7 % inside) but
  costs swath. Our choice: keep all positions, state the higher noise at the edge.
- **Left and right side are almost symmetric** in the std. Single positions stand out (e.g. Antarctic −33° and
  +31°), before and after correction.

## Mean SIC vs. angle (`B2_mean_vs_angle.png`)
- The tie point is now the mean over the whole swath, so the inner swath has a small positive mean
  (N +0.25 %, S +0.48 %) and the outer positions a negative one (N −2.5 %, S −3.7 %).
- Within the inner swath single positions are off by up to −4.9 % (N, −32°) and +5.5 % (N) / +6.2 % (S) at +54°,
  in both hemispheres at the same positions. The correction does not change these offsets → probably fixed
  per-position calibration offsets of ESMR, not weather (not tested).
- **Antarctic: left side falls steadily below −40°**, to −8 % at −55.7° and −16 % at the outermost left position;
  the right side stays near +2…3 % up to +62°. The Arctic left edge reaches −9 %. So the outer left positions are
  biased low (T_B too low), the right ones are not. The RTM correction (symmetric in |θ|) cannot remove this.
- Tonboe (2026-11-24): keep the mean, it should be 0 → this figure shows where it is not.
- For the report: one paragraph in Results (Task 3) plus Discussion ("angle- and side-dependent offsets are not
  removed by the weather correction").

## For the report
- Figure: `B2_std_vs_angle.png` (open water; Arctic top, Antarctic bottom; grey/dashed = positions cut by Kolbe et al., kept here).
  - The blue area between the curves is the noise removed by the RTM correction. The reductions per angle band are given in the text, not in the figure.
  - The y axis does not start at 0, so the gap is easier to see. Paper Fig. 5 shows the std in K; we show % SIC, as Task 3 asks for the std of the SIC.
- Caption idea: "Std of the open-water SIC per scan position (1–27 Feb 1973), without and with RTM correction.
  Grey/dashed: positions 1–4 and 75–78 (|θ| > 55.7°), cut by Kolbe et al. (2024) and kept here. The noise rises
  above ≈ 40°; the correction lowers it at all angles, most at large angles in the Arctic."
- Optional second figure `B2_mean_vs_angle.png` for the side asymmetry.

## History
- 2026-11-16: first version, tie points from positions 5–74, edge cut in the analysis (old masks, Arctic water
  corrected 7.8 % at nadir → 11.1 % at the edge; Antarctic 10.5 → 15.0 %).
- 2026-11-17: new masks (`tp_masks.m`): N water 9.1 → 6.8 % at 0–20°, 13.9 → 9.9 % at the edge; S 11.0 → 8.9 %, 17.5 → 13.0 %.
- 2026-11-23: 23 Nov masks (SST > 273 K): inner σ water corrected N 6.33, S 6.93 %; edge mean N −2.8, S −3.8 %.
- 2026-11-24: all positions used for the tie points (this note).
