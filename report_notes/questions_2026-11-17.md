# Questions for Tonboe (after the meeting 2026-11-17)

Status: preprocessing is now one configurable step (`src/matlab/preproc_config.m`, `esmr_preprocess.m`). The default was set by Jo on 2026-11-17, and all results in `output/` were re-run with it. Details are in `A3_filters.md` and `A3b_filter_validation.md`. Write the answers under each question.

**Default preprocessing (source = raw `Brightness_temperature`):**
- analog filter (off)
- Eq. 1, per pixel
- Eq. 2, per pixel (offset blocks)
- Eq. 3 in line mode: a spike on the raw T_B removes its line and the line on each side, no wrap-around
- Eq. 4
- swath edge (positions 1–4/75–78)
- |lat| ≥ 50°
- land (ERA5 SST missing)

## 1. Filters

1. **Is our per-pixel Eq. 2 OK?**
   - In the data, failing line pairs come in pairs: an offset block of about 7–8 lines (max 20) is shifted by about ±100 K.
   - Paper Eq. 2 as written removes line i of each failing pair. That is the good line before the block and the last line of the block, so most of the block is kept.
   - What we do instead: in a short run (≤ 20 lines) between a jump and the jump back, we remove only the pixels that differ by more than 50 K from the good lines around the run.
   - Is that acceptable, or should we follow the literal text?
   - Answer:
2. **Is the Eq. 3 line buffer OK?**
   - A raw-T_B spike (sum > 150 K) now removes its line and the line on each side.
   - We found this rule in DMI's `brightness_temperature_filtered` (A3b, 71.6 % recall, 96.5 % precision).
   - The lines next to a spike carry degraded, too-cold values (10 Feb: 406 water tie-point pixels at 101–154 K). Per-pixel Eq. 3 does not catch them.
   - Cost: about 1 % of the used area.
   - Answer:
3. **Analog filter: should we apply it?**
   - The paper says "anything over a value of 10 is removed". The units of the 16 `Analog_<k>` channels are unknown, and the user's guide does not explain them. Several channels jump by exactly 256/512 (bit flips).
   - DMI's field matches a central gradient > 10 in channels 0–14 only, with ± 5 lines. Analog_15 is not used, which looks like an off-by-one (`range(15)`).
   - Downstream it changes the water SIC std by ≤ 0.06 points. We keep it off.
   - Is that OK, and does DMI really leave out Analog_15?
   - Answer:

## 2. Correction

4. **c = 0/1 for the tie-point pixels in Eq. 14, or our own SIC?**
   - In our iteration the tie-point pixels get the c of the previous step: ERA5 siconc in iteration 1, our clipped SIC in iteration 2.
   - The literal reading of Eq. 14 would use fixed c = 0 for water and c = 1 for ice.
   - With literal 0/1 the water std is about 0.2–0.5 points higher.
   - Which one is intended?
   - Answer:
5. **Is our iteration scheme OK, compared with the paper?**
   - Paper (p. 1253–1254): one RTM correction, starting from the uncorrected SIC.
   - Ours (A6b, `correct_day.m`): iteration 1 starts from ERA5 siconc, then we iterate once more with c from the corrected SIC (iteration 2 = final). Iteration 3 changes < 0.4 points.
   - This is an intentional deviation. Is it acceptable, or should we report the paper's scheme as the main result?
   - Answer:

## 3. Tie-point masks

6. **Is the ERA5 land-sea mask criterion (lsm = 0) OK?**
   - Paper Table 2 has no lsm criterion. Land is handled later on the grid (Sect. 4.3).
   - We require lsm == 0 for both clusters (`tp_masks.m`). On 20 Feb 1973 this removes 24 142 of 109 303 ice candidates (22 %).
   - Keep it, relax it (e.g. lsm < 0.1), or drop it?
   - Answer:
