# Writing plan – Task 2: sensitivity study (which ERA5 inputs matter?)

All numbers below come from `B1_sensitivity.md` and `B1i_L_study.md`. Figures are in `output/`. Length target: about 1.5 pages, plus 2–3 figures. **State 2026-11-17:** all numbers are from the rerun with the new tie-point masks (`tp_masks.m`, Tonboe meeting 2026-11-17: water siconc ≤ 0.01, ice 180 K &lt; T_B &lt; 274 K, ERA5 lsm = 0) and the new preprocessing default (Eq. 3 line buffer, `preproc_config.m`; it changes the std values by ≤ 0.02 points). Old-mask values only where they matter for the story, marked "(old masks: x)".

---

## The story in four sentences

1. To find out which ERA5 inputs drive the correction, we use three complementary approaches:
   - the RTM alone (a sweep, with the SIC change per 1σ of each input read from it): how big each effect **should** be
   - the real Feb 1973 pixels, by leaving inputs out (exclusion test)
   - the real Feb 1973 pixels, directly (SIC error vs. each input, B1f): how big each effect **actually is**
2. Over open water, water vapour V and wind W are the two inputs that matter (V larger in the model and in the Antarctic data, about equal in the Arctic data); for both, the data confirm the RTM sensitivity. SST Ts has almost no effect. For the uncorrected cloud liquid L the RTM predicts more than for V, but the data show less than half of that.
3. Over ice, only the ice temperature Ti matters.
4. Correcting L per pixel makes the result worse than no correction (L study): keeping L at the cluster mean is right.
5. All water sensitivities grow with incidence angle, which leads over to Task 3.

---

## Section structure

### 1. Method (≈ 1 paragraph + list)

**Purpose:** say what "sensitivity" means here and why there are two approaches.

- **Task wording:** "Evaluate by exclusion which ERA5 parameters are most important for the correction."
- **Agreed with the supervisor** (session 13 Nov): do it as an RTM sensitivity study **and** check it with the data.
- **(a) RTM sweep:**
  - One input at a time is varied over its physical range. All other inputs stay at the Feb 1973 mean of the tie-point clusters, except **L = 0 in the V, W, Ts and Ti sweeps** (Tonboe 2026-11-17: so that L does not influence the other curves). The L sweep keeps the others at the mean.
  - Shown at θ = 0°, 30°, 50° for water (c = 0) and ice (c = 1).
  - Ranges: V 0–30 kg/m², W 0–25 m/s, L 0–1 kg/m², Ts 271–290 K, Ti 240–273 K.
- **(b) Sensitivity per 1σ (from the sweep, no extra figure):**
  - From the sweep curves: SIC change when one input moves by 1σ of its observed spread in the tie-point cluster (water pixels; Ti: ice pixels), θ = 50°. Same setup as (a), so L = 0 in the other sweeps. Shown as the box in each panel of Fig. A.
  - Converted to % SIC with the ice–water contrast of the corrected tie points (Arctic 83 K, Antarctic 76 K; 17 Nov: 82 / 70 K; first masks: 81 / 60 K).
- **(c) Exclusion test with the data:**
  - Same correction as in Task 1 (A6b), but one input at a time is left out: its reference value is used in the "actual" RTM run.
  - Then compare the daily std of the open-water SIC with the full correction.
- **(d) L study** (Tonboe 2026-11-17): iteration 1 as always (mean L); iteration 2 either with mean L again or with the pixel's own L in the "actual" run. Compare the std of SIC.
- **Note:** L is not corrected, as in Kolbe et al. (2024, Sect. 4.1); (d) tests this choice. In (a) and (b) we still show L, to quantify the noise that remains.

**Cite:** Kolbe et al. (2024) Sect. 4.1 (correction scheme); Wentz (1997) for the RTM (modified for 0–60° and sea ice, provided code); Eq. 15 for Ti; **Tonboe et al. (2022)** for the term "geophysical noise" and the "sensitivity × 1σ" measure (see the reference section below).

### 2. Results: model view (≈ 1–2 paragraphs + Fig. A)

