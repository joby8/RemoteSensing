# A3b – Preprocessing rebuilt and validated against DMI's prefiltered field

**Report section:** Method → preprocessing (validation, limitation)
**Code:** `src/matlab/preproc_config.m` (all settings, presets, flag code table), `src/matlab/esmr_preprocess.m` (the filters), called by `load_orbit(f, cfg)`; validation `src/matlab/a3b_validate_filters.m` (~5 min, all 312 orbits)
**Outputs:** `output/A3b_confusion.csv`, `A3b_dmi_hypotheses.csv`, `A3b_dmi_analog_channels.csv`, `A3b_dmi_position.csv`, `A3b_neighbour_diffs.csv`/`.png`, `A3b_flag_counts.csv`, `A3b_hard_cases.png`, `A3b_dmi_rule.png`, `A3b_downstream.csv`/`_mean.csv`/`.png`
**Status:** done 2026-11-17; parts (a), (c), (d) re-run the same day with the new default (Eq. 3 `'line'`, ± 1 line, no wrap)

## Goal
Rebuild the filter chain of Kolbe et al. (2024, Sect. 2.2, p. 1249) as one configurable step, check it against DMI's `brightness_temperature_filtered` pixel by pixel, and find out whether the choice matters for the SIC results.

## One preprocessing step
- Paper order: analog filter → Eq. 1 → Eq. 2 → Eq. 3 → Eq. 4 → swath edge; then our masks |lat| ≥ 50° and land.
- `o.flag` = first step that removed the pixel. The code table is stable and stored in `cfg.codes`:
  - 0 kept
  - 5 analog
  - 1–4 Eq. 1–4
  - 6 edge
  - 7 latitude
  - 8 land
- `o.valid = (o.flag == 0)`.
- `o.tb_f` = T_B after the outlier filters only, not masked by edge, latitude or land.
- `o.would.<step>` shows what a disabled step would have removed.
- Presets:
  - `default`: our chain (Eq. 1 and Eq. 2 per pixel, **Eq. 3 `'line'` ± 1 line, no wrap** since 2026-11-17, analog off). Until 2026-11-17 the default had a per-pixel Eq. 3; that version is called `eq3pixel` below.
  - `paper`: literal text (analog on, Eq. 2 removes line i).
  - `dmilike`: our rebuild of DMI's rule (below).
  - `dmi`: the DMI field itself.
- The old default (`eq3pixel`) reproduces the previous `esmr_filters.m` pixel for pixel in all 312 orbits, apart from one bug fix in Eq. 2. After the fix, a jump that closes an offset block can no longer open a new "block". Before, the good lines after a block near the file end were removed against the bad line, e.g. 1 Feb 11:13, lines 808–823. The fix restores 1 226 px in 8 orbits and removes nothing new.
- The tie-point masks are identical whether built from the old `valid` or from `o.valid` (checked for all 312 orbits).

## (a) Pixel-by-pixel comparison with the DMI field (all 312 orbits)
**Source:** `output/A3b_confusion.csv`

"Removed" = NaN after the outlier filters, compared with NaN in the DMI field. "Area" = positions 5–74, |lat| ≥ 50°, ocean (8 282 744 of 37 997 622 px).

| preset | region | kept by both | removed by both | DMI only | ours only | agreement |
| --- | --- | --- | --- | --- | --- | --- |
| default (since 2026-11-17) | all | 35 633 k | 2 129 k | 234 671 | 828 | **99.38 %** |
| default (since 2026-11-17) | area | 8 081 k | 133 493 | 67 914 | 30 | **99.18 %** |
| eq3pixel (old default) | all | 35 633 k | 1 555 k | 808 884 | 828 | 97.87 % |
| eq3pixel (old default) | area | 8 081 k | 20 929 | 180 478 | 30 | 97.82 % |
| paper | all | 35 630 k | 1 638 k | 725 550 | 3 662 | 98.08 % |
| paper | area | 8 081 k | 41 814 | 159 590 | 542 | 98.07 % |
| dmilike | all | 35 633 k | 2 352 k | 12 155 | 1 244 | **99.965 %** |
| dmilike | area | 8 081 k | 195 400 | 6 006 | 318 | **99.924 %** |

- Our default removes almost nothing that DMI keeps (828 px).
- DMI removes 0.23 M px more than our default (0.8 % of the area; the old per-pixel Eq. 3 default: 0.81 M px, 2.2 %). The rest is mostly DMI's analog rule (± 5 lines).

## (b) DMI's extra rule
**Sources:** `A3b_dmi_hypotheses.csv`, `A3b_dmi_analog_channels.csv`, `A3b_dmi_rule.png`

- DMI removes **whole scan lines only**. Only 24 DMI-only pixels lie outside fully removed lines.
- 11 063 of 487 149 lines are removed that are not entirely Eq. 1 failures.
- Blocks are mostly 5 lines (643 blocks), 3 lines (370) and 16 lines (151).
- Line-level recall and precision of each hypothesis against the DMI lines:

