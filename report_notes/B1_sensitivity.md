# B1 – RTM sensitivity study (Task 2)

**Report section:** Results → Task 2 (which ERA5 parameters matter); figure also supports Task 3 (angle dependence)
**Code:** `src/matlab/b1_sensitivity.m` (needs `output/A6b_pixels.mat` from `a6b_iterative.m`; runs in seconds)
**Output:** `output/B1_sensitivity.png`, `output/B1_sensitivity.csv` (ΔT_B per unit and per +1σ at θ = 0/30/50/55.5°)
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

## Next / open
- Optional cross-check with the data: exclusion test (correction with one input fixed at its mean, see how much the std of the corrected SIC grows). This would confirm the ranking V > W ≫ Ts with real pixels.
- Check Ti from Eq. 15 vs. ERA5 `istl1` on the ice side.
- Task 3 (B2): std of SIC vs. θ from `A6b_pixels.mat`. Expectation from this figure: noise rises towards the edge, correction helps most there.
