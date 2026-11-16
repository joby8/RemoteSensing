# Writing plan – Task 2: sensitivity study (which ERA5 inputs matter?)

All numbers below come from `B1_sensitivity.md`. Figures are in `output/`.
Length target: about 1–1.5 pages, plus 2 figures (a 3rd one is optional).

---

## The story in four sentences
1. To find out which ERA5 inputs drive the correction, we use three complementary approaches:
   - the RTM alone (a sweep and ±1σ perturbations): how big each effect **should** be
   - the real Feb 1973 pixels, by leaving inputs out (exclusion test)
   - the real Feb 1973 pixels, directly (SIC error vs. each input, B1f): how big each effect **actually is**
2. Over open water, water vapour V is the most important input and wind W the second; for both, the data confirm the RTM sensitivity. SST Ts has almost no effect. For the uncorrected cloud liquid L the RTM predicts as much as V, but the data show only about half of that.
3. Over ice, only the ice temperature Ti matters.
4. All water sensitivities grow with incidence angle, which leads over to Task 3.

---

## Section structure

### 1. Method (≈ 1 paragraph + list)
**Purpose:** say what "sensitivity" means here and why there are two approaches.

- **Task wording:** "Evaluate by exclusion which ERA5 parameters are most important for the correction."
- **Agreed with the supervisor** (session 13 Nov): do it as an RTM sensitivity study **and** check it with the data.
- **(a) RTM sweep:**
  - One input at a time is varied over its physical range. All other inputs stay at the Feb 1973 mean of the tie-point clusters.
  - Shown at θ = 0°, 30°, 50° for water (c = 0) and ice (c = 1).
  - Ranges: V 0–30 kg/m², W 0–25 m/s, L 0–1 kg/m², Ts 271–290 K, Ti 240–273 K.
- **(b) ±1σ perturbation (tornado):**
  - Each input moved by ±1σ of its observed spread in the tie-point clusters, θ = 50°.
  - Converted to % SIC with the ice–water contrast of the corrected tie points (Arctic 81 K, Antarctic 60 K).
- **(c) Exclusion test with the data:**
  - Same correction as in Task 1 (A6b), but one input at a time is left out: its reference value is used in the "actual" RTM run.
  - Then compare the daily std of the open-water SIC with the full correction.
- **Note:** L is never corrected, as in Kolbe et al. (2024, Sect. 4.1). In (a) and (b) we still show it, to quantify the noise that remains.

**Cite:** Kolbe et al. (2024) Sect. 4.1 (correction scheme); Wentz (1997) for the RTM (modified for 0–60° and sea ice, provided code); Eq. 15 for Ti; **Tonboe et al. (2022)** for the term "geophysical noise" and the "sensitivity × 1σ" measure (see the reference section below).

### 2. Results: model view (≈ 1–2 paragraphs + Fig. A)
**Key message:** over water V > W ≫ Ts; over ice only Ti matters; everything over water grows with θ.

Numbers: ΔT_B between the observed 5 % and 95 % values, θ = 50° (from `B1d_sweep.csv`):

| Input | Arctic water | Antarctic water | Arctic ice | Antarctic ice |
|---|---|---|---|---|
| V | 21 K (26 % SIC) | 22 K (36 %) | 0.9 K | 1.2 K |
| W | 12 K (15 %) | 10 K (16 %) | 0 | 0 |
| L (not corr.) | 25 K (31 %) | 25 K (42 %) | 0.6 K | 1.0 K |
| Ts | −0.6 K | −0.5 K | 0 | 0 |
| Ti | 0 | 0 | 8.2 K (10 %) | 3.6 K (6 %) |

Points to make:
- **Nearly linear over the observed range.** So ±1σ is a fair summary (tornado), and the correction does not depend much on where the reference sits.
- **Wind curve flattens at high W.** This comes from the roughness cap σ² ≤ 0.07 above ≈ 19.5 m/s.
- **Water curves get steeper with θ**, by a factor of about 1.5–2 from 0° to 50°. Reason: the longer path 1/cos θ, and the lower H-pol emissivity reflects more sky. **Use this to lead over to Task 3.**
- **Same ΔT_B gives about 35 % more SIC in the Antarctic**, because the ice–water contrast is smaller (60 vs. 81 K).

Optional ±1σ numbers (tornado, Arctic, θ = 50°): V ±9 % SIC, W ±4 %, L −8/+13 %, Ts ±0.2 %; ice: Ti ±4.5 %.

