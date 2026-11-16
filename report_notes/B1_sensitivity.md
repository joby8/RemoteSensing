# B1 – RTM sensitivity study (Task 2)

**Report section:** Results → Task 2 (which ERA5 parameters matter); figure also supports Task 3 (angle dependence)
**Code:** `src/matlab/b1_sensitivity.m` (needs `output/A6b_pixels.mat` from `a6b_iterative.m`; runs in seconds)
**Output:** `output/B1_sensitivity.png`, `output/B1_sensitivity.csv` (ΔT_B per unit and per +1σ at θ = 0/30/50/55.5°)
**Tornado:** `src/matlab/b1b_tornado.m` → `output/B1_tornado.png`, `output/B1_tornado.csv` (±1σ at θ = 50°, in % SIC and K)
**Sweep (model, full range):** `src/matlab/b1d_sweep.m` → `output/B1d_sweep.png`, `output/B1d_sweep.csv` (see section below)
**Exclusion test (data):** `src/matlab/b1c_exclusion.m` → `output/B1c_exclusion.png`, `output/B1c_exclusion.csv` (see section below)
**Status:** first version 2026-11-13

## Agreed with Tonboe (session 2026-11-13)
- Task 2 = **sensitivity study with the RTM**.
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
**Water (c = 0)**, mean V = 12.7 kg/m², W = 10.6 m/s, L = 0.20 kg/m², Ts = 280.5 K:

| Input | 1σ | ΔT_B per +1σ at 0° / 30° / 50° | per unit at 50° |
|---|---|---|---|
| V | 6.2 kg/m² | 4.3 / 5.1 / **7.3 K** | 1.2 K per kg/m² |
| W | 4.0 m/s | 1.4 / 2.4 / **3.1 K** | 0.8 K per m/s |
| L (not corrected) | 0.32 kg/m² | 6.1 / 7.3 / **10.4 K** | 30 K per kg/m² |
| Ts | 1.6 K | −0.2 / −0.2 / −0.2 K | −0.12 K per K |

**Ice (c = 1)**, mean V = 2.7 kg/m², L = 0.05 kg/m², Ti = 263 K:

| Input | 1σ | ΔT_B per +1σ at 0° / 30° / 50° |
|---|---|---|
| Ti | 4.2 K | **3.8 / 3.8 / 3.6 K** |
| V | 2.1 kg/m² | 0.2 / 0.3 / 0.4 K |
| L | 0.11 kg/m² | 0.1 / 0.2 / 0.4 K |

W and Ts have no effect at c = 1.

## Interpretation (for the discussion)
- **Over water: V > W ≫ Ts.** Water vapour is the most important corrected input, wind is second, SST can be ignored (< 0.3 K).
- **Converted to SIC:** divide by the ice–water contrast (81 K in the North). At 50°, 1σ of V is about 9 % SIC, 1σ of W about 4 % SIC. That is the size of the noise we see.
- **L would be the largest term.** But the ERA5 L field does not match the 1973 clouds pixel by pixel, so correcting it adds noise (A6: std gets worse). This is why the paper does not correct L, and it is the main limitation of the method.
- **Everything over water grows with θ.** The path through the atmosphere scales with 1/cos θ, and the H-pol water emissivity falls with θ, so more sky is reflected. → Task 3: the noise should be largest at the swath edge.
- **Over ice only Ti matters** (≈ 3.8 K per 1σ, about 4.5 % SIC). It hardly depends on θ. The atmosphere is dry and the ice is a strong emitter, so the atmospheric terms are small. This makes Eq. 15 (and a possible ERA5 `istl1` alternative) the key choice for the ice side.