| hypothesis | recall | precision |
| --- | --- | --- |
| analog \|A(i+1)−A(i)\| > 10, ch 0–15 (our old diagnostic) | 12.2 % | 38.4 % |
| Eq. 2 row-mean jump > 50 K, ± 1 line | 2.7 % | 81.1 % |
| Eq. 3 after Eq. 1, ± 1 | 15.4 % | 100 % |
| **Eq. 3 on the raw T_B (before Eq. 1), ± 1 line** | 71.6 % | 96.5 % |
| **analog central gradient (numpy.gradient) > 10, ch 0–14, ± 5 lines** | 43.9 % | 94.5 % |
| data gaps ± 2 | 1.8 % | 4.8 % |
| time step ≠ 4 s | 0.5 % | 33.8 % |
| unusual Status_indicator_1 | 55.1 % | 3.6 % |
| last 3 lines of the file | 2.2 % | 26.1 % |
| **both bold rules combined (Eq. 3 with wrap-around)** | **98.6 %** | **96.9 %** |

**Best hypothesis, reproducing 99.965 % of all pixels:** DMI's field = Eq. 1 per pixel, plus whole lines removed by two rules.
1. **Eq. 3 on the raw T_B**:
   - It runs before Eq. 1, so out-of-range values count as spikes.
   - Any pixel with a sum > 150 K flags its line, and the lines ± 1 are removed with it. A large spike fails on three lines (i−1, i, i+1), which gives the 5-line blocks.
   - The test wraps around: the last line is compared with the first, as `numpy.roll` would do. The first lines of a file are often negative, so the last lines get removed.
2. **Analog filter**:
   - The test is the central gradient (as `numpy.gradient`) > 10 in **Analog_0 … Analog_14**.
   - Analog_15 is **not** used. Lines flagged only by Analog_15 are DMI-removed in 53 % of cases, against 98–100 % for every other channel. This looks like a `range(15)` off-by-one.
   - Flagged lines are padded by ± 5 lines.
   - The analog values change every 4 lines (housekeeping records), so a single bad record gives a 16-line block.
- Remaining differences: 12 155 px DMI-only (183 lines, 127 of them the last 3 lines of a file) and 1 244 px ours-only.
- Other variables checked: housekeeping, status words, time, data gaps, orbit position. None explains the removals.
  - DMI line share by tenth of the file: 3.1, 3.0, 2.6, 1.9, 2.0, 2.0, 1.9, 1.7, 1.7, 2.9 %.
  - No orbit loses more than 42 % of its lines.
  - Per day: 0.4–8.0 % of lines (median 1.6 %).
- Variables in the files (ncdump):
  - swath fields: T_B, lat, lon
  - per line: Pitch/Roll_fine_error, RMP_rate, NADIR_LAT/LON, Height, Digital_b, Status_indicator_1/2, Data_source, Beam_position, PGM_id, HOT/COLD_MEAN/RMS, MUX_1–6, Analog_0–15, Time, era_time
  - ERA5 per pixel: u10, v10, t2m, istl1–4, lsm, msl, siconc, sst, skt, sp, tcw, tcwv

## (c) Sanity checks of the result
**Sources:** `A3b_neighbour_diffs.csv`/`.png`, `A3b_flag_counts.csv`, `A3b_hard_cases.png`

- |ΔT_B| between neighbours left in the used area:

| preset | along: max / 99.9 % / 99.99 % | across: max / 99.9 % / 99.99 % | pairs > 100 K (along + across) |
| --- | --- | --- | --- |
| default (since 2026-11-17) | 80.4 / 44.8 / 59.3 K | 87.6 / 50.3 / 64.8 K | 0 |
| eq3pixel (old default) | 135.5 / 45.3 / 60.3 K | 159.2 / 50.3 / 65.3 K | 28 |
| paper | 144.8 / 45.3 / 60.3 K | 159.2 / 50.3 / 65.3 K | 97 |
| dmilike | 86.2 / 44.8 / 59.3 K | 87.6 / 50.3 / 64.8 K | 0 |
| dmi | 80.4 / 44.8 / 59.3 K | 87.6 / 50.3 / 64.8 K | 0 |

- The bulk of the distribution is the same for all presets: the ice edge gives ≈ 45–65 K.
- The new default leaves no neighbour pair > 100 K (max 80 K along, 88 K across, = DMI). The old per-pixel default kept a few isolated 1–2-pixel outliers of 100–160 K. Example: 1973-02-16 21:06, line 874, 60.8° S: a 246 K pixel next to 131 K over open water.
  - Eq. 3 cannot see them: they are two-line spikes, or they sit at the first lines of a file.
- Pixels per step in the used area (`A3b_flag_counts.csv`):

| preset | Eq. 1 | Eq. 2 | Eq. 3 | analog |
| --- | --- | --- | --- | --- |
| default (since 2026-11-17) | 17 522 | 3 197 | 112 804 | 0 |
| eq3pixel (old default) | 17 522 | 3 197 | 240 | 0 |
| paper | 12 918 | 502 | 160 | 28 776 |
| dmilike | 3 198 | 0 | 84 694 | 107 830 |

