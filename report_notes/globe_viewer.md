# Globe viewer (visualisation tool)

**Use:** figures for the report and live demo in the seminar
**Code:** `src/matlab/globe_html.m` (data export), `src/web/globe_template.html` (page), `src/web/land-50m.json` (Natural Earth coastlines), `src/web/*.min.js` (d3-geo, topojson)
**Output:** `output/globe/ESMR_globe.html` + `output/globe/days/*.js` (keep the folder together; open the HTML by double-click, works offline)
**Static version (MATLAB):** `src/matlab/globe_plot.m` → `output/globe_*.png`, `.fig`

## What it shows
- All orbits of each day in Feb 1973 on a rotatable 3D globe (drag, scroll to zoom, ←/→ for the day).
- Colour modes: T_B, incidence angle θ, tie-point masks, uncorrected SIC (with the daily tie points of A5).
- **Preprocessing slider** (steps 0–4: raw swath → Eq. 1 → swath edges → |lat| ≥ 50° → ERA5 land), removed pixels coloured by reason, with pixel counts per step.
- Hover readout: position, scan position, θ, T_B, SIC, reason a pixel was removed.

## Notes
- Pixels with |lat| < 50° are stored thinned (every 4th line and position) to keep files small; counts are scaled by 16.
- Rebuild after code changes: `matlab -batch "run('src/matlab/globe_html.m')"` (~2 min for all days).

## For the report / seminar
- Screenshots of step 0 vs. step 3 explain the preprocessing in one picture.
- θ mode shows where the large angles are (link to Task 3).
- SIC mode shows the noise over open water before correction (link to Task 1).
