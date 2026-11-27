# PlotsReport: all report figures

Common folder for every figure that goes into the report. All figures follow `plot_rules.md` (land grey, SIC in %,
SIC jet, T_B parula, corrections red-white-blue, LaTeX font 24 pt, panels (a), (b), ..., Arctic top / Antarctic
bottom, no main title). The caption text for each figure is the comment `% caption (report): ...` in its script.

| Figure | Script (branch `jo`, `src/matlab/`) |
|---|---|
| A3b_hard_cases | a3b_validate_filters.m |
| AX1_tiepoint_tb_map, AX2_sic_uncorrected_map, AX3_sic_corrected_map, AX4_sic_std_month, AX5_tb_std_month | axel_figures.m (data: Axel's `.fig`, branch `Axel`) |
| B1c_exclusion | b1c_exclusion.m |
| B1e_sweep_sic | b1e_sweep_sic.m |
| B1f_scatter_ow | b1f_scatter_ow.m |
| B1g_scatter_ice | b1g_scatter_ice.m |
| B1i_L_study | b1i_L_study.m |
| B2_std_vs_angle | b2_angle.m |
| B7_correction_map | b7_correction_map.m |
| B8_uncertainty_map | b8_uncertainty.m |
| C1_sp459_side_by_side | c1_sp459_compare.m |
| C2_feb1973_maps | c2_feb1973_books.m |
| C2_sp489_side_by_side | c2d_sp489_side_by_side.m |
| C2b_maps | c2b_prof_figures.m |
| C3_low_map | c3_low_case.m |

New figures: call `report_style(fig)` (copy in this folder; source in branch `jo`) right before `exportgraphics`, then copy the PNG here.
Known open point: at 16 cm text width the 24 pt text is only about 3.5-6 pt in the PDF (see `plot_rules.md`).