## Presentation ideas (brainstorm 2026-11-13)
Current figure = line plot ΔT_B vs. θ. Jo: wants more colour and easier to read, not only lines. Same numbers, other forms:
1. **Tornado chart** (standard in sensitivity studies): one horizontal bar per input, −1σ and +1σ around the mean state, sorted by size, one colour per input; water and ice panels at one angle (e.g. 50°). Ranking visible at once.
2. **Heatmap θ × input with numbers in the cells**: rows V, W, L, Ts (Ti), columns θ = 0, 10, …, 55°, colour = ΔT_B, value printed. Exact values + growth with θ, compact, prints well.
3. **Stacked area "noise budget" vs. θ**: each input contributes ΔT_B², sum = total weather noise. As 100 % stack it shows the share of each input; L appears as the large uncorrected part.
4. **Unit % SIC instead of K** (for all of them): divide by the ice–water contrast (≈ 81 K North) → "1σ water vapour ≈ 9 % SIC", readable without microwave background.
5. **Fixed colour per input in every figure** (V blue, W orange, L green + hatched/dashed = not corrected, Ts purple, Ti red), also for Task 2/3 figures and slides.

**Recommendation:** report = tornado (1) in % SIC (4) with fixed colours (5) as main figure + heatmap (2) for the θ dependence (together they replace the line plot). Seminar/discussion = noise budget (3) because it tells the L story in one picture. Decision pending (Jo).

## Tornado chart (built 2026-11-13, `b1b_tornado.m`)
Ideas 1 + 4 + 5 from above: one bar per input, −1σ (light) and +1σ (dark), sorted by size, water and ice panels, θ = 50°, fixed colours, L light + dashed = not corrected.
- **Unit % SIC:** ΔT_B divided by the ice–water contrast of the corrected A6b tie points (last iteration, mean over days without 28 Feb): **N 81.3 K**, S 60.2 K. Figure uses North → 1 % SIC = 0.81 K. (In the South the same ΔT_B is ~35 % more SIC, mention in text.)
- **−1σ is computed separately** (RTM is not linear), so the bars are not exactly symmetric. For L the −1σ value is clipped at 0 kg/m² (mean 0.20 − σ 0.32 < 0), so its −1σ bar is smaller (−8.4 % vs. +12.8 %).

| Water, θ = 50° | −1σ | +1σ |
|---|---|---|
| L (not corrected) | −8.4 % (−6.8 K) | +12.8 % (+10.4 K) |
| V | −9.4 % (−7.6 K) | +9.0 % (+7.3 K) |
| W | −4.1 % (−3.4 K) | +3.8 % (+3.1 K) |
| Ts | +0.2 % | −0.2 % |

| Ice, θ = 50° | −1σ | +1σ |
|---|---|---|
| Ti | −4.5 % (−3.6 K) | +4.5 % (+3.6 K) |
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
| no RTM correction | 10.54 (+2.39) | 14.56 (+1.54) | 14.25 (+3.28) | 44.26 (+3.77) |
| **full correction (V, W, Ts, Ti)** | **8.15** | **13.02** | **10.97** | **40.50** |
| without V | 9.33 (**+1.18**) | 13.37 (+0.35) | 13.36 (**+2.39**) | 43.49 (+2.99) |
| without W | 9.28 (**+1.14**) | 13.04 (+0.02) | 11.72 (+0.75) | 41.58 (+1.09) |
| without Ts | 8.13 (−0.01) | 12.88 (−0.14) | 10.89 (−0.08) | 39.60 (−0.89) |
| without Ti | 8.32 (+0.17) | 14.28 (**+1.26**) | 11.12 (+0.15) | 40.87 (+0.37) |

**Interpretation**
- **Water: V is the most important input, W second.**
  - In the Arctic both are about equal (+1.2 / +1.1 %).
  - In the Antarctic, V clearly dominates (+2.4 vs. +0.75 %).
  - This confirms the RTM ranking V > W ≫ Ts with real pixels.
- **Ts brings nothing.** Leaving it out is even slightly better everywhere (−0.01 to −0.9 %). The effect is largest on the Antarctic ice side, where the SST under the ice is a fixed fill value (271.35 K) or near freezing. → Task 4: the correction can drop Ts.
- **Ti matters only on the ice side**, most in the Arctic (+1.26 %). This matches the sensitivity study: over ice only Ti matters.
- **Antarctic ice reacts to V (+3.0 %).** Pure ice should hardly react to V, so this shows that the Antarctic ice cluster (siconc > 0.8) contains many pixels with low c_ice, which behave like water. This is the same weak point as in A6b.
- The single increases do not add up to the total (RTM not linear, inputs correlated), so the ranking is reported, not a budget.

