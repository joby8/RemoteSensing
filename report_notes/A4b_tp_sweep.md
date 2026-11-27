# A4b – Tie-point mask thresholds (sweep, 2026-11-20)

Script: `src/matlab/a4b_tp_sweep.m` → `output/A4b_tp_sweep.csv`, `output/A4b_tp_sweep_mean.csv`.
Reason: meeting 2026-11-20 (more water tie-point pixels, but cold water; less land spill-over), see `meeting_2026-11-20.md`.

Setup: days 0201, 0208, 0215, 0222 (Feb 1973), full correction (`correct_day.m`, 2 iterations, c clipped to 0..1,
no 15 % filter). Varied in `tp_masks.m`: water `sst > sst_min` (278/277/276/275 K), water `|lat| > wlat_min` (0/55°),
both `lsm <= lsm_max` (0/0.10/0.15). Mean over the 4 days.

| Hemi | Variant | n water | n ice | mean SST water [K] | Tp,water corr [K] | std SIC water corr [%] |
|---|---|---|---|---|---|---|
| N | 278, –, lsm 0 (current) | 16 609 | 60 145 | 280.4 | 142.2 | 6.48 |
| N | 275, –, lsm 0 | 29 992 | 60 145 | 278.7 | 141.6 | 6.33 |
| N | 275, >55°, lsm 0 | 18 863 | 60 145 | 278.7 | 141.7 | 6.14 |
| N | 275, >55°, lsm 0.10 | 19 984 | 68 422 | 278.7 | 141.9 | 6.65 |
| N | 275, >55°, lsm 0.15 | 20 158 | 70 038 | 278.7 | 142.0 | 6.83 |
| S | 278, –, lsm 0 (current) | 36 260 | 7 813 | 280.5 | 140.3 | 8.81 |
| S | 275, –, lsm 0 | 76 782 | 7 813 | 278.3 | 139.2 | 8.41 |
| S | 275, >55°, lsm 0 | 41 923 | 7 813 | 277.4 | 138.5 | 7.98 |
| S | 275, >55°, lsm 0.10 | 42 042 | 8 533 | 277.4 | 138.5 | 8.05 |
| S | 275, >55°, lsm 0.15 | 42 056 | 8 638 | 277.4 | 138.5 | 8.07 |

Findings
- **sst_min 278 → 275 K**: about 2× more water pixels (N 1.8×, S 2.1×), cluster 1.7–2.2 K colder, Tp,water 0.6–1.1 K
  lower, water SIC std lower (N 6.48 → 6.33 %, S 8.81 → 8.41 %). Clear improvement.
- **|lat| > 55°** (on top of 275 K): fewer water pixels again (N −37 %, S −45 %, back to about the current number), colder
  in the south (−1 K), lowest water std of all variants (N 6.14 %, S 7.98 %).
- **lsm_max 0 → 0.10**: mostly more *ice* pixels (N +14 %, S +9 %); water pixels +1–6 %. In the north the water std
  rises (6.14 → 6.65 %) and Tp,water by 0.2 K: land spill-over is visible. 0.15 adds almost nothing over 0.10 and
  raises the std further. Ice std almost unchanged.
- Ice tie point and ice std hardly depend on any of the three.

## A4c – land rule (2026-11-20, correction)

The lsm ≤ 0.10 variant above was a misreading of the meeting: it is LOOSER than lsm = 0 (it lets pixels whose ERA5
cell is up to 10 % land into the clusters), so it ADDED coastal pixels. The goal from the meeting is the opposite:
keep more land influence (spill-over) out of the tie points. The pixel's own lsm cannot be stricter than 0, but land
spill-over comes from land NEXT to the pixel inside the large ESMR footprint. So the stricter rule also tests the
land fraction in a box around the pixel (like the 5 × 5 siconc box): the "10–15 %" of the meeting notes is the
allowed land fraction in that neighbourhood.

Script: `src/matlab/a4c_land_sweep.m` → `output/A4c_land_sweep.csv`, `A4c_land_sweep_mean.csv`. Same 4 days,
water sst > 275 K and |lat| > 55° fixed. Box = scan lines × scan positions, centred, mean ERA5 lsm.

| Land rule (both clusters) | N n ice | N T_p,ice [K] | N σ ice [%] | N n water | N σ water [%] | S n ice | S T_p,ice [K] | S σ water [%] |
|---|---|---|---|---|---|---|---|---|
| pixel lsm = 0 (17 Nov) | 60 145 | 225.95 | 10.33 | 18 863 | 6.14 | 7 813 | 213.57 | 7.98 |
| pixel lsm ≤ 0.10 (looser) | 68 422 | 226.31 | 10.40 | 19 984 | 6.65 | 8 533 | 213.04 | 8.05 |
| + 3×3 box land ≤ 10 % | 59 135 | 225.88 | 10.31 | 18 742 | 6.06 | 7 679 | 213.66 | 7.97 |
| + 3×3 box no land | 50 421 | 225.05 | 10.13 | 17 204 | 6.11 | 6 690 | 214.10 | 7.92 |
| + 5×5 box land ≤ 15 % | 58 000 | 225.80 | 10.28 | 18 586 | 6.05 | 7 516 | 213.65 | 7.97 |
| **+ 5×5 box land ≤ 10 %** | 56 532 | 225.71 | 10.25 | 18 362 | 6.04 | 7 311 | 213.72 | 7.96 |
| + 5×5 box no land | 43 950 | 224.09 | 9.83 | 15 662 | 6.19 | 5 735 | 214.42 | 7.89 |

