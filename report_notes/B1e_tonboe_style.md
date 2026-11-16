# B1e/B1f: sensitivity figures in the style of Tonboe et al. (2022)

**Status:** built 2026-11-16 **in addition to** the existing figures (`B1d_sweep.png`, `B1_tornado.png`, `B1c_exclusion.png` stay). Not yet decided which ones go into the report.
**Why:** our supervisor's paper (Tonboe et al. 2022, notes in `ref_Tonboe2022_plots.md`) plots SIC (not T_B) against one geophysical parameter, uses the same y range in every panel and summarises each parameter as "slope × 1σ".

## B1e: sweep in % SIC (`src/matlab/b1e_sweep_sic.m` → `output/B1e_sweep_sic.png`, `.csv`)
- Same model runs as B1d: one input swept, others at the cluster mean, water (solid) / ice (dashed), θ = 0/30/50°.
- **Changes vs. B1d:**
  - Main y axis = ΔSIC in %, the same range (±45 %) in all 10 panels. K is now on the right axis.
  - ±1σ of the observed pixels marked as dotted lines.
  - Box in each panel: SIC change per 1σ at θ = 50°.
- Effect: Arctic and Antarctic can be compared directly. The Antarctic curves are steeper in % SIC because the ice–water contrast is smaller (60 vs. 81 K).
- 1σ at θ = 50° (σ per hemisphere; the tornado pools both hemispheres, so its numbers differ slightly):

| input | Arctic water | Arctic ice | Antarctic water | Antarctic ice |
|---|---|---|---|---|
| V | +8.1 % | +0.3 % | +11.9 % | +0.6 % |
| W | +4.6 % | 0 | +4.9 % | 0 |
| L | +10.5 % | +0.3 % | +14.3 % | +0.7 % |
| Ts | −0.3 % | 0 | −0.3 % | 0 |
| Ti | 0 | +3.0 % | 0 | +1.9 % |

## B1f: real pixels (`src/matlab/b1f_scatter_ow.m` → `output/B1f_scatter_ow.png`, `.csv`)
- Tonboe's Figs. 12/13, but with **real** open-water tie-point pixels (1–27 Feb 1973, A6b iteration 2; 460 k Arctic, 964 k Antarctic). Columns V, W, L, Ts; rows Arctic/Antarctic.
- **What is plotted:**
  - Grey dots: uncorrected SIC (a subsample of 15 k pixels).
  - Black line: bin mean of the uncorrected SIC.
  - Blue line: bin mean of the corrected SIC.
  - Orange line: RTM prediction from that input alone, computed per pixel with the pixel's own θ.
- **Box in each panel:** linear-fit slope × 1σ and the correlation r.

| | slope × 1σ, no corr. | corrected | RTM alone | r no corr. → corr. |
|---|---|---|---|---|
| Arctic V | +4.0 % | −1.0 % | +5.8 % | 0.38 → −0.12 |
| Arctic W | +4.5 % | +1.4 % | +3.4 % | 0.42 → 0.16 |
| Arctic L | +3.9 % | +0.9 % | +8.5 % | 0.36 → 0.11 |
| Antarctic V | +7.3 % | −1.3 % | +8.5 % | 0.51 → −0.12 |
| Antarctic W | +4.2 % | −0.0 % | +3.7 % | 0.29 → −0.00 |
| Antarctic L | +4.7 % | −0.1 % | +11.7 % | 0.33 → −0.01 |
| Ts (both) | +1.3 / +2.2 % | −0.8 / −0.2 % | −0.2 / −0.3 % | small |

**Findings:**
- **V and W: the data follow the RTM.** The black line lies on the orange line, which means the model sensitivity is real. After the correction the blue line is flat.
  - V is slightly over-corrected: corrected slope −1 %, r = −0.12.
- **L: the data show only about half of the RTM slope** (Antarctic 4.7 vs. 11.7 % per 1σ). The correction does not use L, yet the corrected line is still flat, because L is correlated with V and W.
  - This supports Kolbe et al.'s choice not to correct L.
  - Possible reason: tcw − tcwv also contains cloud ice/snow, which hardly emits at 19 GHz. So the L proxy overestimates the liquid water. This is a hypothesis, not checked.