**Key message:** over water V &gt; W ≫ Ts; over ice only Ti matters; everything over water grows with θ.

Numbers: ΔT_B between the observed 5 % and 95 % values, θ = 50° (from `B1d_sweep.csv`):

| Input | Arctic water | Antarctic water | Arctic ice | Antarctic ice |
| --- | --- | --- | --- | --- |
| V | 17 K (20 % SIC) | 15 K (20 %) | 0.8 K | 1.1 K |
| W | 12 K (14 %) | 10 K (13 %) | 0 | 0 |
| L (not corr.) | 26 K (31 %) | 21 K (28 %) | 0.6 K | 1.0 K |
| Ts | −1.2 K | −1.2 K | 0 | 0 |
| Ti | 0 | 0 | 7.7 K (9 %) | 3.5 K (5 %) |

Points to make:

- **Nearly linear over the observed range.** So the change per 1σ is a fair summary, and the correction does not depend much on where the reference sits.
- **Wind curve flattens at high W.** This comes from the roughness cap σ² ≤ 0.07 above ≈ 19.5 m/s.
- **Water curves get steeper with θ**, by a factor of about 1.5–2 from 0° to 50°. Reason: the longer path 1/cos θ, and the lower H-pol emissivity reflects more sky. **Use this to lead over to Task 3.**
- **Same ΔT_B gives about 10 % more SIC in the Antarctic**, because the ice–water contrast is smaller (76 vs. 83 K; 17 Nov: 70 vs. 82 K; first masks: 60 vs. 81 K, +35 %).
- **Ts would need another frequency:** at 19 GHz the SST signal is ≈ 1 K over the whole observed range, so ESMR cannot see (or correct) SST; that needs a lower frequency, e.g. 6–10 GHz (Tonboe 2026-11-17).

SIC change per 1σ, θ = 50° (from `B1e_sweep_sic.csv`, the boxes in Fig. A):

| Input | Arctic water | Antarctic water | Arctic ice | Antarctic ice |
| --- | --- | --- | --- | --- |
| V | +6.3 % (1σ = 4.3 kg/m²) | +6.6 % (4.2 kg/m²) | +0.3 % | +0.5 % |
| W | +4.4 % (4.6 m/s) | +4.1 % (3.8 m/s) | 0 | 0 |
| L (not corr.) | +11.0 % (0.34 kg/m²) | +9.6 % (0.26 kg/m²) | +0.3 % | +0.5 % |
| Ts | −0.5 % (2.6 K) | −0.5 % (2.3 K) | 0 | 0 |
| Ti | 0 | 0 | +2.7 % (2.6 K) | +1.5 % (1.3 K) |

Ranking in one sentence for the text: over water L &gt; V &gt; W ≫ Ts in the model (but see 3b: the data show L at less than half of this); over ice only Ti.

### 3. Results: data view – exclusion test (≈ 1 paragraph + Fig. B)

**Key message:** the real pixels confirm the ranking; Ts can be dropped.

Mean of the daily std of SIC, 1–27 Feb (`B1c_exclusion.csv`); increase vs. full correction in brackets:

|  | Arctic water | Antarctic water | Arctic ice | Antarctic ice |
| --- | --- | --- | --- | --- |
| full correction | 6.76 | 8.04 | 10.74 | 22.54 |
| without V | +1.13 | **+0.99** | +0.16 | +0.23 |
| without W | **+1.54** | +0.38 | −0.00 | +0.04 |
| without Ts | −0.02 | +0.01 | −0.02 | −0.05 |
| without Ti | +0.08 | +0.03 | **+1.44** | +0.07 |
| no correction | +2.64 | +1.71 | +1.63 | +0.31 |

(17 Nov masks, full correction: 7.05 / 9.34 / 10.86 / 23.70; first masks: 8.15 / 10.97 / 13.02 / 40.50.)

Points to make:

