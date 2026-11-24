# C1 – Reference book NASA SP-459 (Zwally et al. 1983) and comparison idea

**Report section:** Discussion / validation of our Task 1 results (Southern Hemisphere)
**Source:** Zwally, H. J., Comiso, J. C., Parkinson, C. L., Campbell, W. J., Gloersen, P., Carsey, F. D. (1983): *Antarctic Sea Ice, 1973–1976: Satellite Passive-Microwave Observations.* NASA SP-459, Washington DC, 206 pp. NTRS 19840002650.
**File:** `docs/literature/Antarctic Sea Ice 1973-1976 - NASA SP-459 - 1983 - Zwally.pdf` (in git, compressed scan, 222 pages)
**Code:** `src/matlab/c1_sp459_compare.m` (≈ 1 min; daily sums cached in `output/C1_cache/`)
**Input:** `docs/sp459/fig5-2a_feb1973.jpg` (Feb 1973 panel of Fig. 5-2a, cut from the NTRS scan at 300 dpi)
**Output:** `output/C1_sp459_side_by_side.png`, `output/C1_sp459_overlay.png`, `output/C1_sp459_extent.csv`
**Status:** overlay done 2026-11-13 (decision: compare maps / ice edge only, no extraction of concentration values from the book – not asked for in the task)

## Why this book
- **Rasmus has brought up this book several times** and recommended it for the project → we should clearly use it in the report.
- It is *the* original analysis of exactly our instrument: **Nimbus-5 ESMR, 19.35 GHz**, Antarctic, 1973–1976, and it contains **February 1973**, our month.
- Gives us an independent, historical reference to interpret our SIC maps and numbers against.

## What is in it (useful parts, book page numbers)
| Content | Where | Use for us |
|---|---|---|
| SIC algorithm: C_i = (T_B − T_O) / (e_i·T_eff − T_O), Eq. 3-5 | Sect. 3.5, p. 64–67 | compare with our tie-point method (Eq. 16 in Kolbe et al.) |
| T_O = **135 K** (open water, fixed), e_i = **0.92** (first-year ice), T_i = T_air + 0.25·(T_w − T_air), T_w = 271.16 K, Eq. 3-6 | p. 64–65, Fig. 3-23, 3-24 | compare with our daily tie points (South: water ≈ 141–142 K, ice ≈ 192–213 K) |
| Error analysis, uncertainty of SIC (≈ ±12 % std vs. Landsat; Fig. 3-26, 3-28) | Sect. 3.6, p. 67–71 | put our std per day into context |
| Mean monthly T_B maps, **Feb 1973** | Fig. 3-5a (p. ~34) | compare with our T_B map (globe viewer / A3) |
| **Mean monthly SIC maps, Feb 1973–1976** | Fig. 5-2a/b (Ch. 5, p. ~96) | **main visual comparison** with our Feb 1973 SIC map |
| Black-and-white SIC maps + contour maps, Jan–Jun 1973 | Appendix B, Fig. B-1a (p. ~172) | easier to compare edge / contours |
| Ice area Feb 1973: **2.71 × 10⁶ km²** (all sectors, e_i = 0.92); Jan 1973: 3.86 × 10⁶ km² | Table 3-2, p. 68 | **number to compare** with our area |
| Areal distribution of SIC per sector | Appendix C, Fig. C-1a | histogram comparison |
| Feb = annual minimum; western Weddell Sea keeps the most concentrated ice, eastern Weddell almost ice-free (except 1973) | Ch. 5, p. ~93 | qualitative checks on our map |

(PDF page ≈ book page + 15.)

## Idea for the report: compare our map with theirs
Goal: use SP-459 at the end to **interpret our data**. Not a strict validation (different processing, monthly average), but a plausibility check.

1. **Map comparison (visual):** our mean SIC map South, Feb 1973 (monthly average of the A6b corrected SIC on a polar stereographic grid) side by side with SP-459 Fig. 5-2a (Feb 1973) / Fig. B-1a. Same projection and colour classes if possible (they use 15 / 35 / 50 / 65 / 85 / 100 % classes).
2. **Ice area / extent (number):** our ice area (Σ SIC · cell area, cells with SIC > 15 %) for Feb 1973 vs. **2.71 × 10⁶ km²** from Table 3-2. Also extent (area of cells > 15 %).
3. **Tie points / algorithm:** their fixed T_O = 135 K vs. our daily, RTM-corrected water tie point (~141 K South); their ice T_B from e_i·T_i vs. our ice tie point. Discuss why they differ (atmosphere correction, summer melt, multiyear ice in Bellingshausen-Amundsen Seas, Table 3-1).
4. **Uncertainty:** their ~12 % SIC error vs. our std before/after the RTM correction (A5 → A6b) → shows what the ERA5 correction adds compared to the 1983 method.

