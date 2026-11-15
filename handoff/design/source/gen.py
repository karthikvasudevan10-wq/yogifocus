import json, os, sys, math, random, re
from html.parser import HTMLParser
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from art import *
from art import FB_BOX, MISSED, DARK, ONACC, PAPER, SOFTY, HERO_Y, HERO_G, PETAL_CLOSED
HBTN = dict(bg=TEAL, color=ONACC) if DARK else dict(bg=INK, color=WHITE)   # the main button on full-colour screens
SAMPLE = dict(opened=37, missed=(9, 17, 33))      # day 37 of the mandala: 34 practised, 3 missed

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "root", "project")
FH = "'Baloo 2', 'Trebuchet MS', system-ui, sans-serif"
FB = "Inter, system-ui, -apple-system, sans-serif"

ICONS = {
 "clock": '<circle cx="12" cy="12" r="9"></circle><path d="M12 7v5l3 2"></path>',
 "pin": '<path d="M12 21s7-6.2 7-11.5A7 7 0 0 0 5 9.5C5 14.8 12 21 12 21z"></path><circle cx="12" cy="9.5" r="2.5"></circle>',
 "bag": '<path d="M5 8h14l-1 12H6z"></path><path d="M9 8V6a3 3 0 0 1 6 0v2"></path>',
 "chev_left": '<path d="M15 5l-7 7 7 7"></path>',
 "chev_right": '<path d="M9 5l7 7-7 7"></path>',
 "check": '<path d="M5 12.5l4.5 4.5L19 7.5"></path>',
 "settings": '<path d="M4 7h10M18 7h2M4 17h2M10 17h10"></path><circle cx="16" cy="7" r="2"></circle><circle cx="8" cy="17" r="2"></circle>',
 "widget": '<rect x="4" y="4" width="7" height="7" rx="2"></rect><rect x="13" y="4" width="7" height="7" rx="2"></rect><rect x="4" y="13" width="16" height="7" rx="2"></rect>',
 "heart": '<path d="M12 20s-7-4.4-7-9.5A4 4 0 0 1 12 8a4 4 0 0 1 7 2.5C19 15.6 12 20 12 20z"></path>',
 "lotus": '<path d="M12 20c-3-2-4-6 0-12 4 6 3 10 0 12z"></path><path d="M12 20c-4 0-8-2-9-7 3 0 5 1 6.5 3M12 20c4 0 8-2 9-7-3 0-5 1-6.5 3"></path>',
 "plus": '<path d="M12 5v14M5 12h14"></path>',
 "meditate": '<circle cx="12" cy="6" r="2.5"></circle><path d="M4 19c2-1 4-4 8-4s6 3 8 4"></path><path d="M8 15c0-3 1.5-5 4-5s4 2 4 5"></path>',
 "stretch": '<circle cx="12" cy="5" r="2"></circle><path d="M12 7v7M12 14l-4 6M12 14l4 6M5 4l7 5 7-5"></path>',
 "read": '<path d="M3 5.5c3-1 6-1 9 1 3-2 6-2 9-1V19c-3-1-6-1-9 1-3-2-6-2-9-1z"></path><path d="M12 6.5V20"></path>',
 "journal": '<path d="M4 20l1-4L16 5l3 3L8 19z"></path><path d="M14 7l3 3"></path>',
 "walk": '<circle cx="13" cy="4.5" r="2"></circle><path d="M13 7l-2 6 3 3v5M11 13l-3 7M8 11l5-4 3 3 2.5 1"></path>',
 "music": '<path d="M9 18V6l10-2v12"></path><circle cx="6.5" cy="18" r="2.5"></circle><circle cx="16.5" cy="16" r="2.5"></circle>',
 "study": '<path d="M9 18h6M10 21h4"></path><path d="M12 3a6 6 0 0 0-4 10.5c.7.7 1 1.5 1 2.5h6c0-1 .3-1.800 1-2.5A6 6 0 0 0 12 3z"></path>',
 "tidy": '<path d="M4 11l8-7 8 7v9H4z"></path><path d="M10 20v-6h4v6"></path>',
 "plan": '<path d="M9 6h11M9 12h11M9 18h11"></path><circle cx="4.5" cy="6" r="1"></circle><circle cx="4.5" cy="12" r="1"></circle><circle cx="4.5" cy="18" r="1"></circle>',
 "exercise": '<path d="M6 8v8M3.5 10v4M18 8v8M20.5 10v4M6 12h12"></path>',
 "eat": '<path d="M12 8c-2-2-6-1.5-6 3.5 0 4 2.5 8 4.5 8 .8 0 1-.5 1.5-.5s.7.5 1.5.5c2 0 4.5-4 4.5-8 0-5-4-5.5-6-3.5z"></path><path d="M12 8c0-2 1-3.5 3-4"></path>',
 "scattered": '<circle cx="6" cy="7" r="1.4"></circle><circle cx="17" cy="5" r="1.4"></circle><circle cx="12" cy="13" r="1.4"></circle><circle cx="5" cy="18" r="1.4"></circle><circle cx="19" cy="16" r="1.4"></circle>',
 "steady": '<path d="M3 9c3-3 6 3 9 0s6 3 9 0M3 16c3-3 6 3 9 0s6 3 9 0"></path>',
 "absorbed": '<circle cx="12" cy="12" r="2"></circle><circle cx="12" cy="12" r="6"></circle><circle cx="12" cy="12" r="10"></circle>',
}
KEYFRAMES = """@keyframes yf-breathe{0%,100%{transform:scale(1)}50%{transform:scale(1.05)}}
@keyframes yf-float{0%,100%{transform:translateY(0)}50%{transform:translateY(-3px)}}
@keyframes yf-fall{from{transform:translateY(0)}to{transform:translateY(940px)}}
@keyframes yf-sway{from{transform:translateX(-18px) rotate(-50deg)}to{transform:translateX(18px) rotate(70deg)}}
@keyframes yf-rota{0%,40%{opacity:1}48%,90%{opacity:0}98%,100%{opacity:1}}
@keyframes yf-rotb{0%,40%{opacity:0}48%,90%{opacity:1}98%,100%{opacity:0}}
@keyframes yf-spin{to{transform:rotate(360deg)}}
@keyframes yf-levitate{0%,100%{transform:translateY(4px)}50%{transform:translateY(-9px)}}
@keyframes yf-shadow{0%,100%{transform:scale(1);opacity:0.26}50%{transform:scale(0.74);opacity:0.14}}
@keyframes yf-rise{from{transform:translateY(70px)}to{transform:translateY(0)}}
@keyframes yf-draw{from{stroke-dashoffset:420}to{stroke-dashoffset:0}}
@keyframes yf-pop{from{transform:scale(0.4);opacity:0}to{transform:scale(1);opacity:1}}
@keyframes yf-open{from{transform:scale(0.15);opacity:0}to{transform:scale(1);opacity:1}}
@keyframes yf-ring{from{transform:scale(0.8);opacity:0.8}to{transform:scale(1.35);opacity:0}}
@keyframes yf-up{from{transform:translateY(14px);opacity:0}to{transform:translateY(0);opacity:1}}
@keyframes yf-pulse{0%,100%{transform:scale(1);opacity:1}50%{transform:scale(1.7);opacity:0.5}}
@media (prefers-reduced-motion:reduce){*{animation:none!important}}
"""
def icon(name, size=24, color="currentColor", sw=1.8):
    return (f'<svg aria-hidden="true" viewBox="0 0 24 24" width="{size}" height="{size}" fill="none" stroke="{color}" '
            f'stroke-width="{sw}" stroke-linecap="round" stroke-linejoin="round" style="flex: none; display: block">{ICONS[name]}</svg>')

def page(title, root, props=None, logic="renderVals() {\nreturn {};\n}", w=390, h=844, css=""):
    props = dict(props or {}); props["$preview"] = {"width": w, "height": h}
    pj = json.dumps(props, ensure_ascii=False).replace("&", "&amp;").replace("'", "&#39;")
    head = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>' + title + '</title>\n'
            '<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n<helmet>\n'
            '<link href="https://fonts.googleapis.com/css2?family=Baloo+2:wght@500;600;700&amp;family=Inter:wght@400;500;600&amp;display=swap" rel="stylesheet">\n'
            '<style>\nbody{margin:0}\na{color:' + DEEP + '}a:hover{color:' + INK + '}\nbutton,input{font-family:inherit}\nbutton{cursor:pointer}\n' + KEYFRAMES + css + '</style>\n</helmet>\n')
    logic = logic.replace("'#127A35'", f"'{DEEP}'").replace("'#E2EBD6'", f"'{LINE}'").replace("'#E6F8D2'", f"'{SOFT}'").replace("'#FFFFFF'", f"'{PAPER}'")
    tail = ('\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'' + pj + '\'>\nclass Component extends DCLogic {\n'
            + logic + '\n}\n</script>\n</body>\n</html>\n')
    return head + root.replace("[[", "{{").replace("]]", "}}") + tail

def phone(inner, bg=GROUND, color=INK):
    return (f'<div style="width: 390px; height: 844px; box-sizing: border-box; padding: 56px 28px 34px; display: flex; flex-direction: column; '
            f'background: {bg}; color: {color}; font-family: {FB}; font-size: 16px; line-height: 1.55; overflow: hidden">\n{inner}\n</div>')

def topbar(back=None, right=""):
    left = (f'<a href="{back}" aria-label="Back" style="display: flex; align-items: center; justify-content: center; width: 44px; height: 44px; margin-left: -12px; color: {INK}">{icon("chev_left")}</a>'
            if back else '<span style="width: 44px; height: 44px"></span>')
    return f'<div style="display: flex; align-items: center; justify-content: space-between; height: 44px; flex: none">{left}{right}</div>'
def step(t): return f'<span style="font-size: 14px; font-weight: 500; color: {MUTED}">{t}</span>'
def h1(t, size=36, mt=18, color=INK):
    return f'<h1 style="margin: {mt}px 0 0; font-family: {FH}; font-weight: 700; font-size: {size}px; line-height: 1.1; color: {color}; text-wrap: balance">{t}</h1>'
def p(t, mt=12, size=17, color=INK, extra=""):
    return f'<p style="margin: {mt}px 0 0; font-size: {size}px; color: {color}; text-wrap: pretty{extra}">{t}</p>'
def cta(label, href, bg=TEAL, color=ONACC, mt="auto"):
    return (f'<a href="{href}" style="margin-top: {mt}; flex: none; display: flex; align-items: center; justify-content: center; min-height: 56px; border-radius: 28px; '
            f'background: {bg}; color: {color}; font-size: 17px; font-weight: 600; text-decoration: none">{label}</a>')
def ghost(label, href, color=DEEP, border=DEEP, mt="8px"):
    return (f'<a href="{href}" style="margin-top: {mt}; flex: none; display: flex; align-items: center; justify-content: center; min-height: 48px; border-radius: 24px; '
            f'border: 1.5px solid {border}; color: {color}; font-size: 16px; font-weight: 600; text-decoration: none">{label}</a>')
def lotus(size, opened, today=None, num=None, label=None, motion=None, missed=()):
    label = label or f"Lotus with {opened} of 48 petals open"
    n = (f'<div style="grid-area: 1 / 1; font-family: {FH}; font-weight: 700; font-size: {max(15, round(size*0.095))}px; line-height: 1; padding-top: 3px; color: {ONACC}">{num}</div>') if num else ""
    return (f'<div style="display: grid; place-items: center; align-self: center; flex: none">{lotus_svg(size, label, opened=opened, today=today, motion=motion, missed=missed)}{n}</div>')

pages = {}

# ---------- 1 Welcome: a greeting. Golden mandala turning behind, lotus turning below, petals rising
CSS_WELCOME = """@keyframes yf-halo{0%{transform:scale(0.6);opacity:0}12%{opacity:0.9}62%,100%{transform:scale(1.9);opacity:0}}
@keyframes yf-riseup{0%{transform:translateY(0);opacity:0}12%{opacity:1}78%{opacity:1}100%{transform:translateY(-470px);opacity:0}}
@keyframes yf-sway{from{transform:translateX(-18px) rotate(-50deg)}to{transform:translateX(18px) rotate(70deg)}}
"""
def welcome_scene():
    rnd = random.Random(7)
    gold = ("#3D3D13", "#33350F", "#2A2D0C") if DARK else ("#FFE680", "#FFDF57", "#FFDB45")
    halo = (f'<svg aria-hidden="true" viewBox="-150 -150 300 300" width="440" height="440" style="position: absolute; left: -25px; top: -5px; display: block; will-change: transform; animation: yf-spin 120s linear infinite reverse">'
            f'{lotus_body(opened=48, open_cols=gold, sep=HERO_Y, center=None)}</svg>')
    ring = lambda delay: (f'<span style="position: absolute; left: 100px; top: 120px; width: 190px; height: 190px; box-sizing: border-box; border: 5px solid {"#5B6B2A" if DARK else WHITE}; border-radius: 50%; opacity: 0; animation: yf-halo 5s ease-out {delay}s infinite"></span>')
    seat = (f'<div style="position: absolute; left: -12px; top: 177px; width: 414px; height: 414px; transform: scaleY(0.4)">'
            f'<svg aria-hidden="true" viewBox="-150 -150 300 300" width="414" height="414" style="display: block; will-change: transform; animation: yf-spin 48s linear infinite">'
            f'{lotus_body(opened=48, open_cols=(TEALD, TEALM, TEAL), sep=HERO_Y, center=None)}</svg></div>')
    shadow = f'<span style="position: absolute; left: 131px; top: 371px; width: 128px; height: 26px; border-radius: 50%; background: {"#000000" if DARK else "#7A5B00"}; opacity: 0.26; animation: yf-shadow 4.5s ease-in-out infinite"></span>'
    cols = [WHITE, "#FF8FB1", SAFF, WHITE, TEALD, "#FF8FB1", WHITE]
    petals = []
    for k in range(14):
        left = round(18 + (k + rnd.random()) * 340 / 14)
        dur = round(rnd.uniform(7, 11), 1); delay = round(rnd.uniform(0, dur), 1); sway = round(rnd.uniform(1.8, 3), 1); sz = rnd.choice([11, 13, 15])
        petals.append(f'<span style="position: absolute; left: {left}px; top: 400px; will-change: transform; animation: yf-riseup {dur}s linear -{delay}s infinite">'
                      f'<span style="display: block; width: {sz}px; height: {sz}px; border-radius: 0 100% 0 100%; background: {cols[k % len(cols)]}; animation: yf-sway {sway}s ease-in-out -{round(rnd.uniform(0, sway), 1)}s infinite alternate"></span></span>')
    yogi = (f'<svg role="img" aria-label="A smiling yogi greets you with palms together, floating above a turning lotus" viewBox="0 0 200 200" width="300" height="300" style="position: absolute; left: 45px; top: 76px; display: block; animation: yf-levitate 4.5s ease-in-out infinite">'
            f'{yogi_body(mat=False, dhoti=WHITE, dhoti_shade="#E9DDB8", joyful=True, namaste=True)}</svg>')
    return (f'<div style="position: absolute; left: 0; top: 0; width: 390px; height: 470px">{halo}{ring(0)}{ring(2.5)}{seat}{shadow}{"".join(petals)}{yogi}</div>')
