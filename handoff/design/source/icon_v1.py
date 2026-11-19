import sys, os, math, colorsys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from art import *

def rosette(cx, cy, rings):
    out = []
    for n, base, l, w, off, col, sep in rings:
        d = petal_path(l, w)
        for k in range(n):
            out.append(f'<path d="{d}" transform="translate({cx} {cy}) rotate({off + k*360/n:g}) translate(0 {-base})" fill="{col}" stroke="{sep}" stroke-width="6"/>')
    return "".join(out)

def icon_svg(bg, greens, yogi_kw, scale=1.0, size=1024):
    cx, cy = 512, 548
    rings = [(12, 150, 262, 104, 0, greens[2], bg), (12, 96, 214, 80, 15, greens[1], bg), (12, 40, 170, 56, 0, greens[0], bg)]
    body = (f'{rosette(cx, cy, rings)}<g transform="translate(152 150) scale(3.6)">{yogi_body(mat=False, **yogi_kw)}</g>')
    g = f'<g transform="translate(512 512) scale({scale}) translate(-512 -512)">{body}</g>' if scale != 1 else body
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="{size}" height="{size}"><rect width="1024" height="1024" fill="{bg}"/>{g}</svg>')

def grey(svg):
    import re
    def lum(m):
        h = m.group(0); r, g, b = (int(h[i:i+2], 16) / 255 for i in (1, 3, 5))
        y = round(255 * (0.2126*r + 0.7152*g + 0.0722*b)); return f"#{y:02X}{y:02X}{y:02X}"
    return re.sub(r'#[0-9A-Fa-f]{6}', lum, svg)

LIGHT = dict(bg=CREAM, greens=(TEALD, TEALM, TEAL), yogi_kw=dict(dhoti=WHITE, dhoti_shade="#E9DDB8"))
DARK = dict(bg="#10281A", greens=("#1E8A3C", "#2BA545", "#49BD3A"), yogi_kw=dict(dhoti=WHITE, dhoti_shade="#E9DDB8"))
if __name__ == "__main__":
    out = sys.argv[1]; os.makedirs(out, exist_ok=True)
    files = {"ios-icon-light.svg": icon_svg(**LIGHT), "ios-icon-dark.svg": icon_svg(**DARK), "ios-icon-tinted.svg": grey(icon_svg(**DARK)),
             "watch-icon.svg": icon_svg(scale=0.86, **LIGHT)}
    for n, s in files.items(): open(os.path.join(out, n), "w", encoding="utf-8").write(s)
    print(sorted(files))
