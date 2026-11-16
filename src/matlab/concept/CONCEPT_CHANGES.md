# Concept branch `axel-concept`: fixes to the first RTM version

Based on `Axel` (commit 9e76b44). Same structure (main.m → filterTb → getTiePoints → applyRTM),
only the bugs found in the review are fixed. Run `main.m`, then `plotConceptComparison.m`.

## Fixes

| # | File | Problem | Fix |
|---|------|---------|-----|
| 1 | applyRTM.m | Cloud water `L = tcwv - tcw` is always ≤ 0 (down to −34 mm) → negative absorption, τ > 1 | `L = tcw - tcwv` (≥ 0). L stays **not corrected**: day-mean L in both runs (paper Sect. 4.1, report_notes/A6) |
| 2 | applyRTM.m | `Vsingle`… never reset → rows of the previous day enter the day mean when a day has fewer files | Arrays preallocated with NaN every day |
| 3 | init.m, main.m | Hard-coded `day_indices` disagree with the file names from day 6 on; day 28 skipped | Day read from the file name (`1973mMMDD`), all 28 days |
| 4 | applyRTM.m | One missing class (e.g. no Arctic-ocean pixels, 5 of the first 40 files) set **all four** classes of the file to NaN | Decided per class |
| 5 | applyRTM.m | `isnan(mask)` on a logical mask is always false → masks did nothing; AntIce used the ArcIce mask | `~mask`, one loop over the four classes |
| 6 | esmr_rtm.m | `if` on matrices (V > 48, c_ice clamp, σ² ≤ 0.07) only fires if *all* pixels match; wind up to 27 m/s was not capped | Element-wise clamps (NaN stays NaN) |
| 7 | filterTb.m | Scan filter: `sum` without `omitnan` → every scan with one NaN pixel skipped (465 of 1691 scans in file 1) | `sum(...,'omitnan')` over valid pairs, guard n = 0 |
| 8 | filterTb.m | Stuck-value filter removed only the first of 7 identical scans | Whole run `i:i+6` removed |
| 9 | PlotOnGlobe.m, mainSingleFile.m | Tie points undefined inside the function → crash | `PlotOnGlobe(Data, DayStats)` uses `calculateSIC` |
| 10 | main.m, mainSingleFile.m | Windows-only paths `..\` | `fullfile` |
| 11 | main.m, poolStats.m | Day std = mean of per-file stds (no between-orbit spread, unweighted) | All pixels of a day pooled (`poolStats.m`), pixel count `_n` stored |
| 12 | filterTb.m and all `5:end-5` | Rim cut 4 left / 5 right | Symmetric `5:end-4` |

Kept on purpose: `sic > 0.95 → 1` in calculateSIC.m.
Removed: `calcSIC.m` (old copy of calculateSIC, undefined `File1`), `readAllFiles.m` (empty).

## Output
`results_concept/Uncorrected.mat`, `results_concept/Corrected.mat`,
`results_concept/compare_tiepoint_mean.png`, `results_concept/compare_tiepoint_std.png`
(Axel original code vs. fixed code, each without and with RTM correction, per class and day).