For the report: `B1c_exclusion.png` (rows Arctic/Antarctic, columns water/ice) as the data figure for Task 2 next to the tornado chart (model figure). Caption idea: "Std of the SIC when one ERA5 input is left out of the correction (1–27 Feb 1973). Water vapour is the most important input, wind second; leaving out SST does not increase the noise."

## Sweep over the full input range (built 2026-11-16, `b1d_sweep.m`)
Tonboe asked for a sweep, e.g. over wind speed.
- **Method:**
  - One input at a time is swept over its physical range: V 0–30 kg/m², W 0–25 m/s, L 0–1 kg/m², Ts 271–290 K, Ti 240–273 K.
  - All other inputs stay at the 1–27 Feb mean of the A6b tie-point cluster of that hemisphere.
  - Shown is ΔT_B relative to the mean state, for water (c = 0) and ice (c = 1) at θ = 0°, 30° and 50°.
  - Grey band = observed 5–95 % range. The right axis shows the same ΔT_B in % SIC (Arctic 1 % = 0.81 K, Antarctic 0.60 K).
- **Figure:** rows Arctic/Antarctic, columns V, W, L, Ts, Ti, with the fixed colours of B1.

ΔT_B between the observed 5 % and 95 % values (θ = 50°), i.e. the full noise range each input can cause:

| Input | Arctic water | Antarctic water | Arctic ice | Antarctic ice |
|---|---|---|---|---|
| V | **21.0 K (26 % SIC)** | **21.9 K (36 %)** | 0.9 K (1 %) | 1.2 K (2 %) |
| W | **12.1 K (15 %)** | **9.9 K (16 %)** | 0 | 0 |
| L (not corrected) | 25.4 K (31 %) | 25.2 K (42 %) | 0.6 K (1 %) | 1.0 K (2 %) |
| Ts | −0.6 K (−0.7 %) | −0.5 K (−0.8 %) | 0 | 0 |
| Ti | 0 | 0 | **8.2 K (10 %)** | **3.6 K (6 %)** |

**What the sweep adds to the ±1σ figures:**
- **Almost linear in V, W and L over the observed range.** The ±1σ tornado is therefore a fair summary, and the correction (a difference of two RTM runs) does not depend much on where the reference sits.
- **Wind:** slightly concave, the slope drops at high wind. This comes from the roughness cap σ² ≤ 0.07 above ≈ 19.5 m/s. Wind has **no** effect over ice.
- **Angle:** all water curves get steeper with θ, by a factor of about 1.5–2 from 0° to 50°. The ice curves hardly depend on θ. → Task 3: the open-water noise should grow towards the swath edge.
- **Ts:** flat (< 1 K over the whole range), and slightly negative (warmer water is less emissive at 19 GHz H). This explains why leaving Ts out does not hurt (exclusion test).
- **Ti:** the only ice term, linear, about 0.9 K per K. In the Antarctic the observed Ti range is narrow (268.5–272.7 K), because Eq. 15 with a mild t2m keeps Ti close to 272 K.
- **Same unit, different SIC:** the same ΔT_B is about 35 % more SIC in the Antarctic (smaller ice–water contrast).

Caption idea: "RTM sweep: change of T_B when one ERA5 input is varied over its full range, all others at the Feb 1973 tie-point mean (solid water, dashed ice; θ = 0/30/50°). Grey: observed 5–95 % range."

## Next / open
- Check Ti from Eq. 15 vs. ERA5 `istl1` on the ice side.
- Task 3 (B2): std of SIC vs. θ from `A6b_pixels.mat`. Expectation from this figure: noise rises towards the edge, correction helps most there.
