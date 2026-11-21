import runpy, os, re, json, shutil, sys
HERE = os.path.dirname(os.path.abspath(__file__))
G = runpy.run_path(os.path.join(HERE, "gen.py"))
sys.path.insert(0, HERE)
from art import *
from art import MISSED
import icon as ICON
PKG = os.path.join(HERE, "pkg", "yogi-focus-handoff")
shutil.rmtree(PKG, ignore_errors=True)
A = os.path.join(PKG, "assets", "svg")
def w(rel, text):
    p = os.path.join(PKG, rel); os.makedirs(os.path.dirname(p), exist_ok=True)
    open(p, "w", encoding="utf-8").write(text)
def svg(viewbox, body, extra=""):
    assert "animation" not in body, "asset must be static"
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{viewbox}"{extra}>{body}</svg>\n'
X = "</circle></path></rect></ellipse></polyline>".split("</")  # nothing; keep markup as generated (explicit close tags are valid SVG)

# ---- yogi
WH = dict(dhoti=WHITE, dhoti_shade="#E9DDB8")
for name, kw in {"yogi-calm": {}, "yogi-calm-on-mat": dict(mat=True), "yogi-joyful": dict(joyful=True), "yogi-namaste-joyful": dict(joyful=True, namaste=True),
                 "yogi-calm-white-dhoti": WH, "yogi-joyful-white-dhoti": dict(joyful=True, **WH), "yogi-namaste-joyful-white-dhoti": dict(joyful=True, namaste=True, **WH)}.items():
    kw = dict(dict(mat=False), **kw)
    w(f"assets/svg/yogi/{name}.svg", svg("0 0 200 200", yogi_body(**kw)))
# ---- lotus
LB = "-150 -150 300 300"
w("assets/svg/lotus/lotus-48-open-green.svg", svg(LB, lotus_body(opened=48)))
w("assets/svg/lotus/lotus-0-open.svg", svg(LB, lotus_body(opened=0)))
w("assets/svg/lotus/lotus-12-open-today-highlighted.svg", svg(LB, lotus_body(opened=12, today=12)))
w("assets/svg/lotus/lotus-day-37-with-3-missed.svg", svg(LB, lotus_body(**G["SAMPLE"])))
w("assets/svg/lotus/lotus-day-30-with-2-missed.svg", svg(LB, lotus_body(opened=30, today=30, missed=(9, 17))))
w("assets/svg/lotus/lotus-gold-on-yellow.svg", svg(LB, lotus_body(opened=48, open_cols=("#FFE680", "#FFDF57", "#FFDB45"), sep=CREAM, center=None)))
w("assets/svg/lotus/lotus-greens-on-yellow.svg", svg(LB, lotus_body(opened=48, sep=CREAM, center=None)))
w("assets/svg/lotus/lotus-white-yellow-on-green.svg", svg(LB, lotus_body(opened=48, open_cols=(WHITE, CREAMS, CREAM), sep=TEAL, center=None)))
for nm, bg in (("white", WHITE), ("soft-yellow", CREAMS), ("bright-yellow", CREAM), ("soft-green", SOFT)):
    t = G["LOTUS_TINT"][bg]
    w(f"assets/svg/lotus/widget-lotus-on-{nm}.svg", svg(LB, lotus_body(opened=48, open_cols=t, sep=bg, center=t[0])))