### 3. Results: data view – exclusion test (≈ 1 paragraph + Fig. B)
**Key message:** the real pixels confirm the ranking; Ts can be dropped.

Mean of the daily std of SIC, 1–27 Feb (`B1c_exclusion.csv`); increase vs. full correction in brackets:

| | Arctic water | Antarctic water | Arctic ice | Antarctic ice |
|---|---|---|---|---|
| full correction | 8.15 | 10.97 | 13.02 | 40.50 |
| without V | +1.18 | **+2.39** | +0.35 | +2.99 |
| without W | +1.14 | +0.75 | +0.02 | +1.09 |
| without Ts | −0.01 | −0.08 | −0.14 | −0.89 |
| without Ti | +0.17 | +0.15 | **+1.26** | +0.37 |
| no correction | +2.39 | +3.28 | +1.54 | +3.77 |

Points to make:
- **Water:** V matters most (Antarctic clearly, Arctic about equal with W), W second.
- **Leaving Ts out never makes the result worse**, and sometimes slightly better. This feeds into the Task 4 recommendation.
- **Ti only helps on the ice side**, most in the Arctic.
- **Antarctic ice reacts to V (+3 %).** Pure ice should not. This shows that the Antarctic ice cluster contains many low-c_ice pixels, the same weakness as in Task 1.
- The single increases do not add up to the total (non-linear RTM, correlated inputs). So report a **ranking, not a budget**.
- **Validation sentence:** the "all inputs" case reproduces the Task 1 numbers exactly.

### 3b. Results: data view – real pixels vs. model (≈ 1 paragraph + Fig. D)
**Key message:** the model sensitivities for V and W are real; the model overestimates the cloud effect L by about 2×.
Details and simple explanation: `B1e_tonboe_style.md`. Style follows Tonboe et al. (2022), Figs. 12/13, but with real pixels.

- **What the figure is:** all points are open water, so the true SIC is 0 %, and every deviation is error. x = ERA5 input of the pixel, y = computed SIC.
- **Three lines, three questions:**
  - Black (no correction): does the error depend on the input? → the problem
  - Orange (RTM, this input alone): does the model predict it? → the explanation
  - Blue (with correction): is it gone? → the solution
- Numbers, slope × 1σ in % SIC (`B1f_scatter_ow.csv`):

| | no corr. | corrected | RTM alone |
|---|---|---|---|
| Arctic V / W / L | +4.0 / +4.5 / +3.9 | −1.0 / +1.4 / +0.9 | +5.8 / +3.4 / +8.5 |
| Antarctic V / W / L | +7.3 / +4.2 / +4.7 | −1.3 / −0.0 / −0.1 | +8.5 / +3.7 / +11.7 |

Points to make:
- **V and W:** the data follow the RTM line; after the correction the line is flat. This confirms the model sensitivities (and the tornado) for the two inputs we correct.
- **L:** the data slope is only about half of the RTM slope. Without this check, the tornado would suggest that L is the largest effect. Consistent with A6 (per-pixel L made the noise worse) and with not correcting L. Possible reason (not checked): tcw − tcwv also contains cloud ice, which hardly emits at 19 GHz.
- **Ts:** the small data slope is the V effect (warm water comes with moist air), not the SST itself.
- **Caveat:** data slopes mix correlated inputs and the θ distribution; only the RTM line is a clean single-input sensitivity.
- **What is new:** Tonboe et al. (2022) could only simulate. The comparison with real data is our contribution.

**Ice side (Fig. E, `B1g_scatter_ice.png`, short paragraph or appendix):**
- Same plot for the ice tie-point pixels vs. Ti, V, L; ideal = flat at 100 %. (B1f has no Ti column: over open water Ti has no effect in the RTM.)
- **Arctic Ti:** the data follow the RTM (+3.4 vs. +2.8 % per 1σ), corrected ≈ flat (+0.3 %). This confirms the Ti sensitivity on real data. The drop above ≈ 266 K is ice-edge pixels (lower c_ice), not Ti.
- **Antarctic Ti:** U-shaped, not explained by the model, and not changed by the correction. ERA5 siconc is ≈ 0.91 everywhere, but the ESMR c_ice varies from 0.79 to 0.93: different ice compactness inside the cluster. Report it as a **limit of the Antarctic ice cluster** (same as Task 1), not as a Ti sensitivity.
- V and L over ice: small in the model and in the data → "the atmosphere plays a minor role over sea ice" (Tonboe et al. 2022).

