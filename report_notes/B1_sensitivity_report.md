## **Sensitivity Study**

<!-- Review 2026-11-20: green = changed/added by Claude, red = TODO (missing). Remove the <mark> tags when done. -->

## Intro

<mark style="background:#ffb3b3">TODO: Intro is empty. 2–3 sentences: Task 2 wording ("evaluate by exclusion which ERA5 parameters are most important for the correction"), which inputs are corrected (V, W, Ts, Ti) and that L is not corrected (Kolbe et al. 2024), and what the reader gets from this section (ranking of the inputs, model vs. data).</mark>

### 1. <mark style="background:#b6f2b6">Methods</mark>

The correction that we <mark style="background:#b6f2b6">make</mark> with <mark style="background:#b6f2b6">the</mark> RTM is based <mark style="background:#b6f2b6">on</mark> multiple inputs from ERA5. Each input has an influence on the total correction of the output values. <mark style="background:#b6f2b6">This</mark> influence is the sensitivity.

To find out which ERA5 inputs truly drive the correction<mark style="background:#b6f2b6">,</mark> we look at <mark style="background:#b6f2b6">two complementary</mark> approaches<mark style="background:#b6f2b6">: the RTM alone (a, b) and the real 1973 data (c, d)</mark>.

### (a)

First we look at the RTM alone and sweep each parameter in order to see how big each effect can be on the correction. For this<mark style="background:#b6f2b6">,</mark> one input is <mark style="background:#b6f2b6">varied</mark> over its physical range while the other inputs stay at their <mark style="background:#b6f2b6">February 1973 (1–27 Feb)</mark> mean of the tie-point clusters <mark style="background:#b6f2b6">of each hemisphere</mark>. One <mark style="background:#b6f2b6">exception</mark> is L. L is set to L = 0 in the V, W, Ts and Ti sweeps. (talked about this). <mark style="background:#b6f2b6">We</mark> do this because L would <mark style="background:#b6f2b6">otherwise influence the other sweeps, and we do not</mark> have true <mark style="background:#b6f2b6">values</mark> for L. The L sweep keeps the other values at the mean. To also <mark style="background:#b6f2b6">look at</mark> different <mark style="background:#b6f2b6">incidence angles</mark><mark style="background:#b6f2b6">,</mark> we plot at θ = 0°, 30°<mark style="background:#b6f2b6"> and</mark> 50° for water (c = 0) and ice (c = 1).

<mark style="background:#ffb3b3">TODO: "(talked about this)" → delete, or give the reason/reference (agreed with Tonboe, meeting 2026-11-17).</mark>
<mark style="background:#ffb3b3">TODO: give the sweep ranges (V 0–30 kg/m², W 0–25 m/s, L 0–1 kg/m², Ts 271–290 K, Ti 240–273 K) and explain white = observed 5–95 % range, grey = values that hardly occur (Figure 1).</mark>

### (b)

Within the plot we also mark the <mark style="background:#b6f2b6">±1σ</mark> per parameter with a dotted line. At these x-coordinates we look at the 50° incidence angle for <mark style="background:#b6f2b6">ice</mark> and water. <mark style="background:#b6f2b6">These</mark> numbers are also shown in <mark style="background:#b6f2b6">Table 1</mark><mark style="background:#b6f2b6">,</mark> converted from <mark style="background:#b6f2b6">ΔT_B</mark> to SIC in %<mark style="background:#b6f2b6"> by dividing by the ice–water contrast of the corrected tie points of each hemisphere (Arctic 82 K, Antarctic ≈ 72 K)</mark>.

### (c)

Then we rerun the RTM <mark style="background:#b6f2b6">correction</mark> without one <mark style="background:#b6f2b6">input</mark> at a time in order to see <mark style="background:#b6f2b6">its effect</mark> on the real data of 1973<mark style="background:#b6f2b6">;</mark> this is the exclusion test. We compare the daily <mark style="background:#b6f2b6">std of the</mark> SIC <mark style="background:#b6f2b6">of the open-water and ice tie points</mark> with the full correction<mark style="background:#b6f2b6">, so</mark> we see the <mark style="background:#b6f2b6">influence of each input in our real data</mark>.

<mark style="background:#ffb3b3">TODO: one sentence on how "left out" works: the input gets its reference value in the RTM run, so it corrects nothing. Mean over 1–27 Feb.</mark>

<mark style="background:#ffb3b3">TODO: methods for section 2.3 are missing (Figures 3, 4): SIC of each tie-point pixel vs. one ERA5 input, bin means without / with correction, RTM prediction of this input alone (others at the cluster mean, pixel θ), and the "slope × 1σ" number in the box (Tonboe et al. 2022).</mark>

