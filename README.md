# 30350 Remote Sensing – Project 1: Regional noise reduction of NIMBUS 5 ESMR SIC

Group project (DTU 30350). `main` holds only the material given for the project; do not commit work directly to it.

## Contents of `main`
- `docs/read_me.txt` / `read_me.docx` – task description
- `docs/Kolbe_etal_essd-16-1247-2024.pdf` – method paper
- `docs/Tellefsen_etal_essd-18-2891-2026.pdf` – newer paper (optional)
- `provided/` – RTM code (`esmr_rtm.py`/`.m`), `spos2ia.txt`, resampling example

## Data (not in git)
The ESMR swath NetCDFs (`ESMR_colocated_filtered/`, 5.6 GB) are shared separately. Place the folder in the repo root; it is git-ignored.

## Workflow
Everyone works on their own branch (`jo`, `<name>`, ...) created from `main`:

    git clone https://github.com/joby8/RemoteSensing.git
    git checkout -b <yourname>
    # work, commit
    git push -u origin <yourname>

Merge results into `main` via pull request when the group agrees.
