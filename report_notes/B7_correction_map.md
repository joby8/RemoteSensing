# B7 Where is the correction largest? (Tonboe, meeting 2026-11-17)

**Question (meeting 2026-11-17):** "Geo-correction: where is it largest? Which regions are affected by the correction?"

## What we did
- Script: `src/matlab/b7_correction_map.m`, run time about 75 s for 1–27 Feb 1973 (28 Feb left out: only 1 orbit).
- Per day, `correct_day.m` runs the A6b method (2 iterations) on **all** ocean pixels with |lat| ≥ 50° and all 78 scan positions. Tie-point masks as A6b (state 2026-11-24: water siconc ≤ 0.01, SST > 272 K, |lat| > 55°; ice siconc > 0.8, 180 K < T_B < 274 K; lsm = 0 and ≤ 10 % land in the 5 × 5 box).
- Per pixel:
  - SIC_u is computed with the day's uncorrected tie points.
  - SIC_c is computed with the corrected T_B and the corrected tie points.
  - ΔSIC = SIC_c − SIC_u.
  - The share of each input (V, W, Ts, Ti) is that input's part of ΔT_B divided by the tie-point contrast. L is not corrected.
- Pixels go onto a 50 km polar grid (azimuthal equidistant), averaged over the month with every day weighted the same (per cell daily mean first, then mean over the days; since 2026-11-20). The std map is the day-weighted std of the pixel ΔSIC. The regional numbers are also first averaged per day and group, then over the days. Cells with fewer than 20 pixels are left blank. Land comes from ERA5 `lsm` (> 0.5, shown grey; MATLAB has no `coastlines` without the Mapping Toolbox).
- Figure `output/B7_correction_map.png`: Arctic top, Antarctic bottom. Columns: mean ΔSIC, std of ΔSIC over the month, input with the largest mean share.
- Numbers: `output/B7_regions.csv`, grouped by class (open water c = 0, ice edge 0 < c < 0.8, ice c ≥ 0.8) × latitude band and × sector. Grid: `output/B7_grid.mat`.

## Results (1–27 Feb 1973, mean SIC in %, state 2026-11-24, day-weighted, `B7_regions.csv`)

**Open water: the correction has both signs. It follows V, relative to the cold reference water.**

| | lat band | SIC_u | SIC_c | ΔSIC | share V / W / Ts |
|---|---|---|---|---|---|
| Arctic | 50–60 | −5.1 | −6.1 | −1.0 | −2.1 / +1.0 / −0.1 |
| Arctic | 60–70 | −6.2 | −4.7 | +1.5 | +0.4 / +1.1 / −0.1 |
| Arctic | ≥ 70 | −7.0 | −3.4 | +3.6 | +2.9 / +1.4 / −0.9 |
| Antarctic | 50–60 | −2.3 | −7.1 | −4.8 | −4.4 / −1.1 / +0.6 |
| Antarctic | 60–70 | −6.7 | −5.3 | +1.5 | +1.2 / +0.5 / −0.4 |
| Antarctic | ≥ 70 | −7.3 | −2.2 | +5.2 | +4.5 / +1.9 / −1.2 |

(Open water here = all ERA5 ocean pixels with c = 0, not only the tie-point cluster; the band means are therefore
not 0. They include water that the tie-point mask excludes: 50–55°, SST ≤ 272 K, next to the coast.)

- The water tie point (reference weather) is now **cold, high-latitude water** (SST > 272 K, |lat| > 55°).
  - **Near the ice (≥ 70°, Antarctic coast, Arctic marginal seas)** the water is colder and drier than the reference,
    T_B is low and SIC_u negative (−7 %). The correction raises it: +3.6 % (N), +5.2 % (S), mostly V, plus W.
  - **Further out (50–60°)** the water is warmer and moister than the reference, so the correction lowers T_B and the
    SIC: −1.0 % (N), **−4.8 % (S, the largest change of all open-water bands)**, again mostly V.
  - The map shows this as a red ring around Antarctica (60–70° S, near the ice edge) and a blue outer ring
    (50–55° S); in the Arctic red over the water close to the ice edge, blue over the open North Atlantic and North Pacific.
- **The corrected SIC is not flat:** the mean stays −2 to −7 % in every band. The correction moves each band
  toward the reference, but a bias remains that the RTM inputs do not explain (L, spill-over near coasts and ice, ERA5).
- **Wind dominates** in narrow bands (right column of the map): North Pacific / Bering Sea and the North Atlantic
  south of Greenland and Iceland; Antarctic in a broken band along the ice edge and near the Antarctic Peninsula. Elsewhere V dominates.
- The month-long std of ΔSIC is largest at the outer edge of the maps (7–8 %, both hemispheres), where storms change V
  and W from day to day; 2–4 % over the Arctic Ocean pack ice and the Antarctic coastal ice.

**Ice: small correction, driven by ice temperature Ti.**
- Central Arctic (≥ 70° N, c ≥ 0.8): ΔSIC +0.1 %, Ti +0.6 %.
- Marginal Arctic ice at 50–60° N (Okhotsk, Bering, Baffin, Hudson): ΔSIC −5.3 %, of which −4.3 % is Ti; 60–70° N −2.5 %
  (Ti −1.8 %). There t2m is warmer than the ice-cluster mean, so Ti is warmer and the uncorrected SIC is too high (106 %).
- Antarctic ice ≥ 70° S: ΔSIC +0.8 % (Ti +0.9 %); 60–70° S −0.6 %. (50–60° S: −8.3 %, only ≈ 500 pixels.)

**Ice edge (0 < c < 0.8):** a mix of the two.
- Arctic: −2.8 % (50–60°, V −1.9) → −0.6 % → +2.0 % (≥ 70°, V +2.0).
- Antarctic: −3.5 % (50–60°, V −3.0) → +2.3 % (60–70°) → +3.0 % (≥ 70°, V +2.5).

## For the report
- Answer to Tonboe: **over open water the correction is a few % SIC and has both signs**: positive over cold, dry water
  near the ice, negative over warmer, moister water further out (largest −4.8 % at 50–60° S). Mostly water vapour;
  wind in bands along the storm tracks and the ice edge. **Over consolidated pack ice it is smallest** (< 1 %), driven by Ti;
  at the marginal Arctic ice Ti lowers the SIC by up to 5 %.
- Discussion links:
  - The sign depends on the reference: the water tie point is cold high-latitude water (272 K), so everything warmer
    is corrected down. With the 17 Nov masks (278 K) the reference was warm water and the correction was positive almost everywhere.
  - Wind matters regionally (storm tracks), even though V dominates on average (link B1c: in the Arctic tie-point
    cluster W even ranks first).
  - The remaining negative bias of the corrected SIC outside the tie-point cluster → limitation (L, spill-over).
- Figure: `output/B7_correction_map.png`, as is or with only the first and third columns for a narrower version.

## History
- 2026-11-17 (first version, SST > 278 K): open water ΔSIC positive everywhere (+0.9 to +11 %, largest at
  60–70° S +8.5 % and ≥ 70° S +11 %), because the warm reference made all colder water look too "dry".
- 2026-11-20: every day gets the same weight (before: pooled pixels); changes ≤ 0.2 points.
- 2026-11-23 (273 K): already the pattern above (50–60° S −3.9 %); 2026-11-24 changes < 0.2 points except
  Antarctic open water 50–60° S (−3.9 → −4.8 %) and the ice edge there (−3.0 → −3.5 %).