### (d)

<mark style="background:#b6f2b6">To</mark> test <mark style="background:#b6f2b6">how much the result depends on which L value we use</mark>, we do a small study. <mark style="background:#b6f2b6">We</mark> do <mark style="background:#b6f2b6">two</mark> tests<mark style="background:#b6f2b6">, each with two RTM iterations</mark>. <mark style="background:#b6f2b6">The difference</mark> is that the <mark style="background:#b6f2b6">second</mark> iteration of the <mark style="background:#b6f2b6">second</mark> test <mark style="background:#b6f2b6">uses</mark> the L per pixel instead of the mean<mark style="background:#b6f2b6">; all</mark> other iterations use the <mark style="background:#b6f2b6">mean L</mark>. <mark style="background:#b6f2b6">Then</mark> we compare the std of the SIC. <mark style="background:#b6f2b6">This</mark> way we also test <mark style="background:#b6f2b6">the decision</mark> made in the paper <mark style="background:#b6f2b6">by Kolbe</mark> et al. <mark style="background:#b6f2b6">(2024) not to correct L</mark>.

### 2.1 <mark style="background:#b6f2b6">Results (model)</mark>

<mark style="background:#b6f2b6">![Figure 1](../output/B1e_sweep_sic.png)</mark>
<mark style="background:#b6f2b6">**Figure 1:** RTM sweep: change of SIC (left axis) and T_B (right axis) when one ERA5 input is varied over its range, all others at the Feb 1973 tie-point mean and L = 0 (solid water, dashed ice; θ = 0/30/50°). White: observed 5–95 % range; grey: values that hardly occur; dotted: ±1σ. Arctic top, Antarctic bottom.</mark>

The results for the RTM sweep show that all effects are nearly linear over the observed range.

<mark style="background:#b6f2b6">The</mark> wind curve for water flattens towards <mark style="background:#b6f2b6">high wind speeds</mark>. This <mark style="background:#b6f2b6">is</mark> caused by the roughness cap: σ² ≤ 0.07 above ≈ 19.5 m/s.

The water vapour V<mark style="background:#b6f2b6">,</mark> wind speed W and cloud liquid <mark style="background:#b6f2b6">L</mark> (water curves) all show <mark style="background:#b6f2b6">a similar</mark> type of <mark style="background:#b6f2b6">result</mark>. <mark style="background:#b6f2b6">The</mark> effect on the water is biggest and gets bigger with the incidence angle θ. The factor is about <mark style="background:#b6f2b6">1.7–2.3</mark> from 0° to 50°<mark style="background:#b6f2b6"> (V and L ≈ 1.7, W ≈ 2.3)</mark>. The reason is the longer path 1/cos θ<mark style="background:#b6f2b6"> and</mark> the lower H-pol emissivity<mark style="background:#b6f2b6">, which reflects</mark> more sky.

<mark style="background:#b6f2b6">The</mark> effect of these changes in <mark style="background:#b6f2b6">T_B</mark> <mark style="background:#b6f2b6">on the SIC is</mark> bigger or smaller in <mark style="background:#b6f2b6">the Arctic and Antarctic, depending on each</mark> ice–water contrast. The effects on the ice are in general smaller than the ones on water<mark style="background:#b6f2b6">, and</mark> the factor with the biggest effect is <mark style="background:#b6f2b6">the ice</mark> temperature Ti. The sea surface temperature <mark style="background:#b6f2b6">Ts</mark> does not have a notable impact on the SIC<mark style="background:#b6f2b6">; on</mark> water it is about <mark style="background:#b6f2b6">−0.2 %</mark>.

<mark style="background:#b6f2b6">**Table 1:** Effect of +1σ of each input on the SIC at θ = 50° (RTM, Figure 1); 1σ of the observed tie-point pixels in brackets.</mark>

| Input | Arctic water | Antarctic water | Arctic ice | Antarctic ice |
| --- | --- | --- | --- | --- |
| V | +8.2 % (1σ = 5.5 kg/m²) | +10.2 % (6.1 kg/m²) | +0.3 % | +0.5 % |
| W | +4.5 % (4.6 m/s) | +4.1 % (3.7 m/s) | 0 | 0 |
| L (not corr.) | +10.5 % (0.32 kg/m²) | +12.0 % (0.32 kg/m²) | +0.3 % | +0.5 % |
| Ts | −0.2 % (1.6 K) | −0.2 % (1.6 K) | 0 | 0 |
| Ti | 0 | 0 | +2.8 % (2.6 K) | +1.6 % (1.4 K) |