Possible script: `src/matlab/c1_sp459_compare.m` (monthly grid South, area, figure next to a cropped page of the book).

## What we did (c1_sp459_compare.m)
1. **Our map:** every day `correct_day.m` (A6b, 2 iterations); SIC per pixel with that day's corrected South tie points (month mean: water 140.9 K, ice 210.9 K; old masks 201.0 K). Pixels binned on a **30 km polar stereographic grid** (as SP-459). Monthly mean = mean of the daily cell means of the unclipped pixel SIC (every day the same weight, since 2026-11-20), then clipped to 0–100 %. Land = ERA5 (sst NaN).
2. **Georeferencing the scan:** the map is polar stereographic, 0° up (checked: circle radii follow tan((90°−|φ|)/2); equal-area fits worse). Affine fit (the scan is ~1.6 % stretched vertically) to 129 points on the 55–70°S circles + 87 points on the 45° meridians → **rms 1.6 px ≈ 9 km** (< 1/3 grid cell).
3. **Ice / no ice from the scan:** every image pixel → nearest of the 23 legend colours, land (black) or graticule line. Grid cell = majority of the non-line pixels in a 7×7 window. Ice = any class ≥ 16 %. Isolated ice cells (< 3 ice neighbours) removed (light speckles in the printed water fall into the "≥ 98 %" class). Note: the "32 %" colour is very close to the "< 14 %" water colour → nearest-class matching, not a simple threshold.
4. **Comparison** on common cells (lat ≤ −52°, SP-459 not land, we have ocean data): our ice = mean SIC ≥ 15 %.

## Results (Feb 1973, South)
| | SP-459 (digitised) | this work |
|---|---|---|
| Ice extent, common cells | **5.72 × 10⁶ km²** | **5.35 × 10⁶ km²** (−6 %; 5.51 in the first run) |
| Ice area (Σ SIC·A, cells ≥ 15 %) | **2.71 × 10⁶ km²** (Table 3-2) | **3.48 × 10⁶ km²** (+28 %; old masks 3.86, +42 %) |
| Open-water tie point | 135 K fixed | 140.9 K (daily, corrected) |
| 100 % ice | e_i·T_i ≈ 0.92 · ~265 K ≈ 240–245 K | 210.9 K (ERA5 siconc > 0.8, T_B > 180 K cluster; old 201.0 K) |

- **Ice edge agrees well:** 96.0 % (old masks 95.7 %) of the common area is classified the same (both ice: 4.72, only ours: 0.63, only SP-459: 1.00 × 10⁶ km²; re-read from `C1_sp459_extent.csv` 2026-11-17).
- **0.83 of the ≈ 1.0 × 10⁶ km² "only SP-459" lie directly at the coast** → different land masks (ice shelves, coarse 1983 mask vs. ERA5) and ±1 cell position error, not a real difference.
- "Only ours" is a thin ring along the outer edge: our edge is ~1 cell further out (15 % vs. 16 % class, footprint smoothing of the monthly mean).
- Per sector (extent, SP-459 / ours, 10⁶ km²): Weddell 1.63 / 1.67, Indian 0.84 / 0.56, Pacific 0.82 / 0.73, Ross 1.10 / 1.15, Bellingshausen-Amundsen 1.33 / 1.23. Largest difference in the Indian sector (mostly coastal cells).
- **Concentrations: ours are clearly higher** (side-by-side figure: most of the pack ≥ 98 %, SP-459 mostly 50–65 %). Reason: our ice tie point (211 K; 201 K with the old masks) comes from the ERA5 siconc > 0.8 cluster in summer (wet snow / melt, mixed pixels), so it is much lower than SP-459's e_i·T_i (~240 K) → same T_B gives higher SIC. Extent (threshold near the water tie point) is insensitive to this, area is not. → good discussion point on the **ice tie point in summer**, and SP-459 itself says the summer area is uncertain (Table 3-2, p. 67–68).

## For the report
- Cite SP-459 in the introduction (history of ESMR sea ice data) and in the discussion (comparison).
- One figure: our Feb 1973 SIC map vs. SP-459 Fig. 5-2a.
- One sentence / small table: ice area ours vs. 2.71 × 10⁶ km².

## Open
- Optional: same comparison for January 1973 (Fig. 5-1a, area 3.86 × 10⁶ km²) – but our data is February only.
- Ask Rasmus whether he had a specific chapter / figure in mind.

