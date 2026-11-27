# PlotsReport: all report figures

Common folder for every figure that goes into the report (one-column LaTeX). `main/` = main part, `appendix/` =
appendix. All figures follow `plot_rules.md` (land grey, SIC in %, SIC jet, T_B parula, corrections red-white-blue,
LaTeX font 24 pt at 1250 px width = about 9 pt in the PDF, panels (a), (b), ..., Arctic top / Antarctic bottom, no main
title). Captions: `captions.md` (draft, from the `% caption (report)` comments in the scripts).

| Figure | Folder | Script (branch `jo`, `src/matlab/`) |
|---|---|---|
| B1c_exclusion | main | b1c_exclusion.m |
| B1e_sweep_sic_antarctic / _arctic | main / appendix | b1e_sweep_sic.m |
| B1f_scatter_ow | main | b1f_scatter_ow.m |
| B1g_scatter_ice | main | b1g_scatter_ice.m |
| B1i_L_study | main | b1i_L_study.m |
| B2_std_vs_angle | main | b2_angle.m |
| B7_correction_map | main | b7_correction_map.m (size not changed) |
| B8_uncertainty_map / B8_uncertainty_parts | main / appendix | b8_uncertainty.m |
| C1_sp459_side_by_side | main | c1_sp459_compare.m |
| C2_sp489_side_by_side | appendix | c2d_sp489_side_by_side.m |
| C2_feb1973_maps | appendix | c2_feb1973_books.m |
| C2b_maps_arctic / _antarctic | appendix | c2b_prof_figures.m |
| C3_low_era5, C3_low_sic | main | c3_low_case.m |
| D1_sic_day_map, D2_tiepoint_tb_map | main | d1_day_maps.m (our pipeline, same day as AX1-AX3) |
| AX4_sic_std_month, AX5_tb_std_month | main | axel_figures.m (data: Axel's `.fig`, branch `Axel`) |
| AX1_tiepoint_tb_map, AX2/AX3_sic_*_map | appendix | axel_figures.m |

New figures: call `report_style(fig, 'width', 'full', 'aspect', h/w)` (copy in this folder; source in branch `jo`)
right before `exportgraphics`, then copy the PNG to `main/` or `appendix/`.
