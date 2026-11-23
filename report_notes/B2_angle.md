# B2 – Std of the SIC vs. incidence angle (Task 3)

**Report section:** Results → Task 3; Discussion → angle cut-off (Task 4)
**Code:** `src/matlab/b2_angle.m` (~80 s)
**Output:** `output/B2_std_vs_angle.png` (main figure), `output/B2_mean_vs_angle.png` (extra), `output/B2_angle.csv` (per hemisphere, class and scan position: θ, n, mean and std of SIC, uncorrected and corrected; water and ice)
**Figures: open water only, Arctic top / Antarctic bottom**, as paper Fig. 5 ("only ocean points which fulfill the ERA5 SIC and SST criteria"). The research question is about open water. The ice side is not plotted; it is kept in the csv and in one sentence below.
**Status:** done 2026-11-16

## What we did
- **Same method as A6b:** Table 2 clusters, |lat| ≥ 50°, c_ice from ERA5, reference values mixed by c_ice, L not corrected, iteration 2. 1–27 Feb; 28 Feb left out (1 orbit).
- **Whole swath:**
  - Tie points and reference weather come **only from scan positions 5–74**, as in A6b. Task 1 therefore stays unchanged; the check reproduces A6b to 0.0000 %.
  - SIC and correction are then applied to **all 78 positions**.
  - Positions 1–4 and 75–78 (|θ| > 55.7°) are shown dashed on a grey band. They are cut in the analysis.
- **Std per scan position** = std of all pixels of the month at that position. The SIC is computed relative to the daily tie points.
- At |θ| = 61.7° and 63.9° the RTM ice emissivity is extrapolated, because its table ends at 60°. This only matters for the dashed edge.

## Result: std of SIC [%], no RTM → with RTM (pooled pixels)
| |θ| | 0–20° | 20–40° | 40–50° | 50–55.7° | **edge 55.7–64° (cut)** |
|---|---|---|---|---|---|
| Arctic water | 9.9 → 7.8 | 10.2 → 7.9 | 11.3 → 8.5 | 12.6 → 9.3 | 14.8 → 11.1 |
| Antarctic water | 13.2 → 10.5 | 13.9 → 10.7 | 15.1 → 11.2 | 17.2 → 12.5 | 20.8 → 15.0 |

Ice side, from the csv and not plotted: Arctic 14.9 → 13.4 % at 0–20° and 15.7 → 13.5 % at the edge, so almost flat. Antarctic about 41 % at all angles.

## Interpretation
- **Open water: the noise is flat up to about 40° and then rises towards the edge.**
  - Arctic, corrected: 7.8 % at nadir, 9.3 % at 50–56°, 11.1 % at the cut edge (+42 %).
  - Antarctic, corrected: 10.5 → 12.5 → 15.0 %.
  - This matches the sweep (B1d): all water sensitivities grow with θ (longer path 1/cos θ, lower H-pol emissivity → more reflected sky).
- **The correction helps at every angle, and most at large angles:**
  - Near nadir (|θ| < 20°) it removes 21 % (Arctic) and 20 % (Antarctic).
  - At 45–55.7° it removes 24–29 % (Arctic) and 25–30 % (Antarctic).
  - This fits the sweep: the weather terms grow with θ, so there is more to correct at the edge.
  - It still does not remove the rise towards the edge, because the uncorrected L and the remaining noise also grow with θ.
- **Ice (not plotted): hardly any angle dependence** (Arctic 12.7–13.5 % corrected). This matches B1d: over ice only Ti matters, and it does not depend on θ. One sentence in the text is enough.
- **The cut at 55.7° is justified.** The two outermost positions on each side are the noisiest of the whole swath (water up to 12 % Arctic / 16 % Antarctic, even after correction).
- **Possible further cut (Task 4):** between 50° and 55.7° the corrected water noise is already about 20 % above nadir. A cut at about 50° would lower the noise further but cost about 8 % of the swath. This trade-off goes into Task 4.
- **Left and right side are almost symmetric** for water. Single scan positions stand out (e.g. Antarctic −33° and +31°), and this is visible both before and after correction.

## Extra: mean SIC vs. angle (`B2_mean_vs_angle.png`)
- Water: within the inner swath the mean stays within ±3 %, but single scan positions are off by up to −6 % (−32°) and +7 % (+54°), in both hemispheres at the same positions.
  - The correction does not change these offsets.
  - So they are probably fixed per-position calibration offsets of ESMR, not weather. Not tested.
- For the report: optional, as one sentence in the discussion ("angle-dependent offsets are not removed by the weather correction").

## For the report
- Figure: `B2_std_vs_angle.png` (open water; Arctic top, Antarctic bottom; dashed = cut edge).
  - The blue area between the curves is the noise removed by the RTM correction. The reductions per angle band are given in the text, not in the figure.
  - The y axis does not start at 0, so the gap is easier to see. Paper Fig. 5 shows the std in K; we show % SIC, as Task 3 asks for the std of the SIC.
- Caption idea: "Std of the SIC per scan position (1–27 Feb 1973), without and with RTM correction. Grey/dashed: swath edge (|θ| > 55.7°), not used in the analysis. Over open water the noise rises above ≈ 40°; the correction lowers it at all angles but does not remove the rise."

## Update 2026-11-17: rerun with the new tie-point masks (`tp_masks.m`, see A6b note)
std of SIC [%], 1–27 Feb, pooled pixels, no RTM → with RTM:

| | 0–20° | 20–40° | 40–50° | 50–56° | 56–64° (edge) |
|---|---|---|---|---|---|
| N water | 9.1 → 6.8 | 9.3 → 6.9 | 10.4 → 7.4 | 11.6 → 8.2 | 13.9 → 9.9 |
| N ice | 12.1 → 10.4 | 12.3 → 10.6 | 13.2 → 11.5 | 13.7 → 11.9 | 14.7 → 12.5 |
| S water | 11.0 → 8.9 | 11.6 → 9.1 | 12.6 → 9.6 | 14.5 → 10.8 | 17.5 → 13.0 |
| S ice | 24.2 → 23.5 | 24.7 → 23.9 | 24.7 → 23.6 | 24.8 → 23.3 | 25.2 → 23.1 |

Same shape as before: water noise flat to ~40°, then rises; ice almost flat.
Rerun 2026-11-17 with the new preprocessing default (`preproc_config.m`; B2 uses it with `cfg.edge = []`, so all 78 positions are kept): only S ice changed by 0.1 point (0–20° and edge); the check against A6b is still 0.0000 %.

> **Update 2026-11-23:** recomputed with the 23 Nov masks (SST > 273 K, |lat| > 55°, 5 × 5 land box) and the new clipping (no 15 % filter). Numbers above are from 17 Nov; old → new values in `rerun_2026-11-23.md` (full table `output/rerun_compare.csv`).