w("assets/svg/lotus/watch-lotus-on-black.svg", svg(LB, lotus_body(opened=48, open_cols=G["WLOTUS"], sep="#000000", center=G["WLOTUS"][0])))
w("assets/svg/lotus/watch-lotus-bright-on-black.svg", svg(LB, lotus_body(opened=48, sep="#000000", center=None)))
w("assets/svg/lotus/petal.svg", svg("-12 -26 24 28", f'<path d="{petal_path(24, 9)}" fill="{TEAL}"></path>'))
w("assets/svg/lotus/confetti-petal.svg", svg("0 0 16 16", f'<path d="M0 0H8A8 8 0 0 1 16 8V16H8A8 8 0 0 1 0 8Z" fill="#FF8FB1"></path>'))
w("assets/lotus-geometry.json", json.dumps({
  "viewBox": [-150, -150, 300, 300], "petals": 48, "rings": [
    {"ring": k, "days": [k*16+1, k*16+16], "count": 16, "baseRadius": r, "length": l, "controlWidth": cw, "angleOffsetDeg": off}
    for k, (r, l, cw, off) in enumerate(RINGS)],
  "petalPath": "M0 0 C w -0.35l, w -0.75l, 0 -l C -w -0.75l, -w -0.35l, 0 0 Z  (l = length, w = controlWidth; drawn pointing up from its base)",
  "placement": "petal i (0..15) of a ring: rotate(i*22.5 + angleOffsetDeg) then translate(0, -baseRadius). Day n opens ring (n-1)//16, petal (n-1)%16. Draw the outer ring first so inner petals overlap it.",
  "centreDisc": {"radius": 27}, "strokeBetweenPetals": 1.5,
  "colours": {"practised": [TEALD, TEALM, TEAL], "missed": MISSED, "toCome": "#EEF4E6", "toComeStroke": "#D9E4CC", "todayOnceKept": SAFF, "centre": CREAM},
  "meaning": "Each petal is one calendar day of the 48-day mandala. Practised = green, missed = red, still to come = pale. A missed day never resets anything. Show the lotus as progress only from day 30."}, indent=1))
# ---- illustrations
sr = "".join(f'<path d="M0 -46L0 -56" transform="rotate({k*30})" stroke="{SAFF}" stroke-width="4" stroke-linecap="round"></path>' for k in range(12))
w("assets/svg/illustrations/sun.svg", svg("-70 -70 140 140", f'<circle r="64" fill="#FFE566"></circle><circle r="50" fill="{CREAM}"></circle>{sr}<circle r="36" fill="{SAFF}"></circle>'))
w("assets/svg/illustrations/moon-crescent.svg", svg("120 25 94 94", '<circle cx="167" cy="72" r="44" fill="#2C4C8C" opacity="0.55"></circle><path d="M158.71 49.47A24 24 0 1 0 189.53 80.29A22 22 0 1 1 158.71 49.47Z" fill="#FFF6CF"></path>'))
w("assets/svg/illustrations/cloud.svg", svg("0 -2 56 32", f'<g fill="{WHITE}"><ellipse cx="28" cy="20" rx="28" ry="9"></ellipse><circle cx="19" cy="14" r="10"></circle><circle cx="35" cy="11" r="12"></circle></g>'))
w("assets/svg/illustrations/tree.svg", svg("-13 -17 26 35", f'<rect x="-2" y="0" width="4" height="16" rx="2" fill="{HAIR}"></rect><circle cx="0" cy="-4" r="11" fill="{TEALD}"></circle>'))
w("assets/svg/illustrations/hills.svg", svg("0 90 334 100", f'<path d="M0 190L0 158Q167 98 334 158L334 190Z" fill="{TEAL}"></path><path d="M0 190L0 178Q110 146 220 172Q280 186 334 170L334 190Z" fill="{TEALM}"></path>'))
def strip_anim(s):
    s = re.sub(r';?\s*animation: [^";]*', '', s)
    s = re.sub(r'\s*style="\s*"', '', s)
    return s
def from_page(name):
    src = G["pages"][name]
    m = re.search(r'(<svg role="img"[^>]*viewBox="0 0 334 \d+".*?</svg>)', src, re.S)
    s = strip_anim(m.group(1))
    s = re.sub(r' style="display: block; margin-top: 8px; flex: none[^"]*"', '', s)
    s = s.replace('opacity: 0', 'opacity: 1') if name == "Idea-Same.dc.html" else s
    return s.replace('<svg ', '<svg xmlns="http://www.w3.org/2000/svg" ', 1).replace(' width="334"', '', 1)