**Complete 5 × 2 version (B1h), points worth one sentence each:**
- **Ti over water:** the RTM says no effect, but the data show +2.3 / +4.8 % per 1σ, because Ti comes from the air temperature, which is correlated with V. → A data slope alone is not a sensitivity; the model line is needed to tell them apart.
- **W over ice:** no effect in the RTM, but in the data the SIC drops at strong wind (Antarctic ≈ 90 % at 13 m/s). Possibly wind-opened leads (not checked).
- **Ts over ice:** ERA5 SST under ice is a constant 271.46 K → no information, which explains the zero effect of leaving Ts out on the ice side (B1c).

### 4. Discussion (≈ 1 paragraph)
- **Model and data agree:** V > W ≫ Ts over water; Ti over ice. The direct data view (B1f) confirms the size of the V and W effects, not only their ranking.
- **Largest remaining noise source is L.** In the model it is as large as V, but in the real data only about half as large (B1f). It is not corrected, because ERA5 clouds do not match the 1973 scenes pixel by pixel. Per-pixel L made Task 1 worse:
  - A6 test: std of SIC 11.5 % N / 13.7 % S, worse than uncorrected.
  - Check on one orbit (1 Feb, Antarctic open water): the correlation of the measured T_B with the modelled ΔT_B is ≈ 0 for L and V, but 0.38 for W. This comes from the review of Axel's code (`Matlab/README.md` on branch `axel-concept`). Quote it only as "one orbit".
- **Angle dependence** → link to Task 3 (noise rises above ≈ 40°).
- **Hand over to Task 4:** keep V and W, drop Ts, Ti for the ice side; L remains the main limitation.

---

## Figures
| | File | Use | Caption idea |
|---|---|---|---|
| **A** | `B1d_sweep.png` | main (model) | "RTM sweep: change of T_B when one ERA5 input is varied over its full range, all others at the Feb 1973 tie-point mean (solid water, dashed ice; θ = 0/30/50°). Grey: observed 5–95 % range. Rows: Arctic, Antarctic." |
| **B** | `B1c_exclusion.png` | main (data) | "Std of the SIC when one ERA5 input is left out of the correction (1–27 Feb 1973). Water vapour is the most important input, wind second; leaving out SST does not increase the noise." |
| C | `B1_tornado.png` | optional / seminar | "RTM sensitivity at the mean Feb 1973 tie-point weather (θ = 50°): ±1σ of each input in % SIC." |
| **D** | `B1f_scatter_ow.png` | main candidate (data vs. model) | "SIC of the open-water tie-point pixels (1–27 Feb 1973) vs. one ERA5 input. Black/blue: bin means without/with RTM correction; orange: RTM prediction from this input alone. V and W follow the model and are removed by the correction; the cloud effect in the data is about half of the modelled one." |
| E | `B1g_scatter_ice.png` | appendix / discussion (ice side) | "As Fig. D for the ice tie-point pixels. Arctic: the SIC follows the modelled Ti sensitivity and is flattened by the correction. Antarctic: the pattern comes from varying ice compactness inside the cluster, which ERA5 does not resolve." |
| D+/E+ | `B1h_scatter_water.png`, `B1h_scatter_ice.png` | complete versions of D/E (all 5 inputs × water/ice); appendix or seminar | "Same as D/E for all five inputs. Where the RTM line is flat, the input has no effect on that surface; any slope in the data then comes from correlated inputs (e.g. Ti over water via air temperature and V). ERA5 SST under ice is constant at 271.46 K." |
| A' | `B1e_sweep_sic.png` | alternative to A | Same as A, but y axis in % SIC (same range in all panels) and ±1σ marked; follows Tonboe et al. (2022). |

Before using them:
- **Figure A:** decide between `B1d_sweep.png` (K, % SIC on the right) and `B1e_sweep_sic.png` (% SIC main axis, ±1σ boxes).
- **Figure D:** for the seminar, build it up in three steps (black → + orange → + blue).
- **Page budget:** with D the section has 3 main figures. If too many: D replaces B (exclusion) in the main text, or A goes to the appendix.
- **Figure B:** check that the bar labels are readable at report size (maybe only the water column in the report, ice in the appendix).

---

---