<mark style="background:#b6f2b6">In</mark> total the effect of L is largest, <mark style="background:#b6f2b6">second</mark> is V<mark style="background:#b6f2b6">, then</mark> W<mark style="background:#b6f2b6">;</mark> Ts has a rather small influence and Ti <mark style="background:#b6f2b6">acts</mark> only over ice.

### 2.2 <mark style="background:#b6f2b6">Results (data, exclusion test)</mark>

<mark style="background:#b6f2b6">![Figure 2](../output/B1c_exclusion.png)</mark>
<mark style="background:#b6f2b6">**Figure 2:** Std of the SIC when one ERA5 input is left out of the correction (1–27 Feb 1973).</mark>

<mark style="background:#b6f2b6">Looking</mark> at the real pixels<mark style="background:#b6f2b6">,</mark> these findings <mark style="background:#b6f2b6">are</mark> confirmed.

<mark style="background:#b6f2b6">**Table 2:** Mean daily std of the SIC [%] with the full correction, and its increase when one input is left out.</mark>

|  | Arctic water | Antarctic water | Arctic ice | Antarctic ice |
| --- | --- | --- | --- | --- |
| full correction | 7.05 | 9.34 | 10.86 | 23.70 |
| without V | +1.20 | **+1.85** | +0.17 | +0.53 |
| without W | **+1.40** | +0.57 | −0.02 | +0.09 |
| without Ts | +0.01 | −0.02 | −0.04 | −0.12 |
| without Ti | +0.08 | +0.09 | **+1.51** | +0.34 |
| no correction | +2.56 | +2.54 | +1.67 | +0.87 |

<mark style="background:#b6f2b6">In</mark> the <mark style="background:#b6f2b6">figure</mark> it can be seen that <mark style="background:#b6f2b6">V</mark> and <mark style="background:#b6f2b6">W</mark> are the <mark style="background:#b6f2b6">inputs</mark> that have the biggest impact<mark style="background:#b6f2b6"> over water (in the Arctic W is slightly ahead of V), while</mark> on ice <mark style="background:#b6f2b6">Ti</mark> has the biggest impact<mark style="background:#b6f2b6">. Ts is</mark> not really <mark style="background:#b6f2b6">relevant;</mark> <mark style="background:#b6f2b6">its</mark> effect is <mark style="background:#b6f2b6">≤ +0.01 %</mark>.

<mark style="background:#ffb3b3">TODO: one sentence that the single increases do not add up to "no correction" (RTM not linear, inputs correlated), so this is a ranking, not a budget.</mark>

### 2.3 <mark style="background:#b6f2b6">Results (real pixels vs. model)</mark>

<mark style="background:#b6f2b6">![Figure 3](../output/B1h_scatter_water.png)</mark>
<mark style="background:#b6f2b6">**Figure 3:** SIC of the open-water tie-point pixels vs. one ERA5 input (1–27 Feb 1973). Black: bin mean without correction; blue: with correction; orange dashed: RTM prediction of this input alone. Box: slope × 1σ.</mark>

<mark style="background:#b6f2b6">In</mark> <mark style="background:#b6f2b6">Figure 3</mark> all points are open water, so their <mark style="background:#b6f2b6">true</mark> SIC is 0 %. All <mark style="background:#b6f2b6">deviation</mark> is error. <mark style="background:#b6f2b6">x</mark> is <mark style="background:#b6f2b6">the</mark> ERA5 input of the pixel and <mark style="background:#b6f2b6">y</mark> is the computed SIC.

The black line is the uncorrected error. <mark style="background:#b6f2b6">It</mark> should be a flat line at 0 % if there was no error.

<mark style="background:#b6f2b6">The orange dashed</mark> line is <mark style="background:#b6f2b6">the RTM prediction for this input alone, so what the model predicts, and the blue</mark> line is the corrected version.

<mark style="background:#b6f2b6">For</mark> V and W the data <mark style="background:#b6f2b6">follow</mark> the RTM line<mark style="background:#b6f2b6">, resulting</mark> in <mark style="background:#b6f2b6">a</mark> good correction. For L the model <mark style="background:#b6f2b6">overshoots</mark> a lot<mark style="background:#b6f2b6"> (RTM 8.4 / 9.8 % per σ, data 3.9 / 3.9 %)</mark>. The model alone <mark style="background:#b6f2b6">would</mark> therefore suggest that L has the largest effect.

The small <mark style="background:#b6f2b6">Ts</mark> effects really come from moist air<mark style="background:#b6f2b6">,</mark> not <mark style="background:#b6f2b6">from the</mark> water <mark style="background:#b6f2b6">temperature</mark> itself.

