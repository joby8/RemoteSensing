# C3 One low-pressure system as an example (Tonboe, meeting 2026-11-20, point 8)

**Question (meeting 2026-11-20):** "Look at concrete data, look at low-pressure systems." Not a study over the
month, only one example that shows what the correction does in a storm over open water.

## What we did
- Choosing the case: for every swath file, the lowest ERA5 `msl` over open water (siconc ≤ 0.01, |lat| ≥ 55°).
  The deepest Arctic low of Feb 1973 is **11–14 Feb in the Norwegian Sea / Greenland Sea**: 945 → 941 → 950 → 957 hPa,
  close to the ice edge. Antarctic candidates (not used): 7–8 Feb Amundsen/Bellingshausen Sea (941–945 hPa),
  20 and 27 Feb (940–943 hPa).
- Script `src/matlab/c3_low_case.m` (about 25 s): `correct_day.m` for 12 Feb (A6b method, 2 iterations, the day's tie
  points). Of the 5 orbits that see the core, the one with the core closest to nadir is used: **08:19 UTC, scan
  position 34**, core 941.9 hPa at 67.4° N 4.5° W. One orbit, so all fields are at the same time.
- SIC is raw (not clipped), as B7: SIC_u with the day's uncorrected tie points, SIC_c with corrected TB and corrected tie points.
- Open water for the numbers and panel (d) = the water tie-point mask of Task 1 (`tp_masks.m`). With ERA5
  siconc ≤ 0.01 alone, coast and ice-edge pixels dominate far from the core (up to +40 % SIC).
- Figures:
  - `output/C3_low_map.png`, 3000 km window, isobars every 8 hPa, ERA5 ice edge in red.
    - top: msl, W, V, L
    - bottom: SIC uncorrected, SIC corrected, ΔSIC, wind part of ΔSIC
  - `output/C3_low_transect.png`, a cut along track through the core:
    - (a) msl, W, V, L
    - (b) SIC uncorrected / corrected / ERA5
    - (c) part of each input in ΔSIC
    - (d) open-water SIC vs. distance from the core
- Numbers: `output/C3_low_numbers.csv`.

## What the example shows
- **Structure of the low (ERA5):**
  - Calm core: W ≈ 2–3 m/s at the centre.
  - A ring of strong wind, up to 25 m/s on the north side along the ice edge.
  - A spiral cloud band (L up to 0.7 kg/m², V ≈ 10 kg/m²) that wraps around the core into the ice edge. This is the front / occlusion.
- **Wind correction depends on the place in the low.**
  - In the calm core the wind is far below the reference wind, so TB is too low and the uncorrected SIC is negative (≈ −10 %). The W part raises it by about +5 %.
  - Under the strong-wind ring the W part is negative (−3 %).
  - So one low gives a correction of both signs within a few hundred km (transect panel c).
- **Water-vapour correction is largest in the cloud band.**
  - Inside the band the V part is −4.9 % SIC on average.
  - Uncorrected mean SIC +3.7 % → corrected −2.3 %. Std 7.1 → 6.5 %.
- **Cloud liquid L is not corrected (B1i).** We expected a positive rest in the cloud band. In this case the mean is slightly negative instead. Possible reasons:
  - V and L are correlated, and the V correction already takes out part of the cloud signal.
  - ERA5 puts the band slightly in the wrong place.
  - The std in the band stays the highest of the groups (6.45 %).
- **Noise over open water** (water tie-point mask, this orbit):

| open water | n | msl | W | V | L | SIC_u mean / std | SIC_c mean / std |
|---|---|---|---|---|---|---|---|
| within 600 km of the core | 1306 | 955 | 13.3 | 5.8 | 0.13 | −0.9 / 6.5 | −1.3 / 5.5 |
| rest of the orbit (Arctic) | 1603 | 972 | 14.1 | 7.1 | 0.25 | +1.4 / 7.3 | −0.5 / 6.3 |
| cloud band L > 0.3 | 488 | 966 | 15.8 | 10.0 | 0.72 | +3.7 / 7.1 | −2.3 / 6.5 |
| clear L < 0.1 | 1535 | 963 | 12.8 | 5.5 | 0.05 | −0.8 / 6.5 | −0.5 / 5.7 |

  The correction lowers the std in every group by 0.6–1.1 points (−9 to −16 %). That is about the same gain as in Task 1. The low is not a special failure case for the correction, but it is also not removed completely.
- **Near the ice edge:**
  - The Ti part (−5 to −8 %) dominates in the first 300 km of ice behind the edge (transect c).
  - The strong wind plus the cloud band right at the edge are where false ice is most likely.
  - ESMR and ERA5 put the edge 50–100 km apart (transect b).

## For the report / seminar
- One figure (the map) plus 1–2 sentences per point above.
- Message: in a storm the noise sources change on a scale of 100s of km.
  - The RTM correction follows W and V there: positive in the calm core, negative under the wind ring.
  - The rest comes from the cloud band (L), which is not corrected.
- Link to Task 4 (B4): L as the next variable to correct, or flag pixels with high ERA5 L.
- Limits: one orbit, one case; ERA5 position errors of the front are possible.

## Map version 2026-11-23 (after Jo: "on the SIC maps you see almost nothing")
- With the raw SIC (−20…60 %, then ±15 %) the two maps looked the same. Reason: the correction is ±2–5 % per
  pixel, but the pixel noise is ≈ 6 % std, so a narrower colour scale only makes the noise louder.
- Now the SIC panels show a 3 × 3-pixel mean (≈ 75 km) over open water (ERA5 siconc ≤ 0.15), scale ±8 %. ΔSIC and the
  wind part stay per pixel.
- What the smoothed maps show: the large structures stay after the correction.
  - The negative ring around the calm core.
  - The negative band in the south-west.
  - The positive band along the ice edge.
  - Only their strength changes a little.
  So most of the visible pattern is **not** explained by W and V in the RTM. Candidates:
  - the cloud band (L, not corrected);
  - ice-edge spill-over (the red band follows the ERA5 edge);
  - ERA5 position errors.
  Message for the report: the correction removes part of the weather signal (std −15 % in the low), the
  structures that remain are what it cannot see.

### Spill-over test (same day)
- Smoothed SIC first over ERA5 siconc ≤ 0.01: the red band along the ice edge and the coasts stayed. So it is
  **not** from the pixels with 1–15 % ERA5 ice.
- Then over the water tie-point mask (`o.mw`, 5 × 5 box keeps ice and land ≥ 2 pixels away): the band along the
  coasts and most of the ice edge is **gone**.
  → It was spill-over from the large ESMR footprint (ice/land in the neighbouring pixel).
  → The map now uses this mask. This is also why Task 1 uses the 5 × 5 box.
- On this map the correction is visible:
  - The positive patches weaken with the correction:
    - the arc west of the core (strong wind + cloud band);
    - the band in the south-west;
    - the patches in the south-east.
  - The negative ring around the calm core and the negative band in the south-west stay almost unchanged.
  - The red patch in the north-east (Barents Sea, at the end of the cloud band) stays.