- **Ts:** the uncorrected slope (+1.3 to +2.2 %) is larger than the RTM slope (−0.2 %). That is correlation with V/W (warm water comes with moist air), not the SST effect itself.
- **Caveat for the report:** a data slope mixes correlated inputs and the θ distribution; only the orange line is a clean single-input sensitivity.

## B1g: real pixels, ice side (`src/matlab/b1g_scatter_ice.m` → `output/B1g_scatter_ice.png`, `.csv`)
- Counterpart of B1f for the **ice** tie-point pixels (siconc > 0.8, A6b iteration 2, 1–27 Feb; 2.1 M Arctic, 347 k Antarctic). Style of Tonboe et al. (2022) Figs. 7/10 (c_ice of 100 % ice vs. T_si).
- Columns: the inputs that act over ice (tornado): Ti, V, L. Same lines as B1f.
  - The RTM line uses each pixel's own θ and c_ice (c_used, as in the correction).
  - Ideal after the correction: flat at 100 %.
- **Why B1f has no Ti column:** B1f shows only open-water pixels. At c = 0, Ti has no effect in the RTM (the water curve in the Ti sweep panel is flat at 0).

| | slope × 1σ, no corr. | corrected | RTM alone | r no corr. → corr. |
|---|---|---|---|---|
| Arctic Ti (σ 2.8 K) | +3.4 % | +0.3 % | +2.8 % | 0.23 → 0.02 |
| Arctic V | +2.5 % | +0.0 % | +0.4 % | 0.17 → 0.00 |
| Arctic L | +0.7 % | −0.5 % | +0.4 % | 0.05 → −0.04 |
| Antarctic Ti (σ 1.4 K) | −4.6 % | −6.0 % | +1.8 % | −0.10 → −0.15 |
| Antarctic V | +0.6 % | −1.2 % | +0.8 % | ≈ 0 |
| Antarctic L | +2.1 % | +0.9 % | +1.6 % | ≈ 0 |

**Findings:**
- **Arctic Ti: the data follow the RTM** (+3.4 vs. +2.8 % per 1σ), and the correction makes the line flat up to ≈ 266 K. This confirms the Ti sensitivity that the tornado shows for ice, on real data. Tonboe et al. (2022) found the same for the simulated ESMR (0.007/K, "sensitive to T_si").
  - Drop above ≈ 266 K: these are ice-edge pixels. In the warmest Ti decile the ERA5 siconc is 0.95 and c_used is 0.92 (vs. 0.95–0.96 elsewhere), so more open water is in the footprint. That is not a Ti effect.
- **Arctic V:** the data slope (+2.5 %) is larger than the RTM slope (+0.4 %) because V is correlated with Ti (warm air is moist). After the correction it is flat.
- **Antarctic Ti: the model does not explain the data.** The data show a U shape (≈ 140 % at 267 K, 90 % at 271 K, 115 % at 273 K), and the correction changes nothing (blue = black).
  - Check per Ti decile: the ERA5 siconc is ≈ 0.91 in every decile, but the ESMR-based c_used varies from 0.79 to 0.93 and the T_B from 194 to 212 K. The cold decile has c_used 0.93, T_B 212 K and SIC 123 %.
  - So the pattern comes from **different ice types/compactness inside the cluster**, which ERA5 does not see. Compact (cold) pack ice lies above the tie point, which is pulled down by the many low-c pixels. The warm end (> 272.5 K, T_B 211 K) has a similar high T_B; the cause there is not checked (wet snow? coast?).
  - This is the same weakness of the Antarctic ice cluster as in Task 1 (std 40 %) and B1c (ice reacts to V). It is **not a Ti sensitivity**. Do not report the Antarctic Ti slope as one.
- **Ice V and L:** small in the model and in the data. This confirms "the atmosphere plays a minor role over sea ice" (Tonboe et al. 2022).