- **Water:** V and W are the two that matter. Antarctic: V clearly first (+1.0 vs. +0.4). Arctic: W ahead (+1.5 vs. +1.1; with the 17 Nov masks +1.4 vs. +1.2, first masks V slightly ahead). The cold 272 K water cluster is drier and has less V spread, so V matters less there → report "V and W", with the order depending on the hemisphere.
- **Leaving Ts out never makes the result worse** (≤ +0.01). This feeds into the Task 4 recommendation.
- **Ti only helps on the ice side**, most in the Arctic (+1.4): the "some improvement by ice temperature" from the meeting.
- **Antarctic ice:** the correction gains little (22.9 → 22.5 %). With the first masks the ice cluster reacted strongly to V (+3.0), a sign of ocean pixels in it; the 180 K limit removed most of them (now +0.2). The remaining \~22 % noise fits Antarctic summer (wet/melting ice, water vapour), which the RTM does not model.
- The single increases do not add up to the total (non-linear RTM, correlated inputs). So report a **ranking, not a budget**.
- **Validation sentence:** the "all inputs" case reproduces the Task 1 numbers exactly.

### 3b. Results: data view – real pixels vs. model (≈ 1 paragraph + Fig. D)

**Key message:** the model sensitivities for V and W are real; the model overestimates the cloud effect L by about 2×. Details and simple explanation: `B1e_tonboe_style.md`. Style follows Tonboe et al. (2022), Figs. 12/13, but with real pixels.

- **What the figure is:** all points are open water, so the true SIC is 0 %, and every deviation is error. x = ERA5 input of the pixel, y = computed SIC.
- **Three lines, three questions:**
  - Black (no correction): does the error depend on the input? → the problem
  - Orange (RTM, this input alone): does the model predict it? → the explanation
  - Blue (with correction): is it gone? → the solution
- Numbers, slope × 1σ in % SIC (`B1f_scatter_ow.csv`):

|  | no corr. | corrected | RTM alone |
| --- | --- | --- | --- |
| Arctic V / W / L | +3.8 / +5.5 / +3.4 | −0.6 / +2.0 / +0.8 | +4.8 / +3.4 / +9.2 |
| Antarctic V / W / L | +4.6 / +3.6 / +3.1 | −1.1 / −0.6 / −0.6 | +5.2 / +3.2 / +8.7 |

Points to make:

- **V and W:** the data follow the RTM line; after the correction the line is (nearly) flat. This confirms the model sensitivities (and the 1σ values of Fig. A) for the two inputs we correct. Arctic W keeps a small residual slope (+2.0 %).
- **L:** the data slope is less than half of the RTM slope (3.4 vs. 9.2, 3.1 vs. 8.7). Without this check, the model alone (Fig. A) would suggest that L is the largest effect. Consistent with A6 (per-pixel L made the noise worse) and with not correcting L. Possible reason (not checked): tcw − tcwv also contains cloud ice, which hardly emits at 19 GHz.
- **Ts:** the small data slope is the V effect (warm water comes with moist air), not the SST itself.
- **Caveat:** data slopes mix correlated inputs and the θ distribution; only the RTM line is a clean single-input sensitivity.
- **What is new:** Tonboe et al. (2022) could only simulate. The comparison with real data is our contribution.

**Ice side (Fig. E,** `B1g_scatter_ice.png`**, short paragraph or appendix):**

- Same plot for the ice tie-point pixels vs. Ti, V, L; ideal = flat at 100 %. (B1f has no Ti column: over open water Ti has no effect in the RTM.)
- **Arctic Ti:** same sign as the RTM, but the data slope is larger (+5.1 vs. +2.6 % per 1σ); the correction removes part of it (+2.2 % left; first masks: +3.4 → +0.3). So Ti is a real effect on the ice side, but Eq. 15 does not capture all of it (warm marginal ice, B7: −5 % at 50–60° N).
- **Antarctic Ti:** opposite sign to the model (−1.6 %, −3.0 % after correction), not explained by the RTM. Antarctic summer: melt and wet snow change the emissivity, which the RTM and Eq. 15 do not model (meeting 2026-11-17: "melting ice makes weird data"). Report it as a **limit of the Antarctic ice side in summer** (same as Task 1), not as a Ti sensitivity.
- V and L over ice: small in the model and in the data → "the atmosphere plays a minor role over sea ice" (Tonboe et al. 2022).

