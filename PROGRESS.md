# Project 1: Regional noise reduction of NIMBUS 5 ESMR SIC

30350 Remote Sensing · supervisor Rasmus Tonboe (rtt@space.dtu.dk)
Method: Kolbe et al. 2024, Sect. 4.1 (`docs/Kolbe_etal_essd-16-1247-2024.pdf`, p. 5–8).
Newer paper (Tonboe mail 2026-11-06, local dynamical tie points; optional): `docs/Tellefsen_etal_essd-18-2891-2026.pdf`.
Tasks: `docs/read_me.txt`. Report notes per step (writing plan): `report_notes/`. Learning page: `docs/learning/Kolbe_etal_essd-16-1247-2024_interaktiv.html`.

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
- [x] A3 Filters: Eq. 1 (90 K < T_B ≤ 273.15 K) and drop scan positions 1–4 and 75–78. Eq. 2–4 later if needed.
- [x] A4 Open-water mask, Table 2: siconc = 0, sst > 278 K, 90 K < T_B < 180 K, lat > 32° N or < −48° S (5×5 box optional). Meeting: only use |lat| ≥ 50° (skip the low latitudes, less data); SST > 278 K as in Table 2.
- [x] A5 Uncorrected SIC (Eq. 16): Tp,water = mean T_B of the mask, Tp,ice from 95 %→100 % ice pixels (per day, per hemisphere; was 225 K placeholder). Mean and std on **raw** SIC (no clipping, no 15 % filter).
- [x] A6 Correction (Eq. 13–14): means V̄, W̄, T̄s, T̄i over the mask; L = mean in both runs. Corrected SIC with the corrected tie point → mean and std. **Task 1 for one orbit.**

- [x] A6b Iterative correction (session 2026-11-13): Table 2 clusters (ice siconc > 0.8, |lat| ≥ 50°), c_ice from ERA5 → iterate, reference values mixed by c_ice; std per day N/S for water and ice. **Main method for Task 1.**

