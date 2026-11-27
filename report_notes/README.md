# Report notes

One file per work step: what we did, why (decisions with source), numbers, figures and what goes into the report.
Use them as the writing plan for the report (due 6 Dec) and the seminar (4 Dec).

**Numbers: state 2026-11-24** (water tie points SST > 272 K, all 78 scan positions, c clipped only inside the RTM).
All step notes below were updated to it on 2026-11-27, except the ones marked *history*. Old → new: `rerun_2026-11-24.md`.

## Notes by report chapter (structure agreed with Tonboe 2026-11-24, outline `../report/main_outline.tex`)

| Chapter / section | Notes | Main figures (`output/`) |
|---|---|---|
| **1 Introduction** (radiometer, framework, where we fit, objectives) | `meeting_2026-11-24.md` (point 14), task text | – |
| **2 Theory** ("Siri"): Nimbus 5 ESMR, SIC from one channel, RTM + correction, sensitivity study (without L study) | `B1_sensitivity.md` (RTM sweep, ±1σ), `B1_writing_plan.md`, `B1_sensitivity_report.md` (draft), `ref_Tonboe2022_plots.md`, `C3_low_pressure.md` (wind ∝ (1 − c)) | `B1e_sweep_sic.png`, `B1_tornado.png` |
| **3 Data**: ESMR swath, ERA5 reanalysis, preprocessing / filters | `A1_data.md`, `A2_inputs.md`, `A3_filters.md`, `A3b_filter_validation.md` | `A2_tb_latlon_matlab.png`, `A3_tb_filtered.png`, `A3b_hard_cases.png` |
| **4 Methodology**: tie points, uncorrected / corrected SIC, uncertainty, evaluation | `A4_tiepoint_masks.md`, `A4b_tp_sweep.md` (A4b–A4d), `A4e_tp_outliers.md` (rejected), `A6b_iterative.md`, `B8_uncertainty.md` (method part), `pipeline_flowchart.html` | `A4_masks.png` |
| **5.1 Results Task 1**: open-water mean and std, uncorrected vs. corrected | `A6b_iterative.md` (section "Current numbers"), `B7_correction_map.md` | `A6b_iterative.png`, `A6b_hist.png`, `B7_correction_map.png` |
| **5.2 Results Task 2**: most important parameters (exclusion, data vs. RTM, L study) | `B1_sensitivity.md`, `B1i_L_study.md`, `B1e_tonboe_style.md`, `B1_writing_plan.md` | `B1c_exclusion.png`, `B1h_scatter_*.png`, `B1i_L_study.png` |
| **5.3 Results Task 3**: incidence angle (incl. outer scan positions) | `B2_angle.md` | `B2_std_vs_angle.png`, `B2_mean_vs_angle.png` |
| **5.4 Uncertainty** (higher over multiyear ice) | `B8_uncertainty.md` | `B8_uncertainty_map.png` |
| **5.5 Case studies**: one low (12 Feb), lows over the month, atlases | `C3_low_pressure.md`, `C3b_low_month.md`, `C1_SP459_comparison.md`, `C2_feb1973_books.md`, `C2_SP489_arctic_book.md` | `C3_low_map.png`, `C3_low_transect.png`, `C3b_low_month.png`, `C2_feb1973_maps.png`, `C2b_maps.png` |
| **5.6 Recommendation (Task 4)** | to come (B4); inputs in B1 ("Hand over to Task 4"), B2, B7 | – |
| **6 Discussion**: geography of Task 1/2, ice edge, multiyear ice, limitations, deviations from Kolbe et al. | `B7_correction_map.md`, `B8_uncertainty.md` (multiyear ice), `B2_angle.md` (side asymmetry), `A4_tiepoint_masks.md` (272 K), `meeting_2026-11-24.md` | – |
| **7 Conclusion** | back to Task 1–4 | – |
| Figures / seminar | `globe_viewer.md` | `globe/ESMR_globe.html` |

## Key numbers (1–27 Feb 1973, mean of the daily values, iteration 2)

| | Arctic | Antarctic | Note |
|---|---|---|---|
| water / ice tie-point pixels per day | 23 443 / 61 552 | 100 023 / 7 901 | A6b |
| T_p,water / T_p,ice corrected | 142.65 / 225.96 K | 136.53 / 212.22 K | A6b |
| **σ open-water SIC uncorrected → corrected** | **9.40 → 6.76 %** (−28 %) | **9.76 → 8.04 %** (−18 %) | A6b, Task 1 |
| σ ice SIC uncorrected → corrected | 12.37 → 10.74 % | 22.85 → 22.54 % | A6b |
| exclusion: σ water increase without V / W | +1.13 / +1.54 | +0.99 / +0.38 | B1c, Task 2 |
| per-pixel L instead of mean L (σ water) | 10.44 % | 12.22 % | B1i |
| σ water corrected, 0–20° → outer positions | 6.6 → 8.2 % | 6.5 → 11.5 % | B2, Task 3 |
| total uncertainty open water u → c | 14.4 → 11.3 % | 13.1 → 10.7 % | B8 |
| extent ours / book, edge agreement | 17.36 / 16.58 Mkm², 96.9 % | 5.31 / 4.83 Mkm², 98.2 % | C2 |

