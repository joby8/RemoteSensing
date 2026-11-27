# Figure captions (draft)

Captions for every figure in `main/` and `appendix/`. They are collected from the `% caption (report)` comments in
the scripts. Panel letters match the (a), (b), ... in the figures. All figures are made for the one-column report:
`\includegraphics[width=\textwidth]{...}` (D2 and AX1-AX3: `width=0.5\textwidth`). 24 pt in MATLAB then gives about
9 pt in the PDF.

## Main part

**B1c_exclusion**: Exclusion test (Task 2). The RTM correction is run with one ERA5 input left out, 1-27 Feb 1973.
Bars: std of the SIC (mean of the daily values) for the water (left) and ice (right) tie-point pixels, (a, b) Arctic,
(c, d) Antarctic. Number in brackets: increase of the std compared with the full correction (dashed line). L is never
corrected.

**B1e_sweep_sic_antarctic**: RTM sweep (Task 2), Antarctic. One ERA5 input is varied over its full range, all others
stay at the February 1973 mean of the tie-point cluster. Solid: water (c = 0), dashed: ice (c = 1). Light to dark:
incidence angle 0°, 30°, 50°. Each curve is 0 at the mean of its own cluster. L = 0 in the V, W, T_s and T_i sweeps.
White band: observed 5-95 % range; grey line: mean; dotted: ±1σ of the water pixels (T_i: ice pixels). Box: SIC change
per 1σ at 50°. Right axis: the same change in ΔT_B. Arctic: Fig. B1e_sweep_sic_arctic (appendix).

**B1f_scatter_ow**: SIC of the open-water tie-point pixels (1-27 Feb 1973) against one ERA5 input at a time,
(a)-(d) Arctic, (e)-(h) Antarctic. Grey dots: single pixels without correction (random subsample of 15 000 per
panel). Lines: mean in 30 bins of the input (only bins with at least 200 pixels). Black: without correction. Blue: with
RTM correction (ideal: flat at 0 %). Orange dashed: SIC change that the RTM predicts when only this input varies and
all others stay at the cluster mean (shifted to mean 0). A flat blue line means that the correction removes the
influence of this input. V, L and W are correlated in the data, so the black line mixes several inputs; the orange
line does not.

**B1g_scatter_ice**: As B1f_scatter_ow for the ice tie-point pixels (ERA5 SIC > 80 %), (a)-(c) Arctic, (d)-(f)
Antarctic; ideal: flat at 100 %. T_i is not measured but taken from Eq. 15 (0.4 t2m + 0.6 × 272 K).

**B1i_L_study**: Should the cloud liquid water L be corrected? Open-water tie-point pixels, 1-27 Feb 1973, 2nd
iteration with the mean L (blue) or with the pixel's own ERA5 L (orange). (a, c) daily std of the SIC, numbers in the
legend: monthly mean; (b, d) mean SIC per L bin (ideal: 0). (a, b) Arctic, (c, d) Antarctic.

**B2_std_vs_angle**: Std of the open-water SIC against the incidence angle, 1-27 Feb 1973 (as Kolbe et al., 2024,
Fig. 5, in % SIC), all 78 scan positions (full swath), (a) Arctic, (b) Antarctic. Blue area: noise removed by the RTM
correction. Negative angle: left side of the swath.

**B7_correction_map**: Where the RTM correction changes the SIC, 1-27 Feb 1973, all ocean pixels |lat| ≥ 50°.
Columns: mean ΔSIC = corrected - uncorrected, its std over the month, and the input with the largest mean share of the
correction. Polar grid 50 km, cells with fewer than 20 pixels blank, land (ERA5) grey, circles every 10° latitude.

**B8_uncertainty_map**: SIC uncertainty as in Kolbe et al. (2024), Sect. 4.2, monthly mean of the daily values,
1-27 Feb 1973. (a, c) total uncertainty (Eq. 19) of the corrected SIC; (b, d) total uncertainty corrected -
uncorrected (blue: the correction lowers it). 30 km grid, cells with data on fewer than 3 days blank, land (ERA5) grey,
circles every 10° latitude. The two parts of the total: Fig. B8_uncertainty_parts (appendix).