- The literal paper Eq. 2 removes only line i of each pair. It therefore keeps most of every offset block (`A3b_hard_cases.png`, row 3: shifted pixels survive).
- Hard case 20 Feb 06:05, line 657, positions 37–41 (54.7° S 84.6° E), raw 240.1, 240.1, 241.2, −213.7, −213.7 K:
  - default, paper and dmilike: −213.7 K removed by Eq. 1, the three 240 K pixels by Eq. 3 (default and dmilike: with the whole line ± 1).
  - dmilike and DMI: lines 655–659 and 665–670 removed.

## (d) Downstream: does the filter matter?
**Sources:** `A3b_downstream.csv`, `_mean.csv`, `.png`

- Method: A6b method (`correct_day.m`, iteration 2), days 1, 4, …, 25 Feb.
- Values are the mean of the 9 daily std of SIC [%], uncorrected → corrected.

| preset | water N | water S | ice N | ice S |
| --- | --- | --- | --- | --- |
| **default (since 2026-11-17)** | **9.68 → 7.18** | **11.81 → 9.52** | **12.36 → 10.66** | **25.07 → 24.15** |
| eq3pixel (old default) | 9.82 → 7.38 | 11.92 → 9.59 | 12.37 → 10.67 | 25.09 → 24.17 |
| paper | 9.82 → 7.37 | 11.91 → 9.58 | 12.36 → 10.67 | 25.09 → 24.16 |
| dmilike | 9.68 → 7.18 | 11.79 → 9.49 | 12.35 → 10.65 | 25.07 → 24.15 |
| DMI field | 9.68 → 7.17 | 11.79 → 9.49 | 12.35 → 10.65 | 25.07 → 24.15 |
| eq3pixel + DMI analog rule | 9.81 → 7.37 | 11.87 → 9.53 | 12.36 → 10.66 | 25.10 → 24.15 |
| eq3pixel + DMI line Eq. 3 (with wrap) | 9.69 → 7.18 | 11.81 → 9.52 | 12.36 → 10.66 | 25.07 → 24.15 |

- The filter choice changes the water std by ≤ 0.2 points on average. The relative correction gain (−25 % N, −20 % S) is the same for all presets.
- The difference comes almost entirely from DMI's **± 1-line buffer around raw-T_B spikes**, not from the analog filter. It is concentrated on a few days (N: 10 Feb −1.0, 7 Feb −0.4; S: 22 Feb −0.6 points).
- On 10 Feb the buffer removes 406 water tie-point pixels with T_B 101–154 K (median 117 K; day mean 143.5 K). Lines next to a spike therefore carry degraded, too-cold values that per-pixel Eq. 3 does not catch.
- Ice std: differences ≤ 0.03 points.

## Recommendation
- Keep the per-pixel Eq. 1/Eq. 2 (the literal Eq. 2 keeps offset blocks).
- **Add DMI's line buffer for spikes:** `cfg.eq3.mode = 'line'` (pad 1, wrap off).
  - Cost: ≈ 1 % of the used area.
  - Gain: removes the remaining 100–160 K outliers and the cold lines next to spikes, and matches DMI's water std.
- The analog filter can stay off. It changes nothing downstream (≤ 0.06 points), and its units are unknown.
- Alternatively use `dmilike`, which is equivalent to the field Tonboe recommended but documented and switchable.
- **Decided by Jo on 2026-11-17:** the default in `preproc_config.m` is now Eq. 3 `'line'` (pad 1, no wrap), analog off. All results A4–C1 were re-run with it (`PROGRESS.md`). They agree with the earlier DMI-field runs to ≤ 0.02 points. Questions for Tonboe: `questions_2026-11-17.md`.

## For the report
- One sentence plus a table: "We re-implemented the filters. DMI's field = Eq. 1 + whole-line removal (raw-T_B Eq. 3 ± 1 line, analog gradient ± 5 lines); our rebuild matches 99.97 % of pixels; the choice changes the open-water SIC std by ≤ 0.2 percentage points."
- Figures: `A3b_hard_cases.png` (what each variant removes), `A3b_downstream.png`.

## Open
- Ask Tonboe or DMI to confirm the rule, including the Analog_15 omission and the wrap-around at the file end.
- ~~Scripts with their own edge/latitude/land copies~~: switched to `o.valid` / `preproc_config()` on 2026-11-17 (a3_filter, a4_mask, a5_sic, a6_corrected, b2_angle (with `cfg.edge = []`), globe_plot, video_export, correct_day). Kept on purpose, display only: the land background in b7_correction_map and c1_sp459_compare; the fixed comparison region in a3b_validate_filters.

> **Update 2026-11-23:** recomputed with the 23 Nov masks (SST > 273 K, |lat| > 55°, 5 × 5 land box) and the new clipping (no 15 % filter). Numbers above are from 17 Nov; old → new values in `rerun_2026-11-23.md` (full table `output/rerun_compare.csv`).
