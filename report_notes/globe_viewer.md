# Globe viewer (visualisation tool)

**Use:** figures for the report and live demo in the seminar
**Code:** `src/matlab/globe_html.m` (data export), `src/web/globe_template.html` (page), `src/web/land-50m.json` (Natural Earth coastlines), `src/web/*.min.js` (d3-geo, topojson)
**Output:** `output/globe/ESMR_globe.html` + `output/globe/days/*.js` (keep the folder together; open the HTML by double-click, works offline)
**Static version (MATLAB):** `src/matlab/globe_plot.m` → `output/globe_*.png`, `.fig`

## What it shows
- All orbits of each day in Feb 1973 on a rotatable 3D globe (drag, scroll to zoom, ←/→ for the day).
- Colour modes: T_B, incidence angle θ, tie-point masks (Table 2: ice siconc > 0.8), **SIC raw**, **ΔT_B** (RTM correction per pixel) and **SIC corrected**.
- Correction = A6b method (c_ice from ERA5, one iteration, L not corrected) applied to **all** valid ocean pixels via `src/matlab/correct_day.m`. Same tie points and std as `a6b_iterative.m` (checked for 5 Feb: identical).
- Tie-point table per day: T_p,water, T_p,ice, std SIC water and ice, raw → corrected.
- **Preprocessing slider** (steps 0–4: raw swath → Eq. 1 → swath edges → |lat| ≥ 50° → ERA5 land), removed pixels coloured by reason, with pixel counts per step.
- Slider (which pixels are left) and colour mode (what is shown) are independent. For SIC raw, ΔT_B and SIC corrected the slider jumps to step 4 (ocean after all filters = what A6b works on); kept pixels without a value there are drawn light grey ("no value: land or outside the filters").
- Hover readout: position, scan position, θ, T_B, ΔT_B, SIC raw and corrected, reason a pixel was removed.

## Notes
- Pixels with |lat| < 50° are stored thinned (every 4th line and position) to keep files small; counts are scaled by 16.
- Rebuild after code changes: `matlab -batch "run('src/matlab/globe_html.m')"` (~2.5 min for all days, ~240 MB in `output/globe/days/`).

## For the report / seminar
- Screenshots of step 0 vs. step 3 explain the preprocessing in one picture.
- θ mode shows where the large angles are (link to Task 3).
- SIC raw vs. SIC corrected on the same day shows the effect of the correction (Task 1).
- ΔT_B mode shows where the RTM corrects most: storms (high V/W) and the swath edges (large θ) → links Task 2 and Task 3.
- Range of ΔT_B on 5 Feb: −25.5 … +20.6 K, mean +2.8 K.