welcome_inner = f"""<div style="font-family: {FH}; font-weight: 600; font-size: 19px; line-height: 1.2">Namaste, and welcome.</div>
<div style="margin-top: 2px; font-family: {FH}; font-weight: 700; font-size: 50px; line-height: 1; color: {DEEP}">Yogi Focus</div>
<h1 style="margin: 6px 0 0; font-family: {FH}; font-weight: 600; font-size: 30px; line-height: 1.15; color: {INK}">One small routine.<br>One day at a time.</h1>
{p("Come as you are. Scattered days and missed days are welcome here too. We'll go gently.", mt=8, size=16)}
{cta("Begin", "Idea-Today.dc.html", **HBTN)}"""
welcome_root = (f'<div style="position: relative; width: 390px; height: 844px; box-sizing: border-box; padding: 56px 28px 34px; display: flex; flex-direction: column; '
                f'background: {HERO_Y}; color: {INK}; font-family: {FB}; font-size: 16px; line-height: 1.55; overflow: hidden">\n{welcome_scene()}\n'
                f'<div style="position: relative; margin-top: 412px; flex: 1; min-height: 0; display: flex; flex-direction: column">\n{welcome_inner}\n</div>\n</div>')
pages["Main.dc.html"] = page("Welcome to Yogi Focus", welcome_root, css=CSS_WELCOME)

# ---------- 2 Only today: the sun crosses the sky, night falls, a new day rises
CSS_TODAY = """@keyframes yf-arc{0%{transform:rotate(-98deg)}50%{transform:rotate(98deg)}50.01%,100%{transform:rotate(-98deg)}}
@keyframes yf-moon{0%,47%{transform:rotate(-98deg)}94%{transform:rotate(98deg)}94.01%,100%{transform:rotate(-98deg)}}
@keyframes yf-night{0%{opacity:0.25}6%,40%{opacity:0}50%,90%{opacity:1}100%{opacity:0.25}}
@keyframes yf-stars{0%,46%{opacity:0}54%,88%{opacity:1}96%,100%{opacity:0}}
@keyframes yf-dim{0%{filter:brightness(0.85) saturate(1)}5%,40%{filter:brightness(1) saturate(1)}52%,88%{filter:brightness(0.42) saturate(0.8)}100%{filter:brightness(0.85) saturate(1)}}
@keyframes yf-cloudnight{0%{opacity:0.8}6%,40%{opacity:1}50%,90%{opacity:0.2}100%{opacity:0.8}}
@keyframes yf-twinkle{0%,100%{opacity:1}50%{opacity:0.25}}
@keyframes yf-drift{from{transform:translateX(-80px)}to{transform:translateX(350px)}}
"""
DAY = "18s linear -4.5s infinite"          # one full day and night; starts at noon
NIGHT_SKY = "#14284F"
def cloud(y, dur, delay, sc=1):
    return (f'<g transform="translate(0 {y}) scale({sc})"><g fill="{WHITE}" style="animation: yf-drift {dur}s linear -{delay}s infinite">'
            f'<ellipse cx="28" cy="20" rx="28" ry="9"></ellipse><circle cx="19" cy="14" r="10"></circle><circle cx="35" cy="11" r="12"></circle></g></g>')
sun_rays = "".join(f'<path d="M0 -46L0 -56" transform="translate(167 72) rotate({k*30})" stroke="{SAFF}" stroke-width="4" stroke-linecap="round"></path>' for k in range(12))
tree = lambda x, y, r: f'<rect x="{x-2}" y="{y}" width="4" height="16" rx="2" fill="{HAIR}"></rect><circle cx="{x}" cy="{y-4}" r="{r}" fill="{TEALD}"></circle>'
_sr = random.Random(11)
stars = "".join(f'<circle cx="{_sr.randint(14, 320)}" cy="{_sr.randint(10, 112)}" r="{_sr.choice([1.2, 1.6, 2.1])}" fill="#FFF6CF" style="animation: yf-twinkle {_sr.choice([1.7, 2.3, 2.9, 3.4])}s ease-in-out -{_sr.randint(0, 30) / 10}s infinite"></circle>' for _ in range(22))
sun = (f'<svg role="img" aria-label="The sun crosses the sky over a hill where a yogi sits, night falls with a moon and stars, and a new day rises" viewBox="0 0 334 190" width="334" height="190" style="display: block; margin-top: 8px; flex: none">'
       f'<clipPath id="r"><rect x="0" y="0" width="334" height="190" rx="26"></rect></clipPath><g clip-path="url(#r)">'
       f'<rect x="0" y="0" width="334" height="190" fill="{CREAMS}"></rect>'
       f'<rect x="0" y="0" width="334" height="190" fill="{NIGHT_SKY}" style="opacity: 0; animation: yf-night {DAY}"></rect>'
       f'<g style="opacity: 0; animation: yf-stars {DAY}">{stars}</g>'
       f'<g style="{FB_BOX}; animation: yf-arc 18s cubic-bezier(0.3, 0.1, 0.7, 0.9) -4.5s infinite"><circle cx="167" cy="230" r="240" fill="none"></circle>'
       f'<circle cx="167" cy="72" r="64" fill="#FFE566" style="{FB_BOX}; animation: yf-breathe 4s ease-in-out infinite"></circle><circle cx="167" cy="72" r="50" fill="{CREAM}" style="{FB_BOX}; animation: yf-breathe 4s ease-in-out 0.4s infinite"></circle>'
       f'<g style="{FB_BOX}; animation: yf-spin 18s linear infinite">{sun_rays}</g><circle cx="167" cy="72" r="36" fill="{SAFF}"></circle></g>'
       f'<g style="{FB_BOX}; animation: yf-moon 18s cubic-bezier(0.3, 0.1, 0.7, 0.9) -4.5s infinite"><circle cx="167" cy="230" r="240" fill="none"></circle>'
       f'<circle cx="167" cy="72" r="44" fill="#2C4C8C" opacity="0.55" style="{FB_BOX}; animation: yf-breathe 4s ease-in-out infinite"></circle>'
       f'<path d="M158.71 49.47A24 24 0 1 0 189.53 80.29A22 22 0 1 1 158.71 49.47Z" fill="#FFF6CF"></path></g>'
       f'<g style="animation: yf-cloudnight {DAY}">{cloud(18, 30, 8)}{cloud(50, 42, 27, 0.7)}</g>'
       f'<g style="animation: yf-dim {DAY}"><path d="M0 190L0 158Q167 98 334 158L334 190Z" fill="{TEAL}"></path>{tree(58, 132, 11)}{tree(84, 124, 8)}'
       f'<g style="animation: yf-float 5s ease-in-out infinite"><g transform="translate(217 88) scale(0.3)">{yogi_body(mat=False)}</g></g>'
       f'<path d="M0 190L0 178Q110 146 220 172Q280 186 334 170L334 190Z" fill="{TEALM}"></path></g></g></svg>')
pages["Idea-Today.dc.html"] = page("Only today", phone(f"""{topbar("Main.dc.html", step("1 of 3"))}
{sun}
{h1("Only today.")}
{p("“Do this every day for the rest of your life” is too heavy to carry. So a yogi doesn't carry it. Each morning they ask a single question.")}
<div style="margin-top: 18px; padding: 20px 22px; border-radius: 22px; background: {CREAM}; color: {ONACC}; font-family: {FH}; font-weight: 600; font-size: 22px; line-height: 1.25">This is a new day. How will I keep my practice today?</div>
{p("It is the only thing Yogi Focus will ever ask of you.", size=15, color=MUTED, mt=14)}
{cta("Next", "Idea-Same.dc.html")}"""), css=CSS_TODAY)

# ---------- 3 Same time, place, things: a day whirls by, then the hour, the spot and the mat return
CSS_SAME = """@keyframes yf-min{0%{transform:rotate(-360deg)}55%,88%{transform:rotate(0deg)}100%{transform:rotate(720deg)}}
@keyframes yf-hour{0%{transform:rotate(-30deg)}55%,88%{transform:rotate(0deg)}100%{transform:rotate(330deg)}}
@keyframes yf-drop{0%{transform:translateY(-52px);opacity:0}14%{opacity:1}52%{transform:translateY(0)}58%{transform:translateY(-8px)}64%,90%{transform:translateY(0);opacity:1}100%{transform:translateY(-52px);opacity:0}}
@keyframes yf-unroll{0%{stroke-dashoffset:196}55%,88%{stroke-dashoffset:0}100%{stroke-dashoffset:196}}
@keyframes yf-roll{0%{transform:translateX(-196px)}55%,88%{transform:translateX(0)}100%{transform:translateX(-196px)}}
@keyframes yf-chime{0%,53%{transform:scale(0.9);opacity:0}58%{opacity:0.9}82%,100%{transform:scale(1.55);opacity:0}}
"""
T = "6.5s ease-in-out -4.3s infinite"
ticks = "".join(f'<path d="M0 -33L0 -29" transform="translate(104 66) rotate({k*90})" stroke="{INK}" stroke-width="2.5" stroke-linecap="round"></path>' for k in range(4))
same = (f'<svg role="img" aria-label="A clock settles at seven, a pin drops on the same spot and a mat unrolls, again and again" viewBox="0 0 334 170" width="334" height="170" style="display: block; margin-top: 8px; flex: none">'
        f'<rect x="0" y="0" width="334" height="170" rx="26" fill="{SOFT}"></rect>'
        f'<circle cx="104" cy="66" r="40" fill="none" stroke="{SAFF}" stroke-width="4" style="{FB_BOX}; opacity: 0; animation: yf-chime {T}"></circle>'
        f'<circle cx="104" cy="66" r="40" fill="{CREAM}"></circle>{ticks}'
        f'<g style="{FB_BOX}; animation: yf-hour {T}"><circle cx="104" cy="66" r="30" fill="none"></circle><path d="M104 66L94 83" stroke="{INK}" stroke-width="4.5" stroke-linecap="round" fill="none"></path></g>'
        f'<g style="{FB_BOX}; animation: yf-min {T}"><circle cx="104" cy="66" r="30" fill="none"></circle><path d="M104 66L104 39" stroke="{INK}" stroke-width="3.5" stroke-linecap="round" fill="none"></path></g>'
        f'<circle cx="104" cy="66" r="3.5" fill="{INK}"></circle>'
        f'<ellipse cx="226" cy="106" rx="18" ry="5" fill="none" stroke="{SAFF}" stroke-width="3" style="{FB_BOX}; opacity: 0; animation: yf-chime {T}"></ellipse>'
        f'<g style="animation: yf-drop {T}"><path d="M226 104C206 78 202 68 202 58a24 24 0 1 1 48 0c0 10-4 20-24 46Z" fill="{SAFF}"></path><circle cx="226" cy="58" r="9" fill="{WHITE}"></circle></g>'
        f'<path d="M65 135L269 135" fill="none" stroke="{TEAL}" stroke-width="26" stroke-linecap="round" style="stroke-dasharray: 204 400; animation: yf-unroll {T}"></path>'
        f'<rect x="248" y="122" width="34" height="26" rx="13" fill="{DEEP}" style="animation: yf-roll {T}"></rect></svg>')
# ---------- 3 Same time, place, things
pages["Idea-Same.dc.html"] = page("Same time, same place, same things", phone(f'''{topbar("Idea-Today.dc.html", step("2 of 3"))}
{same}
{h1("Same time.<br>Same place.<br>Same things.")}
{p("A yogi practises at the exact hour, in the exact spot, with the same mat and the same clothes.")}
{p("When nothing around the routine changes, there is nothing to decide and nothing to remember. The moment itself reminds you.")}
{cta("Next", "Idea-Mandala.dc.html")}'''), css=CSS_SAME)

