# Project 1: Regional noise reduction of NIMBUS 5 ESMR SIC

30350 Remote Sensing · supervisor Rasmus Tonboe (rtt@space.dtu.dk) Method: Kolbe et al. 2024, Sect. 4.1 (`docs/Kolbe_etal_essd-16-1247-2024.pdf`, p. 5–8). Newer paper (Tonboe mail 2026-11-06, local dynamical tie points; optional): `docs/Tellefsen_etal_essd-18-2891-2026.pdf`. Tasks: `docs/read_me.txt`. Report notes per step (writing plan): `report_notes/`. Learning page: `docs/learning/Kolbe_etal_essd-16-1247-2024_interaktiv.html`.

**Deadlines:** seminar talk (length tbc) 4 Dec · report due midnight 6 Dec · defence in the oral exam 15 Dec.

**Research question:** How effective is regional noise reduction of NIMBUS 5 ESMR data over open water?

## Folder layout

| Folder | What |
| --- | --- |
| `ESMR_colocated_filtered/` | swath NetCDFs, 312 orbits, 1–28 Feb 1973 (not in git, 5.6 GB) |
| `provided/` | `esmr_rtm.py`/`.m` (RTM), `spos2ia.txt` (scan position → θ), resampling example |
| `docs/` | paper, task read-me, literature (literature not in git) |
| `src/matlab/` | our code, **MATLAB** (`a1_inspect.m`, `load_orbit.m`, `a2_plot.m`); `src/*.py` is the first Python version of A1/A2 |
| `output/` | figures and tables (not in git) |

## Steps

### Phase A: one orbit end to end

- [x] A1 Open one file, list variables and shapes (scan lines × 78). Check what is already filtered ("filtered" in the folder name).

- [x] A2 Prepare: T_B, lat, lon (already in K/°, no ÷10 needed); θ from `spos2ia`; W = √(u10² + v10²); V = `tcwv`; Ts = `sst`; Ti = 0.4·t2m + 0.6·272 (Eq. 15). Plot T_B on lat/lon.

- [x] A3 Filters: Eq. 1–4 of Kolbe et al. 2024 (p. 1249) **per pixel** in `load_orbit.m` → `esmr_preprocess.m` (config `preproc_config.m`; validated against DMI in `report_notes/A3b_filter_validation.md`) (2026-11-17; Eq. 2 adapted to remove only the offset pixels, not whole lines; **Eq. 3 in line mode: a raw-T_B spike removes its line ± 1 line, no wrap** (default decided by Jo 2026-11-17); analog filter off), then drop scan positions 1–4 and 75–78, |lat| &lt; 50° and land (SST missing). One step: `o.flag`/`o.valid`, used by every script. Notes: `report_notes/A3_filters.md`. A4–C1 re-run with it (2026-11-17).

- [x] A4 Open-water mask, Table 2: siconc = 0, sst &gt; 278 K, 90 K &lt; T_B &lt; 180 K, lat &gt; 32° N or &lt; −48° S. **5×5 box criterion (ERA5 box mean &lt; 0.01 water / &gt; 0.8 ice) added 2026-11-17** in `tp_masks.m` (`opt.box`, default on); everything rerun. Meeting: only use |lat| ≥ 50° (skip the low latitudes, less data); SST &gt; 278 K as in Table 2.

- [x] A5 Uncorrected SIC (Eq. 16): Tp,water = mean T_B of the mask, Tp,ice from 95 %→100 % ice pixels (per day, per hemisphere; was 225 K placeholder). Mean and std on **raw** SIC (no clipping, no 15 % filter).

- [x] A6 Correction (Eq. 13–14): means V̄, W̄, T̄s, T̄i over the mask; L = mean in both runs. Corrected SIC with the corrected tie point → mean and std. **Task 1 for one orbit.**

- [x] A6b Iterative correction (session 2026-11-13): Table 2 clusters (ice siconc &gt; 0.8, |lat| ≥ 50°), c_ice from ERA5 → iterate, reference values mixed by c_ice; std per day N/S for water and ice. **Main method for Task 1.**

### Phase B: tasks

