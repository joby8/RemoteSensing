# A3 – Filters

**Report section:** Method → preprocessing **Code:** `src/matlab/esmr_preprocess.m` (settings `preproc_config.m`, called by `load_orbit.m`); `src/matlab/a3_filter.m` prints the counts per step for one orbit. Since 2026-11-17 every script uses `o.valid` / `o.flag` from this one step (no own copies of the edge/latitude/land cuts any more). **Figures:** `output/A3_tb_filtered.png`, `output/globe_A3_tb_N.png` / `_S.png`; interactive: `output/globe/ESMR_globe.html` (slider "Preprocessing") **Status:** done 2026-11-13; preprocessing rebuilt 2026-11-17 (default decided by Jo, see below)

## Goal

Remove pixels that are physically implausible or not useful before computing tie points and SIC.

## Current default (Jo, 2026-11-17), in this order
Source = raw `Brightness_temperature` (DMI's `brightness_temperature_filtered` is no longer used).
1. **Analog filter: off.** Units unknown; it changes nothing downstream (A3b).
2. **Eq. 1: 90 K < T_B ≤ 273.15 K**, per pixel.
3. **Eq. 2, per pixel:** only the shifted pixels of short offset blocks (our version, see the update below).
4. **Eq. 3 in 'line' mode with a ± 1-line buffer, no wrap-around.** It is tested on the raw T_B. A spike removes its line and the line on each side, because the neighbouring lines are degraded (A3b (d)).
5. **Eq. 4:** 7 identical values along track.
6. **Swath edges: off since 2026-11-24** (`cfg.edge = []`, Tonboe: the outer 4 positions go into everything). All 78 positions are kept, **θ = ±63.86°**. Kolbe et al. (2024) drop positions 1–4 and 75–78 (θ = ±55.67°); preset `preproc_config('paper')` still does.
7. **High latitudes only: |lat| ≥ 50°**, both hemispheres.
8. **Land:** ERA5 SST missing.

`o.flag` = first step that removed the pixel (0 kept, 5 analog, 1–4 Eq. 1–4, 6 edge, 7 latitude, 8 land); `o.valid = o.flag == 0`.

## Result (orbit 1973-02-01 02:23, `a3_filter.m`, default of 2026-11-24)

| Step (flag code) | removed | Pixels left | Share |
| --- | --- | --- | --- |
| all | | 131 898 | 100 % |
| analog filter (5, off) | 0 | 131 898 | 100 % |
| Eq. 1 (1) | 10 460 | 121 438 | 92.1 % |
| Eq. 2 (2) | 13 | 121 425 | 92.1 % |
| Eq. 3 + line buffer (3) | 372 | 121 053 | 91.8 % |
| Eq. 4 (4) | 0 | 121 053 | 91.8 % |
| swath edge (6, off) | 0 | 121 053 | 91.8 % |
| |lat| < 50° (7) | 62 610 | 58 443 | 44.3 % |
| land (8) | 23 447 | 34 996 | 26.5 % |

(Default of 2026-11-17 with the edge cut: −12 222 at the edge, 52 705 after the latitude cut, 31 358 = 23.8 % at the end. Keeping the edges gives +12 % pixels.)

(Before 2026-11-17, with the DMI field: 121 066 after "Eq. 1", 108 844 after the edge cut, 52 705 after the latitude cut; land was not counted as a separate step.)

## Decisions and reasons

- ~~**Filtered field instead of own Eq. 1–4**~~ (until 2026-11-17): replaced by our own Eq. 1–4 on the raw T_B, which reproduce DMI's field when its line rules are added (A3b). A newer paper (Tellefsen et al. 2026) uses a less aggressive filter → mention as limitation/outlook.
- **Swath edges:** the paper removes positions 1–4 and 75–78 (long atmospheric path, footprint distortion). We keep them (Tonboe, meeting 2026-11-24): B2 shows the noise there is higher but still corrected, and Task 3 needs the full angle range. Deviation from Kolbe et al. (2024), state it in the report.
- **|lat| ≥ 50°:** Tonboe: low latitudes are not of interest for sea ice and dropping them reduces the data volume. Note: Table 2 of the paper uses 32° N / −48° S; ours is stricter.

## For the report

- One table of the filter chain with the remaining fraction (above).
- Globe figure (interactive page, step slider) shows clearly what each step removes → good for the seminar.

## Open

- Eq. 2–4 of the paper (further quality filters) not implemented; only if Tonboe asks for them.
- **Correction: `brightness_temperature_filtered` is not Eq. 1 alone.** It also removes **whole scan lines** around single-pixel spikes (orbit 1973-02-01 04:21):
  - 3 712 px are outside 90–273.15 K, but 20 980 px *inside* that range are removed as well.
  - 276 of 1 483 rows are fully removed (50 blocks); 177 of these rows contain no out-of-range pixel. Rows with a bad pixel outside these blocks (281) keep their other pixels.
  - 48 of 50 blocks sit around an along-track spike (Eq. 3, > 150 K): mostly spike row ± 1 (3 rows), 5–7 rows for repeated spikes, 16–18 rows in 8 cases (likely a whole data record). 2 blocks of 16 rows have no spike at all.
  - Example: row 386 has 2 pixels at −77 K (rest ≈ 140 K) → rows 373–388 removed.
  - Paper Eq. 2 (row mean |ΔT_B| > 50 K) flags no row on the raw data, so this is DMI's implementation, not the equation as written.
  - The viewer step "Eq. 1" and the text above are therefore mislabelled (fix after asking Tonboe).
- **Question for Tonboe:** is removing whole rows intended, or should we filter per pixel (Eq. 1 + Eq. 3) and keep ≈ 18 % more data? Our notes from 2026-11-10 only say "use the filtered field". Compare with the less aggressive filter in Tellefsen et al. 2026.
## Update 2026-11-17: outlier filters Eq. 1–4 per pixel

**Code:** `src/matlab/esmr_preprocess.m` (was `esmr_filters.m`; settings in `preproc_config.m`, validation in `A3b_filter_validation.md`), called by `load_orbit.m` → `o.tb_f` (final T_B), `o.flag` (0 kept, 1–4 = first equation that removed the pixel), `o.analog` (diagnostic, see below). Replaces the step "Eq. 1 (file field)" above; the DMI field is no longer used.

### Paper (Kolbe et al. 2024, Sect. 2.2, p. 1249), order: analog filter → Eq. 1 → 2 → 3 → 4 → cut 4 edge positions
- Analog filter: "computes the absolute gradient in the analog signals, and anything over a value of 10 is removed."
- Eq. 1: 90 K < T_B ≤ 273.15 K.
- Eq. 2: "removes erroneous scan lines (across track rows). Consecutive scan lines should not differ by more than 50 K": Σ_j |T_B(j,i+1) − T_B(j,i)| / n ≤ 50 K, i along track, j across track, n = number of (valid) positions in the row. → a **whole-line** test on the **row mean**, not "neighbouring pixels must not differ by more than 50 K".
- Eq. 3: |p_i − p_{i−1}| + |p_{i+1} − p_i| ≤ 150 K, p single pixel, i **along-track** index → single-pixel spikes.
- Eq. 4: the sum of the 6 |differences| of 7 consecutive along-track values must not be 0 (values "locked to the same value").
- "If only a single data point or a couple of scan lines are affected, only those data points and scan lines are removed."

### What we implemented (all 78 positions, before the edge cut)
- Eq. 1, 3, 4 as written. Differences are taken after the previous filters: a NaN neighbour (Eq. 1 failed, or removed by Eq. 2) is never used, so an invalid neighbour cannot remove a good pixel. Eq. 3 needs both along-track neighbours; otherwise the pixel is not tested. Eq. 4 removes all 7 locked values.
- No differences across **data gaps** (centre-to-centre distance between consecutive lines > 2.5 × median; 827 gaps in Feb 1973): lines on both sides of a gap are not neighbours on the ground.
- **Eq. 2 (deviation from the literal text):** the jump test is the paper's row-mean test (> 50 K over the n valid pairs). In the data, failing pairs come in pairs: an offset block of 7–8 (up to 14) lines shifted by ≈ ±100 K, with one jump in and one jump out. The literal rule removes line i of each failing pair, i.e. the good line before the block and the last line of the block, and **keeps the rest of the block**. We therefore:
  1. treat a short run (≤ 20 lines) between a jump and the opposite jump back, or between a jump and a boundary (file start/end, gap, row without valid pairs), as erroneous lines;
  2. remove in those lines **only pixels that differ by > 50 K** from the good lines around the run (same scan position, linear interpolation between the line before and after; pixels without a valid reference are kept);
  3. a jump that brackets no such run (8 cases) is handled as in the paper (line i), but again only its pixels with |ΔT_B| > 50 K.
- **Analog filter not applied** (stored as `o.analog`, both lines of a pair with gradient > 10 in any of `Analog_0..15`): it has one value per scan line, so it can only remove whole lines (3 505 lines = 0.7 %), and only 10 % of the flagged lines contain any gross T_B error (vs. 0.3 % of the other lines). The units of the 16 entries are unknown (paper: user's guide does not explain them); several channels jump by exactly 256/512 (bit flips). Conflicts with the per-pixel rule → open question for Tonboe.

### Counts, all 312 orbits (37 997 622 pixels, 487 149 lines)
| removed by (first) | all pixels | used area (pos 5–74, \|lat\| ≥ 50°, 14 503 941 px) |
| --- | --- | --- |
| Eq. 1 | 1 542 646 (4.06 %) | 28 730 |
| Eq. 2 (73 runs + 8 single jumps) | 13 402 (0.035 %) | 5 501 |
| Eq. 3 | 995 | 395 |
| Eq. 4 | 0 | 0 |
| DMI field (for comparison) | 2 363 873 (6.22 %) | 349 011 |

These counts are for the per-pixel Eq. 3 (default until 2026-11-17). **With the new default (Eq. 3 `'line'` ± 1 line, no wrap; `A3b_flag_counts.csv`):**
- Eq. 3 removes 575 208 pixels in all orbits (1.5 %), instead of 995.
- In the used area (positions 5–74, |lat| ≥ 50°, ocean, 8 282 744 px), the removals are:
  - Eq. 1: 17 522 px
  - Eq. 2: 3 197 px
  - Eq. 3: 112 804 px
  - Eq. 4: 0 px
- 8 149 221 px are kept (98.4 %).
- Pixel agreement with the DMI field rises from 97.87 % to 99.38 % (all pixels).

- Full scan lines removed: Eq. 1 alone 804; Eq. 1–4 1 009 (205 more, = offset blocks where every pixel is shifted); DMI field 11 867.
- Literal paper Eq. 2 (whole line i) would remove 93 lines; literal Eq. 1–4 chain leaves 897 full lines removed. **The DMI field is not Eq. 1–4 + analog filter:** only 1 444 of its 11 867 lines are analog-flagged, 9 716 are neither all-Eq.-1 nor analog lines, and the literal chain differs from it in 816 001 pixels. DMI evidently adds buffer lines (≈ ± 1–2 lines around spikes, whole blocks).
- Run lengths of Eq. 2 blocks: mostly 1–8 lines (7 is the most common), max 20.

### Example: 20 Feb 1973, orbit 06:05 UTC
- The "240 K next to −213 K" pixels are line 657, positions 37–41, at **54.7° S, 84.6° E** (not 60.8° S 99.6° E): 240.1, 240.1, 241.2 K next to −213.7, −213.7 K (across-track neighbours). Before: the 240 K pixels passed Eq. 1 and were kept. Now: −213.7 K → Eq. 1, the three 240 K pixels → **Eq. 3** (along-track neighbours ≈ 129–137 K, sum ≈ 210 K > 150 K). Within 3° of that spot T_B is now 124–143 K (raw −214…241 K).
- Near 60.8° S 99.6° E (lines 614–615): 341–365 K and −181…−23 K pixels → Eq. 1; the neighbours (≈ 125 K) are kept. Within 6° of that spot: 120–225 K left.
- Largest neighbour difference left in this orbit (used area): 73 K across track, 65 K along track (natural ice edge level).

### Open
- Ask Tonboe: is the per-pixel Eq. 2 acceptable, is the Eq. 3 line buffer OK, and should the analog filter (whole lines) be applied? → `questions_2026-11-17.md`
- Per-pixel Eq. 3 cannot catch 2-line spikes (two consecutive bad values give a small sum; the line buffer of the new default removes them); Eq. 4 never fires in Feb 1973 (stuck runs are shorter than 7, e.g. 3 identical lines on 4 Feb 05:37).
- ~~A4–A6, B* scripts still hold old numbers~~: all re-run on 2026-11-17 with the new default (A4–C1, `PROGRESS.md`). The results agree with the earlier DMI-field runs to ≤ 0.02 points of SIC std.