**Complete 5 × 2 version (B1h), points worth one sentence each:**

- **Ti over water:** the RTM says no effect, but the data show +2.4 / +3.1 % per 1σ, because Ti comes from the air temperature, which is correlated with V. → A data slope alone is not a sensitivity; the model line is needed to tell them apart.
- **W over ice:** no effect in the RTM, but in the data the SIC drops at strong wind (slope −1.7 % per 1σ in the Antarctic). Possibly wind-opened leads (not checked).
- **Ts over ice:** ERA5 SST under ice is a constant 271.46 K → no information, which explains the zero effect of leaving Ts out on the ice side (B1c).

### 3c. Results: should L be corrected? – L study (≈ 1 paragraph + Fig. F)

**Key message:** no. Mean L in both iterations gives the lowest noise; the pixel's own L over-corrects and is worse than no correction. Details: `B1i_L_study.md`. Agreed with Tonboe (2026-11-17).

Mean of the daily std of SIC, 1–27 Feb, iteration 2 (`B1i_L_study.csv`):

|  | uncorrected | mean L | per-pixel L |
| --- | --- | --- | --- |
| Arctic water | 9.40 | **6.76** | 10.44 |
| Antarctic water | 9.76 | **8.04** | 12.22 |
| Arctic ice | 12.37 | 10.74 | 10.70 |
| Antarctic ice | 22.85 | 22.54 | 22.52 |

Points to make:

- **Water:** mean L better on all 27 days in both hemispheres; per-pixel L is worse than doing nothing (+1.0 / +2.5 points).
- **Why (panel 3, mean SIC vs. L):** uncorrected SIC rises with L (≈ −3 → +8…9 %); mean L stays flat within ±2 %; per-pixel L turns it into **−15 % (Arctic) / −22 % (Antarctic) at L ≈ 0.8 kg/m²**, and cloud-free pixels get +4…5 %. ERA5 cloud liquid for 1973 does not match the clouds ESMR saw.
- **Ice:** no difference (≤ 0.04 points), L hardly changes the ice T_B.
- Fits 3b (data L slope &lt; half of the RTM slope) and the A6 test (per-pixel L worse).

### 4. Discussion (≈ 1 paragraph)

- **Model and data agree:** V &gt; W ≫ Ts over water; Ti over ice. The direct data view (B1f) confirms the size of the V and W effects, not only their ranking.
- **Largest remaining noise source is L.** In the model it is larger than V, but in the real data less than half as large (B1f). It is not corrected, because ERA5 clouds do not match the 1973 scenes pixel by pixel. Per-pixel L makes Task 1 worse:
  - L study (3c): 6.76 → 10.44 % (N), 8.04 → 12.22 % (S), worse than uncorrected.
  - Earlier A6 test (old masks, one iteration): std of SIC 11.5 % N / 13.7 % S, worse than uncorrected.
  - Check on one orbit (1 Feb, Antarctic open water): the correlation of the measured T_B with the modelled ΔT_B is ≈ 0 for L and V, but 0.38 for W. This comes from the review of Axel's code (`Matlab/README.md` on branch `axel-concept`). Quote it only as "one orbit".
- **SST:** not usable with one 19 GHz channel; an SST correction would need another (lower) frequency (Tonboe 2026-11-17).
- **Ice temperature:** some improvement on the ice side (Arctic +1.4 points when left out), but Eq. 15 does not explain all Ti-related noise.
- **Antarctic summer** (February): water vapour over the ice edge and melting / wet ice change the brightness in ways the RTM does not model → southern ice noise stays ≈ 22–23 %. Do not over-interpret Antarctic ice numbers.
- **Where it matters on the map** (B7, `B7_correction_map.md`): over open water the correction has both signs, mostly V: positive over the cold, dry water near the ice (≥ 70°: +3.6 % N, +5.2 % S), negative over warmer, moister water further out (50–60° S: −4.8 %); W dominates in bands along the storm tracks and the ice edge; on pack ice Ti dominates and the correction is small (marginal Arctic ice −5 %). → link to Task 4.
- **Angle dependence** → link to Task 3 (noise rises above ≈ 40°).
- **Hand over to Task 4:** keep V and W, drop Ts, Ti for the ice side; do not correct L per pixel (L study); L remains the main limitation.

