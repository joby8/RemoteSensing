# Feedback session 2026-11-13 – questions for Tonboe

Status: A1–A6 done (Task 1 answered). Write the answers under each question.

## Show first

1. Globe viewer with the preprocessing slider: `output/globe/ESMR_globe.html`
2. `output/A6_sic_corrected.png`: histogram and daily std before/after
3. The L result as discussion point (see 1.2)

## 1. Task 1 – check results

**Our numbers (Feb 1973, without 28 Feb):** std open-water SIC N 10.6 → 8.7 %, S 11.5 → 9.6 % (−17 %); std T_B 8.5 → 7.0 K.

1. **Is −17 % realistic for ESMR?** What did he expect?
   - Answer:
2. **L not corrected:** with per-pixel L (tcw − tcwv) the std gets *worse* than uncorrected (N 11.5 %, S 13.7 %). Is it OK to use the mean L in both RTM runs, as in the paper (Sect. 4.1)? Is there a better proxy for L (e.g. ERA5 `tclw`)?
   - Answer:
3. **Tie points daily or smoothed:** we use daily tie points, the paper a 15-day running mean. Should we test that too?
   - Answer: **calibration per day** (confirmed, ✓ in notes).
4. **5×5-box criterion** (distance from the ice edge) is not applied. Needed for the water tie points near the ice?
   - Answer:
5. **Antarctic ice tie point:** only 3–6 k pixels per day with siconc ≥ 0.95. Enough, or use &gt; 0.8 as in Table 2?
   - Answer: use the ERA5 algorithm → use ERA5 SIC for the T_B model, with the criteria of **Table 2** (see notes; interpretation to confirm).

## 2. Task 2 – exclusion test (next step)

6. **How exactly?** Plan: fix one of V, W, Ts, Ti at its mean and see how much the std grows. Or does he mean an RTM sensitivity study (ΔT_B per unit of each input)? He said "sensitivity" in the last meeting.
   - Answer: **sensitivity study with the RTM.**
7. **Ti and the ice side:** over water Ti has no effect. Should we also do the test on the ice side and compare Eq. 15 with ERA5 `istl1` (he asked for better T_i values)?
   - Answer:

## 3. Task 3 – std vs. incidence angle

8. **Cut before the analysis?** Scan positions 1–4/75–78 are removed so far. For Task 3, keep all angles up to ±63.9° to show where the noise rises?
   - Answer:
9. **Plot:** std of SIC per θ bin, uncorrected vs. corrected. Enough, or also ΔT_B vs. θ like paper Fig. 4?
   - Answer:

## 4. Organisation

10. **Seminar 4 Dec:** length? number of slides?
    - Answer:
11. **Report:** length or structure required? Is one month (Feb 1973) enough, or use more data?
    - Answer:

## Notes / next steps agreed

Handwritten notes from the session (transcribed):

- Calibration per data set / **day** / etc. → **per day** ✓
- → **Standard deviation per day, north and south** → of the tie points ice/water
- → **Use ERA5 algorithm → use SIC for T_B model** (→ Table 2)
- **Sensitivity study with the RTM** (Task 2)

Our reading (to confirm with the group / Tonboe if unclear):

- Report the std **per day and hemisphere** (time series), for the water **and** the ice tie points, not only one monthly number.
- Tie-point selection exactly as in **Table 2** (ice: ERA5 siconc &gt; 0.8, Arctic lat &gt; 32°, Antarctic lat &lt; −48°), and use the **ERA5 SIC as c_ice in the RTM** instead of fixed 0/1.
- Task 2 = RTM sensitivity: ΔT_B per unit change of V, W, L, Ts, Ti (and θ).

Also discussed (verbally): Tonboe liked the RTM animation in the learning page (Sect. 4); we need to find a way to get it into the report → idea and first figure in [B1_sensitivity.md](B1_sensitivity.md).
