# A4e – Tie-point outlier test (2026-11-23) – tried, NOT used

**Decision (Jo, 2026-11-23): not used.** The 3 σ_robust test cuts too much of the natural spread of the clusters:
the σ of the tie-point clusters goes down mostly because pixels at the tails are dropped, not because the SIC gets
better, and it removes real weather (raw TB) or rain/cloud-water pixels (corrected TB) together with the
artefacts. Default `tp_opt` `tb_mad = 0`; the code stays as an option (`tp_outlier.m`, `correct_day.m`).
The 7 Feb offset block stays in the data and is described in the report as a known artefact of the
preprocessing (Eq. 2 limit 50 K, jump 32 K): it lowers that day's Arctic T_p,water by about 0.5 K; SIC map not
affected (clipped to 0).

Scripts: `src/matlab/tp_outlier.m` (the test), `correct_day.m` (applies it), `a4e_tp_outliers.m` (evaluation)
→ `output/A4e_tp_outliers.csv` (test on the corrected TB, used), `output/A4e_tp_outliers_rawTB.csv` (first try on the
raw TB, not used). Setting: `tp_opt` field `tb_mad` (0 = off, the default; the evaluation used 3).

## Why

7 Feb 1973, orbit 08:30 UTC, scan lines 1456–1462 (Norwegian Sea, 67° N): a block of 5–7 scan lines is offset by
about −30 K (TB ≈ 111 K instead of ≈ 141 K). Line 1463 has a spike (337 K).
- Eq. 3 removes the spike line and ±1 line (1461–1466). Eq. 2 misses the block: the row-mean jump is 32 K, the
  limit is 50 K.
- Lowering the Eq. 2 limit to 20 K finds the block, but our block logic then also removes the 13 good lines on
  the other side of the jump (a small data gap before them counts as a block boundary); 0.04 % of all pixels.
- A line-offset test against a running median along track (31 lines, > 15 K) flags > 1000 lines, almost all real
  ice edges and coasts in the Antarctic. Not usable.
- For the SIC map the block does not matter (SIC < 0, clipped to 0). But it lies in the water tie-point cluster:
  254 of 15 915 Arctic water pixels of that day, T_p,water −0.46 K, cluster TB std 5.85 → 6.86 K.

So the preprocessing stays as it is and the tie points are protected instead. The 7 Feb block is a known artefact
(report: one sentence + the globe picture).

## The test

Per day, hemisphere and cluster (water, ice): after iteration 1, pixels whose **corrected** TB (TB + ΔTB of
iteration 1) is more than 3 σ_robust from the cluster median are taken out of the cluster. σ_robust = 1.4826 · MAD
(= std for normal data; the outliers do not widen the limit themselves). Iteration 2 (reference means Mw/Mi and
tie points) uses the cleaned clusters. Not in the paper.

Why the corrected TB: the first try on the raw TB removed mostly real weather. The removed water pixels were
almost all on the warm side (N 5244 of 5911, S 42 018 of 43 395) and had much more wind and water vapour
(S: V 18.6 vs 9.4 kg/m², W 11.4 vs 8.7 m/s), i.e. storms and wet air masses, the case the RTM correction is made
for (and meeting point 8, low-pressure systems). On the corrected TB the wind/vapour signal is mostly removed,
so what is left as an outlier is what the correction cannot explain: artefacts, and rain/cloud liquid water
(L is not corrected, B1i).

## What it removes (Feb 1973, 27 days, 28 Feb left out: 1 orbit)

| | water out | of which low / high | ice out | limits water (corr. TB) | limits ice |
|---|---|---|---|---|---|
| N | 5 199 of 571 007 (0.91 %, ≈ 190 / day) | 1 197 / 4 002 | 5 803 of 1 529 551 (0.38 %) | 126.8–158.7 K | 193.8–257.5 K |
| S | 28 786 of 2 098 765 (1.37 %, ≈ 1 070 / day) | 8 512 / 20 274 | 0 of 201 711 | 121.4–152.5 K | 147.9–272.9 K |

(low / high = below / above the cluster median of the final corrected TB.)

Removed water pixels vs the kept ones: N wind 12.6 vs 10.6 m/s, vapour 7.7 vs 7.0 kg/m² (nearly normal weather);
S wind 9.8 vs 8.8 m/s, vapour 14.2 vs 9.5 kg/m² (wetter: rain/cloud water that the correction does not cover).
Ice: N removes mostly the cold side (5 741 of 5 803, very low TB inside the 80 % SIC box, e.g. multi-year ice or
thin-ice/lead mixtures); S removes nothing (the Antarctic ice cluster is very wide, σ ≈ 22 % SIC, so 3 σ_robust
spans 148–273 K).

7 Feb, N: 356 water pixels out (264 low: the offset block), T_p,water 139.14 → 139.46 K, σ water SIC 7.26 → 5.88 %.

## Do we lose noise?

Mean of the daily values, iteration 2, with / without the test:

| | T_p,water | T_p,ice | σ water SIC | σ ice SIC |
|---|---|---|---|---|
| N | 142.86 → 142.75 K | 226.23 → 226.35 K | 6.52 → 6.07 % | 10.58 → 10.20 % |
| S | 137.03 → 136.86 K | 212.30 → 212.29 K | 7.37 → 6.77 % | 22.60 → 22.56 % |

- Yes, the σ over the tie-point clusters goes down (water −0.45 / −0.60 points). Part of this is by construction
  (σ is computed over the kept pixels), so it is not a proof that the SIC is better.
- What changes the SIC map is the tie points: on average they move by only 0.1–0.2 K (< 0.3 % SIC). On single days
  with artefacts they move more (largest daily change of T_p,water 0.5 K; largest σ drop 2.5 points, 10 Feb N;
  7 Feb N 1.4 points).
- So: on normal days the test changes almost nothing; on days with artefacts it keeps them out of the tie points.
  That is the purpose.

## Globe

With `tb_mad = 0` the criterion is hidden. When it is on: step 2 gets a new last criterion for water and ice, "corrected T_B within median ± 3·σ_robust" (bits 11/12 of the day
file, v5). 7 Feb: the offset block shows in red. The comparison button now compares with the **20 Nov** masks
(SST 275 K, no outlier test): green = new water from SST 273 K, red = dropped (outliers).
