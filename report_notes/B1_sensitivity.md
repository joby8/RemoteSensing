# B1 – RTM sensitivity study (Task 2)

**Report section:** Results → Task 2 (which ERA5 parameters matter); figure also supports Task 3 (angle dependence)
**Code:** `src/matlab/b1_sensitivity.m` (needs `output/A6b_pixels.mat` from `a6b_iterative.m`; runs in seconds)
**Output:** `output/B1_sensitivity.png`, `output/B1_sensitivity.csv` (ΔT_B per unit and per +1σ at θ = 0/30/50/55.5°)
**Tornado:** `src/matlab/b1b_tornado.m` → `output/B1_tornado.png`, `output/B1_tornado.csv` (±1σ at θ = 50°, in % SIC and K)
**Sweep (model, full range):** `src/matlab/b1d_sweep.m` → `output/B1d_sweep.png`, `output/B1d_sweep.csv` (see section below)
**Exclusion test (data):** `src/matlab/b1c_exclusion.m` → `output/B1c_exclusion.png`, `output/B1c_exclusion.csv` (see section below)
**L study:** `src/matlab/b1i_L_study.m` → `output/B1i_L_study.png`, `.csv` (details `B1i_L_study.md`, summary below)
**Status:** first version 2026-11-13 · **rerun 2026-11-17 with the new tie-point masks** (`tp_masks.m`: water siconc ≤ 0.01, ice 180 K < T_B < 274 K, ERA5 lsm = 0; Tonboe meeting 2026-11-17). All tables below are the new numbers; old-mask values only in brackets where useful.

## Agreed with Tonboe (session 2026-11-13, meeting 2026-11-17)
- Task 2 = **sensitivity study with the RTM**.
- 2026-11-17: he liked the sweep plots. Changes: grey = input range that is not really used (outside the observed 5–95 %), white = used range; **L = 0 in the V, W, Ts, Ti sweeps**, so L has no influence there. Plus an **L study** (mean L vs. per-pixel L in the 2nd iteration).
- He liked the animation in the learning page (`docs/learning/Kolbe_etal_essd-16-1247-2024_interaktiv.html`, Sect. 4): bars of ΔT_B per input while θ sweeps. Open question from him: **how to get it into the report?**

## Idea: the animation as one static figure
The animation has one moving parameter (θ). Put θ on the x axis and the whole animation fits into one line plot:
- **x:** incidence angle θ (0–64°), the removed swath edge (> 55.7°) shaded grey
- **y:** ΔT_B for a +1σ change of one input, everything else at the mean
- one line per input, left panel water (c_ice = 0), right panel ice (c_ice = 1)

Changes compared with the learning page:
- **Base state and perturbation come from our data**, not from fixed test values:
  - base state = mean conditions of the Feb 1973 tie-point clusters (A6b)
  - perturbation = the real 1σ of each input in those clusters
- So each curve is the T_B noise that this input really adds. That answers Task 2 directly and is better than a test perturbation.

Ways to keep the interactivity:
- **Report:** static figure + table (below). Optional appendix sentence with a link to the interactive page in the repo.
- **Seminar (4 Dec) and oral defence (15 Dec):** show the interactive page live for 30 s, after the static figure. The defence is what gets graded, so this is where the animation helps most.

## What we did
1. Load all tie-point pixels of Feb 1973 (without 28 Feb) from A6b. Water and ice clusters, both hemispheres pooled.
2. Mean and std of V, W, L, Ts, Ti per cluster.
3. RTM (`esmr_rtm_vec.m`) at the mean state for θ = 0…64°. Then once more with one input at mean + 1σ (and mean + 1 unit for the table).

## Result
**Water (c = 0)**, mean V = 12.8 kg/m², W = 10.6 m/s, L = 0.20 kg/m², Ts = 280.5 K:

| Input | 1σ | ΔT_B per +1σ at 0° / 30° / 50° | per unit at 50° |
|---|---|---|---|
| V | 6.3 kg/m² | 4.3 / 5.1 / **7.3 K** | 1.2 K per kg/m² |
| W | 4.0 m/s | 1.4 / 2.4 / **3.1 K** | 0.8 K per m/s |
| L (not corrected) | 0.32 kg/m² | 6.1 / 7.3 / **10.4 K** | 30 K per kg/m² |
| Ts | 1.6 K | −0.2 / −0.2 / −0.2 K | −0.12 K per K |

**Ice (c = 1)**, mean V = 2.6 kg/m², L = 0.05 kg/m², Ti = 263 K:

