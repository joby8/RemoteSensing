# C2 - February 1973: our SIC against both reference books (SP-489 Arctic, SP-459 Antarctic)

**Code:** `src/matlab/c2_feb1973_books.m` (about 25 s with cache `output/C2_cache/`, 2 min without). C1 is unchanged.
**Output:** `output/C2_feb1973_maps.png`, `output/C2_conc_compare.png`, `output/C2_feb1973_books.csv`, `output/C2_feb1973_classes.csv`,
`output/C2_classified_scans.png` (check figure of the colour classification), `output/globe/feb1973.js` (0.82 MB).

## Method
- **Our map:** as C1 for both hemispheres. Per day `correct_day.m` (A6b, iteration 2), SIC per pixel with the day's corrected tie points of its hemisphere,
  mean of the unclipped pixel SIC per cell, then clip to 0-100 %. Days 0201-0228 (all files; 28 Feb has one orbit only, as in C1). Land = ERA5 (sst NaN).
- **Grids** (sphere, Re = 6371 km, 30 km, L = 4800 km, n = 320). South: u = 2Re tan((90+lat)/2) sin(lon), v = +2Re tan((90+lat)/2) cos(lon).
  North: u = 2Re tan((90-lat)/2) sin(lon), v = -2Re tan((90-lat)/2) cos(lon) (0 deg down, 90E right). Row 1 = bottom.
- **Georeference SP-489:** affine fit (image = t + A [tan(colat/2) sin(lon); tan(colat/2) cos(lon)]) to 696 points found automatically on the parallels
  50-85 N and on the 45 deg meridians (darkest thin line, outlier rejection). **rms 0.64 px = 4.0 km** (about 1/7 cell). The scan is about 3.5 % stretched
  vertically; the search window starts wide (26 px, was 10 px) so that the fit finds this (fixed 2026-11-18: before, the printed parallels at the top and bottom
  were 9-15 px = 60-90 km outside our circles; the 195 points of the old fit lay mostly left and right). The map is rotated by 45 deg
  (135E up); this is inside A. South: as C1, rms 1.6 px = 9 km.
- **Classification:** every pixel to the nearest swatch in CIE Lab. North swatches: legend first-year column (F_MY = 0), sampled in the legend crop, plus
  3 water and 5 land swatches sampled in the map and a black line swatch. Cell = majority of the non-line pixels in 5x5 (N) / 7x7 (S) pixels.
  Ice cell needs >= 3 ice neighbours (as C1). Ice = class >= 14 %. Classes: 22 ice classes of 4 %, lower bounds 14, 18, ..., 98 (midpoints 16, ..., 96, 99).
- **Fixes found by looking at the classified map (differences to C1):**
  1. Violet (100 % WET) was matched to the navy swatch "26-30 %" (14000 px). That swatch is dropped. A real 26-30 % edge band is rare, so the effect is small.
  2. Thin black coast and graticule lines match the near-black classes (42, 66-78, 94 %). Dark blobs < 5 px are treated as line. Isolated land cells (graticule dots) -> water.
  3. South: the dark-grey swatch of class 76 % is also the printed coastline. Such a cell counts as ice only if >= 2 neighbours are ice of another class.
     This lowers the South book extent from 5.90 (C1) to 5.23 x 10^6 km2 (both lat <= -50).
- Common cells: book ocean + our ocean data, lat >= 50 N / <= -50 S (same limit in both hemispheres, = preprocessing |lat| >= 50; C1 used -52 before 2026-11-18). Our ice = mean SIC >= 15 %.

## Results (common cells, 10^6 km2)
| | Arctic (SP-489) | Antarctic (SP-459) |
|---|---|---|
| common area | 28.14 | 44.78 |
| extent ours / book | 16.03 / 15.60 | 5.33 / 5.23 |
| both ice / only ours / only book | 15.06 / 0.98 / 0.54 | 4.67 / 0.66 / 0.57 |
| agreement (ice and water) | 94.6 % | 97.2 % |
| ice area ours (SIC x A, ice cells) | 14.66 | 3.36 |
| ice area book (class midpoints) | 13.03 | 2.61 |
| ice area book, Table 3-2 | - (none for Feb 1973) | 2.71 |
| ice area ours, all cells in the hemisphere | 16.42 | 3.43 |
| mean (ours - book midpoint), cells with ice in one of them | +10.0 | +12.9 |
| tie points water / ice (month mean) | 144.4 K / 226.6 K | 140.9 K / 212.1 K |