day = from_page("Idea-Today.dc.html"); day = re.sub(r' height="190"', '', day, count=1)
SUN_G = re.search(r'<g style="transform-box: fill-box; transform-origin: 50% 50%"><circle cx="167" cy="230" r="240" fill="none"></circle><circle cx="167" cy="72" r="64".*?<circle cx="167" cy="72" r="36" fill="[^"]*"></circle></g>', day, re.S).group(0)
MOON_G = re.search(r'<g style="transform-box: fill-box; transform-origin: 50% 50%"><circle cx="167" cy="230" r="240" fill="none"></circle><circle cx="167" cy="72" r="44".*?</path></g>', day, re.S).group(0)
w("assets/svg/illustrations/scene-only-today-day.svg", day.replace(MOON_G, "") + "\n")
night = day.replace(SUN_G, "").replace('fill="#14284F" style="opacity: 0"', 'fill="#14284F"').replace('<g style="opacity: 0"><circle', '<g><circle')
night = night.replace('<g><g transform="translate(0 18)', '<g opacity="0.2"><g transform="translate(0 18)').replace('<g><path d="M0 190L0 158Q167 98 334 158L334 190Z"', '<g style="filter: brightness(0.42) saturate(0.8)"><path d="M0 190L0 158Q167 98 334 158L334 190Z"')
w("assets/svg/illustrations/scene-only-today-night.svg", night + "\n")
same = from_page("Idea-Same.dc.html"); same = re.sub(r' height="170"', '', same, count=1).replace('opacity: 1', 'opacity: 0')
w("assets/svg/illustrations/scene-same-time-place-things.svg", same + "\n")
jr = from_page("Idea-Mandala.dc.html"); jr = re.sub(r' height="200"', '', jr, count=1)
jr = re.sub(r'<rect x="[\d.]+" y="14" width="[\d.]+" height="146" rx="12" fill="(#FFD21F|#F2AE8B)"></rect>', '', jr)
jr = re.sub(r'<text [^>]*style="opacity: 0">Boring middle</text>', '', jr)
w("assets/svg/illustrations/graph-48-days-final.svg", jr + "\n")
w("assets/svg/illustrations/clock-7am.svg", svg("60 22 88 88", f'<circle cx="104" cy="66" r="40" fill="{CREAM}"></circle>{G["ticks"]}<path d="M104 66L94 83" stroke="{INK}" stroke-width="4.5" stroke-linecap="round" fill="none"></path><path d="M104 66L104 39" stroke="{INK}" stroke-width="3.5" stroke-linecap="round" fill="none"></path><circle cx="104" cy="66" r="3.5" fill="{INK}"></circle>'))
w("assets/svg/illustrations/pin.svg", svg("198 30 56 78", f'<path d="M226 104C206 78 202 68 202 58a24 24 0 1 1 48 0c0 10-4 20-24 46Z" fill="{SAFF}"></path><circle cx="226" cy="58" r="9" fill="{WHITE}"></circle>'))
w("assets/svg/illustrations/mat.svg", svg("48 118 238 34", f'<rect x="52" y="122" width="230" height="26" rx="13" fill="{TEAL}"></rect><rect x="248" y="122" width="34" height="26" rx="13" fill="{DEEP}"></rect>'))
import math
def rays_svg(fill, n=16, half=5.2, r=500):
    ws = []
    for k in range(n):
        a = k*360/n
        p = [(r*math.sin(math.radians(a+d)), -r*math.cos(math.radians(a+d))) for d in (-half, half)]
        ws.append(f'<path d="M0 0L{p[0][0]:.1f} {p[0][1]:.1f}L{p[1][0]:.1f} {p[1][1]:.1f}Z"></path>')
    return svg(f"{-r} {-r} {2*r} {2*r}", f'<g fill="{fill}">{"".join(ws)}</g>')