| Input | 1σ | ΔT_B per +1σ at 0° / 30° / 50° |
|---|---|---|
| Ti | 4.1 K | **3.7 / 3.7 / 3.5 K** |
| V | 2.1 kg/m² | 0.2 / 0.2 / 0.4 K |
| L | 0.11 kg/m² | 0.1 / 0.2 / 0.4 K |

W and Ts have no effect at c = 1.

## Interpretation (for the discussion)
- **Over water: V > W ≫ Ts.** Water vapour is the most important corrected input, wind is second, SST can be ignored (< 0.3 K).
- **Converted to SIC:** divide by the ice–water contrast (82 K in the North, 70 K in the South). At 50°, 1σ of V is about 9 % SIC, 1σ of W about 4 % SIC. That is the size of the noise we see.
- **L would be the largest term.** But the ERA5 L field does not match the 1973 clouds pixel by pixel, so correcting it adds noise (L study below; A6). This is why the paper does not correct L, and it is the main limitation of the method.
- **SST:** the 19 GHz channel is almost blind to SST (−0.2 K per σ); retrieving or correcting SST would need another, lower frequency (Tonboe 2026-11-17).
- **Everything over water grows with θ.** The path through the atmosphere scales with 1/cos θ, and the H-pol water emissivity falls with θ, so more sky is reflected. → Task 3: the noise should be largest at the swath edge.
- **Over ice only Ti matters** (≈ 3.5–3.7 K per 1σ, about 4.3 % SIC): "some improvement by ice temperature" (meeting 2026-11-17). It hardly depends on θ. The atmosphere is dry and the ice is a strong emitter, so the atmospheric terms are small. This makes Eq. 15 (and a possible ERA5 `istl1` alternative) the key choice for the ice side.

## Presentation ideas (brainstorm 2026-11-13)
Current figure = line plot ΔT_B vs. θ. Jo: wants more colour and easier to read, not only lines. Same numbers, other forms:
1. **Tornado chart** (standard in sensitivity studies): one horizontal bar per input, −1σ and +1σ around the mean state, sorted by size, one colour per input; water and ice panels at one angle (e.g. 50°). Ranking visible at once.
2. **Heatmap θ × input with numbers in the cells**: rows V, W, L, Ts (Ti), columns θ = 0, 10, …, 55°, colour = ΔT_B, value printed. Exact values + growth with θ, compact, prints well.
3. **Stacked area "noise budget" vs. θ**: each input contributes ΔT_B², sum = total weather noise. As 100 % stack it shows the share of each input; L appears as the large uncorrected part.
4. **Unit % SIC instead of K** (for all of them): divide by the ice–water contrast (≈ 82 K North) → "1σ water vapour ≈ 9 % SIC", readable without microwave background.
5. **Fixed colour per input in every figure** (V blue, W orange, L green + hatched/dashed = not corrected, Ts purple, Ti red), also for Task 2/3 figures and slides.

**Recommendation:** report = tornado (1) in % SIC (4) with fixed colours (5) as main figure + heatmap (2) for the θ dependence (together they replace the line plot). Seminar/discussion = noise budget (3) because it tells the L story in one picture. Decision pending (Jo).

## Tornado chart (built 2026-11-13, `b1b_tornado.m`)
Ideas 1 + 4 + 5 from above: one bar per input, −1σ (light) and +1σ (dark), sorted by size, water and ice panels, θ = 50°, fixed colours, L light + dashed = not corrected.
- **Unit % SIC:** ΔT_B divided by the ice–water contrast of the corrected A6b tie points (iteration 2, mean over days without 28 Feb): **N 82.0 K**, S 70.4 K (old masks: 81.3 / 60.2 K). Figure uses North → 1 % SIC = 0.82 K. (In the South the same ΔT_B is ~17 % more SIC, mention in text.)
- **−1σ is computed separately** (RTM is not linear), so the bars are not exactly symmetric. For L the −1σ value is clipped at 0 kg/m² (mean 0.20 − σ 0.32 < 0), so its −1σ bar is smaller (−8.3 % vs. +12.7 %).

| Water, θ = 50° | −1σ | +1σ |
|---|---|---|
| L (not corrected) | −8.3 % (−6.8 K) | +12.7 % (+10.4 K) |
| V | −9.3 % (−7.6 K) | +9.0 % (+7.3 K) |
| W | −4.1 % (−3.3 K) | +3.8 % (+3.1 K) |
| Ts | +0.2 % | −0.2 % |