# ---------- 4 One mandala: willpower alone (orange, dotted) against the Yogi Focus journey (blue). Plays once.
BLUE, BLUED, ORNG, ORNGD = DEEP, DEEP, "#E8792B", "#A84A12"   # the Yogi Focus path stays green
def dx(d): return 18 + d * 5.85
def ly(v): return 150 - v * 1.3
JP = [(dx(d), ly(v)) for d, v in [(0,35),(4,60),(14,48),(16,55),(27,72),(38,84),(42,86),(48,88)]]
WP = [(dx(d), ly(v)) for d, v in [(0,20),(4,95),(14,30),(20,42),(27,22),(48,5)]]
def plen(P):
    c = [0.0]
    for (x0, y0), (x1, y1) in zip(P, P[1:]): c.append(c[-1] + math.hypot(x1 - x0, y1 - y0))
    return c
cum = plen(JP); JL = cum[-1]; WL = plen(WP)[-1]
ex, ey = JP[-1]
pc = lambda c: 100 * c / JL
p7 = pc(cum[1] + (cum[2] - cum[1]) * (7 - 4) / (14 - 4)); p27 = pc(cum[4])
W0, WD, B0, BD = 0.5, 2.8, 3.6, 4.2                    # seconds: orange starts / lasts, blue starts / lasts
BEND = B0 + BD
head_kf = "".join(f"{pc(c):.2f}%{{transform:translate({x-ex:.1f}px,{y-ey:.1f}px)}}" for c, (x, y) in zip(cum, JP))
CSS_MANDALA = (f"@keyframes yf-wdraw{{from{{stroke-dashoffset:{WL+2:.0f}}}to{{stroke-dashoffset:0}}}}\n"
  f"@keyframes yf-line{{from{{stroke-dashoffset:{JL+2:.0f}}}to{{stroke-dashoffset:0}}}}\n"
  f"@keyframes yf-head{{{head_kf}}}\n"
  f"@keyframes yf-fadein{{from{{opacity:0}}to{{opacity:1}}}}\n"
  f"@keyframes yf-band1{{0%{{opacity:0}}4%,{p7:.1f}%{{opacity:1}}{p7+6:.1f}%,100%{{opacity:0}}}}\n"
  f"@keyframes yf-band2{{0%,{p7-1:.1f}%{{opacity:0}}{p7+5:.1f}%,{p27:.1f}%{{opacity:1}}{p27+6:.1f}%,100%{{opacity:0}}}}\n"
  f"@keyframes yf-band3{{0%,{p27-1:.1f}%{{opacity:0}}{p27+5:.1f}%,100%{{opacity:1}}}}\n"
  f"@keyframes yf-burst{{0%{{transform:scale(0.4);opacity:0}}15%{{opacity:0.9}}100%{{transform:scale(3);opacity:0}}}}\n"
  f"@keyframes yf-fall{{from{{transform:translateY(0)}}to{{transform:translateY(940px)}}}}\n"
  f"@keyframes yf-sway{{from{{transform:translateX(-18px) rotate(-50deg)}}to{{transform:translateX(18px) rotate(70deg)}}}}\n")
BT = f"{BD}s linear {B0}s 1 both"
tx = f'font-family="{FB}" font-size="12" font-weight="600" fill="{MUTED}" text-anchor="middle"'
tl = f'font-family="{FB}" font-size="12.5" font-weight="700" text-anchor="middle"'
def band(d0, d1, fill, kf):
    return f'<rect x="{dx(d0)+(2 if d0 else -8):.1f}" y="14" width="{dx(d1)-dx(d0)-(4 if d0 else -6)+(8 if d1 == 48 else 0):.1f}" height="146" rx="12" fill="{fill}" style="animation: {kf} {BT}"></rect>'
def bloom(k, n, base, l, w, col, off=0.0):
    return (f'<g transform="translate({ex:.1f} {ey:.1f}) rotate({off + k*360/n:g}) translate(0 {-base})"><path d="{petal_path(l, w)}" fill="{col}" stroke="{SOFT}" stroke-width="0.8" '
            f'style="transform-box: fill-box; transform-origin: 50% 100%; animation: yf-open 0.55s cubic-bezier(0.3, 1.3, 0.5, 1) {BEND + 0.05*k:.2f}s 1 both"></path></g>')
lotus_end = "".join(bloom(k, 8, 7, 17, 6.5, "#FF8FB1") for k in range(8)) + "".join(bloom(k, 8, 5, 11, 4.5, CREAM, 22.5) for k in range(8))
wpts = " ".join(f"{x:.1f},{y:.1f}" for x, y in WP); pts = " ".join(f"{x:.1f},{y:.1f}" for x, y in JP)
journey = (f'<svg role="img" aria-label="Two paths across 48 days. Willpower alone, dotted orange, starts high, crashes in the boring middle and fades out. With Yogi Focus, solid green, the start is gentle, the dip is shallow, and the routine climbs and settles." viewBox="0 0 334 200" width="334" height="200" style="display: block; margin-top: 8px; flex: none; overflow: visible">'
           f'<rect x="0" y="0" width="334" height="200" rx="26" fill="{SOFT}"></rect><rect x="{dx(7):.1f}" y="14" width="{dx(27)-dx(7):.1f}" height="146" rx="12" fill="#D6F2BC"></rect>'
           f'{band(0, 7, CREAM, "yf-band1")}{band(7, 27, "#F2AE8B", "yf-band2")}{band(27, 48, "#B9F08F", "yf-band3")}'
           f'<mask id="wm"><polyline points="{wpts}" fill="none" stroke="#FFFFFF" stroke-width="12" stroke-linecap="round" stroke-linejoin="round" style="stroke-dasharray: {WL+2:.0f}; animation: yf-wdraw {WD}s linear {W0}s 1 both"></polyline></mask>'
           f'<polyline points="{wpts}" mask="url(#wm)" fill="none" stroke="{ORNG}" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" stroke-dasharray="0.1 8"></polyline>'
           f'<text x="{dx(37.5):.1f}" y="{ly(13)-12:.1f}" {tl} fill="{ORNGD}" style="animation: yf-fadein 0.5s ease-out {W0+WD:.1f}s 1 both">Interest fades</text>'
           f'<text x="{(dx(7)+dx(27))/2:.1f}" y="150" {tl} fill="{INK}" style="opacity: 0; animation: yf-band2 {BT}">Boring middle</text>'
           f'<text x="{dx(37.5):.1f}" y="{ly(80)+24:.1f}" {tl} fill="{BLUED}" style="animation: yf-band3 {BT}">It becomes yours</text>'
           f'<polyline points="{pts}" fill="none" stroke="{BLUE}" stroke-width="4.5" stroke-linecap="round" stroke-linejoin="round" style="stroke-dasharray: {JL+2:.0f}; animation: yf-line {BT}"></polyline>'
           f'<circle cx="{ex:.1f}" cy="{ey:.1f}" r="9" fill="none" stroke="#FF8FB1" stroke-width="3" style="{FB_BOX}; opacity: 0; animation: yf-burst 1.1s ease-out {BEND}s 1 both"></circle>{lotus_end}'
           f'<g style="animation: yf-fadein 0.25s linear {B0-0.2:.1f}s 1 both"><g style="animation: yf-head {BT}"><circle cx="{ex:.1f}" cy="{ey:.1f}" r="6.5" fill="{BLUE}" stroke="{WHITE}" stroke-width="2.5"></circle></g></g>'
           f'<text x="{(dx(0)+dx(7))/2+4:.1f}" y="182" {tx}>Days 1–6</text><text x="{(dx(7)+dx(27))/2:.1f}" y="182" {tx}>Days 7–27</text><text x="{(dx(27)+dx(48))/2:.1f}" y="182" {tx}>Days 28–48</text></svg>')
def path_row(sample, title, text):
    return (f'<div style="display: flex; gap: 12px; align-items: flex-start"><svg aria-hidden="true" viewBox="0 0 26 12" width="26" height="12" style="flex: none; margin-top: 6px; display: block">{sample}</svg>'
            f'<div style="display: flex; flex-direction: column; gap: 1px"><div style="font-size: 16px; font-weight: 600">{title}</div><div style="font-size: 15px; line-height: 1.45; color: {MUTED}">{text}</div></div></div>')
def petal_shower(start, n=26, seed=4):
    rnd = random.Random(seed); cols = ["#FF8FB1", WHITE, CREAM, SAFF, "#FF8FB1", TEALM]
    out = []
    for k in range(n):
        left = round((k + rnd.random()) * 100 / n, 1); dur = round(rnd.uniform(3.2, 5.2), 1); delay = round(start + rnd.uniform(0, 1.6), 2)
        sway = round(rnd.uniform(1.4, 2.4), 1); sz = rnd.choice([11, 13, 15])
        out.append(f'<span style="position: absolute; left: {left}%; top: -40px; will-change: transform; animation: yf-fall {dur}s linear {delay}s 1 both">'
                   f'<span style="display: block; width: {sz}px; height: {sz}px; border-radius: 0 100% 0 100%; background: {cols[k % len(cols)]}; animation: yf-sway {sway}s ease-in-out infinite alternate"></span></span>')
    return f'<div aria-hidden="true" style="position: absolute; left: 0; top: 0; width: 390px; height: 844px; overflow: hidden; pointer-events: none">{"".join(out)}</div>'
mandala_inner = f"""{topbar("Idea-Same.dc.html", step("3 of 3"))}
{journey}
{h1("One mandala is 48 days.", mt=16)}
{p("Yogis hold that a practice kept for one mandala is likely to stay for life. This is how those 48 days tend to go.", mt=8, size=15.5)}
<div style="margin-top: 16px; display: flex; flex-direction: column; gap: 12px">
{path_row(f'<path d="M2 6L24 6" stroke="{ORNG}" stroke-width="4" stroke-linecap="round" stroke-dasharray="0.1 7.3" fill="none"></path>', "Willpower alone", "A burst of effort, a crash in the boring middle, and then interest quietly dies.")}
{path_row(f'<path d="M2 6L24 6" stroke="{BLUE}" stroke-width="4.5" stroke-linecap="round" fill="none"></path>', "With Yogi Focus", "A gentle ten-minute start, a shallow dip, a nudge to just start, and by the end it runs on its own.")}
</div>
{cta("Next", "How-Yogi-Helps.dc.html")}"""
mandala_root = (f'<div style="position: relative; width: 390px; height: 844px; box-sizing: border-box; padding: 56px 28px 34px; display: flex; flex-direction: column; '
                f'background: {GROUND}; color: {INK}; font-family: {FB}; font-size: 16px; line-height: 1.55; overflow: hidden">\n{petal_shower(BEND)}\n'
                f'<div style="position: relative; flex: 1; min-height: 0; display: flex; flex-direction: column">\n{mandala_inner}\n</div>\n</div>')
pages["Idea-Mandala.dc.html"] = page("One mandala is 48 days", mandala_root, css=CSS_MANDALA)

# ---------- 5 How Yogi Focus helps: an invitation, with the three helpers pictured
CSS_HELP = """@keyframes yf-heart{0%{transform:translateY(0) scale(0.5);opacity:0}15%{opacity:1}100%{transform:translateY(-64px) scale(1);opacity:0}}
"""
HEART = "M0 6C-9 0 -10 -7 -5 -9C-2 -10 0 -8 0 -6C0 -8 2 -10 5 -9C10 -7 9 0 0 6Z"
def heart(x, y, delay, sc=1.0):
    return (f'<g transform="translate({x} {y}) scale({sc})"><path d="{HEART}" fill="#FF8FB1" style="transform-box: fill-box; transform-origin: 50% 50%; animation: yf-heart 4s ease-out {delay}s infinite"></path></g>')
help_art = (f'<svg role="img" aria-label="A smiling yogi floats above a turning lotus beside a small widget that says It is time, Meditate" viewBox="0 0 334 164" width="334" height="164" style="display: block; margin-top: 6px; flex: none">'
            f'<clipPath id="hp"><rect x="0" y="0" width="334" height="164" rx="26"></rect></clipPath><g clip-path="url(#hp)"><rect x="0" y="0" width="334" height="164" fill="{SOFT}"></rect>'
            f'<g transform="translate(222 150) scale(0.78 0.34)"><g style="{FB_BOX}; animation: yf-spin 40s linear infinite">{lotus_body(opened=48, sep=SOFT, center=None)}</g></g>'
            f'<ellipse cx="222" cy="150" rx="34" ry="6" fill="#0B3D1A" style="{FB_BOX}; opacity: 0.22; animation: yf-shadow 4.5s ease-in-out infinite"></ellipse>'
            f'{heart(176, 60, 0)}{heart(268, 48, 1.7, 0.8)}{heart(250, 86, 2.9, 0.65)}'
            f'<g style="animation: yf-levitate 4.5s ease-in-out infinite"><g transform="translate(159 6) scale(0.63)">{yogi_body(mat=False, joyful=True, namaste=True)}</g></g>'
            f'<g style="animation: yf-float 5s ease-in-out infinite"><g transform="rotate(-6 80 82)">'
            f'<rect x="24" y="30" width="112" height="104" rx="20" fill="{CREAM}"></rect>'
            f'<circle cx="41" cy="50" r="4" fill="{SAFF}"></circle><text x="50" y="54" font-family="{FB}" font-size="11" font-weight="700" fill="{ONACC}">It&#39;s time</text>'
            f'<text x="37" y="78" font-family="{FH}" font-size="20" font-weight="700" fill="{ONACC}">Meditate</text>'
            f'<rect x="37" y="94" width="86" height="27" rx="13.5" fill="{TEAL}"></rect><text x="80" y="112" font-family="{FB}" font-size="12" font-weight="700" fill="{ONACC}" text-anchor="middle">Done</text></g></g>'
            f'</g></svg>')
def hrow(col, ic, title, text):
    return (f'<div style="display: flex; gap: 14px; align-items: flex-start"><div style="flex: none; width: 46px; height: 46px; border-radius: 23px; background: {col}; color: {ONACC}; display: flex; align-items: center; justify-content: center">{icon(ic)}</div>'
            f'<div style="display: flex; flex-direction: column; gap: 1px"><div style="font-size: 16.5px; font-weight: 600">{title}</div><div style="font-size: 14.5px; line-height: 1.45; color: {MUTED}">{text}</div></div></div>')