## Update 2026-11-17: rerun with the new tie-point masks (`tp_masks.m`, ice T_B > 180 K, lsm == 0)
Numbers above (201.0 K, 3.86 × 10⁶ km², 95.7 %) are the **old** run; new:
- South ice tie point (month mean): **210.9 K** (was 201.0 K); water 140.9 K (unchanged).
- Ice area (cells ≥ 15 %): **3.48 × 10⁶ km²** (was 3.86) vs SP-459 2.71 × 10⁶ km² → **+28 %** (was +42 %).
- Ice-edge agreement: **96.0 %** of the common area (was 95.7 %).
- The higher ice tie point moves our concentrations towards SP-459; the remaining gap still fits the summer ice tie point (210.9 K vs SP-459 e_i·T_i ≈ 240 K).

## Rerun 2026-11-17 with the new preprocessing default (`preproc_config.m`, Eq. 3 line buffer; cache `output/C1_cache/` rebuilt)
- No change at the printed precision: ice tie point 210.9 K, water 140.9 K, ice area 3.48 × 10⁶ km², agreement 96.0 %, extent (common cells) 5.35 × 10⁶ km².

## Rerun 2026-11-17 with the 5×5 box in the tie-point masks (cache rebuilt)
- South ice tie point (month mean): **212.1 K** (was 210.9 K); water 140.9 K (unchanged).
- Ice area (cells ≥ 15 %): **3.43 × 10⁶ km²** (was 3.48) vs SP-459 2.71 × 10⁶ km² → +27 %.
- Ice-edge agreement: **96.0 %** of the common area (unchanged).

## Rerun 2026-11-18: common cells now lat ≤ −50° (was −52°), same limit as the preprocessing and the Arctic (C2)
- The 52° limit had no reason; the 50°S circle is the outermost printed parallel of SP-459 (checked in `output/C2_classified_scans.png`).
- Extent, common cells: SP-459 **5.90**, ours **5.39 × 10⁶ km²** (both 4.74, only ours 0.66, only SP-459 1.16). Agreement **96.0 %** (unchanged).
- Per sector (SP-459 / ours): Weddell 1.66 / 1.68, Indian 0.86 / 0.56, Pacific 0.84 / 0.73, Ross 1.12 / 1.15, Bellingshausen-Amundsen 1.41 / 1.28.
- Ice area (all cells ≥ 15 %, lat ≤ −50°): 3.43 × 10⁶ km² (unchanged).
- C2 reads the same map with the coast fix (dark-grey 76 % class = coastline) and gives a book extent of 5.23 → use the C2 numbers in the report.

## Rerun 2026-11-20: every day has the same weight
- Per cell first the daily mean SIC, then the mean over the days (before: all pixels of the month pooled, so days with more overpasses counted more).
- Extent, common cells: ours **5.40 × 10⁶ km²** (was 5.39); both 4.74, only ours 0.66, only SP-459 1.16. Agreement **96.0 %** (unchanged).
- Ice area (all cells ≥ 15 %, lat ≤ −50°): **3.45 × 10⁶ km²** (was 3.43). Per sector the extent changes by ≤ 0.02 × 10⁶ km².

> **Update 2026-11-23:** recomputed with the 23 Nov masks (SST > 273 K, |lat| > 55°, 5 × 5 land box) and the new clipping (no 15 % filter). Numbers above are from 17 Nov; old → new values in `rerun_2026-11-23.md` (full table `output/rerun_compare.csv`).

## Fix 2026-11-24: no-data cells counted as open water
- Bug: `min(max(SIC, 0), 1)` turned NaN (cells with < 3 pixels in the month, mostly at the coast) into 0 % SIC, so these cells were
  "our open water" in the common cells. NaN is now kept ('includenan'); such cells are no longer common. Same fix in C2.
- Most of the old "only SP-459" area was this, not land-mask differences (the 0.83 "at the coast" above).
- Extent, common cells: SP-459 **5.90 → 5.00**, ours 5.35 (unchanged); both 4.73, only ours 0.62, only SP-459 **1.17 → 0.27 × 10⁶ km²**.
  Agreement **97.3 → 98.0 %**; common area 44.41 × 10⁶ km².
- Per sector (SP-459 / ours): Weddell 1.54 / 1.66, Indian 0.69 / 0.55, Pacific 0.70 / 0.72, Ross 0.99 / 1.15, Bellingshausen-Amundsen 1.07 / 1.27.
  The large Indian and Bellingshausen-Amundsen gaps were mostly the bug.
- Ice area (all cells, lat ≤ −50°) unchanged: 3.43 × 10⁶ km².
