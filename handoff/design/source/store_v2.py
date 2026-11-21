# App Store screenshots for Yogi Focus 2.0: same frame and caption style as 1.0, v2 screens.
import os, json
HERE = os.path.dirname(os.path.abspath(__file__))
src = open(os.path.join(HERE, "store.py")).read().split("jobs = []")[0]
exec(src)
SL = os.path.join(HERE, "store", "slides2"); SRC2 = os.path.join(HERE, "store", "src2")
def img2(name): return f"file://{SRC2}/{name}.png"
def pick(name): return img2(name) if os.path.exists(os.path.join(SRC2, name + ".png")) else img(name)
def device2(name, sw, sh, w, radius, bez=26):
    h = round(w * sh / sw)
    return (f'<div style="flex: none; padding: {bez}px; border-radius: {radius + bez}px; background: {BEZ}; box-shadow: 0 40px 90px rgba(20,48,31,0.28)">'
            f'<img src="{pick(name)}" alt="" style="display: block; width: {w}px; height: {h}px; border-radius: {radius}px"></div>')
jobs = []
IW, IH = 1320, 2868
cap = lambda head, sub, top=150: (f'<div style="position: absolute; left: 100px; right: 100px; top: {top}px; display: flex; flex-direction: column; gap: 30px; text-align: center; align-items: center">'
           f'<h1 class="h" style="font-size: 124px">{head}</h1><p class="s" style="font-size: 50px; line-height: 1.32; max-width: 1060px">{sub}</p></div>')
def iphone(n, bg, head, sub, screen, color=INK, deco=(900, 640, -300)):
    dev = f'<div style="position: absolute; left: 50%; top: 790px; transform: translateX(-50%)">{device2(screen, 1170, 2532, 960, 108)}</div>'
    jobs.append(slide(f"iphone-6.9-{n:02d}", IW, IH, bg, cap(head, sub) + dev, color, deco))
shadow = "box-shadow: 0 24px 60px rgba(20,48,31,0.22)"
iphone(1, TEAL, "One small routine. One day at a time.", "Keep a routine the way yogis have for centuries.", "iphone-welcome")
iphone(2, CREAM, "Ten minutes, two, or not today", "On a harder day, two minutes still keeps the day. Not today is a kind answer too.", "iphone-today")
iphone(3, SOFT, "Tap the nudge. Begin.", "Your timer opens ready to go, with a soft chime at the end.", "iphone-timer")
home = (f'<div style="position: absolute; left: 0; right: 0; top: 800px; display: flex; flex-direction: column; align-items: center; gap: 40px">'
        f'<img src="{img2("widget-medium-0")}" alt="" style="display: block; width: 1040px; height: 486px; border-radius: 64px; {shadow}">'
        f'<img src="{img2("widget-large-0")}" alt="" style="display: block; width: 1040px; height: 1091px; border-radius: 74px; {shadow}">'
        f'<div style="padding: 26px; border-radius: 80px; background: #1D6B3A; {shadow}"><img src="{img2("live-lock-0")}" alt="" style="display: block; width: 988px; height: 274px; border-radius: 70px"></div></div>')
jobs.append(slide("iphone-6.9-04", IW, IH, TEAL, cap("The widget does the remembering", "Done, two minutes or not today, right from your Home Screen. Your timer waits on the Lock Screen.") + home, deco=(900, 640, -300)))
iphone(5, CREAM, "Forever was never the job. Today was.", "Every day kept is celebrated. Then only tomorrow.", "iphone-kept")
iphone(6, SOFT, "Reminders that step back", "They follow the hour you really practise, and grow lighter as the routine becomes yours.", "iphone-fade")
iphone(7, TEAL, "Miss a day? Nothing resets.", "After 30 days, watch your lotus bloom, one petal for each day.", "iphone-mandala")
wface = lambda i: f'<img src="{img2(f"watch-{i}")}" alt="" style="display: block; width: 520px; height: 620px; border-radius: 120px; border: 22px solid #000; box-shadow: 0 30px 70px rgba(0,0,0,0.45)">'
watch = (f'<div style="position: absolute; left: 0; right: 0; top: 860px; display: grid; grid-template-columns: repeat(2, 564px); justify-content: center; gap: 56px 56px">'
         f'{wface(0)}{wface(3)}{wface(2)}{wface(4)}</div>')