Reading:
- Loosening (pixel lsm ≤ 0.10) makes everything worse in the Arctic: water σ +0.5 points, ice σ up, T_p,ice +0.4 K
  (warm land in the footprint raises T_B). This confirms the spill-over.
- The box rules work in the right direction: the stricter the rule, the lower the Arctic ice tie point and ice σ.
  Removed coastal pixels are warmer than the rest of the ice cluster, i.e. land spill-over.
- Water clusters hardly change (open water with SST > 275 K and |lat| > 55° is mostly far from land).
- "No land in 5×5" removes 27 % of the ice pixels and moves T_p,ice (N) by −1.9 K: strongest effect, but it also
  removes a lot of real coastal ice (fast ice, the Canadian Archipelago, the Antarctic coast).

## A4d – SST limit 273 K (2026-11-23)

Script: `src/matlab/a4d_sst_sweep.m` → `output/A4d_sst_sweep.csv`, `_mean.csv`. Same 4 days, 20 Nov masks
(|lat| > 55°, 5 × 5 land box), only the water SST limit varies.

| Hemi | SST > | n water | mean SST water [K] | T_p,water corr [K] | σ water [%] | T_p,ice [K] |
|---|---|---|---|---|---|---|
| N | 275 K | 18 362 | 278.72 | 141.63 | 6.04 | 225.71 |
| N | 274 K | 20 320 | 278.31 | 141.65 | 6.12 | 225.70 |
| N | 273 K | 21 341 | 278.08 | 141.65 | 6.26 | 225.70 |
| S | 275 K | 41 911 | 277.35 | 138.48 | 7.96 | 213.72 |
| S | 274 K | 59 142 | 276.51 | 137.96 | 7.77 | 213.68 |
| S | 273 K | 76 853 | 275.84 | 137.44 | 7.62 | 213.64 |

Reading: in the Antarctic 273 K is clearly better (+83 % water pixels, 1.5 K colder, T_p,water −1 K, σ lower). In
the Arctic only +16 % pixels and 0.6 K colder, and σ rises slightly (+0.2 points): the added pixels near the ice
are a little noisier. Ice side unchanged.
**Decision (Jo, 2026-11-23): 273 K for both hemispheres** (Tonboe: as cold as possible). The small σ rise in the
Arctic goes into the report.

**Update 2026-11-24 (meeting with Tonboe): 272 K.** Reason: close to the freezing point of sea water (≈ 271.4 K
at S = 35). Not part of this 4-day sweep; full month with 272 K and all 78 scan positions (`rerun_2026-11-24.md`):
water pixels per day N 23 443, S 100 023; T_p,water corr N 142.65 K, S 136.53 K; σ water SIC corr N 6.76 %, S 8.04 %.
(The σ rise vs. 23 Nov comes mostly from the outer scan positions, not from the SST limit.)

## Decision (2026-11-20): new default masks (SST updated 2026-11-23 and 2026-11-24, see A4d)

| | water | ice |
|---|---|---|
| ERA5 SST | > 272 K (24 Nov, Tonboe; 23 Nov: 273 K, A4d; 20 Nov: 275 K; 17 Nov: 278 K) | – |
| latitude | \|lat\| > 55° (new) | \|lat\| ≥ 50° (preprocessing) |
| land | pixel lsm = 0 **and** ≤ 10 % land in the 5 × 5 box around the pixel (new) | same |

Set in `tp_opt.m` (used by `tp_masks.m`, `correct_day.m` and every script that builds tie points).
The earlier masks stay available as `tp_opt('nov20')` and `tp_opt('nov17')`; the globe compares with the 20 Nov masks (step 2).

Why:
1. **The water tie point must be cold open water** (Tonboe, meeting 2026-11-20). The RTM correction uses the water
   cluster as the reference weather and surface for water (Mw). Water that is too warm and too far from the ice is a
   poor reference for the water near the ice edge, where SIC matters. With 275 K and |lat| > 55° the water cluster is
   1.7 K (N) and 3.1 K (S) colder than with the 17 Nov masks (mean ERA5 SST 278.7 / 277.4 K instead of 280.4 / 280.5 K).
2. **The water SIC is less noisy.** Std of the corrected SIC over the water cluster: N 6.48 → 6.04 %, S 8.81 → 7.96 %.
   Of the 24 SST/latitude variants of A4b, 275 K + |lat| > 55° has the lowest σ in both hemispheres.
3. **Enough pixels.** Lowering the SST limit alone doubles the water cluster, but mostly with warmer water at lower
   latitude. The latitude limit removes that part again; the cluster ends up a bit larger than before (N 16.6k → 18.4k,
   S 36.3k → 41.9k pixels per day), so the tie point is not noisier.
4. **No tie points next to land** (Tonboe: "allow land fraction 10–15 %", meant for the surroundings of a pixel). The
   5 × 5 box with ≤ 10 % land removes the coastal ice pixels with spill-over: N ice σ 10.33 → 10.25 %, T_p,ice
   225.95 → 225.71 K, at a cost of 6 % (N) / 6 % (S) of the ice pixels. 15 % keeps a few more pixels with nearly the
   same numbers; "no land in the box" is stricter but removes 27 % of the ice cluster, including real coastal ice.
5. The ice tie point changes by less than 0.3 K (N) and 0.2 K (S) compared with the 17 Nov masks, so the ice side
   of SIC stays as it was.

To check in the globe (step 2, "Compare with 17 Nov masks"): new water (green) should be cold water close to the
ice, dropped water (red) south of 55°; dropped ice (pink) should sit along the coasts.

Next: rerun A6b/B1/B2/B7/C1/C2 with the new masks and the new clipping (meeting 2026-11-20, point 4).