pages["How-Yogi-Helps.dc.html"] = page("How Yogi Focus helps you build a routine", phone(f"""{topbar("Idea-Mandala.dc.html")}
{help_art}
{h1("How Yogi Focus helps you build a routine", size=31, mt=14)}
<div style="margin-top: 16px; display: flex; flex-direction: column; gap: 13px">
{hrow(CREAM, "widget", "A gentle nudge, right on time", "A widget on your Home Screen shows the hour, the place and what to bring.")}
{hrow(TEAL, "heart", "A kind word every day", "Tell Yogi Focus how your practice felt. Every answer is a good one.")}
{hrow("#FFB07A", "lotus", "A lotus that blooms with you", "Each day you practise opens a petal. After 30 days, you get to see it.")}
</div>
<div style="margin-top: 16px; padding: 15px 20px; border-radius: 22px; background: {CREAM}; color: {ONACC}; font-family: {FH}; font-weight: 600; font-size: 19px; line-height: 1.3">Ten minutes a day is all it takes to begin. Let's choose your first routine.</div>
{cta("Choose my first routine", "Choose-Routine.dc.html")}"""), css=CSS_HELP)

# ---------- 6 Choose a routine
acts = [("meditate","Meditate"),("stretch","Stretch"),("exercise","Exercise or sport"),("walk","Walk"),("eat","Eating habits"),("read","Read"),
        ("journal","Journal"),("music","Play music"),("study","Study"),("tidy","Tidy up"),("plan","Plan my day"),("plus","My own")]
tiles = "\n".join(
    f'<button type="button" onClick="[[pick{i}]]" aria-pressed="[[on{i}]]" style="display: flex; align-items: center; gap: 10px; min-height: 54px; padding: 0 14px; border-radius: 18px; '
    f'border: 2px solid [[bd{i}]]; background: [[bg{i}]]; color: {INK}; font-size: 15px; font-weight: 500; line-height: 1.2; text-align: left">{icon(ic, 22, DEEP)}<span>{lab}</span></button>'
    for i, (ic, lab) in enumerate(acts))
pages["Choose-Routine.dc.html"] = page("Choose one routine", phone(f'''{topbar("How-Yogi-Helps.dc.html")}
{h1("What would you like to practise?", size=34, mt=6)}
{p("Choose one, and only one. Ten minutes a day to begin.", mt=8)}
<div style="margin-top: 18px; display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px">
{tiles}
</div>
{p("When your first mandala is complete, Yogi Focus will invite you to add another.", size=14, color=MUTED, mt=14)}
{cta("Continue", "Anchor.dc.html")}'''), logic='''renderVals() {
const s = this.state || {};
const picked = s.picked ?? 0;
const v = {};
for (let i = 0; i < 12; i++) {
const on = i === picked;
v['on' + i] = on;
v['bd' + i] = on ? '#127A35' : '#E2EBD6';
v['bg' + i] = on ? '#E6F8D2' : '#FFFFFF';
v['pick' + i] = () => this.setState({ picked: i });
}
return v;
}''')

# ---------- 7 Anchor
lab = f'font-size: 13px; font-weight: 500; color: {MUTED}'
chip = f'display: flex; align-items: center; min-height: 34px; padding: 0 12px; border-radius: 17px; background: {SOFT}; font-size: 15px; font-weight: 500'
pages["Anchor.dc.html"] = page("Give the routine a home", phone(f'''{topbar("Choose-Routine.dc.html")}
{h1("Give Meditate a home.", size=34, mt=6)}
{p("The more exact you are, the easier it is to begin.", mt=8)}
<div style="margin-top: 18px; border-radius: 22px; border: 1px solid {LINE}; background: {PAPER}; display: flex; flex-direction: column">
<button type="button" style="display: flex; align-items: center; gap: 14px; min-height: 68px; padding: 0 18px; border: none; background: transparent; color: {INK}; text-align: left">{icon("clock", 22, DEEP)}<span style="display: flex; flex-direction: column; flex: 1"><span style="{lab}">When</span><span style="font-size: 17px; font-weight: 600">7:00 am, for 10 minutes</span></span>{icon("chev_right", 20, MUTED)}</button>
<div style="display: flex; align-items: center; gap: 14px; min-height: 72px; padding: 0 18px; border-top: 1px solid {LINE}">{icon("pin", 22, DEEP)}<div style="display: flex; flex-direction: column; flex: 1"><label for="place" style="{lab}">Where</label><input id="place" type="text" value="[[place]]" onChange="[[setPlace]]" style="border: none; background: transparent; padding: 0; min-height: 30px; width: 100%; font-size: 17px; font-weight: 600; color: {INK}"></div></div>
<div style="display: flex; align-items: flex-start; gap: 14px; padding: 14px 18px; border-top: 1px solid {LINE}"><div style="padding-top: 2px">{icon("bag", 22, DEEP)}</div><div style="display: flex; flex-direction: column; gap: 8px; flex: 1"><span style="{lab}">With</span><div style="display: flex; flex-wrap: wrap; align-items: center; gap: 8px"><span style="{chip}">Yoga mat</span><span style="{chip}">Grey shawl</span><button type="button" aria-label="Add something you use" style="display: flex; align-items: center; justify-content: center; width: 44px; height: 44px; border-radius: 22px; border: 1.5px dashed {MUTED}; background: transparent; color: {DEEP}">{icon("plus", 20)}</button></div></div></div>
</div>
{p("A first routine is ten minutes. No less, and for the first week, no more.", size=14, color=MUTED, mt=10)}
<div style="margin-top: 12px; padding: 16px 22px; border-radius: 22px; background: {CREAM}; color: {ONACC}; display: flex; flex-direction: column; gap: 6px"><span style="font-size: 13px; font-weight: 600">Your routine</span><div style="font-family: {FH}; font-weight: 600; font-size: 20px; line-height: 1.3">Each day at 7:00 am, I go to [[place]] with my yoga mat and grey shawl, and meditate for ten minutes.</div></div>
{cta("This is my routine", "Widget-Setup.dc.html")}'''), logic='''renderVals() {
const s = this.state || {};
return {
place: s.place ?? 'the balcony',
setPlace: (e) => this.setState({ place: e.target.value })
};
}''')

# ---------- Routines: see them all, configure each
def rcard(name, when, where, things, chip_html, foot_html):
    r = lambda ic, t: f'<div style="display: flex; align-items: center; gap: 10px; min-height: 26px">{icon(ic, 18, DEEP)}<span>{t}</span></div>'
    return (f'<div style="padding: 18px 12px 6px 18px; border-radius: 24px; border: 1px solid {LINE}; background: {PAPER}; display: flex; flex-direction: column">'
            f'<div style="display: flex; align-items: center; justify-content: space-between; gap: 10px; padding-right: 6px"><div style="font-family: {FH}; font-weight: 700; font-size: 26px; line-height: 1.1">{name}</div>{chip_html}</div>'
            f'<div style="margin-top: 8px; display: flex; flex-direction: column; font-size: 15px">{r("clock", when)}{r("pin", where)}{r("bag", things)}</div>'
            f'<div style="margin-top: 4px; display: flex; align-items: center; justify-content: space-between; gap: 10px">{foot_html}'
            f'<a href="Routine-Edit.dc.html" aria-label="Edit {name}" style="flex: none; display: flex; align-items: center; gap: 2px; min-height: 44px; padding: 0 6px; font-size: 15px; font-weight: 600; text-decoration: none">Edit{icon("chev_right", 18)}</a></div></div>')
chip_kept = f'<span style="flex: none; display: flex; align-items: center; gap: 5px; padding: 4px 11px; border-radius: 14px; background: {SOFT}; color: {DEEP}; font-size: 13px; font-weight: 600">{icon("check", 14, DEEP, 2.6)}Kept today</span>'
chip_next = f'<span style="flex: none; padding: 4px 11px; border-radius: 14px; background: {CREAM}; font-size: 13px; font-weight: 600">Next, 9:30 pm</span>'
foot_done = (f'<span style="display: flex; align-items: center; gap: 8px; font-size: 13.5px; font-weight: 600; color: {DEEP}">{lotus_svg(30, "A fully open lotus", opened=48).replace("grid-area: 1 / 1", "flex: none")}First mandala complete</span>')
foot_new = f'<span style="font-size: 13.5px; font-weight: 500; color: {MUTED}">In its first days</span>'
pages["Routines.dc.html"] = page("Your routines", phone(f"""{topbar("Today.dc.html")}
{h1("Your routines", size=34, mt=6)}
{p("Each one has its own hour, its own place and its own things.", size=15, color=MUTED, mt=6)}
<div style="margin-top: 16px; display: flex; flex-direction: column; gap: 12px">
{rcard("Meditate", "7:00 am, 10 minutes", "The balcony", "Yoga mat, grey shawl", chip_kept, foot_done)}
{rcard("Read", "9:30 pm, 10 minutes", "The bedside chair", "Book, reading lamp", chip_next, foot_new)}
<a href="Choose-Routine.dc.html" style="display: flex; align-items: center; justify-content: center; gap: 8px; min-height: 60px; border-radius: 24px; border: 1.5px dashed {MUTED}; color: {INK}; font-size: 16px; font-weight: 600; text-decoration: none">{icon("plus", 20)}Add a routine</a>
</div>
{p("Add slowly. Give each routine a full mandala before you start the next.", size=14, color=MUTED, mt=12)}"""))

sw = lambda on, label_id: (f'<button type="button" role="switch" aria-checked="{"true" if on else "false"}" aria-labelledby="{label_id}" style="flex: none; width: 76px; height: 58px; border: none; background: transparent; display: flex; align-items: center; justify-content: center">'
      f'<span style="width: 52px; height: 32px; border-radius: 16px; background: {TEAL if on else "#B8C4B4"}; display: flex; align-items: center; justify-content: {"flex-end" if on else "flex-start"}; padding: 0 3px; box-sizing: border-box"><span style="width: 26px; height: 26px; border-radius: 13px; background: {WHITE}"></span></span></button>')
pages["Routine-Edit.dc.html"] = page("Routine settings", phone(f"""{topbar("Routines.dc.html")}
<div style="margin-top: 6px; font-size: 14px; font-weight: 600; color: {MUTED}">Routine</div>
{h1("Meditate", size=34, mt=0)}
<div style="margin-top: 16px; border-radius: 22px; border: 1px solid {LINE}; background: {PAPER}; display: flex; flex-direction: column">
<button type="button" style="display: flex; align-items: center; gap: 14px; min-height: 68px; padding: 0 18px; border: none; background: transparent; color: {INK}; text-align: left">{icon("clock", 22, DEEP)}<span style="display: flex; flex-direction: column; flex: 1"><span style="{lab}">When</span><span style="font-size: 17px; font-weight: 600">7:00 am, for 10 minutes</span></span>{icon("chev_right", 20, MUTED)}</button>
<div style="display: flex; align-items: center; gap: 14px; min-height: 72px; padding: 0 18px; border-top: 1px solid {LINE}">{icon("pin", 22, DEEP)}<div style="display: flex; flex-direction: column; flex: 1"><label for="place" style="{lab}">Where</label><input id="place" type="text" value="[[place]]" onChange="[[setPlace]]" style="border: none; background: transparent; padding: 0; min-height: 30px; width: 100%; font-size: 17px; font-weight: 600; color: {INK}"></div></div>
<div style="display: flex; align-items: flex-start; gap: 14px; padding: 14px 18px; border-top: 1px solid {LINE}"><div style="padding-top: 2px">{icon("bag", 22, DEEP)}</div><div style="display: flex; flex-direction: column; gap: 8px; flex: 1"><span style="{lab}">With</span><div style="display: flex; flex-wrap: wrap; align-items: center; gap: 8px"><span style="{chip}">Yoga mat</span><span style="{chip}">Grey shawl</span><button type="button" aria-label="Add something you use" style="display: flex; align-items: center; justify-content: center; width: 44px; height: 44px; border-radius: 22px; border: 1.5px dashed {MUTED}; background: transparent; color: {DEEP}">{icon("plus", 20)}</button></div></div></div>
</div>
<div style="margin-top: 14px; border-radius: 22px; border: 1px solid {LINE}; background: {PAPER}; display: flex; flex-direction: column">
<div style="padding-left: 18px; min-height: 60px; display: flex; align-items: center; justify-content: space-between; gap: 12px"><span id="chime2" style="font-size: 15.5px; font-weight: 500">A soft chime at 7:00 am</span>{sw(True, "chime2")}</div>
<div style="padding-left: 18px; min-height: 68px; border-top: 1px solid {LINE}; display: flex; align-items: center; justify-content: space-between; gap: 12px"><span style="display: flex; flex-direction: column"><span id="pause" style="font-size: 15.5px; font-weight: 500">Pause this routine</span><span style="font-size: 13px; color: {MUTED}">The widget goes quiet. Nothing is lost.</span></span>{sw(False, "pause")}</div>
</div>
<button type="button" style="margin-top: 8px; align-self: center; min-height: 44px; padding: 0 12px; border: none; background: transparent; color: {INK}; font-size: 15px; font-weight: 500; text-decoration: underline">Remove this routine</button>
{cta("Save", "Routines.dc.html")}"""), logic="""renderVals() {
const s = this.state || {};
return {
place: s.place ?? 'the balcony',
setPlace: (e) => this.setState({ place: e.target.value })
};
}""")

