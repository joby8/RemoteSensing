# Writing plan – Task 2: sensitivity study (which ERA5 inputs matter?)

All numbers below come from `B1_sensitivity.md`. Figures are in `output/`.
Length target: about 1–1.5 pages, plus 2 figures (a 3rd one is optional).

---

## The story in four sentences
1. To find out which ERA5 inputs drive the correction, we use two complementary approaches:
   - the RTM alone (a sweep and ±1σ perturbations)
   - the real Feb 1973 pixels (an exclusion test)
2. Over open water, water vapour V is the most important input and wind W the second. SST Ts has almost no effect. The uncorrected cloud liquid L would be as large as V.
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

**Cite:** Kolbe et al. (2024) Sect. 4.1 (correction scheme); Wentz (1997) for the RTM (modified for 0–60° and sea ice, provided code); Eq. 15 for Ti.

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

### 4. Discussion (≈ 1 paragraph)
- **Model and data agree:** V > W ≫ Ts over water; Ti over ice.
- **Largest remaining noise source is L.** In the model it is as large as V, but it is not corrected, because ERA5 clouds do not match the 1973 scenes pixel by pixel. Per-pixel L made Task 1 worse:
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

Before using them:
- **Figure A:** decide whether to keep the 2nd y axis (% SIC) or switch to % SIC only, which reads easier.
- **Figure B:** check that the bar labels are readable at report size (maybe only the water column in the report, ice in the appendix).

---

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
