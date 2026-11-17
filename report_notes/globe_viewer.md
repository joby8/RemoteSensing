# Globe viewer (visualisation tool)

**Use:** figures for the report and live demo in the seminar
**Code:** `src/matlab/globe_html.m` (data export), `src/web/globe_template.html` (page), `src/web/land-50m.json` (Natural Earth coastlines), `src/web/*.min.js` (d3-geo, topojson)
**Output:** `output/globe/ESMR_globe.html` + `output/globe/days/*.js` (keep the folder together; open the HTML by double-click, works offline)
**Static version (MATLAB):** `src/matlab/globe_plot.m` → `output/globe_*.png`, `.fig`

## Interface (2026-11-16)
Apple-style layout (system font, iOS colours, light/dark): globe with floating controls (Arctic/Antarctic switch, zoom, legend capsule, hover card); inset grouped lists on the right: Day/Orbit · Map (T_B, θ, clusters, SIC raw/corrected with σ water) · Correction (Value / Difference / Effect) · Corrected inputs sorted by size, with a stacked bar like Screen Time · Not corrected (L) · Reference (c) · Preprocessing (slider + tappable steps, switch for removed pixels) · Daily tie points. Works offline (no web fonts).

## What it shows
- All orbits of each day in Feb 1973 on a rotatable 3D globe (drag, scroll to zoom, ←/→ for the day).
- Colour modes: T_B, incidence angle θ, tie-point masks (`tp_masks.m`, 17 Nov: water siconc ≤ 0.01, SST > 278 K, 90–180 K; ice siconc > 0.8, 180–274 K; both ERA5 lsm = 0), **SIC raw**, **ΔT_B** (RTM correction per pixel) and **SIC corrected**.
- Correction = A6b method (c_ice from ERA5, one iteration, L not corrected) applied to **all** valid ocean pixels via `src/matlab/correct_day.m`. Same tie points and std as `a6b_iterative.m` (checked for 5 Feb: identical).
- Tie-point table per day: T_p,water, T_p,ice, std SIC water and ice, raw → corrected.
- **Preprocessing slider** (steps 0–8, one per calculation in the paper's order: raw swath → analog filter → Eq. 1 → Eq. 2 → Eq. 3 → Eq. 4 → swath edges → |lat| ≥ 50° → ERA5 land; see the 2026-11-17 v2 section below), removed pixels coloured by step, with pixel counts per step.
- **Correction step by step** (box under the colour buttons): the RTM inputs of every corrected pixel, in the order of the explainer video: water vapour V, wind W, cloud liquid water L, SST T_s, ice temperature T_i, ice fraction c. Three views per input:
  - *pixel*: the ERA5 value (c: ice fraction of the last iteration),
  - *− reference*: pixel minus the reference (1 − c)·mean_water + c·mean_ice of the day's clusters (= how far the weather is from the mean weather),
  - *part of ΔT_B*: correction from this input alone = T_B,RTM(reference) − T_B,RTM(reference with only this input set to the pixel value), same colour scale as ΔT_B.
  - **L is not corrected.** Both model runs use the same L_ref = (1 − c)·L̄_water + c·L̄_ice (day mean of tcw − tcwv over the Table 2 clusters per hemisphere, e.g. 5 Feb N 0.30 / S 0.29 kg/m² over water, ≈ 0.04 over ice), so L cancels in ΔT_B (paper Sect. 4.1; per-pixel L made A6 worse). The globe has two rows: *ERA5 cloud water L* (not used; bar = effect if it were) and *L in the model* (map of L_ref, effect 0 K).
  - Where ice/ocean is for the reference (all inputs, incl. L): via c per pixel. Iteration 1: c = ERA5 siconc; iteration 2 (shown): c = own SIC of iteration 1, clipped, < 15 % → 0. Land is removed before (no ERA5 SST).
  - The parts add up to ΔT_B within 0.2 K rms (max 0.9 K, 5 Feb, 294 060 pixels); the rest comes from the non-linear model.
  - In ΔT_B and input modes the hover readout lists, per input, pixel / reference → part, plus sum vs. ΔT_B.
- **Pin a pixel**: click a pixel (without dragging) to pin it. It gets a white ring on the globe and its card stays open while you switch layers, inputs and views, so one pixel can be followed through all steps. Unpin with ✕, Esc, or by clicking off the swath; changing the day unpins.
- Show removed pixels is off by default. Texts kept short (one-line captions).
- **Method of the SIC maps**: when SIC raw or SIC corrected is selected, its row shows the steps used (filters → tie points → Eq. 16; for corrected: method A6b RTM correction, iteration 2 of 2, reference weather, Eq. 14, iteration 1 with ERA5 c, iteration 2 with own c, Eq. 13, corrected tie points, Eq. 16) with the day's numbers (tie points, σ water raw → corrected).
- Slider (which pixels are left) and colour mode (what is shown) are independent. For SIC raw, ΔT_B and SIC corrected the slider jumps to the last step (8; was step 4 before 17 Nov) (ocean after all filters = what A6b works on); kept pixels without a value there are drawn light grey ("no value: land or outside the filters").
- Hover readout: position, scan position, θ, T_B, ΔT_B, SIC raw and corrected, reason a pixel was removed.

## Notes
- Loading a day shows a progress card (reading the file, then decoding orbit by orbit); the last 4 days stay in memory and switch instantly.
- **Two different land sources:**
  - *ERA5 land* (slider step 4, grey "no value" pixels): from the data files themselves. A pixel is land where the collocated ERA5 `sst` is missing. Same rule as in the processing (water tie points need SST > 278 K). ERA5 `lsm` would be an alternative.
  - *Drawn continents and coastlines*: Natural Earth 1:50m (`world-atlas@2.0.2`, public domain), downloaded once to `src/web/land-50m.json` and embedded in the page. Only a background map: it does not change any data. Nothing is loaded online at runtime.
- Correction inputs and parts are stored only for corrected pixels, as 1 byte each (V 0.25 kg/m², W 0.1 m/s, L 0.02 kg/m², T_s 0.2 K, T_i 0.25 K, c 0.4 %, parts 0.25 K, L part 0.5 K). They come from `correct_day.m` (new outputs c, dV, dW, dL, dTs, dTi and cluster means Mw/Mi).
- Pixels with |lat| < 50° are stored thinned (every 4th line and position) to keep files small; counts are scaled by 16.
- Rebuild after code changes: `matlab -batch "run('src/matlab/globe_html.m')"` (~2 min for all days, ~350 MB in `output/globe/days/`).

## Update 2026-11-17: new tie-point masks
- Rebuilt with the masks from the Tonboe meeting (`tp_masks.m`, used via `correct_day.m`). The cluster class bits in `globe_html.m` come from `correct_day`'s `o.mw` / `o.mi`, so the globe and `a6b_iterative.m` share one rule. Texts in the tie-point panel and the cluster legend updated.
- Coastal pixels (ERA5 lsm > 0) are now left out of the tie-point clusters, but they are still corrected and shown as ocean where ERA5 has an SST (unchanged behaviour). The slider's "ERA5 land" step is still "sst missing".
- Check 5 Feb (iteration 2), globe = `output/A6b_iterative.csv` exactly: N T_p,water 146.3 → 146.6 K, T_p,ice 224.0 → 224.6 K, std water 10.77 → 7.28 %, ice 13.06 → 10.96 %; S T_p,water 140.6 → 140.8 K, T_p,ice 211.3 → 211.8 K, std water 12.57 → 9.92 %, ice 24.59 → 23.51 %.
- The 5 Feb example numbers below (ΔT_B range, parts, example pixel) are from the **old masks** (before 17 Nov). Re-read them from the globe before using them in the report.

## For the report / seminar
- Screenshots of step 0 vs. step 3 explain the preprocessing in one picture.
- θ mode shows where the large angles are (link to Task 3).
- SIC raw vs. SIC corrected on the same day shows the effect of the correction (Task 1).
- ΔT_B mode shows where the RTM corrects most: storms (high V/W) and the swath edges (large θ) → links Task 2 and Task 3.
- Range of ΔT_B on 5 Feb: −25.5 … +20.6 K, mean +2.8 K.
- Parts on 5 Feb (1st–99th percentile): V −9.0 … +10.9 K, W −3.7 … +6.7 K, T_i −7.0 … +4.6 K (only over ice), T_s −1.9 … +0.3 K; L (not applied) −19.6 … +10.2 K. Same order as the tornado plot (Task 2): V > W > T_s over water, T_i over ice, L largest but not corrected.
- Example pixel 54.0°N 22.4°W (02:53 UTC, water tie point, θ −50°): V 18.5 vs. ref 12.3 kg/m² → −7.3 K, W 14.0 vs. 11.3 m/s → −2.0 K, T_s → +0.3 K; sum −9.0 K, ΔT_B −9.1 K; SIC 19.7 % → 7.7 %. L 0.48 vs. 0.30 kg/m² would add another −5.5 K.
- Input-part maps for one day show *why* ΔT_B looks the way it does: V-part follows the moist air masses, W-part the storms, T_i-part only the ice.

## Eq. 1 per pixel (2026-11-17)
The slider step "Eq. 1" showed whole red scan lines: the DMI field `brightness_temperature_filtered` also drops entire scan lines (11 867 in Feb 1973, 821 203 in-range pixels). `load_orbit.m` now applies 90 K < T_B ≤ 273.15 K per pixel to the raw T_B, so only the failing pixels are removed. Affects every script that uses `tb_f` (tie points, SIC, correction); globe data regenerated.
- 2026-11-17 (later): slider step 1 is now **"Eq. 1–4"** (Kolbe et al. 2024 outlier filters per pixel, `esmr_filters.m`, now `esmr_preprocess.m`); the hover card names the equation that removed the pixel (`code` bits 6–7: 0 Eq. 1, 1 Eq. 2, 2 Eq. 3, 3 Eq. 4). Example 20 Feb 06:05 UTC, 54.7° S 84.6° E: 240 K pixels next to −214 K → "Eq. 3 · spike" and "Eq. 1".
- 2026-11-17 (preprocessing refactor, not rebuilt yet): `globe_html.m` takes `cfg` (preproc_config.m) and writes an optional per-pixel `rm` (= o.flag) when the analog filter is on; the page shows "Analog filter" for those pixels. Plan: one slider step per paper step, storing `o.flag` directly (code table in `preproc_config.m`).

## Update 2026-11-17 (v2): one slider step per paper calculation, per-criterion cluster view
- **Slider steps 0–8** in the paper's order (Kolbe et al. 2024, Sect. 2.2): 0 raw swath → 1 analog filter → 2 Eq. 1 → 3 Eq. 2 → 4 Eq. 3 → 5 Eq. 4 → 6 swath edges → 7 |lat| ≥ 50° → 8 ERA5 land. Each step has its own colour (analog pink, Eq. 1 red, Eq. 2 orange, Eq. 3 yellow, Eq. 4 mint, edge purple, latitude slate, land brown), the pixels left plus the delta, and a one-line keep condition built from the day's `cfg` (e.g. "|p_i − p_{i−1}| + |p_{i+1} − p_i| ≤ 150 K · whole line ±1"). Default position 7 (as the old step 3); SIC/ΔT_B/inputs jump to 8.
- A **disabled step** (analog, off by default) is shown as "not applied · would −N". Tapping it draws the pixels it would remove as a checker pattern on top (from `o.would`).
- **Hover/pin card** names the step and the value: "Removed · Eq. 3 · along-track spike 693.2 K > 150 K in this line", "… in line 656 (±1 line buffer)", "Eq. 1 · T_B = −213.7 K ≤ 90 K", "Eq. 2 · scan-line jump … K > 50 K · offset block", "Not applied · would remove: Analog filter · housekeeping jump 13.0 > 10". Kept pixels that a later step removes show "Later step k · …". The card also gives the scan line number.
- **Tie-point clusters → criteria** (tap in the Map list, under "Tie-point clusters"): Water siconc ≤ 0.01 → SST > 278 K → 90 < T_B < 180 K → lsm = 0; Ice siconc > 0.8 → 180 < T_B < 274 K → lsm = 0. Only `o.valid` pixels; the slider moves to 8. Passing pixels in the group colour, drop-outs red, earlier failures grey; count passing / dropping per criterion; paper value where we deviate. Last line: cluster T_B mean ± std per hemisphere and the day's T_p and σ SIC. Tap again (or "Final clusters") for the default view.
- Criteria come from `tp_masks.m` (new optional 3rd output `C` with the single criteria; mw/mi unchanged), so globe and analysis share one rule. `globe_html.m` asserts that the combined bits equal `correct_day`'s o.mw/o.mi.
- **Day file format v2** (header of `globe_html.m`): pixels stored scan line by scan line (`lpc` = pixels per line → line number); per pixel `flag` (= o.flag, code table cfg.codes), `bits` (criteria bits 0–5, thinned bit 6, no-SST bit 7), optional `would`; per line reason values `la/lao`, `l2`, `l3/l3o` (+ `p3` per pixel for Eq. 3 'pixel' mode); `cfg` per day. The old code byte and `rm` are gone. 394 MB for 28 days (was 348 MB).
- **Example 20 Feb 1973** (all 13 orbits, thinned pixels × 16): raw 1 639 789 · analog not applied (would −5 799) · Eq. 1 −70 987 · Eq. 2 −96 · Eq. 3 −34 587 · Eq. 4 −0 · edges −154 116 · latitude −762 592 · land −260 594 → 356 817 kept (= the valid pixels; sum checks). Clusters: water 203 646 → 63 391 → 62 751 → 60 907, ice 114 084 → 109 303 → 85 161 = N 20 699 + S 40 208 water and N 74 283 + S 10 878 ice, as in `tp`; T_p,water N 146.4 / S 138.6 K, T_p,ice N 225.3 / S 209.6 K.
- **06:05 UTC, 54.7° S 84.6° E**: line 657 positions 37–39 (240 K) → Eq. 3 (spike 693 K in this line), positions 40–41 (−213.7 K) → Eq. 1; lines 656/658 → Eq. 3 (own spike 351/355 K), lines 655/659 → Eq. 3 ±1 line buffer.
- Checked in headless Chrome (CDP): page loads without console errors, all colour modes, input views, pin, criteria toggle, dark mode.
- Eq. 4 removes nothing in Feb 1973 (as in A3_filters.md).
- Ice criterion lsm = 0 removes 24 142 of 109 303 ice pixels on 20 Feb (coast of Antarctica/Arctic). This is the largest of our deviations from the paper.

## Update 2026-11-17 (v3): Tasks 2 and 3 in the globe data
- `correct_day.m` has an optional 4th argument `opts`. With `opts.extra = true` (used only by `globe_html.m`) it also corrects the **swath-edge pixels** (positions 1–4 / 75–78 that pass the latitude and land rules; B2 method: tie points, clusters and reference weather still come from the inner swath only), and returns dtb of **iteration 1**, the **exclusion cases** without V / W / Ts / Ti (as `b1c_exclusion.m`) and the **per-pixel L** case (`b1i_L_study.m`, variant a). Without `opts` nothing changes (checked bit-identical on 5 Feb; valid-pixel dtb and all old TP fields also bit-identical with `extra = true`). The edge rule matches `load_orbit` with `cfg.edge = []` exactly (5 Feb: 34 950 edge pixels).
- **Day file v3:** `dtb` is now also set for edge pixels (flag 6 and dtb set = corrected edge pixel). New per-pixel arrays in `inp` (int8, difference to the final dtb): `d1` (iteration 1, 0.25 K), `xV`, `xW`, `xTs`, `xTi` (exclusion, 0.25 K), `xL` (per-pixel L, 0.5 K).
- **New tie-point fields** in `tp` and the manifest: `w_mean_u/c`, `i_mean_u/c`; `it1` (iteration 1 tie points and std); `X.without_V/W/Ts/Ti`, `X.L_pixel` (tie points, std, mean); `spos` (count, sum and sum of squares of SIC per scan position, raw and corrected, incl. the edge), so the page can pool the std over days exactly as `b2_angle.m`.
- **Check, mean over 1–27 Feb** (globe = script, all to < 1e-4 %): water std iteration 2 N 9.61 → 7.05 %, S 11.88 → 9.34 % (A6b); iteration 1 N 7.23 %, S 9.73 % (A6b); without V N 8.25 / S 11.19 %, without W 8.45 / 9.90 %, without Ts 7.06 / 9.32 %, without Ti 7.13 / 9.43 % (B1c); per-pixel L 9.99 / 13.61 % (B1i). The std per scan position pooled from `spos` equals `output/B2_angle.csv` (n, mean and std, all 78 positions, water and ice).
- Quantisation (5 Feb, 329 960 pixels): rms error 0.05–0.07 K for `d1`, `xV`, `xW`, `xTs`, `xTi`, 0.14 K for `xL`; clipped at ±127 steps: 1 pixel (`d1`), 74 pixels (`xL`, > 63.5 K).
- Day files now 481 MB for 28 days (was 394 MB).