## All notes

| Step | File | Status |
|---|---|---|
| A1 Read data | [A1_data.md](A1_data.md) | |
| A2 RTM inputs | [A2_inputs.md](A2_inputs.md) | |
| A3 Filters | [A3_filters.md](A3_filters.md) | current |
| A3b Preprocessing validated against DMI's field | [A3b_filter_validation.md](A3b_filter_validation.md) | (d) current |
| A4 Tie-point masks | [A4_tiepoint_masks.md](A4_tiepoint_masks.md) | current |
| A4b–A4d Tie-point mask sweeps (SST, latitude, land box) | [A4b_tp_sweep.md](A4b_tp_sweep.md) | sweeps = history, 272 K decision added |
| A4e Tie-point outlier test (tried, not used) | [A4e_tp_outliers.md](A4e_tp_outliers.md) | history |
| A5 Uncorrected SIC | [A5_uncorrected_sic.md](A5_uncorrected_sic.md) | history (superseded by A6b) |
| A6 Corrected SIC | [A6_corrected_sic.md](A6_corrected_sic.md) | history (superseded by A6b) |
| A6b Iterative correction (final) | [A6b_iterative.md](A6b_iterative.md) | current (top section) |
| D1 Task 1 with Axel's pipeline (bugs fixed) – cross-check | [D1_concept_task1.md](D1_concept_task1.md) | history (16 Nov) |
| B1 RTM sensitivity + sweep + exclusion test (Task 2) | [B1_sensitivity.md](B1_sensitivity.md) | current |
| B1 writing plan / report draft (Task 2) | [B1_writing_plan.md](B1_writing_plan.md), [B1_sensitivity_report.md](B1_sensitivity_report.md) | numbers current |
| B1e Tonboe-style data vs. RTM | [B1e_tonboe_style.md](B1e_tonboe_style.md) | numbers partly old (see B1 writing plan 3b) |
| Reference: how Tonboe et al. (2022) plot sensitivity | [ref_Tonboe2022_plots.md](ref_Tonboe2022_plots.md) | |
| B1i L study: mean L vs. per-pixel L | [B1i_L_study.md](B1i_L_study.md) | current |
| B2 Std vs. incidence angle, whole swath (Task 3) | [B2_angle.md](B2_angle.md) | current |
| B7 Where the correction changes the SIC (map) | [B7_correction_map.md](B7_correction_map.md) | current |
| B8 SIC uncertainty (Kolbe Eq. 18–19) | [B8_uncertainty.md](B8_uncertainty.md) | current |
| C1 NASA SP-459 (Antarctic) | [C1_SP459_comparison.md](C1_SP459_comparison.md), [C1_sp459_steps.html](C1_sp459_steps.html) | current (fix section) |
| C2 Feb 1973 against both books (SP-489, SP-459) | [C2_feb1973_books.md](C2_feb1973_books.md), [C2_SP489_arctic_book.md](C2_SP489_arctic_book.md) | current |
| C3 Low-pressure example, 12 Feb 1973 | [C3_low_pressure.md](C3_low_pressure.md) | current |
| C3b Lows over the whole month | [C3b_low_month.md](C3b_low_month.md) | current |
| Visualisation | [globe_viewer.md](globe_viewer.md) | |
| Pipeline overview | [pipeline_flowchart.html](pipeline_flowchart.html) | 17 Nov state |
| Session 2026-11-13, questions 13 / 17 Nov | [questions_2026-11-13.md](questions_2026-11-13.md), [questions_2026-11-17.md](questions_2026-11-17.md) | decisions |
| Meetings 2026-11-17 / 20 / 24 | [meeting_2026-11-17.md](meeting_2026-11-17.md), [meeting_2026-11-20.md](meeting_2026-11-20.md), [meeting_2026-11-24.md](meeting_2026-11-24.md) | decisions, to-dos |
| Recomputes 23 / 24 Nov: old → new numbers | [rerun_2026-11-23.md](rerun_2026-11-23.md), [rerun_2026-11-24.md](rerun_2026-11-24.md) | |

## Still open (meeting 2026-11-24)
- B4: Task 4 recommendation.
- Multiyear ice: our B8 map shows MYI as low SIC, not as higher δc (see `B8_uncertainty.md`); decide how to show it.
- Check all report figures for clipped SIC (Tonboe: no clipping in the plots).
- ERA5 text: reanalysis = all observations that existed in 1973 (argument and limit).