## Reference: Tonboe et al. (2022) – how the supervisor shows sensitivity
Tonboe, R. T., et al. (2022): Simulated Geophysical Noise in Sea Ice Concentration Estimates of Open Water and Snow-Covered Sea Ice. IEEE JSTARS 15, 1309–1326, doi:10.1109/JSTARS.2021.3134021. Local copy: `docs/literature/Tonboe/relevant/`. Read 2026-11-16.

**What they do:** simulate top-of-atmosphere T_B along realistic model runs (Bellingshausen Sea open water, Ross Sea FYI, Lincoln Sea MYI). Then compute c_ice with 8 algorithms, **including an ESMR algorithm** (one channel, 18.7 GHz H, fixed θ = 55°).

| Figure | Plot type | Use for us |
|---|---|---|
| **Fig. 12** | Open water: **scatter of c_ice vs. total water vapour WV** (0–20 kg/m²), one panel per algorithm (ESMR panel included), y = SIC −1…1 | closest to our V sweep |
| **Fig. 13** | Open water: scatter of c_ice vs. **cloud liquid water CLW** (0–0.8 kg/m²), same layout | L sweep |
| Fig. 7 / 10 | 100 % ice: scatter of c_ice vs. snow–ice interface temperature T_si | our Ti sweep |
| Fig. 8 / 9 | Bars of **partial correlations** of c_ice with 10 snow/ice/atmosphere parameters | alternative to the exclusion test |

**How they quantify it** (same idea as our tornado):
- They fit a line to each cluster, and the slope is the sensitivity, e.g. per kg/m² or per K.
- **Slope × 1 std of the parameter** gives the bias per 1σ. Example, ESMR over MYI: 0.007/K × 8.7 K = 0.061.
- So our "±1σ in % SIC" (tornado) uses exactly their measure. Cite it as such.

**Statements we can cite:**
- "Over OW, … NASA Team, Bristol, TUD, and ESMR have moderate sensitivity [to WV and CLW]" (conclusions).
- Single-channel algorithms incl. ESMR "are sensitive to variations in the snow ice interface temperature T_si" (conclusions). This matches our finding that over ice only Ti matters.
- "the atmospheric c_ice noise plays a minor role over sea ice". Matches our ice side.
- **Wind was not investigated** in their study ("wind not investigated in this study"). Our wind sweep and exclusion test therefore add something new. Say so.
- CLW is "very difficult to quantify adequately in NWP and re-analysis models at the spatial and temporal scale of satellite radiometer measurements". This supports why L is not corrected.

**Consequence for our figures:**
- Our **sweep** (model curves) is the smooth model version of their scatter plots. Our **tornado** uses their "slope × 1σ" measure.
- Wording: "following Tonboe et al. (2022), we express the sensitivity as the SIC change per 1σ of each parameter".
- Tonboe-style figure from our **real data**: built as `B1f_scatter_ow.png` (section 3b). Result: the V and W slopes go to ≈ 0 after the correction. The L slope also goes to ≈ 0, although L is not corrected, because L is correlated with V and W. The modelled L slope is about 2× the observed one.
- Do not compare numbers directly. Their ESMR runs at fixed θ = 55° on simulated T_B; we use real 1973 T_B at 0–55.7°. Only compare the qualitative ranking.

## Words and notation
- Use "water vapour V (tcwv)", "wind speed W (|u10, v10|)", "cloud liquid L (tcw − tcwv)", "SST Ts", "ice temperature Ti (Eq. 15)". Define each once and keep it.
- Give ΔT_B in K **and** % SIC. Say once which contrast was used for the conversion.
- "Exclusion" = the input is left out of the correction (reference value in the actual run). Do not call it "removed from the data".
- θ = incidence angle; the analysis uses |θ| ≤ 55.7° (scan positions 5–74).

## Avoid
- Calling L "not important": it is the largest term but deliberately not corrected.
- Adding up the exclusion increases to a "share of the total".
- Over-interpreting the Antarctic ice numbers: that cluster is contaminated (Task 1).
- Mixing the Arctic and Antarctic % SIC without saying that the contrast differs.

## Checklist before handing in
- [ ] Both figures referenced in the text, captions say Arctic/Antarctic and θ.
- [ ] Every number in the text matches `B1_sensitivity.md` / csv files.
- [ ] Sentence on why L is not corrected, with the paper citation.
- [ ] Link forward to Task 3 (angle) and Task 4 (drop Ts).