## B1h: all five inputs for water AND ice (`src/matlab/b1h_scatter_all.m` → `output/B1h_scatter_water.png`, `output/B1h_scatter_ice.png`, `output/B1h_scatter_all.csv`)
- Complete version of B1f/B1g (added 2026-11-16, Jo's idea): two figures, each 2 × 5 panels (rows Arctic/Antarctic, columns V, W, L, Ts, Ti). The panels where an input has **no** effect on that surface are shown on purpose. That is the instructive part.
- Water: same numbers as B1f for V, W, L, Ts. Ice: same as B1g for V, L, Ti. New panels:

| new panel | RTM alone (per 1σ) | data, no corr. → corr. | what it teaches |
|---|---|---|---|
| water vs. Ti (Arctic / Antarctic) | 0.0 % (flat) | +2.3 → −1.4 % / +4.8 → −0.8 % | **A slope in the data is not a sensitivity.** The model says Ti does nothing over water, yet the data have a slope: Ti comes from the 2 m air temperature (Eq. 15), and warm air is moist (V). The correction removes it via V. |
| ice vs. W | +0.2 / +0.6 % (≈ flat; only through the water fraction of mixed pixels) | −0.8 → −1.7 % / −1.8 → −2.7 % | Over ice the RTM has no wind effect. In the data the SIC drops at strong wind (Antarctic ≈ 90 % at 13 m/s), and the correction makes it slightly worse. Possible reason (not checked): strong wind opens leads, so the footprint has less ice than ERA5 says. |
| ice vs. Ts | – | – | **ERA5 SST under ice is constant** (271.46 K = −1.69 °C, the freezing point of sea water; 99 % Arctic, 100 % Antarctic). Ts gives no information over ice. That is why leaving Ts out has no effect on the ice side in B1c. |

- Water vs. L with the full x range (up to 1.5 kg/m²): the gap between the RTM and the data grows further (Antarctic RTM ≈ +48 % at 1.5 kg/m², data ≈ +15 %).
- Arctic ice: about 1 % of the pixels have SST = 273.15 K (0 °C), probably coastal/fjord pixels. Not used.

**Teaching point for the talk/report:** with all panels side by side, it becomes clear why the orange line is needed. Without the model, the data slope of Ti over water (+4.8 %) would look like a real Ti effect over water.

## How to read B1f (simple explanation, e.g. for the talk)
- All points are **open water**, so the true SIC is 0 % everywhere. Any deviation from 0 is error (noise).
- x = how much of the input (e.g. water vapour) ERA5 gives for that pixel; y = the SIC our algorithm computes there.
- The three lines answer three questions (Antarctic V panel as the example):
  1. **Black = the problem:** does the error depend on V? Yes: dry air ≈ −8 %, moist air ≈ +18 %. Moist air emits extra, the water looks warmer, the algorithm reads that as ice.
  2. **Orange = the explanation:** does the RTM predict this? Ask the model "if only V changes, how much SIC error?" The orange line lies almost on the black one, so the model explains the error.
  3. **Blue = the solution:** is the error gone after the correction? Yes, flat at 0, whatever V is.
- W behaves like V. For L, orange is much steeper than black: the model (or the ERA5 L proxy) overestimates the cloud effect, so correcting L would subtract too much. This matches A6, where per-pixel L made the noise worse (11.5 % instead of 10.6 % std, Arctic). For Ts, orange is flat; the small black slope is the V effect (warm water comes with moist air).
- Report sentence: "For water vapour and wind, the SIC error in the real data follows the RTM prediction and disappears after the correction; for cloud liquid, the RTM predicts about twice the effect seen in the data, which supports not correcting L."
- Talk idea: build the figure up in three steps (black only → + orange → + blue).

## How B1f fits into the sensitivity study (Task 2)
- The sensitivity study asks: **how much does the SIC change when one input changes?** We answer it three ways:
  1. **Model** (B1d/B1e sweep, B1 tornado): the RTM says how big each effect *should* be.
  2. **Data, by leaving inputs out** (B1c exclusion): how much worse the correction gets without each input.
  3. **Data, direct** (B1f): the SIC error vs. each input in the real pixels, i.e. how big the effect *actually is*.
- B1f links 1 and 2. It checks whether the model sensitivities are real:
  - V and W: yes, model and data agree (±1σ ≈ 4–8 %).
  - L: the model overestimates by about 2×. This is a limit of the model sensitivity, an important caveat for the tornado chart, where L looks like the largest effect.
- Tonboe et al. (2022) could only do part 1 (simulations). The data comparison is what our study adds.

## For the report (open)
- B1f is the strongest new figure: it tests the RTM against the data, which Tonboe (simulation only) cannot do. A candidate for the Task 2 data figure, next to or instead of B1c.
- B1e vs. B1d: same content; decide which y axis (% SIC or K) reads better.
- Cite: Tonboe et al. (2022), "slope × one STD" and Figs. 12/13 as the template.