- [x] B1 Task 2 (agreed 2026-11-13: **RTM sensitivity study**): `b1_sensitivity.m` → `output/B1_sensitivity.png` = static report version of the learning-page animation (θ on x axis, ΔT_B per +1σ of each input). Exclusion test with the data done 2026-11-16: `b1c_exclusion.m` → `output/B1c_exclusion.png` (V &gt; W ≫ Ts; Ts can be dropped; Ti only for ice).

- [x] B2 Task 3: std of SIC per scan position over the whole swath, uncorrected vs corrected (`b2_angle.m` → `output/B2_std_vs_angle.png`, edge |θ| &gt; 55.7° dashed). Water noise flat to \~40°, then rises (Arctic corrected, with 5×5 box: 6.6 % at 0–20°, 7.8 % at 50–55.7°, 9.3 % at the edge; n-weighted mean of the per-position std); ice flat. Notes: `report_notes/B2_angle.md`

- [x] Tie-point masks updated 2026-11-17 (Tonboe): `tp_masks.m`, water siconc ≤ 0.01, ice T_B &gt; 180 K, lsm == 0. A6b, B1c/d/e/f/g/h, B2 rerun. Water std (iter. 2) N 8.2 → 7.05 %, S 11.0 → 9.3 %; ice S 40.5 → 23.7 %. With the 5×5 box (below): N 7.04 %, S 9.18 %; ice N 10.74, S 23.18 %.

- [x] B1i L study (`b1i_L_study.m` → `output/B1i_L_study.png`): mean L in both iterations best (N 7.04 / S 9.18 %); per-pixel L in iteration 2 worse than uncorrected (10.0 / 13.4 %; with 5×5 box).

- [x] B7 correction map (`b7_correction_map.m` → `output/B7_correction_map.png`): largest over open water near the ice edge / Southern Ocean (V), storm tracks (W), Ti on pack ice.

- [x] Inverse grey confirmed by Jo (2026-11-17): grey = input range not really used (outside 5–95 %), white = observed range (B1d/B1e).

- [x] All figures and the globe rebuilt on the new masks (2026-11-17): A4, globe_plot, B1, B1b, B1c–i, B2, B7, C1 (cache cleared), globe viewer; flowchart numbers updated. Not rebuilt: explainer video (`video_export.m` + `video/build.py`).

- [x] B3 Scale up to all of Feb 1973, both hemispheres (done implicitly: A5/A6b/B1c/B2 run on 1–27 Feb, N and S; 28 Feb excluded, 1 orbit).

- [x] Globe v3 (2026-11-17): panel = pipeline steps 0–7 (data → preprocessing → clusters → raw SIC → ΔT_B → corrected SIC it. 1/2 (Task 1) → exclusion test incl. L per pixel (Task 2) → σ vs θ incl. swath edges (Task 3)); numbers identical to A6b, B1c, B1i, B2 CSVs. `correct_day(..., struct('extra', true))`. Notes: `report_notes/globe_viewer.md` (v3).

- [ ] B4 Task 4: recommendation (angle cut-off, which variables, ice side, clouds).

- [ ] B5 Seminar slides (length tbc) · B6 Report.

## Decisions and open questions

- Our data are Feb 1973 (before the hot-load anomaly Mar–May 1973). Paper Fig. 5 is Jan 1974: compare shape, not exact numbers.
- **Meeting with Tonboe (2026-11-10):**
  - L: use `tcw − tcwv` as cloud liquid proxy.
  - Tie points: compute **every day** (not per orbit or month). Watch out for bad data.
  - Filter: use `brightness_temperature_filtered`. A newer paper on the same data (Tonboe sent it by mail) uses a less aggressive filter: look at it, but too complex to implement ourselves.
  - Hemispheres: use both, but with **separate calibration** (separate tie points). Don't use local tie points.
  - Ice tie point: sea ice 95 % → treat as 100 % (replaces my 225 K placeholder). Surface temperature: as in paper (Eq. 15).
  - Water tie point: water must be cold enough for the cold-water calibration. The number is in the given paper: **Table 2, SST (ERA5) &gt; 278 K** (the only SST threshold in the paper; the "275 K" in my notes is unverified).
  - Speed-up: only use high latitudes (|lat| ≥ 50°, both hemispheres); the equator/low latitudes are not of interest and dropping them means less data.
  - Ti (Eq. 15) is based on a fixed minimum (272 K); we may check whether better values exist.
  - Task 2: **sensitivity study of the RTM**: how much does the output change per input? Ice/emitting-layer temperature is important.
  - Seminar: present the report to the other students; length unknown. Last feedback for the exam is given there. Make good figures (useful for the exam).
  - **Exam (15 Dec):** (1) draw a remote-sensing topic, present it 5 min, short questions; (2) topic 2: 7 min of questions; (3) present the report 5 min. Report = 1/3 of the grade, but only the **defence** is graded, not the report text.