w("assets/svg/illustrations/rays-on-green.svg", rays_svg("#7EDC49")); w("assets/svg/illustrations/rays-on-yellow.svg", rays_svg("#FFDF52"))
# ---- icons
for name, body in G["ICONS"].items():
    w(f"assets/svg/icons/{name.replace('_', '-')}.svg", f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="{INK}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">{body}</svg>\n')
# ---- app icon
w("assets/svg/app-icon/ios-icon-light.svg", ICON.icon_svg(**ICON.LIGHT) + "\n"); w("assets/svg/app-icon/ios-icon-dark.svg", ICON.icon_svg(**ICON.DARK) + "\n")
w("assets/svg/app-icon/ios-icon-tinted.svg", ICON.grey(ICON.icon_svg(**ICON.DARK)) + "\n"); w("assets/svg/app-icon/watch-icon.svg", ICON.icon_svg(**ICON.LIGHT) + "\n")

# ---- standalone screens (HTML, live animations)
defaults = {'place': 'the balcony', 'note': ''}
for i in range(12):
    defaults[f'bd{i}'] = DEEP if i == 0 else LINE; defaults[f'bg{i}'] = SOFT if i == 0 else WHITE
for k, on in (('a', 0), ('b', 1), ('c', 0)):
    defaults[f'{k}.bd'] = DEEP if on else LINE; defaults[f'{k}.bg'] = SOFT if on else WHITE
idx = json.load(open(os.path.join(HERE, "root", "project", "canvas.json"), encoding="utf-8"))
links = []
DKV = dict(sel="#8AE264", line="#2C3D2E", soft="#1C3A21", paper="#18271B")
for name in idx["order"]:
    dark = name.endswith("-Dark.dc.html")
    s = open(os.path.join(HERE, "root", "project", name), encoding="utf-8").read() if dark else G["pages"][name]
    dv = dict(defaults)
    if dark:
        for k in list(dv):
            if k.endswith("bd") or k[:2] == "bd": dv[k] = DKV["sel"] if dv[k] == DEEP else DKV["line"]
            elif k.endswith("bg") or k[:2] == "bg": dv[k] = DKV["soft"] if dv[k] == SOFT else DKV["paper"]
    style = re.search(r'<style>(.*?)</style>', s, re.S).group(1)
    body = s.split('</helmet>')[1].split('</x-dc>')[0]
    body = re.sub(r'<sc-if value="\{\{([abc])\.on\}\}"[^>]*>(.*?)</sc-if>', lambda m: m.group(2) if m.group(1) == 'b' else '', body, flags=re.S)
    body = re.sub(r'\s(onClick|onChange)="\{\{[^}]*\}\}"', '', body)
    body = re.sub(r'aria-pressed="\{\{on(\d+)\}\}"', lambda m: f'aria-pressed="{"true" if m.group(1) == "0" else "false"}"', body)
    body = re.sub(r'aria-pressed="\{\{([abc])\.on\}\}"', lambda m: f'aria-pressed="{"true" if m.group(1) == "b" else "false"}"', body)
    body = re.sub(r'\{\{\s*([\w.]+)\s*\}\}', lambda m: dv[m.group(1)], body)
    body = body.replace('.dc.html"', '.html"')
    b = idx["boards"][name]; title = re.search(r'<title>(.*?)</title>', s).group(1)
    html = (f'<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<meta name="viewport" content="width=device-width, initial-scale=1">\n<title>{title} · Yogi Focus design reference</title>\n'
            f'<link href="https://fonts.googleapis.com/css2?family=Baloo+2:wght@500;600;700&amp;family=Inter:wght@400;500;600&amp;display=swap" rel="stylesheet">\n'
            f'<style>\n{style}html{{background:{"#050A06" if dark else "#D9DED3"}}}body{{display:flex;justify-content:center;padding:24px 0}}\n</style>\n</head>\n<body>\n{body.strip()}\n</body>\n</html>\n')
    out = name.replace('.dc.html', '.html'); w(f"design/screens/{out}", html)
    links.append((out, b["title"], b["w"], b["h"]))
rows = "".join(f'<li><a href="screens/{o}">{t}</a> <span>{wd} × {ht} pt</span></li>' for o, t, wd, ht in links)
w("design/index.html", f'<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>Yogi Focus · design reference</title>\n<style>body{{font:16px/1.6 system-ui,sans-serif;max-width:640px;margin:40px auto;padding:0 20px;color:{INK}}}li span{{color:{MUTED};font-size:13px}}a{{color:{DEEP}}}</style>\n</head>\n<body>\n<h1>Yogi Focus · design reference</h1>\n<p>Each link opens one screen as a live page with its animations. They are drawn at 390 × 844 points; widget boards are wider.</p>\n<ol>{rows}</ol>\n</body>\n</html>\n')
json.dump([{"file": o, "title": t, "w": wd, "h": ht} for o, t, wd, ht in links], open(os.path.join(PKG, "design", "screens.json"), "w"), indent=1)
print("assets:", sum(len(f) for _, _, f in os.walk(os.path.join(PKG, "assets"))), "screens:", len(links))
