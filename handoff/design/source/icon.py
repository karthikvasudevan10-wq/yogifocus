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

# v2 icon (option D): the yogi's head and shoulders in front of a bold eight-petal green lotus.
# The v1 icon (small seated yogi on a rosette) is kept in icon_v1.py.
def _petal(cx, cy, ang, l, w, fill, stroke, sw):
    d = f"M0 0C{w} {-0.35*l:.1f} {w} {-0.75*l:.1f} 0 {-l}C{-w} {-0.75*l:.1f} {-w} {-0.35*l:.1f} 0 0Z"
    return f'<path d="{d}" transform="translate({cx} {cy}) rotate({ang})" fill="{fill}" stroke="{stroke}" stroke-width="{sw}" stroke-linejoin="round"/>'
def icon_svg(bg, scale=1.0, size=1024, **_):
    halo = "".join(_petal(512, 470, i * 45, 420, 158, (TEALM if i % 2 else TEAL), bg, 16) for i in range(8))
    fig = (f'<path d="M150 1024Q170 760 512 720Q854 760 874 1024Z" fill="{SKIN}"/>'
           f'<path d="M150 1024Q170 760 400 730L690 1024Z" fill="{SAFF}"/>'
           f'<path d="M400 730Q560 860 690 1024" stroke="{ROBED}" stroke-width="26" fill="none"/>'
           f'<path d="M424 742Q512 850 600 742" stroke="#8A3B2E" stroke-width="18" stroke-linecap="round" stroke-dasharray="0.1 34" fill="none"/>'
           f'<rect x="452" y="600" width="120" height="150" rx="40" fill="{SKIND}"/>'
           f'<circle cx="512" cy="196" r="74" fill="{HAIR}"/><rect x="460" y="244" width="104" height="28" rx="14" fill="{SAFF}"/>'
           f'<circle cx="332" cy="470" r="34" fill="{SKIND}"/><circle cx="692" cy="470" r="34" fill="{SKIND}"/>'
           f'<circle cx="512" cy="450" r="188" fill="{SKIN}"/>'
           f'<path d="M324 450A188 188 0 0 1 700 450Q648 322 512 346Q376 322 324 450Z" fill="{HAIR}"/>'
           f'<circle cx="420" cy="520" r="28" fill="#F29C7B" opacity="0.6"/><circle cx="604" cy="520" r="28" fill="#F29C7B" opacity="0.6"/>'
           f'<path d="M414 474q34 -30 68 0M542 474q34 -30 68 0" stroke="{HAIR}" stroke-width="22" stroke-linecap="round" fill="none"/>'
           f'<path d="M462 548q50 40 100 0" stroke="{HAIR}" stroke-width="22" stroke-linecap="round" fill="none"/>')
    body = halo + fig
    g = f'<g transform="translate(512 512) scale({scale}) translate(-512 -512)">{body}</g>' if scale != 1 else body
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="{size}" height="{size}"><rect width="1024" height="1024" fill="{bg}"/>{g}</svg>')

LIGHT = dict(bg=CREAM)
DARK = dict(bg="#10281A")
if __name__ == "__main__":
    out = sys.argv[1]; os.makedirs(out, exist_ok=True)
    files = {"ios-icon-light.svg": icon_svg(**LIGHT), "ios-icon-dark.svg": icon_svg(**DARK), "ios-icon-tinted.svg": grey(icon_svg(**DARK)),
             "watch-icon.svg": icon_svg(**LIGHT)}
    for n, s in files.items(): open(os.path.join(out, n), "w", encoding="utf-8").write(s)
    print(sorted(files))
