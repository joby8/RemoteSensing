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
- **Preprocessing slider** (steps 0–4: raw swath → Eq. 1 → swath edges → |lat| ≥ 50° → ERA5 land), removed pixels coloured by reason, with pixel counts per step.
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
- Slider (which pixels are left) and colour mode (what is shown) are independent. For SIC raw, ΔT_B and SIC corrected the slider jumps to step 4 (ocean after all filters = what A6b works on); kept pixels without a value there are drawn light grey ("no value: land or outside the filters").
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