The Ti over water <mark style="background:#b6f2b6">is</mark> estimated by <mark style="background:#b6f2b6">the</mark> RTM <mark style="background:#b6f2b6">to have</mark> no effect<mark style="background:#b6f2b6">,</mark> but the data <mark style="background:#b6f2b6">show</mark> <mark style="background:#b6f2b6">2.3 / 3.9 %</mark> per <mark style="background:#b6f2b6">σ (Arctic / Antarctic)</mark>. <mark style="background:#b6f2b6">This</mark> is because Ti comes from <mark style="background:#b6f2b6">the</mark> air <mark style="background:#b6f2b6">temperature</mark>, which is <mark style="background:#b6f2b6">correlated</mark> to V. <mark style="background:#b6f2b6">Looking</mark> at the two lines<mark style="background:#b6f2b6">,</mark> we see that <mark style="background:#b6f2b6">the effect exists but is not accounted for</mark> by the model.
<mark style="background:#b6f2b6">(moved up from the ice part: this paragraph is about the water figure)</mark>

<mark style="background:#b6f2b6">For</mark> the ice:

<mark style="background:#b6f2b6">![Figure 4](../output/B1h_scatter_ice.png)</mark>
<mark style="background:#b6f2b6">**Figure 4:** Same as Figure 3 for the ice tie-point pixels (siconc > 0.8, ideal SIC = 100 %).</mark>

<mark style="background:#b6f2b6">Figure 4</mark> is the same plot as <mark style="background:#b6f2b6">Figure 3</mark>, but for ice.

<mark style="background:#b6f2b6">In</mark> the <mark style="background:#b6f2b6">Arctic</mark> the model <mark style="background:#b6f2b6">corrects</mark> the ice<mark style="background:#b6f2b6">, but</mark> in the <mark style="background:#b6f2b6">Antarctic</mark> summer<mark style="background:#b6f2b6">,</mark> melt and wet snow change the emissivity. The model does not handle this well<mark style="background:#b6f2b6">; this</mark> is a <mark style="background:#b6f2b6">limitation</mark>.

V and L have a rather small influence over sea ice.

<mark style="background:#b6f2b6">The</mark> wind over ice is also not accounted for in the RTM<mark style="background:#b6f2b6">,</mark> but in the <mark style="background:#b6f2b6">Antarctic</mark> it has an effect with a drop of −1.7 % per <mark style="background:#b6f2b6">σ</mark>. <mark style="background:#b6f2b6">This</mark> could be caused by openings in the ice<mark style="background:#b6f2b6">, which</mark> could be opened by strong winds.

<mark style="background:#ffb3b3">TODO: check −1.7 %: B1h_scatter_all.csv gives −1.5 % per σ without correction and −2.1 % with correction (Antarctic ice, W).</mark>

<mark style="background:#b6f2b6">Ts</mark> over ice has no information <mark style="background:#b6f2b6">(ERA5 SST under ice is fixed at the freezing point)</mark> and is therefore left out.

### 2.4 <mark style="background:#b6f2b6">Results (L study)</mark>

<mark style="background:#b6f2b6">![Figure 5](../output/B1i_L_study.png)</mark>
<mark style="background:#b6f2b6">**Figure 5:** L study: daily std of the SIC, histogram, and mean SIC vs. L for mean L and per-pixel L in the second iteration. Arctic top, Antarctic bottom.</mark>

<mark style="background:#b6f2b6">The</mark> results of the correction with L per pixel show a large effect<mark style="background:#b6f2b6">, but</mark> this effect <mark style="background:#b6f2b6">goes</mark> in the <mark style="background:#b6f2b6">wrong</mark> direction<mark style="background:#b6f2b6">: it makes the correction</mark> worse<mark style="background:#b6f2b6">, not better</mark>.

<mark style="background:#b6f2b6">**Table 3:** Mean of the daily std of the SIC [%] over the month, second iteration.</mark>

|  | uncorrected | mean L | per-pixel L |
| --- | --- | --- | --- |
| Arctic water | 9.61 | **7.05** | 9.99 |
| Antarctic water | 11.88 | **9.34** | 13.61 |
| Arctic ice | 12.53 | 10.86 | 10.85 |
| Antarctic ice | 24.57 | 23.70 | 23.65 |