jobs.append(slide("iphone-6.9-08", IW, IH, "#14301F", cap("A gentle tap on your wrist", "Done, not today or a timer, right on Apple Watch. A gentle alarm too, if you choose.") + watch, color="#FFFFFF", deco=(900, 640, -300)))
iphone(9, CREAM, "48 days. Share your mandala.", "Celebrate with a short video of your lotus opening, made right on your phone.", "iphone-share")
icon_svg = ICON.icon_svg(**ICON.LIGHT).replace('width="1024" height="1024"', 'width="420" height="420" style="display: block; border-radius: 94px; box-shadow: 0 30px 80px rgba(20,48,31,0.3)"', 1)
free = (f'<div style="position: absolute; inset: 0; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 70px; padding: 0 110px; text-align: center">{icon_svg}'
        f'<h1 class="h" style="font-size: 150px">Free for everyone. Always.</h1>'
        f'<p class="s" style="font-size: 54px; line-height: 1.35">No subscription. Nothing to buy. For iPhone, iPhone Duo and Apple Watch.</p></div>')
jobs.append(slide("iphone-6.9-10", IW, IH, TEAL, free, deco=(1100, 110, 1800)))

# ---------------- iPhone Duo outer: 1398 x 2034 ----------------
def outer(n, bg, head, sub, screen):
    c = (f'<div style="position: absolute; left: 90px; right: 90px; top: 110px; display: flex; flex-direction: column; gap: 22px; text-align: center; align-items: center">'
         f'<h1 class="h" style="font-size: 104px">{head}</h1><p class="s" style="font-size: 42px; line-height: 1.32">{sub}</p></div>')
    dev = f'<div style="position: absolute; left: 50%; top: 560px; transform: translateX(-50%)">{device2(screen, 1398, 2034, 960, 70, 22)}</div>'
    jobs.append(slide(f"duo-outer-{n:02d}", 1398, 2034, bg, c + dev, deco=(820, 900, -260)))
outer(1, CREAM, "Ten minutes, two, or not today", "On a harder day, two minutes still keeps the day.", "duo-outer-today-v2")
outer(2, SOFT, "Tap the nudge. Begin.", "Your timer opens ready to go, with a soft chime at the end.", "duo-outer-timer")
outer(3, TEAL, "Not today is a kind answer", "No guilt. Tomorrow is a new day.", "duo-outer-not-today")
outer(4, CREAM, "That's today, kept.", "Forever was never the job. Today was.", "duo-outer-kept")
outer(5, SOFT, "Miss a day? Nothing resets.", "After 30 days, watch your lotus bloom.", "duo-outer-mandala")
# ---------------- iPhone Duo inner, wide: 2853 x 2007 ----------------
def inner(n, bg, head, sub, screen):
    c = (f'<div style="position: absolute; left: 150px; top: 0; bottom: 0; width: 820px; display: flex; flex-direction: column; justify-content: center; gap: 40px">'
         f'<h1 class="h" style="font-size: 136px">{head}</h1><p class="s" style="font-size: 54px; line-height: 1.35">{sub}</p></div>')
    dev = f'<div style="position: absolute; right: 120px; top: 50%; transform: translateY(-50%)">{device2(screen, 2853, 2007, 1660, 64, 26)}</div>'
    jobs.append(slide(f"duo-inner-{n:02d}", 2853, 2007, bg, c + dev, deco=(1300, -380, 1100)))
inner(1, CREAM, "One small routine. One day at a time.", "Keep a routine the way yogis have for centuries.", "duo-wide-welcome")
inner(2, TEAL, "Ten minutes, two, or not today", "Open wide to see your routine on one side and how you'll keep it on the other.", "duo-wide-today-v2")
inner(3, SOFT, "Tap the nudge. Begin.", "A calm timer across the whole display, with a soft chime at the end.", "duo-wide-timer")
inner(4, CREAM, "Miss a day? Nothing resets.", "After 30 days, watch your lotus bloom, one petal for each day.", "duo-wide-mandala")
inner(5, TEAL, "48 days. Share your mandala.", "A short video of your lotus opening, made right on your phone.", "duo-wide-share")
json.dump(jobs, open(os.path.join(SL, "jobs.json"), "w"), indent=1)
print(len(jobs), "slides")