- **Feedback session (2026-11-13)**, full notes in `report_notes/questions_2026-11-13.md`:
  - Calibration (tie points) **per day** confirmed.
  - Report the **std per day, north and south**, for the ice and water tie points.
  - Use the ERA5 algorithm: **ERA5 SIC for the T_B model**, criteria as in **Table 2** (interpretation still to confirm).
  - Task 2 = **sensitivity study with the RTM**.
- **(Resolved 2026-11-17, see A3b: DMI = Eq. 1 + raw-T_B Eq. 3 ± 1 line + analog ± 5 lines; we now use our own chain with the Eq. 3 line buffer.) Open question for Tonboe: whole scan lines in** `brightness_temperature_filtered`**.** The field removes whole rows around single-pixel spikes (Kolbe Eq. 3 outliers): usually spike row ± 1, sometimes 16–18 rows. Orbit 1973-02-01 04:21: 276 of 1483 rows removed, 177 of them without any out-of-range pixel; ≈ 21 000 plausible pixels (≈ 18 %) lost. Example: row 386 has 2 pixels at −77 K → rows 373–388 removed. Not the paper's Eq. 2 (&gt; 50 K row mean) as written. Ask: is dropping whole rows intended, or should we filter per pixel (Eq. 1 + Eq. 3)? Our meeting notes (2026-11-10) only say "use the filtered field"; compare with the less aggressive filter in Tellefsen et al. 2026. Details: `report_notes/A3_filters.md` → Open.
- **Meeting with Tonboe (2026-11-17)**, notes in `report_notes/meeting_2026-11-17.md`: map where the correction is largest; inverted grey Task 2 plot; L = 0 / mean / actual run (effect on wind); SST needs another frequency; Antarctic summer ice (vapour, melt) explains weird data; check tie-point masks (raise T_B limit); use the land mask in `provided/resampling_example/` (limit 0.1?); open-water SIC mean ≈ 0 → std is the result.
- Still to check: seminar length (newer paper from Tonboe's mail is optional reading).
- `esmr_rtm.py` ice emissivity table (0.93) ≠ paper Table 1 (0.91); irrelevant over open water.
- `provided/esmr_rtm.m` is scalar-only and uses `endif` (Octave syntax, not valid in MATLAB): needs a fixed/vectorised copy in `src/matlab/` before A5/A6. `interp1` returns NaN outside −5…25 °C.
- `esmr_rtm.py` uses `interp1d` on SST −5…25 °C: values outside raise an error.

## Findings from A1/A2 (orbit 1973-02-01 02:23)

- File: 1691 scan lines × 78 positions, vars in K/degrees already (no ÷10). Python: `src/a1_inspect.py`, `src/a2_plot.py`; MATLAB: `src/matlab/` (same numbers) → `output/A2_tb_latlon_matlab.png`. Run: `matlab -batch "run('src/matlab/a2_plot.m')"` from the project root.
- `brightness_temperature_filtered` = raw T_B with NaN outside 90 K &lt; T_B ≤ 273.15 K (Eq. 1 already applied, mostly land; 8 % NaN). Scan positions 1–4/75–78 are NOT removed yet.
- `sst`/`siconc` are NaN over land (41 %). `spos2ia` has 78 values, θ = ±63.86°.
- No cloud liquid variable; `tcw`, `tcwv` exist.

## Findings from A3–A5 (MATLAB: `a3_filter.m`, `a4_mask.m`, `a5_sic.m`)

- A3 (orbit 02:23, default 2026-11-17): 92.1 % pass Eq. 1, 91.8 % after Eq. 2–4, 82.5 % after dropping scan pos 1–4/75–78, 40.0 % after |lat| ≥ 50°, 23.8 % after land. Kept θ = ±55.67°. → `output/A3_tb_filtered.png`
- A4: ice mask = siconc ≥ 0.95 and 100 K &lt; T_B &lt; 274 K (Table 2 T_B range). 5×5 box not applied. Antarctic ice: few pixels (\~3–6k per day vs. 40–100k Arctic). → `output/A4_masks.png`
- A5 (all of Feb 1973, \~55 s): mean open-water SIC = 0 by construction (same pixels as Tp,water), so **std is the result**. Uncorrected std: **N 10.4 %** (7.1–12.9), **S 11.6 %** (9.0–14.5). Tp,water ≈ 145 K (N) / 141 K (S); Tp,ice ≈ 226 K (N) / 213 K (S). SIC distribution right-skewed (tail to +40 %, presumably wind/clouds). 28 Feb has only 1 orbit (unreliable). → `output/A5_sic_uncorrected.csv`, `.png`

## Findings from A6 (`esmr_rtm_vec.m`, `a6_corrected.m`)

- Vectorised RTM matches provided Python RTM to &lt; 0.001 K (8 test cases).
- L̄ (tcw − tcwv, cluster mean) in **both** runs, as in the paper (Sect. 4.1: "TB is not corrected for the cloud liquid water"). Per-pixel L over-corrects (std SIC 11.5 % N / 13.7 % S, worse than uncorrected).
- Result Task 1 (Feb 1973 without 28 Feb): std open-water SIC **N 10.6 → 8.7 %, S 11.5 → 9.6 %** (−17 %), std T_B 8.5 → 7.0 K; improved on 53 of 54 day/hemisphere cases. → `output/A6_sic_corrected.csv`, `.png`; per-pixel data for B1/B2 in `output/A6_water_pixels.mat`. Notes: `report_notes/A6_corrected_sic.md`

## Findings from A6b (`a6b_iterative.m`)

- Iteration 2 best (iteration 3 changes &lt; 0.4 % SIC). Water std N 10.5 → 8.2 %, S 14.3 → 11.0 % (−23 %); ice std N 14.6 → 13.0 %, S 44.3 → 40.5 %.
- Southern ice tie point with siconc &gt; 0.8: T_p,ice 200 K (vs. 214 K with ≥ 0.95), contrast only 59 K, ice T_B std 26 K → weak point, discuss with Tonboe. Notes: `report_notes/A6b_iterative.md`

## Findings from B1 (`b1_sensitivity.m`)

- Water, ΔT_B per +1σ at 50°: V 7.3 K, W 3.1 K, Ts −0.2 K (L 10.4 K but not corrected); all grow with θ. Ice: Ti 3.6–3.8 K, V and L &lt; 0.4 K.
- Report idea for Tonboe's question (animation → report): θ as x axis gives the whole animation in one figure; interactive page live in seminar/defence. Notes: `report_notes/B1_sensitivity.md`

## Log

- 2026-11-08 · project files copied from Drive, learning page for the paper built · next: A1

- 2026-11-09 · A1+A2 done (Python, then ported to MATLAB in src/matlab/) · next: A3 after feedback session

- 2026-11-13 · A3–A5 done in MATLAB (daily tie points per hemisphere, uncorrected SIC std ≈ 10–12 %) · next: fix/vectorise RTM, A6

- 2026-11-13 · globe viewer `output/globe/ESMR_globe.html` (all days, preprocessing steps, offline) · report notes A1–A5 in `report_notes/`

- 2026-11-13 · A6 done: RTM ported to MATLAB (vectorised, validated), corrected SIC std −17 % · next: B1 (Task 2), B2 (Task 3)

- 2026-11-13 · feedback session; A6b iterative correction done (water std −23 %) · next: B1 RTM sensitivity (Task 2), B2 std vs. θ (Task 3)

- 2026-11-13 · B1 sensitivity study (Task 2) as static version of the animation · next: B2 std vs. θ (Task 3)

- 2026-11-13 · pipeline flowchart `report_notes/pipeline_flowchart.html` (p. 1 flow A1–A6b with paper equations, p. 2 all RTM equations (Wentz 1997) + where each input enters, p. 3 value table; 3 A4 pages)

- 2026-11-13 · explainer video `output/video/ESMR_pipeline_explainer.mp4` (\~8 min, steps 1–9 on orbit 5 Feb 09:59 UTC, narration edge-tts Andrew); sources in `video/` (script.md, player.html, build.py) + `src/matlab/video_export.m`

- 2026-11-13 · globe viewer: A6b correction for all valid ocean pixels (`correct_day.m`), new modes ΔT_B and SIC corrected

- 2026-11-17 · meeting with Tonboe → new tie-point masks, L study, sweep with L = 0 + inverted grey, correction map

- 2026-11-17 · preprocessing as one configurable step (`preproc_config.m`, `esmr_preprocess.m`, `load_orbit(f, cfg)`, `correct_day(f, NIT, cfg)`); DMI's field rebuilt (99.97 % of pixels: Eq. 1 + raw-T_B Eq. 3 ± 1 line + analog gradient ch 0–14 ± 5 lines); filter choice changes water SIC std by ≤ 0.2 points → `report_notes/A3b_filter_validation.md`

- 2026-11-17 · **preprocessing default decided (Jo):** raw T_B → analog filter off → Eq. 1 → Eq. 2 per pixel → Eq. 3 line mode ± 1 line (no wrap) → Eq. 4 → edge 1–4/75–78 → |lat| ≥ 50° → land (SST missing).

  - Every script now uses `o.valid`/`o.flag` (no own cuts; B2 uses `cfg.edge = []`).
  - Re-run: a1–a6, a6b, b1–b1i, b2, b7, c1 (cache rebuilt), globe_plot, a3b (a, c, d). Not re-run: globe_html, video_export.
  - Results vs. the earlier DMI-field runs: ≤ 0.02 points everywhere.
    - Task 1 (A6b it. 2): water N 9.61 → 7.05 %, S 11.88 → 9.34 % (was 9.33); ice N 12.53 → 10.86 %, S 24.57 → 23.70 %.
    - ≈ 1 % more tie-point pixels.
    - The exclusion ranking (B1c) and B2 are unchanged.
  - Agreement with the DMI field: 99.38 % of pixels (old per-pixel Eq. 3: 97.87 %).
  - Questions for Tonboe: `report_notes/questions_2026-11-17.md`.

- 2026-11-17 · globe v3: whole processing step by step (Tasks 1–3) in `output/globe/ESMR_globe.html`; verified against the CSVs; next: B4 recommendation, B5 seminar, B6 report

- 2026-11-17 · 5×5 box (Table 2 ice-edge distance) added to `tp_masks.m` (`opt.box`, default on); everything rerun. Task 1 (A6b it. 2): water σ N 9.60 → 7.04 %, S 11.65 → 9.18 %; ice N 12.45 → 10.74 %, S 24.02 → 23.18 %; Antarctic ice pixels −11 %, T_p,ice S 212.5 K. B1c ranking unchanged (V > W ≫ Ts). C1: ice area 3.43 × 10⁶ km² (was 3.48), agreement 96.0 %. Details: `report_notes/A4_tiepoint_masks.md`.
- 2026-11-17 · C2: Feb 1973 both hemispheres vs SP-489 (N) and SP-459 (S), `c2_feb1973_books.m`: edge agreement N 93.4 % / S 97.3 %, extent N 15.68 vs 15.82, S 5.27 vs 5.12 (10⁶ km²); area ours 14.33 / 3.33 vs book classes 13.23 / 2.56; export `output/globe/feb1973.js`; notes `report_notes/C2_feb1973_books.md`
