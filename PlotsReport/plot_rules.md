# Plot rules for the report

Applies to **every figure that goes into the report** (`PlotsReport/`), from any group member.
Agreed 2026-11-27. Existing figures are brought in line in a later step.

## Rules

| # | Topic | Rule |
|---|---|---|
| 1 | Land | Land is shown in **gray**. |
| 2 | SIC unit | SIC is always given in **%** (0–100), never as a fraction 0–1. |
| 3 | SIC colormap | Maps of SIC use **`jet`**. |
| 4 | T_b / ΔSIC colormap | T_b and ΔSIC maps use the **MATLAB default colormap** (`parula`). |
| 5 | ΔT_b vs. ΔSIC | ⚠ open: ask the supervisor which he prefers |
| 6 | Font | All text uses the **LaTeX interpreter** (`Interpreter`, `TickLabelInterpreter`, legend interpreter = `latex`). |
| 7 | Font size | **24** for all text. |
| 8 | Latitude range | Polar maps cover **±50° to ±90°** (pole down to 50°N / 50°S). |
| 9 | Subplot titles | Each panel gets a label **(a), (b), …** plus the region, e.g. `(a) Arctic`, `(b) Antarctic`. |
| 10 | Main title | **No main title** (no `sgtitle` / tiledlayout title). The caption in the report replaces it. |
| 11 | Size | One-column LaTeX report: the figure is made for its final width, **1250 px for `\textwidth`**, 620 px for half width (`report_style(fig, 'width', 'full'/'half', 'aspect', h/w)`). 24 pt then shows as about 9 pt in the PDF. At most 2-3 panels side by side; wider figures are split. |

Also still valid (earlier agreement): Arctic on top, Antarctic below; plain legend names.

## Open points

- **Rule 5, "ΔT_b vs. ΔSIC":** ask the supervisor whether he prefers plots in ΔT_b or in ΔSIC.

## How to apply (MATLAB)

Call `report_style(fig)` (`src/matlab/report_style.m`) right before `exportgraphics`. It sets rules 6, 7, 9 and 10:
LaTeX interpreter everywhere (TeX/Unicode strings like `\Delta`, `T_s`, `°`, `%` are converted), font size 24,
panel labels (a), (b), ... in reading order in front of the axes titles, no `sgtitle` / tiledlayout title.
Rules 1-4 and 8 (colours, land, 50-90° range) stay in the script. Keep panel titles short ("Arctic",
"Antarctic, this work"); everything else goes into the figure caption (written as a comment above `report_style`).
Make the figure large enough (about 2000-3200 px wide) so that 24 pt text fits.

## Sizes (rule 11, Jo 2026-11-27)

Measured from the PNGs: all figures in `PlotsReport/main` and `appendix` give 8.8-9.7 pt in the PDF at 16 cm, except
B7 (kept as it is on purpose, about 5 pt). Split for this: B8 (main: total + Delta, appendix: the two parts), C3 (ERA5 /
SIC), B1e (one figure per hemisphere, Antarctic in the main part), C2b (one per hemisphere). B1i without the histogram
column. A3b is no longer a report figure.

## Axel's figures (AX*)

`src/matlab/axel_figures.m` reads Axel's `.fig` files from branch `origin/Axel` (`plots/`) and re-exports them with
the rules (`AX1`-`AX5`): data unchanged (his pipeline), SIC x 100 in %, jet [-10 110], T_B parula, land grey
from the ERA5 land mask of C2, Arctic top / Antarctic bottom, no main title, LaTeX 24 pt. New .fig files from Axel:
add a line in that script.
Our version of AX1-AX3 from our pipeline (same day): `d1_day_maps.m` -> D1, D2 (30 km grid as C2/B8).

## Exceptions

- `C1_sp459_side_by_side.png`, `C2_sp489_side_by_side.png`: our map is painted in the atlas colour classes and
  land colours so that it can be compared with the scan. Rules 1 and 3 do not apply there.
- Corrections (ΔSIC = corrected - uncorrected, corrected - uncorrected uncertainty) and the open-water SIC anomaly
  maps in C3 use a **red-white-blue** diverging map around 0 (Jo 2026-11-27): B7 mean ΔSIC, B8 Δ total uncertainty, C3_low_sic.
- `B7_correction_map.png` panel "dominant input": categorical colours (V, W, T_s, T_i), not a colormap.