---

## Figures

|  | File | Use | Caption idea |
| --- | --- | --- | --- |
| **A** | `B1e_sweep_sic.png` | main (model) | "RTM sweep: change of SIC when one ERA5 input is varied over its full range, all others at the Feb 1973 tie-point mean and L = 0 (solid water, dashed ice; θ = 0/30/50°). White: observed 5–95 % range; grey: values that hardly occur; dotted: ±1σ. Box: SIC change per 1σ at θ = 50°, following Tonboe et al. (2022). Rows: Arctic, Antarctic." |
| **B** | `B1c_exclusion.png` | main (data) | "Std of the SIC when one ERA5 input is left out of the correction (1–27 Feb 1973). Water vapour is the most important input, wind second; leaving out SST does not increase the noise." |
| **D** | `B1f_scatter_ow.png` | main candidate (data vs. model) | "SIC of the open-water tie-point pixels (1–27 Feb 1973) vs. one ERA5 input. Black/blue: bin means without/with RTM correction; orange: RTM prediction from this input alone. V and W follow the model and are removed by the correction; the cloud effect in the data is about half of the modelled one." |
| E | `B1g_scatter_ice.png` | appendix / discussion (ice side) | "As Fig. D for the ice tie-point pixels. Arctic: the SIC follows the modelled Ti sensitivity and is flattened by the correction. Antarctic: the pattern comes from varying ice compactness inside the cluster, which ERA5 does not resolve." |
| D+/E+ | `B1h_scatter_water.png`, `B1h_scatter_ice.png` | complete versions of D/E (all 5 inputs × water/ice); appendix or seminar | "Same as D/E for all five inputs. Where the RTM line is flat, the input has no effect on that surface; any slope in the data then comes from correlated inputs (e.g. Ti over water via air temperature and V). ERA5 SST under ice is constant at 271.46 K." |
| A' | `B1d_sweep.png` | appendix only, if at all | Same sweep as A, but y axis in K (% SIC on the right axis), without the 1σ boxes. Source of the 5–95 % ΔT_B table in section 2. |
| **F** | `B1i_L_study.png` | main (L decision) | "L study, 1–27 Feb 1973: open-water SIC with cloud liquid kept at the cluster mean vs. the pixel's own ERA5 value in the 2nd iteration. Left: daily std; middle: SIC histogram; right: mean SIC per L bin. The per-pixel L over-corrects cloudy pixels (−15 % / −22 % at 0.8 kg/m²) and is worse than no correction." |

Before using them:

- **Figure A:** decided: `B1e_sweep_sic.png` (% SIC main axis, 1σ boxes).
- **Figure D:** for the seminar, build it up in three steps (black → + orange → + blue).
- **Page budget:** with D and F the section has 4 main figures. If too many: D replaces B (exclusion) in the main text, A goes to the appendix, or only panel 3 of F is used.
- **Figure B:** check that the bar labels are readable at report size (maybe only the water column in the report, ice in the appendix).

---

---

## Reference: Tonboe et al. (2022) – how the supervisor shows sensitivity

Tonboe, R. T., et al. (2022): Simulated Geophysical Noise in Sea Ice Concentration Estimates of Open Water and Snow-Covered Sea Ice. IEEE JSTARS 15, 1309–1326, doi:10.1109/JSTARS.2021.3134021. Local copy: `docs/literature/Tonboe/relevant/`. Read 2026-11-16.

**What they do:** simulate top-of-atmosphere T_B along realistic model runs (Bellingshausen Sea open water, Ross Sea FYI, Lincoln Sea MYI). Then compute c_ice with 8 algorithms, **including an ESMR algorithm** (one channel, 18.7 GHz H, fixed θ = 55°).

