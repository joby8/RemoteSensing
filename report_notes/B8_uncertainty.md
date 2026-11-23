# B8 SIC uncertainty (Kolbe et al. 2024, Sect. 4.2, Eq. 17–19)

**Why:** meeting 2026-11-20, points 5 (uncertainty as in the paper) and 6 (resample on a grid).

## Method
- Script: `src/matlab/b8_uncertainty.m` (about 2 min for 1–27 Feb 1973; 28 Feb left out, 1 orbit only).
- Same pixels and correction as B7: `correct_day.m`, A6b method (2 iterations), all corrected ocean pixels with |lat| ≥ 50°.

1. **Algorithm uncertainty per swath pixel**, Eq. 18 (the paper computes it on swath data):

   δc_alg = √[ ((1 − c)·δTp,water)² + (c·δTp,ice)² ] / (Tp,ice − Tp,water)

   - δTp,water and δTp,ice are 1 std of the day's water and ice tie point, i.e. the T_B std over the cluster pixels.
   - Because SIC = (T_B − Tp,water)/(Tp,ice − Tp,water), the ratio δTp/(Tp,ice − Tp,water) is exactly the SIC std of the cluster. So δc_alg = √[((1 − c)·σ_SIC,water)² + (c·σ_SIC,ice)²].
   - c is the pixel's own SIC, clipped to 0..1.
   - Eq. 17 (extra instrument-noise term δT_B = 3 K) is only in the CSV, for reference. The paper uses Eq. 18 because the instrument noise is already in the tie-point std.
2. **Daily resampling:** we use the same 30 km polar-stereographic grid as C2 and the globe's "Daily grid mean" (sphere Re = 6371 km, 320 × 320 cells). Per day and cell we take the mean of all corrected pixels of all orbits.
   - Cell SIC = mean of the unclipped pixel SIC (as in C2 and the globe), then clipped to 0..1.
   - Cell δc_alg = mean of the pixel δc_alg.
3. **Resampling uncertainty:** max(c) − min(c) in the 3 × 3 window around the cell on the daily grid. Cells without data (land, gaps) are left out of the window; the centre cell must have data.
4. **Total uncertainty**, Eq. 19: δc_total = √(δc_alg² + δc_res²), per cell and day.

- Monthly map: mean of the daily cell values, every day the same weight. Cells with data on fewer than 3 days are left blank.
- Two versions:
  - **uncorrected:** c, tie points and std from the uncorrected T_B;
  - **corrected:** c, tie points and std from the corrected T_B (last iteration).
- Deviations from the paper:
  - **daily** tie points (the paper uses 2-weekly ones);
  - our own 30 km grid (bin mean, no interpolation; the paper uses the OSI SAF style grid);
  - SIC = 0..1 clipping, no open-water filter (meeting 2026-11-20, point 4).
- Outputs:
  - `output/B8_uncertainty_map.png` (Arctic top, Antarctic bottom; columns: corrected SIC, algorithm, resampling, total, total corrected − uncorrected);
  - `output/B8_uncertainty_pixels.csv` (Eq. 17/18 per pixel class and day);
  - `output/B8_uncertainty_cells.csv` (algorithm / resampling / total per cell class and day);
  - `output/B8_uncertainty_mean.csv` (mean over the days);
  - `output/B8_grid.mat`.

## Results (1–27 Feb 1973, mean over the days, % SIC, classes by the corrected daily cell SIC)

| | class | algorithm u → c | resampling u → c | **total u → c** |
|---|---|---|---|---|
| Arctic | open water (c < 0.15) | 8.7 → 6.4 | 8.4 → 7.2 | **14.0 → 11.1** |
| Arctic | ice edge (0.15 ≤ c < 0.8) | 8.5 → 6.7 | 51.2 → 47.0 | **52.2 → 47.7** |
| Arctic | ice (c ≥ 0.8) | 11.7 → 10.2 | 5.4 → 5.4 | **14.2 → 12.9** |
| Antarctic | open water | 9.0 → 7.3 | 6.7 → 5.7 | **12.3 → 10.1** |
| Antarctic | ice edge | 12.3 → 11.5 | 40.2 → 38.5 | **42.7 → 40.9** |
| Antarctic | ice | 21.3 → 21.1 | 18.3 → 17.8 | **31.6 → 31.0** |

- **Algorithm uncertainty over open water = the Task 1 std.** At c = 0, Eq. 18 reduces to the water-cluster SIC std. The RTM correction lowers it by about 2.3 % (Arctic) and 1.7 % (Antarctic).
- **Resampling uncertainty dominates at the ice edge** (40–50 %). In a 3 × 3 window (90 km) across the edge, c jumps from 0 to 1. This matches the paper (Figs. 6b, 7b: highest uncertainty along the ice edge and the coasts). The correction changes it only a little, because the edge itself is real.
- **Over open water** the resampling term is not zero (6–8 %): it is the remaining noise between neighbouring daily cells. The correction lowers it too (Arctic 8.4 → 7.2 %, Antarctic 6.7 → 5.7 %), because noise that clips to c > 0 becomes rarer.
- **Total over open water:** Arctic 14.0 → 11.1 %, Antarctic 12.3 → 10.1 %. This is the uncertainty reduction from the regional noise reduction in the paper's own uncertainty measure.
- **Over Antarctic ice**, the total stays high (about 31 %): the ice tie-point std is about 22 % (small, mixed summer ice cluster), and the pack ice near the coast is patchy.
- Eq. 18 alone is lowest at intermediate c: the two errors are weighted by (1 − c) and c and add in quadrature. At the edge this is outweighed by the resampling term.
- In the difference map (last column), the correction lowers the total almost everywhere over the ocean. Thin red lines appear only along the ice edge, where the corrected edge moved by one cell.