# ---------- widgets
# A decorative lotus, half off the right edge, tinted to sit just above each widget's own background.
# Every petal is the same tone, so it never reads as progress.
LOTUS_TINT = {PAPER: ("#24402A", "#203825", "#1C3020"), SOFTY: ("#4D461A", "#454017", "#3F3A14"),
              CREAM: ("#FFE780", "#FFE066", "#FFDA47"), SOFT: ("#2A5231", "#25492C", "#204126")} if DARK else {WHITE: ("#DDF3C3", "#E7F7D3", "#EFFAE2"), CREAMS: ("#FFE266", "#FFE87C", "#FFED94"),
              CREAM: ("#FFE780", "#FFE066", "#FFDA47"), SOFT: ("#C6ECA2", "#D0F0B1", "#DAF3C1")}
REMIND = "Remember: same place, same time, same things."
ROT = "9s ease-in-out infinite"
def rot(a, b):
    return (f'<div style="display: grid"><div style="grid-area: 1 / 1; animation: yf-rota {ROT}">{a}</div>'
            f'<div style="grid-area: 1 / 1; opacity: 0; animation: yf-rotb {ROT}">{b}</div></div>')
ANIM = {}
def _an(k): return f"; animation: {ANIM[k]}" if k in ANIM else ""
def _tick(svg): return f'<span style="display: flex{_an("tick")}">{svg}</span>' if "tick" in ANIM else svg
def w_lotus(bg, size, top):
    t = LOTUS_TINT[bg]
    return (f'<svg aria-hidden="true" viewBox="-150 -150 300 300" width="{size}" height="{size}" style="position: absolute; right: {-size // 2}px; top: {top}px; display: block{_an("lotus")}">'
            f'{lotus_body(opened=48, open_cols=t, sep=bg, center=t[0])}</svg>')
def w_small(label, l1, l2="", bg=PAPER, dot=None, done=False, check=False, alt=None):
    d = f'<span style="width: 8px; height: 8px; border-radius: 4px; background: {dot}"></span>' if dot else ""
    c = _tick(icon("check", 15, DEEP, 2.4)) if check else ""
    l2h = f'<div style="font-size: 13px; line-height: 1.35; color: {MUTED}">{l2}</div>' if l2 else ""
    btn = (f'<button type="button" style="margin-top: auto; min-height: 44px; border-radius: 22px; border: none; background: {TEAL}; color: {ONACC}; font-size: 14px; font-weight: 600{_an("press")}">Done</button>') if done else ""
    return (f'<div style="position: relative; overflow: hidden; width: 170px; height: 170px; border-radius: 24px; background: {bg}; color: {ONACC if bg == CREAM else INK}">{w_lotus(bg, 172, 30)}'
            f'<div style="position: relative; box-sizing: border-box; height: 100%; padding: 16px; display: flex; flex-direction: column; line-height: 1.3">'
            f'<div style="display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 600; color: {ONACC if bg == CREAM else DEEP}">{d}{c}<span>{label}</span></div>'
            f'<div style="margin-top: 6px; font-family: {FH}; font-weight: 700; font-size: 25px; line-height: 1.1">Meditate</div>'
            + (rot(f'<div style="margin-top: 2px; font-size: 14px; font-weight: 500">{l1}</div>{l2h}', f'<div style="margin-top: 2px; font-size: 14px; font-weight: 500">{alt}</div>') if alt else
               f'<div style="margin-top: 2px; font-size: 14px; font-weight: 500">{l1}</div>{l2h}') + f'{btn}</div></div>')
def lcell(caption, widget):
    return (f'<div style="display: flex; flex-direction: column; gap: 8px"><div style="height: 30px; display: flex; align-items: flex-end; font-size: 14px; font-weight: 600; line-height: 1.35; color: {INK}">{caption}</div>{widget}</div>')
def w_med(label, line, bg=PAPER, dot=False, check=False, done=False, foot=(), joyful=False, progress=None, alt=None):
    d = f'<span style="width: 8px; height: 8px; border-radius: 4px; background: {SAFF}"></span>' if dot else ""
    c = _tick(icon("check", 15, DEEP, 2.4)) if check else ""
    if progress:
        art = (f'<div style="position: absolute; right: 16px; top: 22px; display: grid; place-items: center">{lotus_svg(126, f"Lotus with {progress} petals open and 3 red petals for missed days", **SAMPLE)}'
               f'<div style="grid-area: 1 / 1; font-family: {FH}; font-weight: 700; font-size: 13px; line-height: 1; padding-top: 2px">{progress}</div></div>')
    else:
        dh = dict(dhoti=WHITE, dhoti_shade="#E9DDB8") if bg == CREAM else {}
        art = (w_lotus(bg, 236, -33) + f'<svg aria-hidden="true" viewBox="0 0 200 200" width="112" height="112" style="position: absolute; right: 10px; top: 32px; display: block">{yogi_body(joyful=joyful, **dh)}</svg>')
    btn = (f'<button type="button" style="margin-top: auto; min-height: 44px; border-radius: 22px; border: none; background: {TEAL}; color: {ONACC}; font-size: 14px; font-weight: 600{_an("press")}">Done</button>') if done else ""
    ft = (f'<div style="margin-top: auto; display: flex; flex-direction: column; font-size: 13px; line-height: 1.4; color: {MUTED}">{"".join(f"<span>{t}</span>" for t in foot)}</div>') if foot else ""
    return (f'<div style="position: relative; overflow: hidden; height: 170px; border-radius: 24px; background: {bg}; color: {ONACC if bg == CREAM else INK}">{art}'
            f'<div style="position: relative; box-sizing: border-box; width: 236px; height: 100%; padding: 16px 0 16px 18px; display: flex; flex-direction: column; line-height: 1.3">'
            f'<div style="display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 600; color: {ONACC if bg == CREAM else DEEP}">{d}{c}<span>{label}</span></div>'
            f'<div style="margin-top: 2px; font-family: {FH}; font-weight: 700; font-size: 28px; line-height: 1.1">Meditate</div>'
            f'<div style="margin-top: 3px; font-family: {FH}; font-weight: 600; font-size: 16px; line-height: 1.25">{rot(f"<span>{line}</span>", f"<span>{alt}</span>") if alt else line}</div>{btn}{ft}</div></div>')
def w_medium(alt=None):
    return w_med("Today", "A new day.", foot=("7:00 am · The balcony", "Yoga mat, grey shawl"), alt=alt)
medium = "\n".join([
  lcell("Days 1 to 6 · earlier in the day · the line rotates", w_medium(alt=REMIND)),
  lcell("Boring middle · at the hour", w_med("It's time", "Don't decide. Just start.", bg=CREAM, dot=True, done=True)),
  lcell("Any day · after you tap Done", w_med("Kept today", "Only tomorrow is next.", bg=SOFT, check=True, joyful=True, foot=("Tomorrow, 7:00 am · The balcony",))),
  lcell("After day 30 · once kept", w_med("Kept today", "34 petals open.", bg=SOFT, check=True, progress=34, foot=("Tomorrow, one more", "7:00 am · The balcony"))),
])

# ---------- 8 Widget setup
def num(n, t):
    return (f'<li style="display: flex; align-items: center; gap: 14px"><span style="flex: none; width: 28px; height: 28px; border-radius: 14px; background: {SOFT}; color: {DEEP}; font-size: 14px; font-weight: 600; display: flex; align-items: center; justify-content: center">{n}</span><span style="font-size: 15.5px; line-height: 1.4">{t}</span></li>')
pages["Widget-Setup.dc.html"] = page("Add the Home Screen widget", phone(f'''{topbar("Anchor.dc.html", f'<a href="Today.dc.html" style="display: flex; align-items: center; min-height: 44px; font-size: 15px; font-weight: 500; text-decoration: none">Not now</a>')}
{h1("Let your Home Screen do the remembering.", size=32, mt=6)}
<div style="margin-top: 16px; padding: 16px; border-radius: 30px; background: {TEAL}">{w_medium()}</div>
<ol style="margin: 18px 0 0; padding: 0; list-style: none; display: flex; flex-direction: column; gap: 12px">
{num(1, "Touch and hold an empty spot on your Home Screen.")}
{num(2, "Tap Edit, then Add Widget.")}
{num(3, "Search for Yogi Focus and choose a size.")}
</ol>
<div style="margin-top: 16px; padding: 0 0 0 18px; min-height: 60px; border-radius: 20px; border: 1px solid {LINE}; background: {PAPER}; display: flex; align-items: center; justify-content: space-between; gap: 12px"><span id="chime" style="font-size: 15.5px; font-weight: 500">A soft chime at 7:00 am</span><button type="button" role="switch" aria-checked="true" aria-labelledby="chime" style="flex: none; width: 76px; height: 58px; border: none; background: transparent; display: flex; align-items: center; justify-content: center"><span style="width: 52px; height: 32px; border-radius: 16px; background: {TEAL}; display: flex; align-items: center; justify-content: flex-end; padding: 0 3px; box-sizing: border-box"><span style="width: 26px; height: 26px; border-radius: 13px; background: {WHITE}"></span></span></button></div>
{p("No badges, no streak alerts, no nagging.", size=14, color=MUTED, mt=10)}
{cta("I've added it", "Today.dc.html")}'''))

# ---------- 9 Widget states
def cell(caption, widget, span=1):
    sp = f"grid-column: span {span}; " if span > 1 else ""
    return (f'<div style="{sp}display: flex; flex-direction: column; gap: 10px"><div style="height: 40px; display: flex; align-items: flex-end; font-size: 14px; font-weight: 600; line-height: 1.35; color: {INK}">{caption}</div>{widget}</div>')
states = "\n".join([
  cell("Days 1 to 6 · earlier in the day", w_small("Today", "7:00 am", "The balcony", alt=REMIND)),
  cell("Days 1 to 6 · twenty minutes before", w_small("In 20 minutes", "The balcony", "Yoga mat, grey shawl", bg=SOFTY)),
  cell("Days 1 to 6 · at the hour", w_small("It's time", "Your mat is waiting.", bg=CREAM, dot=SAFF, done=True)),
  cell("Days 1 to 6 · after you tap Done", w_small("Kept today", "See you tomorrow", "7:00 am", bg=SOFT, check=True)),
  cell("Boring middle · earlier in the day", w_small("Today, 7:00 am", "Dull is normal now.", "It passes. Just show up.", alt=REMIND)),
  cell("Boring middle · twenty minutes before", w_small("In 20 minutes", "No need to feel like it.", "Just go to the balcony.", bg=SOFTY)),
  cell("Boring middle · at the hour", w_small("It's time", "Don't decide. Just start.", bg=CREAM, dot=SAFF, done=True)),
  cell("Boring middle · after you tap Done", w_small("Kept today", "You started anyway.", "That is the whole practice.", bg=SOFT, check=True)),
  cell("Any day · if the hour slips by", w_small("Still today", "Just start when you can.", done=True)),
  cell("Any day · the morning after a miss", w_small("A new day", "7:00 am", "Nothing to catch up. Just start.")),
  cell("Days 28 to 48 · at the hour", w_small("It's time", "You know the way.", bg=CREAM, dot=SAFF, done=True)),
  cell("After day 30 · once kept", w_small("Kept today", "34 petals open", "Tomorrow, 7:00 am", bg=SOFT, check=True)),
  f'<div style="grid-column: span 4; font-size: 14px; font-weight: 600; line-height: 1.45; color: {INK}">Earlier in the day, the widget now and then swaps its lines for the reminder: same place, same time, same things. It is a plain change of text, which widgets allow.</div>',
])
pages["Widget-States.dc.html"] = page("Widget through the 48 days",
  f'<div style="width: 880px; height: 890px; box-sizing: border-box; padding: 44px 48px; background: {NIGHT}; font-family: {FB}; display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); column-gap: 34px; row-gap: 36px; align-content: start">\n{states}\n</div>',
  w=880, h=890)

# ---------- Large widget (364 x 382): room for the whole routine, one line of encouragement and the yogi
def w_large(label, line, bg=PAPER, dot=False, check=False, done=False, foot="", joyful=False, progress=None, alt=None):
    d = f'<span style="width: 9px; height: 9px; border-radius: 5px; background: {SAFF}"></span>' if dot else ""
    c = _tick(icon("check", 17, DEEP, 2.4)) if check else ""
    r = lambda ic, t: f'<div style="display: flex; align-items: center; gap: 10px; min-height: 26px">{icon(ic, 18, ONACC if bg == CREAM else DEEP)}<span>{t}</span></div>'
    if progress:
        art = (f'<div style="position: absolute; right: 18px; top: 20px; display: grid; place-items: center">{lotus_svg(150, f"Lotus with {progress} petals open and 3 red petals for missed days", **SAMPLE)}'
               f'<div style="grid-area: 1 / 1; font-family: {FH}; font-weight: 700; font-size: 15px; line-height: 1; padding-top: 2px">{progress}</div></div>')
    else:
        dh = dict(dhoti=WHITE, dhoti_shade="#E9DDB8") if bg == CREAM else {}
        art = (w_lotus(bg, 372, 26) + f'<svg aria-hidden="true" viewBox="0 0 200 200" width="124" height="124" style="position: absolute; right: 12px; top: 58px; display: block">{yogi_body(joyful=joyful, **dh)}</svg>')
    btn = (f'<button type="button" style="margin-top: auto; min-height: 48px; border-radius: 24px; border: none; background: {TEAL}; color: {ONACC}; font-size: 15px; font-weight: 600{_an("press")}">Done</button>') if done else ""
    ft = (f'<div style="margin-top: auto; font-size: 14px; font-weight: 500; color: {MUTED}">{foot}</div>') if foot else ""
    return (f'<div style="position: relative; overflow: hidden; width: 364px; height: 382px; border-radius: 28px; background: {bg}; color: {ONACC if bg == CREAM else INK}">{art}'
            f'<div style="position: relative; box-sizing: border-box; height: 100%; padding: 20px; display: flex; flex-direction: column; line-height: 1.3">'
            f'<div style="display: flex; align-items: center; gap: 7px; font-size: 13.5px; font-weight: 600; color: {ONACC if bg == CREAM else DEEP}">{d}{c}<span>{label}</span></div>'
            f'<div style="margin-top: 4px; font-family: {FH}; font-weight: 700; font-size: 36px; line-height: 1.1">Meditate</div>'
            f'<div style="margin-top: 10px; display: flex; flex-direction: column; font-size: 15px; font-weight: 500">{r("clock", "7:00 am, 10 minutes")}{r("pin", "The balcony")}{r("bag", "Yoga mat, grey shawl")}</div>'
            f'<div style="margin-top: 22px; font-family: {FH}; font-weight: 600; font-size: 21px; line-height: 1.25; text-wrap: balance">{rot(f"<span>{line}</span>", f"<span>{alt}</span>") if alt else line}</div>{btn}{ft}</div></div>')