| Ice, θ = 50° | −1σ | +1σ |
|---|---|---|
| Ti | −4.3 % (−3.5 K) | +4.3 % (+3.5 K) |
| V | −0.4 % | +0.5 % |
| L | −0.2 % | +0.5 % |

Caption idea: "RTM sensitivity at the mean Feb 1973 tie-point weather (θ = 50°). Each bar moves one input by ±1σ of its observed spread in the tie-point clusters, all others at the mean. Over water, V and the uncorrected L dominate; over ice, only the ice temperature matters."
Still open: heatmap (idea 2) for the θ dependence, noise budget (3) for the seminar.

## Exclusion test with the data (built 2026-11-16, `b1c_exclusion.m`)
This is the literal Task 2 wording: "evaluate by exclusion which ERA5 parameters are most important for the correction".
- **Method:**
  - Same correction as A6b iteration 2: reference values mixed by c_ice, L not corrected.
  - One input at a time (V, W, Ts, Ti) is **left out**: in the "actual" RTM run it gets its reference value, so it corrects nothing.
  - Then the corrected tie points, the SIC and the std per day and hemisphere are computed again. The table shows the mean over 1–27 Feb.
- **Check:** the case "all inputs" reproduces A6b exactly (max difference 0.0000 %), as does "no correction".
- Also computed: "only X" (correction with a single input), stored in the csv.

| std of SIC [%] (increase vs. full) | Arctic water | Arctic ice | Antarctic water | Antarctic ice |
|---|---|---|---|---|
| no RTM correction | 9.61 (+2.56) | 12.53 (+1.67) | 11.88 (+2.54) | 24.57 (+0.87) |
| **full correction (V, W, Ts, Ti)** | **7.05** | **10.86** | **9.34** | **23.70** |
| without V | 8.25 (**+1.20**) | 11.03 (+0.17) | 11.19 (**+1.85**) | 24.22 (+0.53) |
| without W | 8.45 (**+1.40**) | 10.85 (−0.02) | 9.90 (+0.57) | 23.79 (+0.09) |
| without Ts | 7.06 (+0.01) | 10.82 (−0.04) | 9.32 (−0.02) | 23.58 (−0.12) |
| without Ti | 7.13 (+0.08) | 12.37 (**+1.51**) | 9.43 (+0.09) | 24.04 (+0.34) |

(Old masks, full correction: 8.15 / 13.02 / 10.97 / 40.50.)

**Interpretation**
- **Water: V and W are the inputs that matter.**
  - In the Arctic both are about equal, W slightly ahead (+1.4 / +1.2 %; old masks: V +1.18, W +1.14).
  - In the Antarctic, V clearly dominates (+1.9 vs. +0.6 %).
  - This confirms the RTM ranking V, W ≫ Ts with real pixels.
- **Ts brings nothing.** Leaving it out changes the std by ≤ 0.01 % on water and is slightly better on ice (SST under ice is a fixed value, 271.46 K). → Task 4: the correction can drop Ts.
- **Ti matters only on the ice side**, most in the Arctic (+1.5 %). This matches the sensitivity study: over ice only Ti matters.
- **Antarctic ice:** with the old masks it reacted to V (+3.0 %), a sign of ocean pixels in the ice cluster. With the 180 K limit this is gone (+0.5 %). The correction helps little there (24.6 → 23.7 %): February is Antarctic summer, melt and wet ice (and water vapour over the ice edge) change the T_B in ways the RTM does not model (meeting 2026-11-17).
- The single increases do not add up to the total (RTM not linear, inputs correlated), so the ranking is reported, not a budget.

For the report: `B1c_exclusion.png` (rows Arctic/Antarctic, columns water/ice) as the data figure for Task 2 next to the tornado chart (model figure). Caption idea: "Std of the SIC when one ERA5 input is left out of the correction (1–27 Feb 1973). Water vapour is the most important input, wind second; leaving out SST does not increase the noise."

## Sweep over the full input range (built 2026-11-16, `b1d_sweep.m`)
Tonboe asked for a sweep, e.g. over wind speed.
- **Method:**
  - One input at a time is swept over its physical range: V 0–30 kg/m², W 0–25 m/s, L 0–1 kg/m², Ts 271–290 K, Ti 240–273 K.
  - All other inputs stay at the 1–27 Feb mean of the A6b tie-point cluster of that hemisphere, **except L = 0 in the V, W, Ts and Ti sweeps** (Tonboe 2026-11-17, so L does not affect them; numbers barely change: Antarctic V 7.2 → 7.3 K per σ).
  - Shown is ΔT_B relative to the mean state, for water (c = 0) and ice (c = 1) at θ = 0°, 30° and 50°.
  - **White** = observed 5–95 % range, **grey** = input values that hardly occur (inverted 2026-11-17). The right axis shows the same ΔT_B in % SIC (Arctic 1 % = 0.82 K, Antarctic 0.70 K).
