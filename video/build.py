"""Build the explainer video.

Steps (each can be run alone):
  tts      narration clips per sentence (edge-tts, cached by text) -> output/video/tts/
  timeline sentence start times -> output/video/timeline.js, narration.wav
  render   frame-by-frame capture of video/player.html with headless Chrome -> output/video/ESMR_pipeline_explainer.mp4

Usage (from the project root):
  .venv/bin/python video/build.py                 # all steps
  .venv/bin/python video/build.py render --from 120 --to 150 --fps 10   # quick check of a part
  .venv/bin/python video/build.py still 95.0      # one frame as PNG (output/video/still_95.0.png)

Needs: output/video/video_data.js (matlab -batch "run('src/matlab/video_export.m')"), ffmpeg, Google Chrome,
pip packages edge-tts and playwright (in .venv).
"""
import asyncio, hashlib, json, re, subprocess, sys, wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'output' / 'video'
TTS = OUT / 'tts'
VOICE, RATE = 'en-US-AndrewMultilingualNeural', '-5%'
SR = 24000
LEAD, GAP, SCENE_GAP, TAIL = 0.8, 0.45, 1.3, 2.0


def parse_script():
    scenes = []
    for line in (ROOT / 'video' / 'script.md').read_text().splitlines():
        m = re.match(r'^## (\w+) \| (.+?) \| (.+)$', line)
        if m:
            scenes.append(dict(id=m[1], step=m[2], title=m[3], lines=[]))
            continue
        m = re.match(r'^\{([\w+.]+)\} (.+)$', line)
        if m and scenes:
            scenes[-1]['lines'].append(dict(cue=m[1], text=m[2].strip()))
    return scenes


def clip_path(text):
    h = hashlib.sha1(f'{VOICE}|{RATE}|{text}'.encode()).hexdigest()[:12]
    return TTS / f'{h}.mp3'


async def tts(scenes):
    import edge_tts
    TTS.mkdir(parents=True, exist_ok=True)
    todo = [l['text'] for s in scenes for l in s['lines'] if not clip_path(l['text']).exists()]
    for i, text in enumerate(todo):
        for attempt in range(4):
            try:
                await edge_tts.Communicate(text, VOICE, rate=RATE).save(str(clip_path(text)))
                if clip_path(text).stat().st_size < 1000: raise RuntimeError('empty clip')
                break
            except Exception as e:
                print('retry', attempt, e); clip_path(text).unlink(missing_ok=True); await asyncio.sleep(2 + 3 * attempt)
        else:
            raise RuntimeError(f'tts failed: {text}')
        print(f'tts {i + 1}/{len(todo)}', flush=True)


def pcm(path):
    raw = subprocess.run(['ffmpeg', '-v', 'error', '-i', str(path), '-f', 's16le', '-ac', '1', '-ar', str(SR), '-'],
                         capture_output=True, check=True).stdout
    return raw


def timeline(scenes):
    t = LEAD
    audio = bytearray()
    for s in scenes:
        s['start'] = round(t, 3)
        for l in s['lines']:
            raw = pcm(clip_path(l['text']))
            dur = len(raw) / 2 / SR
            l['start'], l['dur'] = round(t, 3), round(dur, 3)
            pos = int(round(t * SR)) * 2
            audio.extend(b'\0' * (pos + len(raw) - len(audio)))
            audio[pos:pos + len(raw)] = raw
            t += dur + GAP
        t += SCENE_GAP - GAP
        s['end'] = round(t, 3)
    total = t + TAIL
    audio.extend(b'\0' * (int(total * SR) * 2 - len(audio)))
    with wave.open(str(OUT / 'narration.wav'), 'wb') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes(bytes(audio))
    tl = dict(duration=round(total, 3), scenes=scenes)
    (OUT / 'timeline.js').write_text('TIMELINE = ' + json.dumps(tl) + ';')
    land = (ROOT / 'src' / 'web' / 'land-50m.json').read_text()
    (OUT / 'land.js').write_text('LAND = ' + land + ';')
    print(f'timeline: {len(scenes)} scenes, {sum(len(s["lines"]) for s in scenes)} lines, {total:.1f} s')
    return tl


async def render(t0=None, t1=None, fps=25, still=None):
    from playwright.async_api import async_playwright
    tl = json.loads((OUT / 'timeline.js').read_text()[len('TIMELINE = '):-1])
    t0 = 0 if t0 is None else t0
    t1 = tl['duration'] if t1 is None else min(t1, tl['duration'])
    async with async_playwright() as p:
        b = await p.chromium.launch(channel='chrome', args=['--force-device-scale-factor=1'])
        pg = await b.new_page(viewport=dict(width=1920, height=1080))
        pg.on('console', lambda m: print('page:', m.text) if m.type in ('error', 'warning') else None)
        pg.on('pageerror', lambda e: print('page error:', e))
        await pg.goto((ROOT / 'video' / 'player.html').as_uri() + '?capture=1')
        await pg.wait_for_function('window.READY === true', timeout=120000)
        if still is not None:
            for st in still:
                await pg.evaluate(f'renderAt({st})')
                f = OUT / 'stills' / f'still_{st:06.1f}.jpg'
                f.parent.mkdir(exist_ok=True)
                await pg.screenshot(path=str(f), type='jpeg', quality=80)
                print(f)
            await b.close(); return
        part = t0 > 0 or t1 < tl['duration']
        name = f'part_{t0:g}-{t1:g}.mp4' if part else 'frames.mp4'
        vid = OUT / name
        ff = subprocess.Popen(['ffmpeg', '-v', 'error', '-y', '-f', 'image2pipe', '-framerate', str(fps), '-c:v', 'mjpeg',
                               '-i', '-', '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-crf', '18', '-preset', 'medium',
                               str(vid)], stdin=subprocess.PIPE)
        n = int((t1 - t0) * fps)
        for i in range(n):
            for attempt in range(5):   # survives a short stall (e.g. the laptop sleeping)
                try:
                    await pg.evaluate(f'renderAt({t0 + i / fps})')
                    ff.stdin.write(await pg.screenshot(type='jpeg', quality=92, timeout=120000)); break
                except Exception as e:
                    print('retry frame', i, attempt, str(e).splitlines()[0], flush=True)
                    if attempt == 4: raise
            if i % (fps * 10) == 0:
                print(f'frame {i}/{n}  t = {t0 + i / fps:.1f} s', flush=True)
        ff.stdin.close(); ff.wait()
        await b.close()
    final = OUT / ('ESMR_pipeline_explainer.mp4' if not part else name.replace('.mp4', '_av.mp4'))
    subprocess.run(['ffmpeg', '-v', 'error', '-y', '-i', str(vid), '-ss', str(t0), '-t', str(t1 - t0),
                    '-i', str(OUT / 'narration.wav'), '-map', '0:v', '-map', '1:a', '-c:v', 'copy', '-c:a', 'aac',
                    '-b:a', '160k', '-shortest', str(final)], check=True)
    print('saved', final)


def main():
    a = sys.argv[1:]
    step = a[0] if a and not a[0].startswith('--') else 'all'
    opt = lambda k, d=None: float(a[a.index(k) + 1]) if k in a else d
    scenes = parse_script()
    if step in ('all', 'tts'):
        asyncio.run(tts(scenes))
    if step in ('all', 'tts', 'timeline'):
        timeline(scenes)
    if step in ('all', 'render'):
        asyncio.run(render(opt('--from'), opt('--to'), int(opt('--fps', 25))))
    if step == 'still':
        asyncio.run(render(still=[float(x) for x in a[1:]]))


if __name__ == '__main__':
    main()
