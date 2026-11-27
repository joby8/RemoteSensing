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

## Not yet LaTeX-ready (known, left for later, Jo 2026-11-27)

Font size 24 is set, but the figures are 1250-3200 px wide. Scaled to the full text width (16 cm) the text shows
as about 3.5-6 pt in the PDF (B8: 3.4 pt, B1i: 4.8 pt), smaller than the caption. For about 9 pt in the PDF at
24 pt, a full-width figure must be about 1250 px wide (half width about 620 px), so wide multi-panel figures (B8, C3,
C2b, B1e) would need more rows / fewer columns. Decision postponed until the LaTeX report exists.

## Axel's figures (AX*)

`src/matlab/axel_figures.m` reads Axel's `.fig` files from branch `origin/Axel` (`plots/`) and re-exports them with
the rules (`AX1`-`AX5`): data unchanged (his pipeline), SIC x 100 in %, jet [-10 110] as B8, T_B parula, land grey
from the ERA5 land mask of C2, Arctic top / Antarctic bottom, no main title, LaTeX 24 pt. New .fig files from Axel:
add a line in that script.

## Exceptions

- `C1_sp459_side_by_side.png`, `C2_sp489_side_by_side.png`: our map is painted in the atlas colour classes and
  land colours so that it can be compared with the scan. Rules 1 and 3 do not apply there.
- Corrections (ΔSIC = corrected - uncorrected, corrected - uncorrected uncertainty) and the open-water SIC anomaly
  maps in C3 use a **red-white-blue** diverging map around 0 (Jo 2026-11-27): B7 mean ΔSIC, B8 last column, C3 bottom row.
- `B7_correction_map.png` panel "dominant input": categorical colours (V, W, T_s, T_i), not a colormap.