**C1_sp459_side_by_side**: (a) NASA SP-459 (Zwally et al., 1983), Fig. 5-2a, February 1973; (b) this work, mean SIC
February 1973 (RTM-corrected) in the same colour classes. White: no data, black: land (ERA5). The atlas colours are
kept on purpose so that the two maps can be compared.

**C3_low_era5** and **C3_low_sic**: Low-pressure system over open water, 12 Feb 1973 (orbit 08:19 UTC), core 942 hPa
at 67.4° N, 4.5° W. C3_low_era5: (a) sea-level pressure, (b) wind speed W, (c) water vapour V, (d) cloud liquid water L
(ERA5). C3_low_sic: SIC of the open-water pixels (75 km mean) (a) without and (b) with correction, (c) ΔSIC =
corrected - uncorrected, (d) part of ΔSIC that comes from W. Black: isobars every 8 hPa; red: ERA5 ice edge (15 %);
x: core; dashed circle: 600 km around the core; magenta: transect line; grey: land. Window 3000 km, polar projection.

**D1_sic_day_map**: SIC on 2 Feb 1973 from this work, (a, c) without and (b, d) with the RTM correction (2 iterations,
daily tie points). All orbits of the day averaged on the 30 km polar grid (no interpolation), SIC not clipped, colour
scale 0-100 %. White: no data, grey: land (ERA5), circles every 10° latitude. Single empty ocean cells (gaps between
scan lines) are filled with the mean of their neighbours for the display only. Same day as AX2/AX3.

**D2_tiepoint_tb_map**: Corrected T_B of the tie-point pixels (water and ice clusters) on 2 Feb 1973, cell mean on the
30 km polar grid, (a) Arctic, (b) Antarctic. Grey: land. Same day as AX1.

**AX4_sic_std_month** (Axel): Daily std of the SIC, 1-27 Feb 1973, Arctic and Antarctic, corrected (solid) and
uncorrected (dashed).

**AX5_tb_std_month** (Axel): Daily std of the tie-point T_B (water and ice clusters), 1-27 Feb 1973, corrected (solid)
and uncorrected (dashed).

## Appendix

**B1e_sweep_sic_arctic**: As B1e_sweep_sic_antarctic for the Arctic.

**B8_uncertainty_parts**: The two parts of the total uncertainty in B8_uncertainty_map: (a, c) algorithm uncertainty
(Eq. 18), (b, d) resampling uncertainty (max - min in a 3 × 3 window). Same grid and period.

**C2_sp489_side_by_side**: (a) NASA SP-489 (Parkinson et al., 1987), Fig. 4-19a, February 1973; (b) this work in the
same colour classes. White: no data, dark grey: land (ERA5). Atlas colours kept on purpose.

**C2_feb1973_maps**: Mean SIC February 1973, (a, d) this work and (b, e) the atlas (SP-489 Arctic, SP-459 Antarctic,
class midpoints), (c, f) agreement with both 15 % edges; legend: areas in 10⁶ km². SIC < 15 % shown as 0. Coloured:
cells that are ocean in both maps (all numbers use these cells); light grey: no data or ocean in only one map; grey:
land.

**C2b_maps_arctic**, **C2b_maps_antarctic**: February 1973 monthly mean, this work vs. the NASA atlas (SP-489 Arctic,
SP-459 Antarctic): (a) atlas scan, (b) atlas read from the colours, (c) this work (SIC < 15 % shown as 0),
(d) agreement with both 15 % edges. Grey: land. Light grey: not compared (no data, or ocean in only one of the maps).

**AX1_tiepoint_tb_map**, **AX2_sic_uncorrected_map**, **AX3_sic_corrected_map** (Axel): T_B of the tie-point pixels
and SIC without / with correction on 2 Feb 1973 from Axel's pipeline, 0.25° grid. Land grey. Our version of the same
maps: D1, D2.