### Phase B: tasks
- [x] B1 Task 2 (agreed 2026-11-13: **RTM sensitivity study**): `b1_sensitivity.m` → `output/B1_sensitivity.png` = static report version of the learning-page animation (θ on x axis, ΔT_B per +1σ of each input). Optional: data exclusion test as cross-check.
- [ ] B2 Task 3: std of SIC per θ bin, uncorrected vs corrected (like Fig. 5, but in % SIC).
- [ ] B3 Scale up to all of Feb 1973, both hemispheres. Vectorise the RTM (NumPy) if the loop is too slow.
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
  - Water tie point: water must be cold enough for the cold-water calibration. The number is in the given paper: **Table 2, SST (ERA5) > 278 K** (the only SST threshold in the paper; the "275 K" in my notes is unverified).
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
- Still to check: seminar length (newer paper from Tonboe's mail is optional reading).
- `esmr_rtm.py` ice emissivity table (0.93) ≠ paper Table 1 (0.91); irrelevant over open water.
- `provided/esmr_rtm.m` is scalar-only and uses `endif` (Octave syntax, not valid in MATLAB): needs a fixed/vectorised copy in `src/matlab/` before A5/A6. `interp1` returns NaN outside −5…25 °C.
- `esmr_rtm.py` uses `interp1d` on SST −5…25 °C: values outside raise an error.

## Findings from A1/A2 (orbit 1973-02-01 02:23)
- File: 1691 scan lines × 78 positions, vars in K/degrees already (no ÷10). Python: `src/a1_inspect.py`, `src/a2_plot.py`; MATLAB: `src/matlab/` (same numbers) → `output/A2_tb_latlon_matlab.png`. Run: `matlab -batch "run('src/matlab/a2_plot.m')"` from the project root.
- `brightness_temperature_filtered` = raw T_B with NaN outside 90 K < T_B ≤ 273.15 K (Eq. 1 already applied, mostly land; 8 % NaN). Scan positions 1–4/75–78 are NOT removed yet.
- `sst`/`siconc` are NaN over land (41 %). `spos2ia` has 78 values, θ = ±63.86°.
- No cloud liquid variable; `tcw`, `tcwv` exist.

## Findings from A3–A5 (MATLAB: `a3_filter.m`, `a4_mask.m`, `a5_sic.m`)
- A3 (orbit 02:23): 91.8 % pass Eq. 1, 82.5 % after dropping scan pos 1–4/75–78, 40 % after |lat| ≥ 50°. Kept θ = ±55.67°. → `output/A3_tb_filtered.png`
- A4: ice mask = siconc ≥ 0.95 and 100 K < T_B < 274 K (Table 2 T_B range). 5×5 box not applied. Antarctic ice: few pixels (~3–6k per day vs. 40–100k Arctic). → `output/A4_masks.png`
- A5 (all of Feb 1973, ~55 s): mean open-water SIC = 0 by construction (same pixels as Tp,water), so **std is the result**. Uncorrected std: **N 10.4 %** (7.1–12.9), **S 11.6 %** (9.0–14.5). Tp,water ≈ 145 K (N) / 141 K (S); Tp,ice ≈ 226 K (N) / 213 K (S). SIC distribution right-skewed (tail to +40 %, presumably wind/clouds). 28 Feb has only 1 orbit (unreliable). → `output/A5_sic_uncorrected.csv`, `.png`

## Findings from A6 (`esmr_rtm_vec.m`, `a6_corrected.m`)
- Vectorised RTM matches provided Python RTM to < 0.001 K (8 test cases).
- L̄ (tcw − tcwv, cluster mean) in **both** runs, as in the paper (Sect. 4.1: "TB is not corrected for the cloud liquid water"). Per-pixel L over-corrects (std SIC 11.5 % N / 13.7 % S, worse than uncorrected).
- Result Task 1 (Feb 1973 without 28 Feb): std open-water SIC **N 10.6 → 8.7 %, S 11.5 → 9.6 %** (−17 %), std T_B 8.5 → 7.0 K; improved on 53 of 54 day/hemisphere cases. → `output/A6_sic_corrected.csv`, `.png`; per-pixel data for B1/B2 in `output/A6_water_pixels.mat`. Notes: `report_notes/A6_corrected_sic.md`

## Findings from A6b (`a6b_iterative.m`)
- Iteration 2 best (iteration 3 changes < 0.4 % SIC). Water std N 10.5 → 8.2 %, S 14.3 → 11.0 % (−23 %); ice std N 14.6 → 13.0 %, S 44.3 → 40.5 %.
- Southern ice tie point with siconc > 0.8: T_p,ice 200 K (vs. 214 K with ≥ 0.95), contrast only 59 K, ice T_B std 26 K → weak point, discuss with Tonboe. Notes: `report_notes/A6b_iterative.md`

## Findings from B1 (`b1_sensitivity.m`)
- Water, ΔT_B per +1σ at 50°: V 7.3 K, W 3.1 K, Ts −0.2 K (L 10.4 K but not corrected); all grow with θ. Ice: Ti 3.6–3.8 K, V and L < 0.4 K.
- Report idea for Tonboe's question (animation → report): θ as x axis gives the whole animation in one figure; interactive page live in seminar/defence. Notes: `report_notes/B1_sensitivity.md`

## Log
- 2026-11-08 · project files copied from Drive, learning page for the paper built · next: A1
- 2026-11-09 · A1+A2 done (Python, then ported to MATLAB in src/matlab/) · next: A3 after feedback session
- 2026-11-13 · A3–A5 done in MATLAB (daily tie points per hemisphere, uncorrected SIC std ≈ 10–12 %) · next: fix/vectorise RTM, A6
- 2026-11-13 · globe viewer `output/globe/ESMR_globe.html` (all days, preprocessing steps, offline) · report notes A1–A5 in `report_notes/`
- 2026-11-13 · A6 done: RTM ported to MATLAB (vectorised, validated), corrected SIC std −17 % · next: B1 (Task 2), B2 (Task 3)
- 2026-11-13 · feedback session; A6b iterative correction done (water std −23 %) · next: B1 RTM sensitivity (Task 2), B2 std vs. θ (Task 3)
- 2026-11-13 · B1 sensitivity study (Task 2) as static version of the animation · next: B2 std vs. θ (Task 3)
- 2026-11-13 · globe viewer: A6b correction for all valid ocean pixels (`correct_day.m`), new modes ΔT_B and SIC corrected