large = "\n".join([
  lcell("Days 1 to 6 · earlier in the day · the line rotates", w_large("Today", "A new day. How will you keep your practice today?", foot="Starts in 3 hours", alt=REMIND)),
  lcell("Boring middle · at the hour", w_large("It's time", "Dull is normal now. Don't decide. Just start.", bg=CREAM, dot=True, done=True)),
  lcell("Any day · after you tap Done", w_large("Kept today", "That's today, kept. Only tomorrow is next.", bg=SOFT, check=True, joyful=True, foot="Tomorrow, 7:00 am")),
  lcell("After day 30 · once kept", w_large("Kept today", "34 petals open. Tomorrow, one more.", bg=SOFT, check=True, progress=34, foot="Tomorrow, 7:00 am")),
])
pages["Widget-Large.dc.html"] = page("Large widget",
  f'<div style="width: 860px; height: 940px; box-sizing: border-box; padding: 36px 48px; background: {NIGHT}; font-family: {FB}; display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); column-gap: 34px; row-gap: 28px; align-content: start">\n{large}\n</div>',
  w=860, h=940)

pages["Widget-Medium.dc.html"] = page("Medium widget",
  f'<div style="width: 860px; height: 516px; box-sizing: border-box; padding: 36px 48px; background: {NIGHT}; font-family: {FB}; display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); column-gap: 34px; row-gap: 28px; align-content: start">\n{medium}\n</div>',
  w=860, h=516)

# ---------- Widget: the one animated moment, identical on every size
CSS_WDONE = """@keyframes yf-wb{0%,34%{opacity:0}46%,90%{opacity:1}100%{opacity:0}}
@keyframes yf-wlotus{0%,34%{opacity:0;transform:scale(0.5) rotate(-40deg)}50%,90%{opacity:1;transform:scale(1) rotate(0deg)}100%{opacity:0;transform:scale(1) rotate(0deg)}}
@keyframes yf-wtick{0%,38%{transform:scale(0)}45%{transform:scale(1.35)}50%,100%{transform:scale(1)}}
@keyframes yf-wtap{0%,21%{opacity:0;transform:scale(0.4)}27%{opacity:0.45;transform:scale(1)}35%,100%{opacity:0;transform:scale(1.6)}}
@keyframes yf-wpress{0%,26%{transform:scale(1)}29%{transform:scale(0.94)}33%,100%{transform:scale(1)}}
"""
TW = "7s ease-in-out -3.6s infinite"
def done_demo(w, h, radius, before, after, tap_left, tap_top):
    ANIM.clear(); ANIM["press"] = f"yf-wpress {TW}"; a = before()
    ANIM.clear(); ANIM.update(lotus=f"yf-wlotus {TW}", tick=f"yf-wtick {TW}"); b = after()
    ANIM.clear()
    return (f'<div role="img" aria-label="The widget changes from It is time to Kept today when Done is tapped" style="position: relative; width: {w}px; height: {h}px; border-radius: {radius}px; overflow: hidden">{a}'
            f'<div style="position: absolute; left: 0; top: 0; width: {w}px; opacity: 0; animation: yf-wb {TW}">{b}</div>'
            f'<span style="position: absolute; left: {tap_left}px; top: {tap_top}px; width: 44px; height: 44px; border-radius: 22px; background: {INK}; opacity: 0; animation: yf-wtap {TW}"></span></div>')
d_small = done_demo(170, 170, 24, lambda: w_small("It's time", "Don't decide. Just start.", bg=CREAM, dot=SAFF, done=True),
                    lambda: w_small("Kept today", "You started anyway.", "Tomorrow, 7:00 am", bg=SOFT, check=True), 63, 110)
d_med = done_demo(364, 170, 24, lambda: w_med("It's time", "Don't decide. Just start.", bg=CREAM, dot=True, done=True),
                  lambda: w_med("Kept today", "Only tomorrow is next.", bg=SOFT, check=True, joyful=True, foot=("Tomorrow, 7:00 am · The balcony",)), 105, 110)
d_large = done_demo(364, 382, 28, lambda: w_large("It's time", "Dull is normal now. Don't decide. Just start.", bg=CREAM, dot=True, done=True),
                    lambda: w_large("Kept today", "That's today, kept. Only tomorrow is next.", bg=SOFT, check=True, joyful=True, foot="Tomorrow, 7:00 am"), 160, 316)
note = lambda t: f'<div style="display: flex; gap: 10px; align-items: flex-start"><span style="flex: none; width: 6px; height: 6px; margin-top: 8px; border-radius: 3px; background: {INK}"></span><span>{t}</span></div>'
pages["Widget-Done.dc.html"] = page("Widget: tapping Done",
  f'<div style="width: 860px; height: 700px; box-sizing: border-box; padding: 40px 48px; background: {NIGHT}; color: {INK}; font-family: {FB}; display: flex; flex-direction: column">\n'
  f'<div style="font-size: 14px; font-weight: 600">The one animated moment</div>\n<div style="font-family: {FH}; font-weight: 700; font-size: 30px; line-height: 1.15">Tapping Done, on every size</div>\n'
  f'<div style="margin-top: 14px; display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); column-gap: 34px">\n'
  f'<div style="display: flex; flex-direction: column; gap: 22px">{lcell("Small", d_small)}{lcell("Medium", d_med)}</div>\n{lcell("Large", d_large)}\n</div>\n'
  f'<div style="margin-top: 22px; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); column-gap: 24px; font-size: 14px; line-height: 1.45; font-weight: 500">\n'
  f'{note("The card turns green, the tick pops in and the lotus opens once.")}\n{note("On medium and large, the yogi opens his eyes and smiles.")}\n{note("About one second on every size. Nothing else moves by itself.")}\n</div>\n</div>',
  w=860, h=700, css=CSS_WDONE)

# ---------- Today and its variants (nothing is counted on screen before day 30)
def today(head, sub, chip_t, extra=""):
    r = lambda ic, t: f'<div style="display: flex; align-items: center; gap: 12px; min-height: 30px">{icon(ic, 20, DEEP)}<span>{t}</span></div>'
    return phone(f"""<div style="display: flex; align-items: center; justify-content: space-between; height: 44px; flex: none"><div style="font-family: {FH}; font-weight: 700; font-size: 26px; line-height: 1; color: {DEEP}">Yogi Focus</div><a href="Routines.dc.html" aria-label="Your routines" style="width: 44px; height: 44px; margin-right: -10px; color: {INK}; display: flex; align-items: center; justify-content: center">{icon("plan")}</a></div>
<div style="margin-top: 22px; font-size: 14px; font-weight: 500; color: {MUTED}">Sunday 15 November</div>
{h1(head, size=42, mt=2)}
{p(sub, mt=6)}
<div style="margin-top: 22px; padding: 22px; border-radius: 26px; border: 1px solid {LINE}; background: {PAPER}; display: flex; flex-direction: column">
<span style="align-self: flex-start; padding: 4px 12px; border-radius: 14px; background: {CREAM}; color: {ONACC}; font-size: 13px; font-weight: 600">{chip_t}</span>
<div style="margin-top: 10px; font-family: {FH}; font-weight: 700; font-size: 32px; line-height: 1.1">Meditate</div>
<div style="margin-top: 10px; display: flex; flex-direction: column; gap: 4px; font-size: 16px">
{r("clock", "7:00 am, for 10 minutes")}
{r("pin", "The balcony")}
{r("bag", "Yoga mat, grey shawl")}
</div>
</div>{extra}
{cta("I've practised today", "Reflect.dc.html")}""")
def under(t): return "\n" + p(t, size=14, color=MUTED, mt=14)
pages["Today.dc.html"] = page("Today, in the first week", today("A new day.", "How will you keep your practice today?", "In 20 minutes",
  extra=under("This first week, stop at ten minutes, even if you would like more.")))
pages["Just-Start.dc.html"] = page("Today, in the boring middle", today("Just start.", "If today feels flat, that is the practice settling in, not failing. You don't need to feel like it. Go to the balcony, sit on the mat and begin.", "In 20 minutes",
  extra=under("The middle weeks are often the dullest. They pass.")))
pages["Still-Today.dc.html"] = page("Today, after the hour has passed", today("Still today.", "7:00 has gone by, and that is all right. The day isn't over. Just start when you can.", "Whenever you're ready"))
pages["New-Day.dc.html"] = page("Today, after a missed day", today("A new day.", "Yesterday is finished. Nothing to catch up, nothing to make good. Just start today.", "Today at 7:00 am",
  extra=f'\n<a href="Routine-Edit.dc.html" style="margin-top: 6px; display: flex; align-items: center; min-height: 44px; font-size: 15px; font-weight: 500">Is 7:00 am hard to keep? Try another hour</a>'))

# ---------- 11 Reflect
def opt(k, ic, title, sub):
    return (f'<button type="button" onClick="[[{k}.pick]]" aria-pressed="[[{k}.on]]" style="display: flex; align-items: center; gap: 14px; min-height: 72px; padding: 0 16px; border-radius: 20px; border: 2px solid [[{k}.bd]]; background: [[{k}.bg]]; color: {INK}; text-align: left">'
            f'<span style="flex: none; width: 44px; height: 44px; border-radius: 22px; background: {CREAM}; color: {ONACC}; display: flex; align-items: center; justify-content: center">{icon(ic)}</span>'
            f'<span style="display: flex; flex-direction: column"><span style="font-size: 17px; font-weight: 600">{title}</span><span style="font-size: 14px; color: {MUTED}">{sub}</span></span></button>')
def msg(k, t, shown):
    return (f'<sc-if value="[[{k}.on]]" hint-placeholder-val="[[ {shown} ]]"><div style="margin-top: 14px; padding: 18px 22px; border-radius: 22px; background: {CREAM}; color: {ONACC}; font-family: {FH}; font-weight: 600; font-size: 20px; line-height: 1.3; animation: yf-up 0.35s ease-out both">{t}</div></sc-if>')
pages["Reflect.dc.html"] = page("How did it feel?", phone(f'''{topbar("Today.dc.html")}
{h1("You practised today.", size=34, mt=6)}
{p("How did it feel? There is no wrong answer.", mt=8)}
<div style="margin-top: 18px; display: flex; flex-direction: column; gap: 10px">
{opt("a", "scattered", "Scattered", "My mind was everywhere")}
{opt("b", "steady", "Steady", "I stayed with it, mostly")}
{opt("c", "absorbed", "Absorbed", "I lost track of time")}
</div>
{msg("a", "Scattered days build the habit more than easy ones. You came anyway.", "false")}
{msg("b", "Steady is exactly how a practice grows.", "true")}
{msg("c", "Hold on to this feeling. It is what the practice gives back.", "false")}
<div style="margin-top: 14px; display: flex; flex-direction: column; gap: 6px"><label for="note" style="{lab}">A note for yourself (optional)</label><input id="note" type="text" value="[[note]]" onChange="[[setNote]]" placeholder="Anything you noticed" style="box-sizing: border-box; width: 100%; min-height: 48px; padding: 0 14px; border-radius: 14px; border: 1px solid {MUTED}; background: {PAPER}; font-size: 16px; color: {INK}"></div>
{cta("Done", "Kept.dc.html")}'''),
 props={"feeling": {"editor": "enum", "options": ["scattered", "steady", "absorbed"], "default": "steady", "section": "Preview"}},
 logic='''renderVals() {
const s = this.state || {};
const f = s.feeling ?? this.props.feeling ?? 'steady';
const mk = (id) => ({
on: f === id,
bd: f === id ? '#127A35' : '#E2EBD6',
bg: f === id ? '#E6F8D2' : '#FFFFFF',
pick: () => this.setState({ feeling: id })
});
return {
a: mk('scattered'),
b: mk('steady'),
c: mk('absorbed'),
note: s.note ?? '',
setNote: (e) => this.setState({ note: e.target.value })
};
}''')

def rays(cx, cy, r=560, fill="#7EDC49"):
    # one flat layer that the browser can spin without redrawing it
    return (f'<div aria-hidden="true" style="position: absolute; left: {cx - r}px; top: {cy - r}px; width: {2*r}px; height: {2*r}px; border-radius: 50%; '
            f'background: repeating-conic-gradient(from -5.2deg, {fill} 0deg 10.4deg, transparent 10.4deg 22.5deg); will-change: transform; animation: yf-spin 140s linear infinite"></div>')