| Figure | Plot type | Use for us |
| --- | --- | --- |
| **Fig. 12** | Open water: **scatter of c_ice vs. total water vapour WV** (0–20 kg/m²), one panel per algorithm (ESMR panel included), y = SIC −1…1 | closest to our V sweep |
| **Fig. 13** | Open water: scatter of c_ice vs. **cloud liquid water CLW** (0–0.8 kg/m²), same layout | L sweep |
| Fig. 7 / 10 | 100 % ice: scatter of c_ice vs. snow–ice interface temperature T_si | our Ti sweep |
| Fig. 8 / 9 | Bars of **partial correlations** of c_ice with 10 snow/ice/atmosphere parameters | alternative to the exclusion test |

**How they quantify it** (same idea as the 1σ boxes in our Fig. A):

- They fit a line to each cluster, and the slope is the sensitivity, e.g. per kg/m² or per K.
- **Slope × 1 std of the parameter** gives the bias per 1σ. Example, ESMR over MYI: 0.007/K × 8.7 K = 0.061.
- So our "% SIC per 1σ" (boxes in Fig. A) uses exactly their measure. Cite it as such.

**Statements we can cite:**

- "Over OW, … NASA Team, Bristol, TUD, and ESMR have moderate sensitivity \[to WV and CLW\]" (conclusions).
- Single-channel algorithms incl. ESMR "are sensitive to variations in the snow ice interface temperature T_si" (conclusions). This matches our finding that over ice only Ti matters.
- "the atmospheric c_ice noise plays a minor role over sea ice". Matches our ice side.
- **Wind was not investigated** in their study ("wind not investigated in this study"). Our wind sweep and exclusion test therefore add something new. Say so.
- CLW is "very difficult to quantify adequately in NWP and re-analysis models at the spatial and temporal scale of satellite radiometer measurements". This supports why L is not corrected.

**Consequence for our figures:**

- Our **sweep** (model curves) is the smooth model version of their scatter plots. The **1σ boxes** in the sweep use their "slope × 1σ" measure. Tonboe liked the sweep figures (2026-11-17); grey now marks the range that is not really used.
- Wording: "following Tonboe et al. (2022), we express the sensitivity as the SIC change per 1σ of each parameter".
- Tonboe-style figure from our **real data**: built as `B1f_scatter_ow.png` (section 3b). Result: the V and W slopes go to ≈ 0 after the correction. The L slope also goes to ≈ 0, although L is not corrected, because L is correlated with V and W. The modelled L slope is about 2× the observed one.
- Do not compare numbers directly. Their ESMR runs at fixed θ = 55° on simulated T_B; we use real 1973 T_B at 0–63.9°. Only compare the qualitative ranking.

## Words and notation

- Use "water vapour V (tcwv)", "wind speed W (|u10, v10|)", "cloud liquid L (tcw − tcwv)", "SST Ts", "ice temperature Ti (Eq. 15)". Define each once and keep it.
- Give ΔT_B in K **and** % SIC. Say once which contrast was used for the conversion.
- "Exclusion" = the input is left out of the correction (reference value in the actual run). Do not call it "removed from the data".
- θ = incidence angle; the analysis uses all 78 scan positions, |θ| ≤ 63.9° (since 2026-11-24; Kolbe et al. cut at 55.7°).

## Avoid

- Calling L "not important": it is the largest term but deliberately not corrected.
- Adding up the exclusion increases to a "share of the total".
- Over-interpreting the Antarctic ice numbers: summer melt and wet ice (less contaminated since the 180 K limit, but still ≈ 22–23 % noise).
- Mixing the Arctic and Antarctic % SIC without saying that the contrast differs.

## Checklist before handing in

- [ ] Both figures referenced in the text, captions say Arctic/Antarctic and θ.

- [ ] Every number in the text matches `B1_sensitivity.md` / csv files.

- [ ] Sentence on why L is not corrected, with the paper citation and the L study numbers.

- [ ] All numbers from the 2026-11-17 rerun (new masks), none from the old-mask tables.

- [ ] Link forward to Task 3 (angle) and Task 4 (drop Ts).