# Globe setup

The interactive globe (`output/globe/ESMR_globe.html`) shows the whole processing step by step on the real February 1973 data.
It is a single local HTML page, so it needs no server and no internet. It opens by double-click.

## What is in git
- `output/globe/ESMR_globe.html`: the page, with libraries and coastlines inlined.
- `output/globe/days/0201.js`: data for 1 February, the day the page opens on.

The other days (`days/MMDD.js`, up to about 20 MB each) and the Feb 1973 book comparison (`feb1973.js`, step 8) are generated locally.
After a fresh clone, the page works for 1 February only. Step 8 then shows "Run src/matlab/c2_feb1973_books.m".

## Requirements
- MATLAB (tested with R2024a). Only base MATLAB is used, no toolboxes.
- The ESMR swath data `ESMR_colocated_filtered/` (312 NetCDF files, 5.6 GB). It is not in git and is shared separately.
  Put the folder in the repo root.

## Build
Run every command from the repo root.

```sh
# 1. all 28 days + the page (one data file per day in output/globe/days/)
matlab -batch "run('src/matlab/globe_html.m')"

# 2. step 8: Feb 1973 monthly map vs. the NASA atlases (writes output/globe/feb1973.js; the first run fills output/C2_cache/)
matlab -batch "run('src/matlab/c2_feb1973_books.m')"
```

Some extra commands:
- **Only some days:** `matlab -batch "days=[\"0201\",\"0202\"]; run('src/matlab/globe_html.m')"`.
  Days that already exist stay in the page, because the page lists all `days/*.mat` it finds.
- **Rebuild only the page after a change in `src/web/globe_template.html`:** run the "only some days" command with `days=[\"0201\"]` (about 20 s).
- **Other preprocessing settings:** `matlab -batch "cfg = preproc_config('paper'); run('src/matlab/globe_html.m')"`.

## Open
Double-click `output/globe/ESMR_globe.html`, or open it in Chrome, Safari or Firefox.

How to use it:
- Drag to rotate, scroll to zoom, ← → to change the day.
- Hover a pixel for details. Click to pin it, Esc to unpin.
- Steps 0–8 in the side panel follow the processing (data → preprocessing → tie points → SIC → RTM correction → Tasks 1–3 → book comparison).

## Files
| File | Role |
|---|---|
| `src/web/globe_template.html` | page source (edit this, not the built HTML) |
| `src/matlab/globe_html.m` | builds the day files and inlines the template into the page |
| `src/matlab/correct_day.m`, `tp_masks.m`, `esmr_preprocess.m`, `preproc_config.m` | processing used for every day |
| `src/matlab/c2_feb1973_books.m` | monthly map + book comparison for step 8 |
| `report_notes/globe_viewer.md` | what the globe shows and how it was checked |
