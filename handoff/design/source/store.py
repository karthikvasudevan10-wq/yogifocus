import os, sys, json
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
from art import *
import icon as ICON
SRC = os.path.join(HERE, "store", "src"); SL = os.path.join(HERE, "store", "slides")
FONTS = "".join(f"@font-face{{font-family:'Baloo 2';font-weight:{'700 800' if w == 700 else w};src:url(file://{HERE}/scratch/package/files/baloo-2-latin-{w}-normal.woff2) format('woff2')}}" for w in (500, 600, 700)) + \
        "".join(f"@font-face{{font-family:'Inter';font-weight:{w};src:url(file://{HERE}/scratch/inter/package/files/inter-latin-{w}-normal.woff2) format('woff2')}}" for w in (400, 500, 600, 700))
BEZ = "#0E1A11"
def img(name): return f"file://{SRC}/{name}.png"
def device(name, sw, sh, w, radius, bez=26):
    h = round(w * sh / sw)
    return (f'<div style="flex: none; padding: {bez}px; border-radius: {radius + bez}px; background: {BEZ}; box-shadow: 0 40px 90px rgba(20,48,31,0.28)">'
            f'<img src="{img(name)}" alt="" style="display: block; width: {w}px; height: {h}px; border-radius: {radius}px"></div>')
def lotus_deco(bg, size, x, y, cols):
    return (f'<svg aria-hidden="true" viewBox="-150 -150 300 300" width="{size}" height="{size}" style="position: absolute; left: {x}px; top: {y}px">'
            f'{lotus_body(opened=48, open_cols=cols, sep=bg, center=None)}</svg>')
TINT = {CREAM: ("#FFE266", "#FFDB45", "#FFE780"), TEAL: ("#85DC56", "#7AD84A", "#8FE062"), SOFT: ("#D6F1BB", "#DDF3C6", "#CFEDB2"), "#14301F": ("#1F4229", "#1B3B25", "#173320")}
def slide(fname, W, H, bg, inner, color=INK, deco=None):
    d = lotus_deco(bg, *deco, TINT[bg]) if deco else ""
    html = (f'<!doctype html><html><head><meta charset="utf-8"><style>{FONTS}body{{margin:0}}*{{box-sizing:border-box}}'
            f'.h{{font-family:"Baloo 2";font-weight:800;line-height:1.02;letter-spacing:-0.01em;margin:0;text-wrap:balance}}.s{{font-family:Inter;font-weight:500;margin:0;text-wrap:pretty}}</style></head>'
            f'<body><div style="position: relative; width: {W}px; height: {H}px; overflow: hidden; background: {bg}; color: {color}">{d}{inner}</div></body></html>')
    open(os.path.join(SL, fname + ".html"), "w", encoding="utf-8").write(html)
    return {"file": fname, "w": W, "h": H}
jobs = []
# ---------------- iPhone 6.9-inch: 1320 x 2868 ----------------
IW, IH = 1320, 2868
def iphone(n, bg, head, sub, screen, color=INK, deco=(900, 640, -300)):
    cap = (f'<div style="position: absolute; left: 100px; right: 100px; top: 150px; display: flex; flex-direction: column; gap: 30px; text-align: center; align-items: center">'
           f'<h1 class="h" style="font-size: 124px">{head}</h1><p class="s" style="font-size: 50px; line-height: 1.32; max-width: 1020px">{sub}</p></div>')
    dev = f'<div style="position: absolute; left: 50%; top: 790px; transform: translateX(-50%)">{device(screen, 1170, 2532, 960, 108)}</div>'
    jobs.append(slide(f"iphone-6.9-{n:02d}", IW, IH, bg, cap + dev, color, deco))
iphone(1, TEAL, "One small routine. One day at a time.", "Keep a routine the way yogis have for centuries.", "iphone-welcome")
iphone(2, CREAM, "Made for the boring middle", "Most routines fade after a week. Yogi Focus helps you just start.", "iphone-graph")
w_small = lambda i: f'<img src="{img(f"widget-small-{i}")}" alt="" style="display: block; width: 330px; height: 330px; border-radius: 49px; box-shadow: 0 24px 60px rgba(20,48,31,0.22)">'
widgets = (f'<div style="position: absolute; left: 0; right: 0; top: 800px; display: flex; flex-direction: column; align-items: center; gap: 40px">'
           f'<div style="display: flex; gap: 40px">{w_small(0)}{w_small(2)}{w_small(3)}</div>'
           f'<img src="{img("widget-medium-1")}" alt="" style="display: block; width: 1040px; height: 485px; border-radius: 64px; box-shadow: 0 24px 60px rgba(20,48,31,0.22)">'
           f'<img src="{img("widget-large-0")}" alt="" style="display: block; width: 1040px; height: 1092px; border-radius: 74px; box-shadow: 0 24px 60px rgba(20,48,31,0.22)"></div>')
cap = lambda head, sub, top=150: (f'<div style="position: absolute; left: 100px; right: 100px; top: {top}px; display: flex; flex-direction: column; gap: 30px; text-align: center; align-items: center">'
           f'<h1 class="h" style="font-size: 124px">{head}</h1><p class="s" style="font-size: 50px; line-height: 1.32; max-width: 1020px">{sub}</p></div>')
