# A3 – Filters

**Report section:** Method → preprocessing
**Code:** `src/matlab/a3_filter.m` (same rules are repeated inline in `a4_mask.m`, `a5_sic.m`, `globe_html.m`)
**Figures:** `output/A3_tb_filtered.png`, `output/globe_A3_tb_N.png` / `_S.png`; interactive: `output/globe/ESMR_globe.html` (slider "Preprocessing", steps 0–4)
**Status:** done 2026-11-13

## Goal
Remove pixels that are physically implausible or not useful before computing tie points and SIC.

## What we did (in this order)
1. **Eq. 1: 90 K < T_B ≤ 273.15 K.** Already applied in `brightness_temperature_filtered`; we use that field (Tonboe: use the filtered field).
2. **Swath edges: drop scan positions 1–4 and 75–78.** Removes the largest incidence angles; the kept swath is **θ = ±55.67°**.
3. **High latitudes only: |lat| ≥ 50°**, both hemispheres.

## Result (orbit 1973-02-01 02:23)
| Step | Pixels left | Share |
|---|---|---|
| all | 131 898 | 100 % |
| after Eq. 1 | 121 066 | 91.8 % |
| + scan positions 5–74 | 108 844 | 82.5 % |
| + \|lat\| ≥ 50° | 52 705 | 40.0 % |

## Decisions and reasons
- **Filtered field instead of own Eq. 1–4:** the file already contains it; Tonboe confirmed. A newer paper (Tellefsen et al. 2026) uses a less aggressive filter, but it is too complex to implement here → mention as limitation/outlook.
- **Swath edges:** the paper removes positions 1–4 and 75–78; large angles have long atmospheric path and footprint distortion (→ check in Task 3 whether more angles should go).
- **|lat| ≥ 50°:** Tonboe: low latitudes are not of interest for sea ice and dropping them reduces the data volume. Note: Table 2 of the paper uses 32° N / −48° S; ours is stricter.

## For the report
- One table of the filter chain with the remaining fraction (above).
- Globe figure (interactive page, step slider) shows clearly what each step removes → good for the seminar.

## Open
- Eq. 2–4 of the paper (further quality filters) not implemented; only if Tonboe asks for them.
