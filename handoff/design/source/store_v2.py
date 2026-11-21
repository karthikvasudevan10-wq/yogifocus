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
json.dump(jobs, open(os.path.join(SL, "jobs.json"), "w"), indent=1)
print(len(jobs), "slides")
