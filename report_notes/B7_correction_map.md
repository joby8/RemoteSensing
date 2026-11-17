# B7 Where is the correction largest? (Tonboe, meeting 2026-11-17)

**Question (meeting 2026-11-17):** "Geo-correction: where is it largest? Which regions are affected by the correction?"

## What we did
- Script: `src/matlab/b7_correction_map.m`, run time about 75 s for 1–27 Feb 1973 (28 Feb left out: only 1 orbit).
- Per day, `correct_day.m` runs the A6b method (2 iterations) on **all** ocean pixels with |lat| ≥ 50°. The tie-point masks are the new ones from `tp_masks.m`: water siconc ≤ 0.01, ice 180 K < T_B < 274 K, lsm == 0.
- Per pixel:
  - SIC_u is computed with the day's uncorrected tie points.
  - SIC_c is computed with the corrected T_B and the corrected tie points.
  - ΔSIC = SIC_c − SIC_u.
  - The share of each input (V, W, Ts, Ti) is that input's part of ΔT_B divided by the tie-point contrast. L is not corrected.
- Pixels go onto a 50 km polar grid (azimuthal equidistant), averaged over the month. Cells with fewer than 20 pixels are left blank. Land comes from ERA5 `lsm` (> 0.5, shown grey; MATLAB has no `coastlines` without the Mapping Toolbox).
- Figure `output/B7_correction_map.png`: Arctic top, Antarctic bottom. Columns: mean ΔSIC, std of ΔSIC over the month, input with the largest mean share.
- Numbers: `output/B7_regions.csv`, grouped by class (open water c = 0, ice edge 0 < c < 0.8, ice c ≥ 0.8) × latitude band and × sector. Grid: `output/B7_grid.mat`.

## Results (1–27 Feb 1973, mean SIC in %)

**Open water: the correction removes a negative bias that grows towards the ice.**

| | lat band | SIC_u | SIC_c | ΔSIC | share V / W / Ts |
|---|---|---|---|---|---|
| Arctic | 50–60 | −2.3 | −1.4 | +0.9 | +1.0 / +0.7 / −0.6 |
| Arctic | 60–70 | −1.9 | +1.2 | +3.0 | +3.4 / +0.4 / −0.6 |
| Arctic | ≥ 70 | −2.8 | +2.4 | +5.2 | +5.7 / +1.1 / −1.3 |
| Antarctic | 50–60 | −3.7 | −1.2 | +2.5 | +2.6 / +0.6 / −0.6 |
| Antarctic | 60–70 | −7.1 | +1.4 | +8.5 | +8.0 / +2.5 / −1.6 |
| Antarctic | ≥ 70 | −4.3 | +6.8 | +11.1 | +10.9 / +3.4 / −2.4 |

- The water tie point comes from the warm, moist water (SST > 278 K). Open water closer to the ice is colder and **drier** (lower V), so its T_B is low and its uncorrected SIC is negative (down to −7 % in the Antarctic 60–70° band).
- The correction raises T_B there. **Water vapour V explains most of it**, wind adds 0.4–3.4 % and Ts works slightly against it (−0.6 to −2.4 %).
- Largest change: the **Southern Ocean ring at 60–70° S** (+8.5 %) and the coastal water ≥ 70° S (+11 %).
- At ≥ 70° S the correction **overshoots** (SIC −4.3 → +6.8 %). Our reading:
  - this coastal water lies far from the reference water in V;
  - it is also close to summer melt (meeting note 7).
- Equatorward of about 55° (the outer ring of the maps) ΔSIC turns slightly negative: that water is moister than the reference.
- **Wind dominates** in narrow bands, which we read as the storm tracks:
  - Arctic: the North Pacific / Gulf of Alaska and the Labrador Sea / south of Greenland;
  - Antarctic: the outer edge at about 50–55° S.
- The month-long std of ΔSIC is largest at the outer edge (7–8 %, in both hemispheres), where storms change V and W from day to day. Std is 4–6 % in the Nordic Seas and Barents Sea.

**Ice: small correction, driven by ice temperature Ti.**
- Central Arctic (≥ 70° N, c ≥ 0.8): ΔSIC +0.2 %, mean |ΔSIC| 2.4 %, std < 2 %.
- Marginal Arctic ice at 50–60° N (Okhotsk, Bering, Baffin, Hudson): ΔSIC −5.3 %, of which −4.4 % comes from Ti. Here t2m is warmer than the ice-cluster mean, so Ti is warmer and the uncorrected SIC is too high.
- Antarctic ice ≥ 70° S: ΔSIC +0.5 %, Ti +1.0 %.
- Weddell Sea pack (Ti dominates, mean ΔSIC ≈ −1 … 0 %): the smallest correction of all regions (std < 2 %).

**Ice edge (0 < c < 0.8):** a mix of the two.
- Antarctic: ΔSIC +4 to +5 % (V +3.6 to +4.6 %).
- Arctic: −3.5 to +1.7 %, with V and Ti partly cancelling (−3.6 before the preprocessing default of 2026-11-17).

## For the report
- Answer to Tonboe: **the correction is largest over open water near the ice edge and in the Southern Ocean**, mostly through water vapour. It is smallest over the consolidated pack ice, where Ti drives a correction of only a few %.
- Discussion links:
  - The water tie point stands for warm (SST > 278 K) water, so cold water near the ice gets the largest V correction.
  - The overshoot at ≥ 70° S fits the Antarctic summer problem (meeting note 7): melt and humid air near the coast.
  - Wind matters regionally (storm tracks) even though V dominates on average.
- Figure: `output/B7_correction_map.png`, as is or with only the first and third columns for a narrower version.
