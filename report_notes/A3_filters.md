# A3 – Filters

**Report section:** Method → preprocessing **Code:** `src/matlab/a3_filter.m` (same rules are repeated inline in `a4_mask.m`, `a5_sic.m`, `globe_html.m`) **Figures:** `output/A3_tb_filtered.png`, `output/globe_A3_tb_N.png` / `_S.png`; interactive: `output/globe/ESMR_globe.html` (slider "Preprocessing", steps 0–4) **Status:** done 2026-11-13

## Goal

Remove pixels that are physically implausible or not useful before computing tie points and SIC.

## What we did (in this order)

1. **Eq. 1: 90 K &lt; T_B ≤ 273.15 K.** Already applied in `brightness_temperature_filtered`; we use that field (Tonboe: use the filtered field).
2. **Swath edges: drop scan positions 1–4 and 75–78.** Removes the largest incidence angles; the kept swath is **θ = ±55.67°**.
3. **High latitudes only: |lat| ≥ 50°**, both hemispheres.

## Result (orbit 1973-02-01 02:23)

| Step | Pixels left | Share |
| --- | --- | --- |
| all | 131 898 | 100 % |
| after Eq. 1 | 121 066 | 91.8 % |
| \+ scan positions 5–74 | 108 844 | 82.5 % |
| \+ |lat| ≥ 50° | 52 705 | 40.0 % |

## Decisions and reasons

- **Filtered field instead of own Eq. 1–4:** the file already contains it; Tonboe confirmed. A newer paper (Tellefsen et al. 2026) uses a less aggressive filter, but it is too complex to implement here → mention as limitation/outlook.
- **Swath edges:** the paper removes positions 1–4 and 75–78; large angles have long atmospheric path and footprint distortion (→ check in Task 3 whether more angles should go).
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