def confetti(n=28, seed=48):
    rnd = random.Random(seed)
    cols = [WHITE, CREAM, CREAMS, SAFF, "#FFB3C7", CREAM, WHITE]
    out = []
    for k in range(n):
        left = round((k + rnd.random()) * 100 / n, 1)
        dur = round(rnd.uniform(6.5, 11), 1)
        delay = round(rnd.uniform(0, dur), 1)
        sway = round(rnd.uniform(1.6, 2.8), 1)
        sz = rnd.choice([11, 13, 15, 17])
        col = cols[k % len(cols)]
        out.append(f'<span style="position: absolute; left: {left}%; top: -40px; will-change: transform; animation: yf-fall {dur}s linear -{delay}s infinite">'
                   f'<span style="display: block; width: {sz}px; height: {sz}px; border-radius: 0 100% 0 100%; background: {col}; animation: yf-sway {sway}s ease-in-out -{round(rnd.uniform(0, sway), 1)}s infinite alternate"></span></span>')
    return f'<div aria-hidden="true" style="position: absolute; left: 0; top: 0; width: 390px; height: 844px; overflow: hidden; pointer-events: none">{"".join(out)}</div>'

# ---------- 12 Kept: a small celebration, then only tomorrow
CSS_KEPT = """@keyframes yf-fly{0%{transform:translateY(0) scale(0.2);opacity:0}10%{opacity:1}55%{transform:translateY(-92px) scale(1);opacity:1}78%,100%{transform:translateY(-118px) scale(1);opacity:0}}
@keyframes yf-halo{0%{transform:scale(0.6);opacity:0}12%{opacity:0.9}62%,100%{transform:scale(1.9);opacity:0}}
"""
KC = [WHITE, TEALD, SAFF, WHITE, TEALM, "#FF8FB1", WHITE, TEALD, SAFF]
burst = "".join(f'<g transform="translate(150 118) rotate({-120 + k*30}) translate(0 -58)"><path d="{petal_path(26, 10)}" fill="{KC[k]}" '
                f'style="transform-box: fill-box; transform-origin: 50% 100%; animation: yf-fly 4.5s ease-out {k*0.07:.2f}s infinite"></path></g>' for k in range(9))
kept_hero = (f'<svg role="img" aria-label="A smiling yogi floats while petals burst out around him" viewBox="0 0 300 262" width="300" height="262" style="display: block; align-self: center; flex: none; overflow: visible">'
             f'<circle cx="150" cy="118" r="70" fill="none" stroke="{WHITE}" stroke-width="7" style="{FB_BOX}; opacity: 0; animation: yf-halo 4.5s ease-out infinite"></circle>{burst}'
             f'<ellipse cx="150" cy="240" rx="48" ry="8" fill="#7A5B00" style="{FB_BOX}; opacity: 0.26; animation: yf-shadow 4.5s ease-in-out infinite"></ellipse>'
             f'<g style="animation: yf-levitate 4.5s ease-in-out infinite"><g transform="translate(35 8) scale(1.15)">{yogi_body(mat=False, dhoti=WHITE, dhoti_shade="#E9DDB8", joyful=True)}</g></g></svg>')
day_card = lambda bg, anim, inner: (f'<div style="flex: 1; min-width: 0; box-sizing: border-box; min-height: 116px; padding: 14px 16px; border-radius: 22px; background: {bg}; color: {ONACC if bg == TEAL else INK}; display: flex; flex-direction: column; animation: {anim}">{inner}</div>')
kept_inner = f"""{kept_hero}
{h1("That's today, kept.", size=38, mt=10)}
{p("Forever was never the job. Today was, and you did it.", mt=6)}
<div style="margin-top: 18px; display: flex; align-items: center; gap: 8px">
{day_card(TEAL, "yf-pop 0.5s cubic-bezier(0.3, 1.4, 0.5, 1) 0.3s both", f'<span style="font-size: 13px; font-weight: 600">Today</span><span style="margin-top: 2px; font-family: {FH}; font-weight: 700; font-size: 30px; line-height: 1.1">Kept</span><span style="margin-top: auto; width: 30px; height: 30px; border-radius: 15px; background: {ONACC}; color: {CREAM}; display: flex; align-items: center; justify-content: center">{icon("check", 18, "currentColor", 2.6)}</span>')}
<span style="flex: none; color: {INK}; display: flex">{icon("chev_right", 20, "currentColor", 2.4)}</span>
{day_card(PAPER, "yf-up 0.5s ease-out 0.9s both", f'<span style="font-size: 13px; font-weight: 600; color: {DEEP}">Only tomorrow</span><span style="margin-top: 2px; font-family: {FH}; font-weight: 700; font-size: 30px; line-height: 1.1">7:00 am</span><span style="margin-top: auto; font-size: 14px; font-weight: 500">The balcony</span>')}
</div>
{p("Don't think about the week. One day is all you ever have to keep, and the next one is tomorrow.", size=15, mt=14)}
{cta("Done", "Today.dc.html", **HBTN)}"""
kept_root = (f'<div style="position: relative; width: 390px; height: 844px; box-sizing: border-box; padding: 56px 28px 34px; display: flex; flex-direction: column; '
             f'background: {HERO_Y}; color: {INK}; font-family: {FB}; font-size: 16px; line-height: 1.55; overflow: hidden">\n{rays(195, 182, r=700, fill="#182B17" if DARK else "#FFDF52")}\n'
             f'<div style="position: relative; flex: 1; min-height: 0; display: flex; flex-direction: column">\n{kept_inner}\n</div>\n</div>')
pages["Kept.dc.html"] = page("Today is kept", kept_root, css=CSS_KEPT)

# ---------- Day 30: the lotus is shown for the first time
pages["Day-30.dc.html"] = page("Thirty days: meet your lotus", phone(f"""<div style="height: 8px; flex: none"></div>
{lotus(270, 30, today=30, num="28", label="Lotus on day 30: 28 petals open, 2 red petals for missed days", motion="bloom", missed=(9, 17))}
{h1("Thirty days. Meet your lotus.", mt=16)}
{p("Each day you practised opened a petal: 28 so far. Yogi Focus kept it out of sight so that every day could simply be today.", mt=8)}
{p("The two red petals are days you missed. Nothing resets, and the lotus keeps opening.", mt=10)}
{cta("See my mandala", "Mandala.dc.html")}"""))

# ---------- 14 Mandala
def felt(ic, name, n, pct):
    return (f'<div style="display: flex; align-items: center; gap: 12px; min-height: 36px">{icon(ic, 20, DEEP)}<span style="width: 84px; font-size: 15px; font-weight: 500">{name}</span>'
            f'<span style="flex: 1; height: 8px; border-radius: 4px; background: {SOFT}; display: flex"><span style="width: {pct}%; border-radius: 4px; background: {TEALM}"></span></span>'
            f'<span style="width: 52px; text-align: right; font-size: 14px; color: {MUTED}">{n} days</span></div>')
pages["Mandala.dc.html"] = page("Your mandala", phone(f'''{topbar("Today.dc.html")}
<div style="font-size: 14px; font-weight: 600; color: {MUTED}">Meditate</div>
{h1("Your mandala", size=34, mt=0)}
<div style="height: 10px; flex: none"></div>
{lotus(232, num="34", label="Lotus on day 37 of 48: 34 petals open, 3 red petals for missed days", **SAMPLE)}
<div style="margin-top: 10px; text-align: center; font-size: 17px; font-weight: 600">34 of 48 days practised</div>
<div style="text-align: center; font-size: 14px; color: {MUTED}">Day 37. 3 days missed. Nothing resets.</div>
<div style="margin-top: 8px; display: flex; justify-content: center; gap: 16px; font-size: 13px; font-weight: 500"><span style="display: flex; align-items: center; gap: 6px"><span style="width: 10px; height: 10px; border-radius: 5px; background: {TEALM}"></span>Practised</span><span style="display: flex; align-items: center; gap: 6px"><span style="width: 10px; height: 10px; border-radius: 5px; background: {MISSED}"></span>Missed</span><span style="display: flex; align-items: center; gap: 6px"><span style="width: 10px; height: 10px; border-radius: 5px; background: {PETAL_CLOSED}; box-shadow: inset 0 0 0 1px {MUTED}"></span>To come</span></div>
<div style="margin-top: 14px; font-size: 14px; font-weight: 600">How it has felt</div>
<div style="margin-top: 4px; display: flex; flex-direction: column">
{felt("absorbed", "Absorbed", 11, 32)}
{felt("steady", "Steady", 17, 50)}
{felt("scattered", "Scattered", 6, 18)}
</div>
<div style="margin-top: auto; padding: 0 6px 0 20px; min-height: 60px; border-radius: 20px; border: 1px solid {LINE}; background: {PAPER}; display: flex; align-items: center; justify-content: space-between; gap: 10px"><span style="font-size: 15px; font-weight: 500">Every day, 7:00 am, the balcony</span><a href="Routine-Edit.dc.html" style="display: flex; align-items: center; justify-content: center; min-width: 52px; min-height: 44px; font-size: 15px; font-weight: 600; text-decoration: none">Edit</a></div>'''))

# ---------- 16 Mandala complete: the grand finish
complete_inner = f"""<div style="display: flex; flex-direction: column; align-items: center; gap: 3px; text-align: center; flex: none"><div lang="sa" style="font-family: {FH}; font-weight: 600; font-size: 18px; line-height: 1.4; overflow-wrap: anywhere">स तु दीर्घकालनैरन्तर्यसत्कारासेवितो दृढभूमिः</div><div lang="sa-Latn" style="font-size: 14px; line-height: 1.45; font-style: italic; font-weight: 500; text-wrap: balance">sa tu dīrgha-kāla-nairantarya-satkārāsevito dṛḍha-bhūmiḥ</div><div style="margin-top: 4px; font-size: 14px; line-height: 1.5; text-wrap: balance">Practice finds firm ground when it is tended for a long time, steadily and with care.</div><div style="font-size: 12.5px; font-weight: 600">Yoga Sūtra 1.14</div></div>
<div style="display: flex; justify-content: center; margin-top: 10px; flex: none">{hero_svg(266, HERO_G, (WHITE, CREAMS, CREAM), joyful=True)}</div>
{h1("One mandala.", size=46, mt=6)}
{p("Out of 48 days, you practised 45 and missed 3. Yogis say a practice held this long is yours for life.", mt=4)}
{cta("Begin a new mandala", "Today.dc.html", **HBTN)}
{ghost("Add another routine", "Choose-Routine.dc.html", color=INK, border=INK)}"""
complete_root = (f'<div style="position: relative; width: 390px; height: 844px; box-sizing: border-box; padding: 56px 28px 34px; display: flex; flex-direction: column; '
                 f'background: {HERO_G}; color: {INK}; font-family: {FB}; font-size: 16px; line-height: 1.55; overflow: hidden">\n{rays(195, 330, fill="#173019" if DARK else "#7EDC49")}\n{confetti()}\n'
                 f'<div style="position: relative; flex: 1; min-height: 0; display: flex; flex-direction: column">\n{complete_inner}\n</div>\n</div>')
pages["Mandala-Complete.dc.html"] = page("One mandala complete", complete_root)

# ---------- Apple Watch (drawn at 208 x 248 pt, the 46 mm size; black ground as on watchOS)
WSEC = "#C2CDBE"
WLOTUS = ("#1F5129", "#184220", "#12331A")          # dark greens: the lotus sits quietly behind white text
def watch(inner, lotus=True):
    bg = (f'<svg aria-hidden="true" viewBox="-150 -150 300 300" width="236" height="236" style="position: absolute; right: -118px; top: 34px; display: block; will-change: transform; animation: yf-spin 60s linear infinite">'
          f'{lotus_body(opened=48, open_cols=WLOTUS, sep="#000000", center=WLOTUS[0])}</svg>') if lotus else ""
    return (f'<div style="position: relative; width: 208px; height: 248px; box-sizing: border-box; padding: 18px 13px 13px; border-radius: 46px; background: #000000; color: {WHITE}; display: flex; flex-direction: column; line-height: 1.25; overflow: hidden">{bg}'
            f'<div style="position: relative; flex: 1; min-height: 0; display: flex; flex-direction: column">{inner}</div></div>')
def wlabel(t, col=CREAM, dot=False):
    d = f'<span style="width: 8px; height: 8px; border-radius: 4px; background: {SAFF}"></span>' if dot else ""
    return f'<div style="display: flex; align-items: center; gap: 6px; font-size: 13px; font-weight: 600; color: {col}">{d}<span>{t}</span></div>'
wtitle = lambda t="Meditate", sz=27: f'<div style="margin-top: 2px; font-family: {FH}; font-weight: 700; font-size: {sz}px; line-height: 1.1">{t}</div>'
wline = lambda t, col=WHITE, sz=14.5: f'<div style="margin-top: 3px; font-size: {sz}px; font-weight: 500; color: {col}">{t}</div>'
wrow = lambda ic, t: f'<div style="display: flex; align-items: center; gap: 7px; min-height: 22px; font-size: 14px; font-weight: 500">{icon(ic, 16, TEAL)}<span>{t}</span></div>'
wbtn = lambda t="Done": f'<button type="button" style="margin-top: auto; min-height: 44px; border-radius: 22px; border: none; background: {TEAL}; color: {INK}; font-size: 16px; font-weight: 600">{t}</button>'
wyogi = lambda size, right, top, **kw: f'<svg aria-hidden="true" viewBox="0 0 200 200" width="{size}" height="{size}" style="position: absolute; right: {right - 13}px; top: {top - 18}px; display: block; animation: yf-levitate 4.5s ease-in-out infinite">{yogi_body(**kw)}</svg>'
def wfeel(ic, t):
    return (f'<button type="button" style="display: flex; align-items: center; gap: 10px; min-height: 44px; padding: 0 12px; border-radius: 22px; border: none; background: #1F2A1F; color: {WHITE}; font-size: 15.5px; font-weight: 600; text-align: left">'
            f'<span style="flex: none; width: 28px; height: 28px; border-radius: 14px; background: {CREAM}; color: {INK}; display: flex; align-items: center; justify-content: center">{icon(ic, 17)}</span>{t}</button>')