Over water the mean <mark style="background:#b6f2b6">L</mark> is better than the per<mark style="background:#b6f2b6">-</mark>pixel value on all days. <mark style="background:#b6f2b6">Looking at the</mark> mean open-water SIC <mark style="background:#b6f2b6">per L bin, the</mark> uncorrected version rises with L from <mark style="background:#b6f2b6">−4 % to +9 %</mark>. <mark style="background:#b6f2b6">With</mark> the correction <mark style="background:#b6f2b6">with</mark> mean L it stays <mark style="background:#b6f2b6">within ±2 %</mark>. <mark style="background:#b6f2b6">With</mark> the correction <mark style="background:#b6f2b6">with</mark> L per pixel it drops to <mark style="background:#b6f2b6">−14 % (Arctic)</mark> and <mark style="background:#b6f2b6">−19 % (Antarctic)</mark> at L <mark style="background:#b6f2b6">≈ 0.8 kg/m²</mark>, and <mark style="background:#b6f2b6">cloud-free</mark> pixels get a <mark style="background:#b6f2b6">+4…6 %</mark> correction. <mark style="background:#b6f2b6">So</mark> <mark style="background:#b6f2b6">the ERA5 cloud</mark> liquid does not match the clouds <mark style="background:#b6f2b6">that</mark> were seen by ESMR.

Over ice the effect is close to 0. L hardly changes the ice <mark style="background:#b6f2b6">T_B</mark>. <mark style="background:#b6f2b6">This</mark> is also seen in <mark style="background:#b6f2b6">the</mark> sweep test.

<mark style="background:#b6f2b6">The</mark> mean L <mark style="background:#b6f2b6">is</mark> therefore the better choice.

### 3. Discussion

<mark style="background:#b6f2b6">In</mark> conclusion<mark style="background:#b6f2b6">,</mark> the model and the data <mark style="background:#b6f2b6">agree</mark>. <mark style="background:#b6f2b6">Over water, V and W have the biggest effect (V first in the model and in the Antarctic data, W slightly ahead in the Arctic data); Ts has almost no effect, while Ti matters over ice.</mark> <mark style="background:#b6f2b6">The</mark> direct view of the data in <mark style="background:#b6f2b6">Figures 3 and 4</mark> <mark style="background:#b6f2b6">confirms</mark> the sizes of these effects.

<mark style="background:#b6f2b6">The</mark> remaining noise source in the correction is caused by L. In the model<mark style="background:#b6f2b6">,</mark> L is larger than V<mark style="background:#b6f2b6">,</mark> but in the real data it is less than half as large <mark style="background:#b6f2b6">(Figure 3)</mark>. <mark style="background:#b6f2b6">It</mark> is not corrected because the <mark style="background:#b6f2b6">ERA5 clouds</mark> do not match the 1973 scenes per pixel<mark style="background:#b6f2b6">;</mark> the per<mark style="background:#b6f2b6">-</mark>pixel L makes the correction worse.

<mark style="background:#b6f2b6">The</mark> SST Ts is <mark style="background:#b6f2b6">unusable</mark> with only one 19 <mark style="background:#b6f2b6">GHz</mark> channel. <mark style="background:#b6f2b6">For</mark> a good <mark style="background:#b6f2b6">SST</mark> correction we would need another<mark style="background:#b6f2b6">,</mark> lower frequency.

<mark style="background:#b6f2b6">The</mark> ice temperature <mark style="background:#b6f2b6">Ti</mark> <mark style="background:#b6f2b6">gives</mark> some improvement on the ice side in the <mark style="background:#b6f2b6">Arctic: leaving it out increases the std by 1.51 %</mark>.

<mark style="background:#b6f2b6">The</mark> <mark style="background:#b6f2b6">Antarctic</mark> summer with melting ice, wet snow and water vapour over the ice edge is a complex problem in this data. <mark style="background:#b6f2b6">Therefore</mark> the ice data in <mark style="background:#b6f2b6">Antarctica</mark> should not be <mark style="background:#b6f2b6">overinterpreted, since</mark> the ice noise is around 24 %.

<mark style="background:#b6f2b6">The</mark> angle dependence is especially big for <mark style="background:#b6f2b6">W</mark>, V<mark style="background:#b6f2b6"> and</mark> L <mark style="background:#b6f2b6">(if it were corrected)</mark>.

<mark style="background:#ffb3b3">TODO: link the angle sentence to Task 3 (B2: noise flat to ~40°, then rising towards the swath edge), or move it there.</mark>

(ich denke zu where it maters on the map sollte man hier nix schreiben; hier geht es nur um sensitivity study)

> **Update 2026-11-23:** recomputed with the 23 Nov masks (SST > 273 K, |lat| > 55°, 5 × 5 land box) and the new clipping (no 15 % filter). Numbers above are from 17 Nov; old → new values in `rerun_2026-11-23.md` (full table `output/rerun_compare.csv`).