- **Figure:** rows Arctic/Antarctic, columns V, W, L, Ts, Ti, with the fixed colours of B1.

ΔT_B between the observed 5 % and 95 % values (θ = 50°), i.e. the full noise range each input can cause:

| Input | Arctic water | Antarctic water | Arctic ice | Antarctic ice |
|---|---|---|---|---|
| V | **21.6 K (26 % SIC)** | **22.5 K (32 %)** | 0.8 K (1 %) | 1.1 K (2 %) |
| W | **12.0 K (15 %)** | **9.8 K (14 %)** | 0 | 0 |
| L (not corrected) | 25.4 K (31 %) | 25.2 K (36 %) | 0.6 K (1 %) | 1.0 K (1 %) |
| Ts | −0.4 K (−0.5 %) | −0.3 K (−0.4 %) | 0 | 0 |
| Ti | 0 | 0 | **7.9 K (10 %)** | **3.6 K (5 %)** |

**What the sweep adds to the ±1σ figures:**
- **Almost linear in V, W and L over the observed range.** The ±1σ tornado is therefore a fair summary, and the correction (a difference of two RTM runs) does not depend much on where the reference sits.
- **Wind:** slightly concave, the slope drops at high wind. This comes from the roughness cap σ² ≤ 0.07 above ≈ 19.5 m/s. Wind has **no** effect over ice.
- **Angle:** all water curves get steeper with θ, by a factor of about 1.5–2 from 0° to 50°. The ice curves hardly depend on θ. → Task 3: the open-water noise should grow towards the swath edge.
- **Ts:** flat (< 1 K over the whole range), and slightly negative (warmer water is less emissive at 19 GHz H). This explains why leaving Ts out does not hurt (exclusion test); SST would need a lower frequency.
- **Ti:** the only ice term, linear, about 0.9 K per K. In the Antarctic the observed Ti range is narrow (268.5–272.7 K), because Eq. 15 with a mild t2m keeps Ti close to 272 K.
- **Same unit, different SIC:** the same ΔT_B is about 17 % more SIC in the Antarctic (smaller ice–water contrast, 70 vs. 82 K; old masks 60 K, +35 %).

Caption idea: "RTM sweep: change of T_B when one ERA5 input is varied over its full range, all others at the Feb 1973 tie-point mean and L = 0 (solid water, dashed ice; θ = 0/30/50°). White: observed 5–95 % range; grey: values that hardly occur."

## L study (built 2026-11-17, `b1i_L_study.m`, details `B1i_L_study.md`)
Tonboe 2026-11-17: compare (a) iteration 1 mean L, iteration 2 per-pixel L with (b) mean L in both iterations; expected: (b) better.

| std of SIC [%], iteration 2 | uncorrected | mean L | per-pixel L |
|---|---|---|---|
| Arctic water | 9.61 | **7.05** | 9.99 |
| Antarctic water | 11.88 | **9.34** | 13.61 |
| Arctic ice | 12.53 | 10.86 | 10.85 |
| Antarctic ice | 24.57 | 23.70 | 23.65 |

- **Confirmed:** mean L better on all 27 days in both hemispheres; per-pixel L is worse than no correction.
- Mean SIC per L bin: uncorrected rises with L (≈ −4 → +9 %), mean L flat (±2 %), per-pixel L falls to **−14 % (N) / −19 % (S) at L ≈ 0.8 kg/m²** (over-correction), cloud-free pixels +4…6 %.
- Ice: no difference (L hardly affects ice T_B).
- Figure `output/B1i_L_study.png` (Arctic top, Antarctic bottom): daily std, histogram, mean SIC vs. L.

## Link to Task 4: where the correction acts (B7)
`B7_correction_map.md`: the correction is largest over open water near the ice edge and in the Southern Ocean (60–70° S: +8.5 % SIC, mostly V); W dominates only along the storm tracks; on pack ice Ti dominates and the correction is a few %. Use as the map counterpart of the ranking above.

## Next / open
- Check Ti from Eq. 15 vs. ERA5 `istl1` on the ice side.
- Task 3 (B2) done: noise flat to ~40°, then rises towards the edge, as expected from this figure (`B2_angle.md`).