w_before = watch(wlabel("In 20 minutes") + wtitle() + f'<div style="margin-top: 8px; display: flex; flex-direction: column; gap: 2px">{wrow("clock", "7:00 am, 10 min")}{wrow("pin", "The balcony")}{wrow("bag", "Mat, grey shawl")}</div>'
                 + f'<div style="margin-top: auto; font-size: 13px; line-height: 1.35; color: {WSEC}">Same place, same time, same things.</div>')
w_time = watch(wyogi(74, 4, 10, mat=False) + wlabel("It's time", dot=True) + wtitle() + f'<div style="margin-top: 10px; font-family: {FH}; font-weight: 600; font-size: 18px; line-height: 1.2; max-width: 150px">Your mat is waiting.</div>' + wbtn())
w_boring = watch(wyogi(74, 4, 10, mat=False) + wlabel("It's time", dot=True) + wtitle() + f'<div style="margin-top: 10px; font-family: {FH}; font-weight: 600; font-size: 18px; line-height: 1.2; max-width: 150px">Don\'t decide. Just start.</div>' + wbtn())
w_ask = watch(f'<div style="font-family: {FH}; font-weight: 700; font-size: 21px; line-height: 1.1; text-align: center">How did it feel?</div>'
              f'<div style="margin-top: 9px; display: flex; flex-direction: column; gap: 6px">{wfeel("scattered", "Scattered")}{wfeel("steady", "Steady")}{wfeel("absorbed", "Absorbed")}</div>')
w_kept = watch(f'<svg aria-hidden="true" viewBox="-150 -150 300 300" width="116" height="116" style="position: absolute; left: 33px; top: -14px; display: block; will-change: transform; animation: yf-spin 30s linear infinite">{lotus_body(opened=48, sep="#000000", center=None)}</svg>'
               f'<span style="position: absolute; left: 51px; top: 4px; width: 80px; height: 80px; box-sizing: border-box; border: 4px solid {CREAM}; border-radius: 50%; opacity: 0; animation: yf-halo 4.5s ease-out infinite"></span>'
               f'<svg role="img" aria-label="A smiling yogi floats in front of an open lotus" viewBox="0 0 200 200" width="96" height="96" style="position: relative; display: block; align-self: center; margin-top: -4px; animation: yf-levitate 4.5s ease-in-out infinite">{yogi_body(mat=False, joyful=True)}</svg>'
               f'<div style="position: relative; margin-top: 12px; font-family: {FH}; font-weight: 700; font-size: 21px; line-height: 1.1; text-align: center; color: {CREAM}">That\'s today, kept.</div>'
               f'<div style="margin-top: 5px; font-size: 14px; font-weight: 500; text-align: center">Only tomorrow is next.</div><div style="font-size: 13px; text-align: center; color: {WSEC}">7:00 am, the balcony</div>', lotus=False)
w_slip = watch(wlabel("Still today") + wtitle() + f'<div style="margin-top: 10px; font-family: {FH}; font-weight: 600; font-size: 18px; line-height: 1.2">Just start when you can.</div>' + wbtn())
w_app = watch(wyogi(74, 4, 10, mat=False) + wlabel("A new day", col=TEAL) + wtitle() + f'<div style="margin-top: 8px; display: flex; flex-direction: column; gap: 2px">{wrow("clock", "7:00 am")}{wrow("pin", "The balcony")}</div>' + wbtn("I've practised"))
w_stack = watch(f'<div style="font-size: 13px; font-weight: 600; color: {WSEC}">Smart Stack</div>'
                f'<div style="margin-top: 6px; padding: 10px 12px; border-radius: 20px; background: #1F2A1F; display: flex; align-items: center; gap: 10px">{lotus_svg(40, "Lotus", opened=48).replace("grid-area: 1 / 1", "flex: none")}<div style="display: flex; flex-direction: column"><span style="font-size: 12px; font-weight: 600; color: {CREAM}">In 20 minutes</span><span style="font-family: {FH}; font-weight: 700; font-size: 19px; line-height: 1.1">Meditate</span><span style="font-size: 12.5px; color: {WSEC}">The balcony</span></div></div>'
                f'<div style="margin-top: 12px; font-size: 13px; font-weight: 600; color: {WSEC}">Complications</div>'
                f'<div style="margin-top: 6px; display: flex; align-items: center; gap: 12px"><span style="width: 50px; height: 50px; border-radius: 25px; background: #1F2A1F; display: flex; align-items: center; justify-content: center">{lotus_svg(38, "Lotus", opened=48).replace("grid-area: 1 / 1", "flex: none")}</span>'
                f'<span style="display: flex; flex-direction: column; padding: 6px 12px; border-radius: 16px; background: #1F2A1F"><span style="font-size: 11.5px; font-weight: 600; color: {CREAM}">7:00 am</span><span style="font-size: 14px; font-weight: 600">Meditate</span></span></div>', lotus=False)
def wcell(caption, haptic, screen):
    return (f'<div style="display: flex; flex-direction: column; gap: 8px"><div style="height: 52px; display: flex; flex-direction: column; justify-content: flex-end; line-height: 1.3; color: {INK}"><span style="font-size: 14px; font-weight: 600">{caption}</span><span style="font-size: 12.5px; font-weight: 500">{haptic}</span></div>{screen}</div>')
watch_cells = "\n".join([
  wcell("20 minutes before", "Haptic: one gentle tap", w_before),
  wcell("At the hour", "Haptic: a firmer double tap", w_time),
  wcell("Boring middle, at the hour", "Haptic: a firmer double tap", w_boring),
  wcell("If the hour slips by", "Haptic: one gentle tap, once", w_slip),
  wcell("Ten minutes later: asking how it felt", "Haptic: one gentle tap", w_ask),
  wcell("After an answer", "Haptic: the success pattern", w_kept),
  wcell("Opening the watch app", "No haptic", w_app),
  wcell("On the watch face (always still)", "No haptic", w_stack),
])
pages["Watch.dc.html"] = page("Apple Watch",
  f'<div style="width: 1030px; height: 736px; box-sizing: border-box; padding: 40px 48px; background: {NIGHT}; font-family: {FB}; display: grid; grid-template-columns: repeat(4, 208px); justify-content: space-between; row-gap: 30px; align-content: start">\n{watch_cells}\n</div>',
  w=1030, h=736, css="@keyframes yf-halo{0%{transform:scale(0.6);opacity:0}12%{opacity:0.9}62%,100%{transform:scale(1.9);opacity:0}}\n")

# ---------- App icon (iPhone light, dark, tinted; Apple Watch)
import icon as ICON
def icon_cell(caption, svg_markup, radius):
    art = svg_markup.replace('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">', '<svg role="img" aria-label="Yogi Focus app icon: a yogi seated on a green lotus" viewBox="0 0 1024 1024" width="180" height="180" style="display: block">')
    art = re.sub(r'<(\w+)([^<>]*?)/>', r'<\1\2></\1>', art)
    return (f'<div style="display: flex; flex-direction: column; align-items: center; gap: 12px"><div style="width: 180px; height: 180px; border-radius: {radius}; overflow: hidden">{art}</div>'
            f'<div style="font-size: 14px; font-weight: 600; color: {INK}">{caption}</div></div>')
_fix = lambda m: m.replace('<rect width="1024" height="1024" fill', '<rect x="0" y="0" width="1024" height="1024" fill')
pages["App-Icon.dc.html"] = page("App icon",
  f'<div style="width: 960px; height: 330px; box-sizing: border-box; padding: 44px 48px; background: {WHITE}; font-family: {FB}; display: flex; justify-content: space-between; align-items: flex-start">\n'
  + icon_cell("iPhone", _fix(ICON.icon_svg(**ICON.LIGHT)), "22.4%") + "\n" + icon_cell("iPhone, dark", _fix(ICON.icon_svg(**ICON.DARK)), "22.4%") + "\n"
  + icon_cell("iPhone, tinted", _fix(ICON.grey(ICON.icon_svg(**ICON.DARK))), "22.4%") + "\n" + icon_cell("Apple Watch", _fix(ICON.icon_svg(scale=0.86, **ICON.LIGHT)), "50%") + "\n</div>",
  w=960, h=330)

# ---------- canvas index
PH, GAP, PITCH = 844, 80, 1264
rows = [
 ("1 · Understand the idea", ["Main", "Idea-Today", "Idea-Same", "Idea-Mandala", "How-Yogi-Helps"]),
 ("2 · Set up and manage routines", ["Choose-Routine", "Anchor", "Widget-Setup", "Routines", "Routine-Edit"]),
 ("3 · The Home Screen widget", ["Widget-States", "Widget-Done", "Widget-Medium", "Widget-Large"]),
 ("4 · Each day, days 1 to 6", ["Today", "Reflect", "Kept"]),
 ("5 · The boring middle, days 7 to 27", ["Just-Start", "Still-Today", "New-Day"]),
 ("6 · From day 30", ["Day-30", "Mandala", "Mandala-Complete"]),
 ("7 · Apple Watch and app icon", ["Watch", "App-Icon"]),
 ("8 · Dark appearance", ["Main-Dark", "Idea-Today-Dark", "How-Yogi-Helps-Dark", "Choose-Routine-Dark", "Anchor-Dark", "Today-Dark"]),
 ("9 · Dark appearance, continued", ["Reflect-Dark", "Kept-Dark", "Mandala-Dark", "Mandala-Complete-Dark", "Widget-States-Dark"]),
]
DARK_SET = [n[:-5] for _, names in rows for n in names if n.endswith("-Dark")]
titles = {"Main": "Welcome", "Idea-Today": "Idea 1 · Only today", "Idea-Same": "Idea 2 · Same time, place, things", "Idea-Mandala": "Idea 3 · One mandala",
          "How-Yogi-Helps": "How Yogi Focus helps you build a routine", "Choose-Routine": "Choose one routine", "Anchor": "Time, place, things", "Widget-Setup": "Add the widget", "Routines": "Your routines · list", "Routine-Edit": "Routine settings",
          "Widget-States": "Widget through the 48 days", "Widget-Done": "Widget · tapping Done", "Watch": "Apple Watch screens", "App-Icon": "App icon", "Widget-Medium": "Widget · medium size", "Widget-Large": "Widget · large size", "Today": "Today · first week", "Reflect": "How did it feel?", "Kept": "Today is kept", "Just-Start": "Today · just start", "Still-Today": "Today · the hour has passed", "Day-30": "Day 30 · the lotus appears",
          "New-Day": "Today, after a missed day", "Mandala": "Mandala progress", "Mandala-Complete": "Mandala complete · invite a second routine"}
interactive = {"Choose-Routine", "Anchor", "Reflect", "Routine-Edit"}
boards, order, notes = {}, [], {}
for ri, (rt, names) in enumerate(rows):
    x, y = 0, ri * PITCH
    for nm in names:
        n = nm[:-5] if nm.endswith("-Dark") else nm
        w, h = {"Widget-States": (880, 890), "Widget-Done": (860, 700), "Widget-Large": (860, 940), "Widget-Medium": (860, 516), "Watch": (1030, 736), "App-Icon": (960, 330)}.get(n, (390, PH))
        b = {"x": x, "y": y, "w": w, "h": h, "title": titles[n] + (" · dark" if nm != n else ""), "radius": 28 if (n.startswith("Widget-") and n != "Widget-Setup") or n in ("Watch", "App-Icon") else 44}
        if n in interactive: b["is_interactive"] = True
        boards[nm + ".dc.html"] = b; order.append(nm + ".dc.html"); x += w + GAP
    notes[f"row{ri+1}"] = {"x": 0, "y": y - 300, "text": rt, "kind": "title1", "maxW": x - GAP}
index = {"v": 3, "createdOnFiles": {"v": 1, "at": "2026-11-15T19:55:00Z"}, "title": "Yogi — one day at a time", "launch": {"view": "canvas"},
         "pages": [], "boards": boards, "order": order, "notes": notes, "designSystems": []}

# ---------- write, with a tag-balance guard
VOID = {"meta", "link", "br", "input", "img", "hr"}
class Bal(HTMLParser):
    def __init__(s): super().__init__(); s.st = []
    def handle_starttag(s, t, a):
        if t not in VOID: s.st.append(t)
    def handle_endtag(s, t):
        assert s.st and s.st[-1] == t, f"unbalanced </{t}> stack={s.st[-4:]}"
        s.st.pop()
os.makedirs(OUT, exist_ok=True)
def check(name, src):
    b = Bal(); b.feed(src); assert not b.st, (name, b.st)
    assert "[[" not in src and "—" not in src, name
if DARK:
    # the dark run writes only the dark artboards, beside the light ones
    for n in DARK_SET:
        src = pages[n + ".dc.html"]
        for m in DARK_SET: src = src.replace(f'href="{m}.dc.html"', f'href="{m}-Dark.dc.html"')
        check(n, src); open(os.path.join(OUT, n + "-Dark.dc.html"), "w", encoding="utf-8").write(src)
    print(len(DARK_SET), "dark artboards")
else:
    assert set(pages) == {b for b in boards if not b.endswith("-Dark.dc.html")}, set(pages) ^ set(boards)
    for name, src in pages.items():
        check(name, src); open(os.path.join(OUT, name), "w", encoding="utf-8").write(src)
    json.dump(index, open(os.path.join(OUT, "canvas.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print(len(pages), "artboards;", sum(len(s) for s in pages.values()) // 1024, "KB")