jobs.append(slide("iphone-6.9-03", IW, IH, TEAL, cap("Your Home Screen does the remembering", "The hour, the place and what to bring. Tap Done when you have practised.") + widgets, deco=(900, 640, -300)))
iphone(4, SOFT, "One kind question", "However it went, every answer is a good one.", "iphone-reflect")
iphone(5, TEAL, "Forever was never the job. Today was.", "Every day kept is celebrated. Then only tomorrow.", "iphone-kept")
iphone(6, CREAM, "Miss a day? Nothing resets.", "After 30 days, watch your lotus bloom, one petal for each day.", "iphone-mandala")
wface = lambda i: f'<img src="{img(f"watch-{i}")}" alt="" style="display: block; width: 520px; height: 620px; border-radius: 120px; border: 22px solid #000; box-shadow: 0 30px 70px rgba(0,0,0,0.45)">'
watch = (f'<div style="position: absolute; left: 0; right: 0; top: 860px; display: grid; grid-template-columns: repeat(2, 564px); justify-content: center; gap: 56px 56px">'
         f'{wface(0)}{wface(1)}{wface(4)}{wface(5)}</div>')
jobs.append(slide("iphone-6.9-07", IW, IH, "#14301F", cap("A gentle tap on your wrist", "Apple Watch nudges you before the hour, then asks how it felt.") + watch, color="#FFFFFF", deco=(900, 640, -300)))
iphone(8, CREAM, "48 days. Yours for life.", "Complete one mandala and celebrate a practice that is truly yours.", "iphone-complete")
icon_svg = ICON.icon_svg(**ICON.LIGHT).replace('width="1024" height="1024"', 'width="420" height="420" style="display: block; border-radius: 94px; box-shadow: 0 30px 80px rgba(20,48,31,0.3)"', 1)
free = (f'<div style="position: absolute; inset: 0; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 70px; padding: 0 110px; text-align: center">{icon_svg}'
        f'<h1 class="h" style="font-size: 150px">Free for everyone. Always.</h1>'
        f'<p class="s" style="font-size: 54px; line-height: 1.35">No subscription. Nothing to buy. For iPhone, iPhone Duo and Apple Watch.</p></div>')
jobs.append(slide("iphone-6.9-09", IW, IH, TEAL, free, deco=(1100, 110, 1800)))
# ---------------- iPhone Duo outer: 1398 x 2034 ----------------
def outer(n, bg, head, sub, screen):
    c = (f'<div style="position: absolute; left: 90px; right: 90px; top: 110px; display: flex; flex-direction: column; gap: 22px; text-align: center; align-items: center">'
         f'<h1 class="h" style="font-size: 104px">{head}</h1><p class="s" style="font-size: 42px; line-height: 1.32">{sub}</p></div>')
    dev = f'<div style="position: absolute; left: 50%; top: 560px; transform: translateX(-50%)">{device(screen, 1398, 2034, 960, 70, 22)}</div>'
    jobs.append(slide(f"duo-outer-{n:02d}", 1398, 2034, bg, c + dev, deco=(820, 900, -260)))
outer(1, TEAL, "A new day, every day", "Just today's routine: the hour, the place, what to bring.", "duo-outer-today")
outer(2, SOFT, "One kind question", "However it went, every answer is a good one.", "duo-outer-reflect")
outer(3, CREAM, "That's today, kept.", "Forever was never the job. Today was.", "duo-outer-kept")
outer(4, TEAL, "Miss a day? Nothing resets.", "After 30 days, watch your lotus bloom.", "duo-outer-mandala")
# ---------------- iPhone Duo inner, wide: 2853 x 2007 ----------------
def inner(n, bg, head, sub, screen):
    c = (f'<div style="position: absolute; left: 150px; top: 0; bottom: 0; width: 820px; display: flex; flex-direction: column; justify-content: center; gap: 40px">'
         f'<h1 class="h" style="font-size: 136px">{head}</h1><p class="s" style="font-size: 54px; line-height: 1.35">{sub}</p></div>')
    dev = f'<div style="position: absolute; right: 120px; top: 50%; transform: translateY(-50%)">{device(screen, 2853, 2007, 1660, 64, 26)}</div>'
    jobs.append(slide(f"duo-inner-{n:02d}", 2853, 2007, bg, c + dev, deco=(1300, -380, 1100)))
inner(1, CREAM, "One small routine. One day at a time.", "Keep a routine the way yogis have for centuries.", "duo-wide-welcome")
inner(2, TEAL, "Your whole day, side by side", "Open wide to see each routine, its hour and its place.", "duo-wide-today")
inner(3, SOFT, "Miss a day? Nothing resets.", "After 30 days, watch your lotus bloom, one petal for each day.", "duo-wide-mandala")
inner(4, CREAM, "48 days. Yours for life.", "Complete one mandala and celebrate a practice that is truly yours.", "duo-wide-complete")
json.dump(jobs, open(os.path.join(SL, "jobs.json"), "w"), indent=1)
# App Store icon, 1024 square, no transparency
open(os.path.join(SL, "app-store-icon.svg"), "w").write(ICON.icon_svg(**ICON.LIGHT))
print(len(jobs), "slides")
