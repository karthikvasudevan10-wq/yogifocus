import os, sys, math, random
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
from art import *
OUT = os.path.join(HERE, "header")
FONTS = "".join(f"@font-face{{font-family:'Baloo 2';font-weight:{'700 800' if w == 700 else w};src:url(file://{HERE}/scratch/package/files/baloo-2-latin-{w}-normal.woff2) format('woff2')}}" for w in (500, 600, 700))
W, H = 3840, 1646
SAFE = (1097, 493, 1646, 661)          # measured from Apple's template by a third party; Apple publishes none
def lot(size, cx, cy, cols, sep, sy=1.0, op=1.0, center=None):
    return (f'<svg aria-hidden="true" viewBox="-150 -150 300 300" width="{size}" height="{size}" style="position: absolute; left: {cx - size/2}px; top: {cy - size/2}px; transform: scaleY({sy}); opacity: {op}">'
            f'{lotus_body(opened=48, open_cols=cols, sep=sep, center=center)}</svg>')
def rays(cx, cy, r, fill, n=24, half=3.4):
    ws = []
    for k in range(n):
        a = k * 360 / n
        p = [(r * math.sin(math.radians(a + d)), -r * math.cos(math.radians(a + d))) for d in (-half, half)]
        ws.append(f'<path d="M0 0L{p[0][0]:.0f} {p[0][1]:.0f}L{p[1][0]:.0f} {p[1][1]:.0f}Z"></path>')
    return f'<svg aria-hidden="true" viewBox="{-r} {-r} {2*r} {2*r}" width="{2*r}" height="{2*r}" style="position: absolute; left: {cx - r}px; top: {cy - r}px"><g fill="{fill}">{"".join(ws)}</g></svg>'
def petals(n, seed, box, cols, smin, smax):
    rnd = random.Random(seed); x0, y0, x1, y1 = box; out = []
    for k in range(n):
        x, y = rnd.uniform(x0, x1), rnd.uniform(y0, y1); s = rnd.uniform(smin, smax); a = rnd.uniform(0, 360)
        out.append(f'<span style="position: absolute; left: {x:.0f}px; top: {y:.0f}px; width: {s:.0f}px; height: {s:.0f}px; border-radius: 0 100% 0 100%; background: {cols[k % len(cols)]}; transform: rotate({a:.0f}deg); opacity: {rnd.uniform(0.75, 1):.2f}"></span>')
    return "".join(out)
def build(text=True, name="header"):
    YX, YY = 2400, 800                     # the yogi's centre
    gold = ("#FFE680", "#FFDF57", "#FFDB45")
    scene = (rays(YX, YY, 2400, "#FFDA3D") +
             lot(2300, 360, 1500, ("#FFDF57", "#FFDB45", "#FFE266"), CREAM, op=0.9) +
             lot(1900, 3700, 120, ("#FFDF57", "#FFDB45", "#FFE266"), CREAM, op=0.9) +
             lot(1560, YX, YY - 40, gold, CREAM) +
             lot(1500, YX, 1210, (TEALD, TEALM, TEAL), CREAM, sy=0.4) +
             f'<span style="position: absolute; left: {YX - 170}px; top: 1172px; width: 340px; height: 56px; border-radius: 50%; background: #7A5B00; opacity: 0.22"></span>' +
             petals(46, 7, (1000, 80, 3700, 1560), [WHITE, "#FF8FB1", SAFF, WHITE, TEALD, "#FF8FB1", TEAL], 26, 54) +
             f'<svg role="img" aria-label="A smiling yogi with palms together floats above a green lotus" viewBox="0 0 200 200" width="760" height="760" style="position: absolute; left: {YX - 380}px; top: {YY - 410}px">'
             f'{yogi_body(mat=False, dhoti=WHITE, dhoti_shade="#E9DDB8", joyful=True, namaste=True)}</svg>')
    words = (f'<div style="position: absolute; left: 1150px; top: 0; height: {H}px; width: 900px; display: flex; flex-direction: column; justify-content: center">'
             f'<div style="font-family: \'Baloo 2\'; font-weight: 800; font-size: 176px; line-height: 0.95; letter-spacing: -0.01em; white-space: nowrap; color: {INK}">One day</div>'
             f'<div style="font-family: \'Baloo 2\'; font-weight: 800; font-size: 176px; line-height: 0.95; letter-spacing: -0.01em; white-space: nowrap; color: {DEEP}">at a time.</div></div>') if text else ""
    html = (f'<!doctype html><html><head><meta charset="utf-8"><style>{FONTS}body{{margin:0}}</style></head><body>'
            f'<div style="position: relative; width: {W}px; height: {H}px; overflow: hidden; background: {CREAM}">{scene}{words}</div></body></html>')
    open(os.path.join(OUT, name + ".html"), "w", encoding="utf-8").write(html)
build(True, "header-with-words"); build(False, "header-art-only")
print("ok")
