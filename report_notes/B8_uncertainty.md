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

## Results (1–27 Feb 1973, mean over the days, % SIC, classes by the corrected daily cell SIC; state 2026-11-24: 272 K, all 78 scan positions)

| | class | algorithm u → c | resampling u → c | **total u → c** |
|---|---|---|---|---|
| Arctic | open water (c < 0.15) | 9.1 → 6.6 | 8.7 → 7.3 | **14.4 → 11.3** |
| Arctic | ice edge (0.15 ≤ c < 0.8) | 8.7 → 6.8 | 50.5 → 46.2 | **51.5 → 46.9** |
| Arctic | ice (c ≥ 0.8) | 11.9 → 10.3 | 5.3 → 5.4 | **14.4 → 13.0** |
| Antarctic | open water | 9.5 → 7.9 | 7.3 → 5.8 | **13.1 → 10.7** |
| Antarctic | ice edge | 12.5 → 11.7 | 39.4 → 37.7 | **42.0 → 40.1** |
| Antarctic | ice | 21.2 → 21.0 | 17.9 → 17.3 | **31.1 → 30.5** |
| Arctic | all cells | 10.5 → 8.5 | 10.3 → 9.4 | **17.4 → 15.0** |
| Antarctic | all cells | 10.2 → 8.7 | 10.2 → 8.8 | **16.1 → 13.8** |

(23 Nov, 273 K and positions 5–74: open water total 14.0 → 11.1 % N, 12.3 → 10.1 % S; all values now 0.2–0.8 points
higher because the outer scan positions are noisier, see B2.)

- **Algorithm uncertainty over open water = the Task 1 std.** At c = 0, Eq. 18 reduces to the water-cluster SIC std. The RTM correction lowers it by about 2.5 % (Arctic) and 1.6 % (Antarctic).
- **Resampling uncertainty dominates at the ice edge** (40–50 %). In a 3 × 3 window (90 km) across the edge, c jumps from 0 to 1. This matches the paper (Figs. 6b, 7b: highest uncertainty along the ice edge and the coasts). The correction changes it only a little, because the edge itself is real.
- **Over open water** the resampling term is not zero (6–8 %): it is the remaining noise between neighbouring daily cells. The correction lowers it too (Arctic 8.7 → 7.3 %, Antarctic 7.3 → 5.8 %), because noise that clips to c > 0 becomes rarer.
- **Total over open water:** Arctic 14.4 → 11.3 %, Antarctic 13.1 → 10.7 %. This is the uncertainty reduction from the regional noise reduction in the paper's own uncertainty measure.
- **Over Antarctic ice**, the total stays high (about 31 %): the ice tie-point std is about 22.5 % (small, mixed summer ice cluster), and the pack ice near the coast is patchy.
- Eq. 18 alone is lowest at intermediate c: the two errors are weighted by (1 − c) and c and add in quadrature. At the edge this is outweighed by the resampling term.
- In the difference map (last column), the correction lowers the total almost everywhere over the ocean. Thin red lines appear only along the ice edge, where the corrected edge moved by one cell.

## Multiyear ice (meeting 2026-11-24, point 6) – check before writing
- Tonboe: uncertainty is higher over multiyear ice (MYI), explain why. **What our map actually shows (checked 2026-11-27):**
  - The Arctic **algorithm** map is almost uniform over the pack ice (≈ 10 %). That has to be so: Eq. 18 depends
    only on the pixel's c and the day's cluster std, so at c ≈ 1 every ice pixel gets ≈ σ_SIC,ice, MYI or not.
  - The **resampling** term over the central Arctic is low (homogeneous pack).
  - What does stand out is the **corrected SIC**: ≈ 85–90 % (orange) over the central Arctic / MYI area, against
    ≈ 100 % over the first-year ice around it. So with our method MYI shows up as a **low bias**, not as a higher δc.
  - In the Antarctic the Weddell Sea pack (where the Antarctic second-year / multiyear ice is) has the highest
    algorithm and total uncertainty (≈ 21–25 %), but that is because c ≈ 1 there and the Antarctic ice-cluster std is 22 %.
- Physics for the text: at 19 GHz H, MYI has a lower and more variable emissivity than first-year ice (volume
  scattering in the desalinated, bubbly upper layer). One ice tie point per day and hemisphere is a mean over both
  types, so MYI pixels sit below it (SIC too low) and widen the ice-cluster spread, which raises σ_SIC,ice and so
  δc_alg for all ice pixels. The RTM correction (only Ti over ice) cannot remove an emissivity difference. Same
  reason as the MYI correction in NASA SP-489 (`C2_SP489_arctic_book.md`: e = 0.84 vs. 0.92).
- To show "higher uncertainty over MYI" directly we would need a per-region uncertainty (e.g. the T_B / SIC std of
  ice pixels in a MYI box vs. a first-year box). Not done yet; small addition to `b8_uncertainty.m` if wanted.