Classes (`C2_feb1973_classes.csv`, `C2_conc_compare.png`): in both books our SIC rises with the class and lies above the 1:1 line from 30 % up.
South: mean SIC 31 % in the 14 % class, 56 % in 30-34 %, 80 % in 50 %, 88 % in 58 %, about 97 % above 80 %. North: 38 % in the 30 % class, 49 % at 46 %,
90 % at 58 % and above, 92-97 % for 82-90 %.

## Interpretation
- **Edge:** both hemispheres agree at the 95-97 % level. North: our edge is 0.4 x 10^6 km2 larger in total, but the pattern differs: "only ours" is
  along the Siberian and Alaskan coasts and the Labrador/E-Greenland ice edge, "only book" is mostly in the Barents/Kara coasts and inside the archipelago (coast mask and 1-cell shifts).
- **South, summer ice tie point:** the ice edge is fine, but concentrations are higher than the book (+13 points, area 3.36 vs 2.61 (classes) and 2.71 (Table 3-2)).
  Our ice tie point (212 K) comes from the ERA5 siconc > 0.8 cluster in summer (wet snow, melt) and is about 30 K below e_i T_i of the book (about 240 K).
  Same T_B gives higher SIC. The book total area is read from classes here; it is about 5 % below Table 3-2 (class midpoints and the dark-grey ambiguity).
- **North, multiyear ice:** SP-489 uses e = 0.92 (first-year) everywhere. In the central Arctic multiyear ice (e about 0.84) gives a pseudo concentration
  that is too LOW, so the book values there (mostly the 82-90 % classes) are lower than a true concentration. Our SIC is about 90-97 % there. The area gap
  (14.7 vs 13.0) is smaller than in the South because our North ice tie point (226.6 K) is closer to the book value than the summer South one,
  but the central-pack difference is the same sign. We do not model multiyear ice either (single ice tie point).
- **Limits of the book classes:** near-black swatches (42, 66-78, 94 %) are not separable from each other or from the coast lines. The classes 70, 74 and 94 % (North) and 74 % (South)
  have a large std in the class table and should not be interpreted. Violet = 98 % and above (WET) is separated from land and water.

## Globe export (`output/globe/feb1973.js`)
`ESMR_MONTH({N: H, S: H});` with H = proj {Re, dx, L, n, hemi}, bbox {r0, r1, c0, c1} (1-based; both hemispheres r 6..315, c 6..315 = cells with |lat| >= 50),
sic / book / agree (base64 uint8, row-major over the crop, first row = r0 = lowest v), edge_ours / edge_book (arrays of [[lat, lon], ...], 0.01 deg),
stats, src, classes (lower bounds 14, 18, ..., 98). Values: sic 0-100, 254 land, 255 no data; book 0 water, class lower bound, 254 land, 255 outside;
agree 0 not compared, 1 both ice, 2 only ours, 3 only book, 4 both water.

## For the report
Figure `C2_feb1973_maps.png` (rows Arctic/Antarctic) and the results table above. Statements: edge agreement 93 % / 97 %; concentrations higher than the books
(South: summer ice tie point; North: pseudo concentration from multiyear ice in the book). Cite Zwally et al. 1983 and Parkinson et al. 1987.

## Cells only one map has (2026-11-18)
All numbers use only the common cells (ocean in both maps, book readable, |lat| >= 50). Since 2026-11-18 the maps (`C2_feb1973_maps.png`, globe
layers "Our SIC" / "Book") and both edge lines also show only these cells; ocean in one map only is light grey ("not compared"). Stats unchanged.
Cells left out (10^6 km2, in brackets the part with ice):

| | Arctic | Antarctic |
|---|---|---|
| ocean in both (compared) | 27.42 | 44.34 |
| ours ocean, book land | 2.59 (2.37) | 0.08 (0.08) |
| book ocean, ours land | 0.72 (0.51) | 0.44 (0.43) |
| ours ocean, book unreadable / outside the scan | 0.08 | 1.61 (water) |

- Reason: two land masks (ours: ERA5 sst missing; book: printed 1970s coastline), not the georeference (rms 4 km N, 9 km S < 1 cell).
- North: mostly Canadian Archipelago channels and narrow bays printed as land; ERA5 also has sst on large lakes (Canada), which we would count as ocean.
- South: ice shelf fronts (book ocean, ERA5 land).
- We do not adjust one mask to the other: there is no reference for which coastline is right; comparing common cells is the fair choice.
