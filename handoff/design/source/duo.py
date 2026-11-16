# iPhone Duo screens. Executed inside gen.py (shares its names).
#
# Sources (checked 16 Nov 2026):
#  - HIG "Designing for iPhone Duo" and "Preparing your app for iPhone Duo" (developer.apple.com)
#  - App Store Connect screenshot specifications: outer 1398 x 2034 px, inner 2007 x 2853 px
#    -> at 3x: outer 466 x 678 pt, inner 669 x 951 pt (tall) / 951 x 669 pt (wide). Apple does not
#       publish point sizes; these are derived.
#  - Outer display: bars move to a strip on the trailing (right) edge: Dynamic Island, status bar,
#    toolbar (Back, then Done) and tab bar, top to bottom. Outer camera sits in the corner, in line with it.
#  - Inner display wide: controls stay on the side. Inner display tall: standard horizontal bars.
#  - Partially folded like a book (wide): fold divides leading and trailing regions.
#    Tabletop (tall, partially folded): top region for viewing, bottom region for controls.
#  - Keep interactive elements out of the fold; scrolling content need not avoid it.
# Assumed, not published: side strip width (60 pt) and fold avoidance width (40 pt).

DUO_STRIP = 60
DUO_FOLD = 40
DUO_SIZES = {}
DUO_GUIDES = {}

def _strip(h, items=(), tint="rgba(20,48,31,0.045)"):
    """The trailing strip: camera (reserved), status bar (system, left blank), then the app's toolbar items."""
    btns = "".join(items)
    return (f'<div style="position: absolute; right: 0; top: 0; width: {DUO_STRIP}px; height: {h}px; background: {tint}; display: flex; flex-direction: column; align-items: center">'
            f'<span aria-hidden="true" style="margin-top: 18px; width: 30px; height: 30px; border-radius: 15px; background: #000000"></span>'
            f'<span aria-hidden="true" style="height: 92px"></span>'
            f'<div style="display: flex; flex-direction: column; align-items: center; gap: 8px">{btns}</div></div>')
def sbtn(ic, label, href=None, color=None):
    color = color or INK
    inner = icon(ic, 22, color)
    if href:
        return f'<a href="{href}" aria-label="{label}" style="width: 44px; height: 44px; border-radius: 22px; display: flex; align-items: center; justify-content: center; color: {color}">{inner}</a>'
    return f'<button type="button" aria-label="{label}" style="width: 44px; height: 44px; border-radius: 22px; border: none; background: transparent; display: flex; align-items: center; justify-content: center; color: {color}">{inner}</button>'
def duo(w, h, body, bg=GROUND, color=INK, strip=True, items=(), tint="rgba(20,48,31,0.045)", under=""):
    s = _strip(h, items, tint) if strip else ""
    return (f'<div style="position: relative; width: {w}px; height: {h}px; background: {bg}; color: {color}; font-family: {FB}; font-size: 16px; line-height: 1.5; overflow: hidden">'
            f'{under}{body}{s}</div>')
def region(x, y, w, h, inner, extra=""):
    return f'<div style="position: absolute; left: {x}px; top: {y}px; width: {w}px; height: {h}px; box-sizing: border-box; display: flex; flex-direction: column{extra}">{inner}</div>'
def scaled(inner, w, h, k):
    return (f'<div style="position: relative; width: {round(w*k)}px; height: {round(h*k)}px; flex: none; align-self: center">'
            f'<div style="position: absolute; left: 0; top: 0; width: {w}px; height: {h}px; transform: scale({k}); transform-origin: 0 0">{inner}</div></div>')
def fit(svg, width):
    return re.sub(r' width="\d+" height="\d+" style="display: block; margin-top: \d+px; flex: none', f' width="{width}" height="{round(width * int(re.search(r"viewBox=\"0 0 (\d+) (\d+)\"", svg).group(2)) / int(re.search(r"viewBox=\"0 0 (\d+) (\d+)\"", svg).group(1)))}" style="display: block; flex: none', svg, count=1)
def card_routine(name, chip_t, rows3, extra_style=""):
    r = lambda ic, t: f'<div style="display: flex; align-items: center; gap: 12px; min-height: 28px">{icon(ic, 20, DEEP)}<span>{t}</span></div>'
    return (f'<div style="padding: 20px; border-radius: 24px; border: 1px solid {LINE}; background: {PAPER}; display: flex; flex-direction: column{extra_style}">'
            f'<span style="align-self: flex-start; padding: 4px 12px; border-radius: 14px; background: {CREAM}; color: {ONACC}; font-size: 13px; font-weight: 600">{chip_t}</span>'
            f'<div style="margin-top: 8px; font-family: {FH}; font-weight: 700; font-size: 30px; line-height: 1.1">{name}</div>'
            f'<div style="margin-top: 8px; display: flex; flex-direction: column; gap: 2px; font-size: 16px">{"".join(r(i, t) for i, t in rows3)}</div></div>')
def choice(ic, title, sub, on=False, h=64):
    bd, bg = (DEEP, SOFT) if on else (LINE, PAPER)
    return (f'<button type="button" aria-pressed="{"true" if on else "false"}" style="display: flex; align-items: center; gap: 12px; min-height: {h}px; padding: 0 14px; border-radius: 18px; border: 2px solid {bd}; background: {bg}; color: {INK}; text-align: left">'
            f'<span style="flex: none; width: 40px; height: 40px; border-radius: 20px; background: {CREAM}; color: {ONACC}; display: flex; align-items: center; justify-content: center">{icon(ic, 22)}</span>'
            f'<span style="display: flex; flex-direction: column; line-height: 1.3"><span style="font-size: 16px; font-weight: 600">{title}</span><span style="font-size: 13.5px; color: {MUTED}">{sub}</span></span></button>')
def reply(t, size=19):
    return f'<div style="padding: 16px 20px; border-radius: 20px; background: {CREAM}; color: {ONACC}; font-family: {FH}; font-weight: 600; font-size: {size}px; line-height: 1.3">{t}</div>'
def note_field(fid):
    return (f'<div style="display: flex; flex-direction: column; gap: 6px"><label for="{fid}" style="{lab}">A note for yourself (optional)</label>'
            f'<input id="{fid}" type="text" placeholder="Anything you noticed" style="box-sizing: border-box; width: 100%; min-height: 48px; padding: 0 14px; border-radius: 14px; border: 1px solid {MUTED}; background: {PAPER}; font-size: 16px; color: {INK}"></div>')
def btn(label, href, bg=TEAL, color=ONACC):
    return (f'<a href="{href}" style="flex: none; display: flex; align-items: center; justify-content: center; min-height: 56px; border-radius: 28px; background: {bg}; color: {color}; font-size: 17px; font-weight: 600; text-decoration: none">{label}</a>')
def key_row():
    k = lambda c, t, extra="": f'<span style="display: flex; align-items: center; gap: 6px"><span style="width: 10px; height: 10px; border-radius: 5px; background: {c}{extra}"></span>{t}</span>'
    return f'<div style="display: flex; flex-wrap: wrap; gap: 14px; font-size: 13px; font-weight: 500">{k(TEALM, "Practised")}{k(MISSED, "Missed")}{k(PETAL_CLOSED, "To come", f"; box-shadow: inset 0 0 0 1px {MUTED}")}</div>'
FEEL_ROWS = lambda: f'{felt("absorbed", "Absorbed", 11, 32)}{felt("steady", "Steady", 17, 50)}{felt("scattered", "Scattered", 6, 18)}'
def day_cards():
    kept_in = (f'<span style="font-size: 13px; font-weight: 600">Today</span><span style="margin-top: 2px; font-family: {FH}; font-weight: 700; font-size: 28px; line-height: 1.1">Kept</span>'
               f'<span style="margin-top: auto; width: 28px; height: 28px; border-radius: 14px; background: {ONACC}; color: {CREAM}; display: flex; align-items: center; justify-content: center">{icon("check", 17, "currentColor", 2.6)}</span>')
    next_in = (f'<span style="font-size: 13px; font-weight: 600; color: {DEEP}">Only tomorrow</span><span style="margin-top: 2px; font-family: {FH}; font-weight: 700; font-size: 28px; line-height: 1.1">7:00 am</span>'
               f'<span style="margin-top: auto; font-size: 14px; font-weight: 500">The balcony</span>')
    return (f'<div style="display: flex; align-items: center; gap: 8px">{day_card(TEAL, "yf-pop 0.5s cubic-bezier(0.3, 1.4, 0.5, 1) 0.3s both", kept_in)}'
            f'<span style="flex: none; color: {INK}; display: flex">{icon("chev_right", 20, "currentColor", 2.4)}</span>{day_card(PAPER, "yf-up 0.5s ease-out 0.9s both", next_in)}</div>')
VERSE = (f'<div style="display: flex; flex-direction: column; gap: 3px"><div lang="sa" style="font-family: {FH}; font-weight: 600; font-size: 18px; line-height: 1.4; overflow-wrap: anywhere">स तु दीर्घकालनैरन्तर्यसत्कारासेवितो दृढभूमिः</div>'
         f'<div lang="sa-Latn" style="font-size: 14px; line-height: 1.45; font-style: italic; font-weight: 500">sa tu dīrgha-kāla-nairantarya-satkārāsevito dṛḍha-bhūmiḥ</div>'
         f'<div style="font-size: 14px; line-height: 1.5">Practice finds firm ground when it is tended for a long time, steadily and with care.</div><div style="font-size: 12.5px; font-weight: 600">Yoga Sūtra 1.14</div></div>')
CSS_DUO = CSS_WELCOME + CSS_KEPT

# ================= OUTER DISPLAY (closed): 466 x 678, strip on the trailing edge =================
OW, OH = 466, 678
OCW = OW - DUO_STRIP              # content width 406
OPAD = "padding: 18px 22px 22px 24px"
def outer(name, title, body, items=(), bg=GROUND, color=INK, tint="rgba(20,48,31,0.045)", under="", css=""):
    pages[name] = page(title, duo(OW, OH, region(0, 0, OCW, OH, body, f"; {OPAD}"), bg=bg, color=color, items=items, tint=tint, under=under), w=OW, h=OH, css=CSS_DUO + css)
    DUO_SIZES[name[:-8]] = (OW, OH)
back = lambda href: sbtn("chev_left", "Back", href)
routines_btn = sbtn("plan", "Your routines", "Duo-Wide-Routines.dc.html")

outer("Duo-Outer-Welcome.dc.html", "Welcome, outer display", f"""{scaled(welcome_scene(), 390, 470, 0.68)}
<div style="margin-top: 6px; font-family: {FH}; font-weight: 600; font-size: 16px; line-height: 1.2">Namaste, and welcome.</div>
<div style="font-family: {FH}; font-weight: 700; font-size: 36px; line-height: 1.05; color: {DEEP}">Yogi Focus</div>
<h1 style="margin: 4px 0 0; font-family: {FH}; font-weight: 600; font-size: 22px; line-height: 1.15">One small routine. One day at a time.</h1>
{p("Come as you are. We'll go gently.", mt=6, size=15)}
<div style="margin-top: auto">{btn("Begin", "Duo-Outer-Today-Idea.dc.html", **HBTN)}</div>""", bg=HERO_Y, tint="rgba(0,0,0,0.05)")

outer("Duo-Outer-Today-Idea.dc.html", "Only today, outer display", f"""{fit(sun, 358)}
{h1("Only today.", size=32, mt=14)}
{p("Each morning a yogi asks a single question.", mt=4, size=16)}
<div style="margin-top: 12px">{reply("This is a new day. How will I keep my practice today?", 19)}</div>
<div style="margin-top: auto">{btn("Next", "Duo-Outer-Today.dc.html")}</div>""", items=(back("Duo-Outer-Welcome.dc.html"),), css=CSS_TODAY)

outer("Duo-Outer-Today.dc.html", "Today, outer display", f"""<div style="font-size: 14px; font-weight: 500; color: {MUTED}">Sunday 15 November</div>
{h1("A new day.", size=36, mt=0)}
{p("How will you keep your practice today?", mt=4, size=16)}
<div style="margin-top: 14px">{card_routine("Meditate", "In 20 minutes", [("clock", "7:00 am, for 10 minutes"), ("pin", "The balcony"), ("bag", "Yoga mat, grey shawl")])}</div>
{p("This first week, stop at ten minutes, even if you would like more.", size=14, color=MUTED, mt=10)}
<div style="margin-top: auto">{btn("I've practised today", "Duo-Outer-Reflect.dc.html")}</div>""", items=(routines_btn,))

outer("Duo-Outer-Reflect.dc.html", "How did it feel, outer display", f"""{h1("You practised today.", size=30, mt=0)}
{p("How did it feel? There is no wrong answer.", mt=2, size=15.5)}
<div style="margin-top: 12px; display: flex; flex-direction: column; gap: 8px">{choice("scattered", "Scattered", "My mind was everywhere", h=58)}{choice("steady", "Steady", "I stayed with it, mostly", True, h=58)}{choice("absorbed", "Absorbed", "I lost track of time", h=58)}</div>
<div style="margin-top: 10px">{reply("Steady is exactly how a practice grows.", 17)}</div>
<div style="margin-top: 10px">{note_field("onote")}</div>""", items=(back("Duo-Outer-Today.dc.html"), sbtn("check", "Done", "Duo-Outer-Kept.dc.html", DEEP)))

outer("Duo-Outer-Kept.dc.html", "Today is kept, outer display", f"""{scaled(kept_hero, 300, 262, 0.72)}
{h1("That's today, kept.", size=30, mt=8)}
{p("Forever was never the job. Today was, and you did it.", mt=4, size=15.5)}
<div style="margin-top: 12px">{day_cards()}</div>
<div style="margin-top: auto">{btn("Done", "Duo-Outer-Today.dc.html", **HBTN)}</div>""", bg=HERO_Y, tint="rgba(0,0,0,0.05)",
      under=rays(203, 140, r=560, fill="#182B17" if DARK else "#FFDF52"))

outer("Duo-Outer-Mandala.dc.html", "Mandala progress, outer display", f"""<div style="font-size: 14px; font-weight: 600; color: {MUTED}">Meditate</div>
{h1("Your mandala", size=30, mt=0)}
<div style="margin-top: 12px; display: flex; gap: 18px; align-items: center">
{lotus(176, num="34", label="Lotus on day 37 of 48: 34 petals open, 3 red petals for missed days", **SAMPLE)}
<div style="display: flex; flex-direction: column; gap: 6px"><div style="font-family: {FH}; font-weight: 700; font-size: 22px; line-height: 1.15">34 of 48 days practised</div><div style="font-size: 14px; color: {MUTED}">Day 37. 3 days missed. Nothing resets.</div>{key_row()}</div>
</div>
<div style="margin-top: 16px; font-size: 14px; font-weight: 600">How it has felt</div>
<div style="display: flex; flex-direction: column">{FEEL_ROWS()}</div>
<div style="margin-top: auto; font-size: 14.5px; font-weight: 500; color: {MUTED}">Every day, 7:00 am, the balcony</div>""",
      items=(back("Duo-Outer-Today.dc.html"), sbtn("settings", "Edit routine", "Routine-Edit.dc.html")))

# ================= INNER DISPLAY, WIDE: 951 x 669, fold runs top to bottom at the centre =================
WW, WH = 951, 669
FX0, FX1 = WW / 2 - DUO_FOLD / 2, WW / 2 + DUO_FOLD / 2          # fold avoidance band
LW = round(FX0)                                                  # leading region 0..455
RX = round(FX1); RW = WW - DUO_STRIP - RX                         # trailing region 496..891
def wide(name, title, left, right, items=(), bg=GROUND, color=INK, tint="rgba(20,48,31,0.045)", under="", lpad="28px 32px 28px 32px", rpad="28px 28px 28px 32px", css=""):
    body = region(0, 0, LW, WH, left, f"; padding: {lpad}") + region(RX, 0, RW, WH, right, f"; padding: {rpad}")
    pages[name] = page(title, duo(WW, WH, body, bg=bg, color=color, items=items, tint=tint, under=under), w=WW, h=WH, css=CSS_DUO + css)
    DUO_SIZES[name[:-8]] = (WW, WH)
    DUO_GUIDES[name[:-8]] = [{"kind": "columns", "count": 2, "gutter": DUO_FOLD, "margin": 0, "color": "rgba(255,90,60,0.14)"}]

wide("Duo-Wide-Welcome.dc.html", "Welcome, inner display wide",
     f'<div style="flex: 1; display: flex; align-items: center; justify-content: center">{scaled(welcome_scene(), 390, 470, 1.0)}</div>',
     f"""<div style="margin-top: auto; font-family: {FH}; font-weight: 600; font-size: 19px; line-height: 1.2">Namaste, and welcome.</div>
<div style="margin-top: 2px; font-family: {FH}; font-weight: 700; font-size: 50px; line-height: 1; color: {DEEP}">Yogi Focus</div>
<h1 style="margin: 8px 0 0; font-family: {FH}; font-weight: 600; font-size: 30px; line-height: 1.15">One small routine.<br>One day at a time.</h1>
{p("Come as you are. Scattered days and missed days are welcome here too. We'll go gently.", mt=10, size=16)}
<div style="margin-top: 28px; margin-bottom: auto">{btn("Begin", "Duo-Wide-Today.dc.html", **HBTN)}</div>""", bg=HERO_Y, tint="rgba(0,0,0,0.05)", lpad="20px 24px 0 32px")

wide("Duo-Wide-Today.dc.html", "Today with two routines, inner display wide",
     f"""<div style="font-size: 14px; font-weight: 500; color: {MUTED}">Sunday 15 November</div>
{h1("A new day.", size=42, mt=0)}
{p("Two routines today. One is kept.", mt=4, size=16)}
<div style="margin-top: 18px; display: flex; flex-direction: column; gap: 10px">
<a href="#" style="display: flex; align-items: center; gap: 14px; padding: 14px 16px; border-radius: 20px; border: 1px solid {LINE}; background: {PAPER}; color: {INK}; text-decoration: none"><span style="flex: none; width: 36px; height: 36px; border-radius: 18px; background: {SOFT}; color: {DEEP}; display: flex; align-items: center; justify-content: center">{icon("check", 20, DEEP, 2.4)}</span><span style="display: flex; flex-direction: column; flex: 1"><span style="font-size: 17px; font-weight: 600">Meditate</span><span style="font-size: 14px; color: {MUTED}">7:00 am · Kept today</span></span></a>
<a href="#" aria-current="true" style="display: flex; align-items: center; gap: 14px; padding: 14px 16px; border-radius: 20px; border: 2px solid {DEEP}; background: {SOFT}; color: {INK}; text-decoration: none"><span style="flex: none; width: 36px; height: 36px; border-radius: 18px; background: {CREAM}; color: {ONACC}; display: flex; align-items: center; justify-content: center">{icon("read", 20)}</span><span style="display: flex; flex-direction: column; flex: 1"><span style="font-size: 17px; font-weight: 600">Read</span><span style="font-size: 14px; color: {MUTED}">9:30 pm · Next</span></span>{icon("chev_right", 20, MUTED)}</a>
</div>
{p("When one routine is kept, Yogi Focus moves on to the next.", size=14, color=MUTED, mt=14)}""",
     f"""<div style="margin-top: 40px">{card_routine("Read", "Next, 9:30 pm", [("clock", "9:30 pm, for 10 minutes"), ("pin", "The bedside chair"), ("bag", "Book, reading lamp")])}</div>
{p("How will you keep your practice today?", mt=16, size=17)}
<div style="margin-top: auto">{btn("I've practised today", "Duo-Wide-Reflect.dc.html")}</div>""", items=(routines_btn,))

wide("Duo-Wide-Reflect.dc.html", "How did it feel, inner display wide",
     f"""{h1("You practised today.", size=36, mt=24)}
{p("How did it feel? There is no wrong answer.", mt=6)}
<div style="margin-top: 22px; display: flex; flex-direction: column; gap: 10px">{choice("scattered", "Scattered", "My mind was everywhere")}{choice("steady", "Steady", "I stayed with it, mostly", True)}{choice("absorbed", "Absorbed", "I lost track of time")}</div>""",
     f"""<div style="margin-top: 92px">{reply("Steady is exactly how a practice grows.", 22)}</div>
<div style="margin-top: 22px">{note_field("wnote")}</div>""", items=(back("Duo-Wide-Today.dc.html"), sbtn("check", "Done", "Duo-Wide-Kept.dc.html", DEEP)))

wide("Duo-Wide-Kept.dc.html", "Today is kept, inner display wide",
     f'<div style="flex: 1; display: flex; align-items: center; justify-content: center">{kept_hero}</div>',
     f"""<div style="margin-top: auto">{h1("That's today, kept.", size=40, mt=0)}</div>
{p("Forever was never the job. Today was, and you did it.", mt=8)}
<div style="margin-top: 18px">{day_cards()}</div>
{p("Don't think about the week. One day is all you ever have to keep, and the next one is tomorrow.", size=15, mt=14)}
<div style="margin-top: 20px; margin-bottom: auto">{btn("Done", "Duo-Wide-Today.dc.html", **HBTN)}</div>""", bg=HERO_Y, tint="rgba(0,0,0,0.05)",
     under=rays(round(LW / 2), 330, r=820, fill="#182B17" if DARK else "#FFDF52"))

wide("Duo-Wide-Mandala.dc.html", "Mandala progress, inner display wide",
     f"""<div style="font-size: 14px; font-weight: 600; color: {MUTED}">Meditate</div>
{h1("Your mandala", size=36, mt=0)}
<div style="margin-top: 14px; display: flex; justify-content: center">{lotus(330, num="34", label="Lotus on day 37 of 48: 34 petals open, 3 red petals for missed days", **SAMPLE)}</div>
<div style="margin-top: 14px; display: flex; justify-content: center">{key_row()}</div>""",
     f"""<div style="margin-top: 56px; font-family: {FH}; font-weight: 700; font-size: 30px; line-height: 1.15">34 of 48 days practised</div>
<div style="margin-top: 4px; font-size: 15px; color: {MUTED}">Day 37. 3 days missed. Nothing resets.</div>
<div style="margin-top: 26px; font-size: 14px; font-weight: 600">How it has felt</div>
<div style="display: flex; flex-direction: column">{FEEL_ROWS()}</div>
<div style="margin-top: auto; padding: 0 6px 0 18px; min-height: 60px; border-radius: 20px; border: 1px solid {LINE}; background: {PAPER}; display: flex; align-items: center; justify-content: space-between"><span style="font-size: 15px; font-weight: 500">Every day, 7:00 am, the balcony</span><a href="Routine-Edit.dc.html" style="display: flex; align-items: center; min-width: 52px; min-height: 44px; justify-content: center; font-size: 15px; font-weight: 600; text-decoration: none">Edit</a></div>""",
     items=(back("Duo-Wide-Today.dc.html"),))

tile2 = "\n".join(f'<button type="button" aria-pressed="{"true" if i == 0 else "false"}" style="display: flex; align-items: center; gap: 10px; min-height: 52px; padding: 0 12px; border-radius: 16px; border: 2px solid {DEEP if i == 0 else LINE}; background: {SOFT if i == 0 else PAPER}; color: {INK}; font-size: 15px; font-weight: 500; line-height: 1.2; text-align: left">{icon(ic, 21, DEEP)}<span>{lb}</span></button>' for i, (ic, lb) in enumerate(acts))
wide("Duo-Wide-Choose.dc.html", "Choose one routine, inner display wide",
     f"""<div style="margin-top: auto">{h1("What would you like to practise?", size=38, mt=0)}</div>
{p("Choose one, and only one. Ten minutes a day to begin.", mt=10)}
{p("When your first mandala is complete, Yogi Focus will invite you to add another.", size=14.5, color=MUTED, mt=14)}
<div style="margin-top: 28px; margin-bottom: auto">{btn("Continue", "Anchor.dc.html")}</div>""",
     f'<div style="margin-block: auto; display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 8px">{tile2}</div>',
     items=(back("Duo-Wide-Welcome.dc.html"),))

wide("Duo-Wide-Complete.dc.html", "Mandala complete, inner display wide",
     f'<div style="flex: 1; display: flex; align-items: center; justify-content: center">{hero_svg(318, HERO_G, (WHITE, CREAMS, CREAM), joyful=True)}</div>',
     f"""<div style="margin-top: 26px">{VERSE}</div>
{h1("One mandala.", size=46, mt=18)}
{p("Out of 48 days, you practised 45 and missed 3. Yogis say a practice held this long is yours for life.", mt=6)}
<div style="margin-top: auto; display: flex; flex-direction: column; gap: 8px">{btn("Begin a new mandala", "Duo-Wide-Today.dc.html", **HBTN)}{ghost("Add another routine", "Duo-Wide-Choose.dc.html", color=INK, border=INK, mt="0")}</div>""",
     bg=HERO_G, tint="rgba(0,0,0,0.06)", under=rays(round(LW / 2), 330, r=820, fill="#173019" if DARK else "#7EDC49") + confetti(n=30).replace("width: 390px; height: 844px", f"width: {WW}px; height: {WH}px"))

# ================= INNER DISPLAY, TALL: 669 x 951, horizontal bars; tabletop pose folds across the middle =================
TW_, TH_ = 669, 951
FY0, FY1 = TH_ / 2 - DUO_FOLD / 2, TH_ / 2 + DUO_FOLD / 2
TOP_H = round(FY0); BOT_Y = round(FY1); BOT_H = TH_ - BOT_Y
def tbar(back_href, right=""):
    return (f'<div style="position: absolute; left: 0; top: 0; width: {TW_}px; height: 98px; box-sizing: border-box; padding: 50px 24px 0 16px; display: flex; align-items: center; justify-content: space-between">'
            f'<a href="{back_href}" aria-label="Back" style="width: 44px; height: 44px; display: flex; align-items: center; justify-content: center; color: {INK}">{icon("chev_left")}</a>{right}</div>')
def tall(name, title, top, bottom, back_href, right="", bg=GROUND, css=""):
    body = tbar(back_href, right) + region(0, 98, TW_, TOP_H - 98, top, "; padding: 4px 40px 20px") + region(0, BOT_Y, TW_, BOT_H, bottom, "; padding: 24px 40px 40px")
    pages[name] = page(title, duo(TW_, TH_, body, bg=bg, strip=False), w=TW_, h=TH_, css=CSS_DUO + css)
    DUO_SIZES[name[:-8]] = (TW_, TH_)
    DUO_GUIDES[name[:-8]] = [{"kind": "rows", "count": 2, "gutter": DUO_FOLD, "margin": 0, "color": "rgba(255,90,60,0.14)"}]

tall("Duo-Tall-Today.dc.html", "Today, tabletop pose",
     f"""<div style="font-size: 14px; font-weight: 500; color: {MUTED}">Sunday 15 November</div>
{h1("Just start.", size=40, mt=0)}
{p("You don't need to feel like it. Go to the balcony, sit on the mat and begin.", mt=4)}
<div style="margin-top: 16px">{card_routine("Meditate", "It's time", [("clock", "7:00 am, for 10 minutes"), ("pin", "The balcony"), ("bag", "Yoga mat, grey shawl")])}</div>""",
     f"""<div style="flex: 1; display: flex; align-items: center; justify-content: center; gap: 28px">
<svg aria-hidden="true" viewBox="0 0 200 200" width="190" height="190" style="display: block; animation: yf-levitate 4.5s ease-in-out infinite">{yogi_body(mat=True)}</svg>
<div style="max-width: 300px; font-family: {FH}; font-weight: 600; font-size: 22px; line-height: 1.3">The middle weeks are often the dullest. They pass.</div></div>
{btn("I've practised today", "Duo-Tall-Reflect.dc.html")}""", "Duo-Wide-Today.dc.html", right=f'<a href="Duo-Wide-Routines.dc.html" aria-label="Your routines" style="width: 44px; height: 44px; display: flex; align-items: center; justify-content: center; color: {INK}">{icon("plan")}</a>')

tall("Duo-Tall-Reflect.dc.html", "How did it feel, tabletop pose",
     f"""{h1("You practised today.", size=40, mt=10)}
{p("How did it feel? There is no wrong answer.", mt=6)}
<div style="margin-top: auto">{reply("Steady is exactly how a practice grows.", 24)}</div>""",
     f"""<div style="display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 10px">
{"".join(f'<button type="button" aria-pressed="{"true" if on else "false"}" style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 8px; min-height: 132px; border-radius: 22px; border: 2px solid {DEEP if on else LINE}; background: {SOFT if on else PAPER}; color: {INK}"><span style="width: 48px; height: 48px; border-radius: 24px; background: {CREAM}; color: {ONACC}; display: flex; align-items: center; justify-content: center">{icon(ic, 24)}</span><span style="font-size: 17px; font-weight: 600">{t}</span></button>' for ic, t, on in (("scattered", "Scattered", False), ("steady", "Steady", True), ("absorbed", "Absorbed", False)))}
</div>
<div style="margin-top: 16px">{note_field("tnote")}</div>
<div style="margin-top: auto">{btn("Done", "Duo-Wide-Kept.dc.html")}</div>""", "Duo-Tall-Today.dc.html")

tall("Duo-Tall-Mandala-Idea.dc.html", "One mandala is 48 days, inner display tall",
     f'<div style="flex: 1; display: flex; align-items: center; justify-content: center">{fit(journey, 520)}</div>',
     f"""{h1("One mandala is 48 days.", size=36, mt=0)}
{p("Yogis hold that a practice kept for one mandala is likely to stay for life. This is how those 48 days tend to go.", mt=8, size=16)}
<div style="margin-top: 14px; display: flex; flex-direction: column; gap: 10px">
{path_row(f'<path d="M2 6L24 6" stroke="{ORNG}" stroke-width="4" stroke-linecap="round" stroke-dasharray="0.1 7.3" fill="none"></path>', "Willpower alone", "A burst of effort, a crash in the boring middle, and then interest quietly dies.")}
{path_row(f'<path d="M2 6L24 6" stroke="{BLUE}" stroke-width="4.5" stroke-linecap="round" fill="none"></path>', "With Yogi Focus", "A gentle ten-minute start, a shallow dip, a nudge to just start, and by the end it runs on its own.")}
</div>
<div style="margin-top: auto">{btn("Next", "How-Yogi-Helps.dc.html")}</div>""", "Idea-Same.dc.html", css=CSS_MANDALA)

# ================= Routines list, inner wide (sidebar + detail) =================
wide("Duo-Wide-Routines.dc.html", "Your routines, inner display wide",
     f"""{h1("Your routines", size=34, mt=24)}
{p("Each one has its own hour, its own place and its own things.", size=15, color=MUTED, mt=6)}
<div style="margin-top: 16px; display: flex; flex-direction: column; gap: 10px">
<a href="#" aria-current="true" style="display: flex; align-items: center; gap: 12px; padding: 14px 16px; border-radius: 20px; border: 2px solid {DEEP}; background: {SOFT}; color: {INK}; text-decoration: none"><span style="display: flex; flex-direction: column; flex: 1"><span style="font-size: 17px; font-weight: 600">Meditate</span><span style="font-size: 14px; color: {MUTED}">7:00 am · The balcony</span></span>{chip_kept}</a>
<a href="#" style="display: flex; align-items: center; gap: 12px; padding: 14px 16px; border-radius: 20px; border: 1px solid {LINE}; background: {PAPER}; color: {INK}; text-decoration: none"><span style="display: flex; flex-direction: column; flex: 1"><span style="font-size: 17px; font-weight: 600">Read</span><span style="font-size: 14px; color: {MUTED}">9:30 pm · The bedside chair</span></span>{chip_next}</a>
<a href="Duo-Wide-Choose.dc.html" style="display: flex; align-items: center; justify-content: center; gap: 8px; min-height: 56px; border-radius: 20px; border: 1.5px dashed {MUTED}; color: {INK}; font-size: 16px; font-weight: 600; text-decoration: none">{icon("plus", 20)}Add a routine</a>
</div>
<div style="margin-top: auto">{p("Add slowly. Give each routine a full mandala before you start the next.", size=14, color=MUTED, mt=0)}</div>""",
     f"""<div style="margin-top: 24px; font-size: 14px; font-weight: 600; color: {MUTED}">Routine</div>
{h1("Meditate", size=34, mt=0)}
<div style="margin-top: 14px">{card_routine("Every day", "First mandala complete", [("clock", "7:00 am, for 10 minutes"), ("pin", "The balcony"), ("bag", "Yoga mat, grey shawl")])}</div>
<div style="margin-top: 12px; padding: 0 6px 0 18px; min-height: 58px; border-radius: 20px; border: 1px solid {LINE}; background: {PAPER}; display: flex; align-items: center; justify-content: space-between"><span style="font-size: 15.5px; font-weight: 500">A soft chime at 7:00 am</span>{sw(True, "dchime")}</div>
<div style="margin-top: auto">{btn("Edit Meditate", "Routine-Edit.dc.html")}</div>""".replace('id="chime2"', ''),
     items=(back("Duo-Wide-Today.dc.html"),))

# ================= Specification board =================
def dev(w, h, k, label, inner_svg):
    return (f'<div style="display: flex; flex-direction: column; gap: 10px"><svg role="img" aria-label="{label}" viewBox="-6 -6 {w+12} {h+12}" width="{round((w+12)*k)}" height="{round((h+12)*k)}" style="display: block">'
            f'<rect x="-4" y="-4" width="{w+8}" height="{h+8}" rx="34" fill="#1A1A1A"></rect><rect x="0" y="0" width="{w}" height="{h}" rx="30" fill="{GROUND}"></rect>{inner_svg}</svg>'
            f'<div style="font-size: 14px; font-weight: 600">{label}</div></div>')
lbl = lambda x, y, t, anchor="middle", col=INK, sz=13: f'<text x="{x}" y="{y}" font-family="{FB}" font-size="{sz}" font-weight="600" fill="{col}" text-anchor="{anchor}">{t}</text>'
strip_svg = lambda w, h: (f'<rect x="{w-DUO_STRIP}" y="0" width="{DUO_STRIP}" height="{h}" fill="#E6F8D2"></rect><circle cx="{w-DUO_STRIP/2}" cy="33" r="15" fill="#000"></circle>'
    f'{lbl(w-DUO_STRIP/2, 80, "status", sz=11, col=MUTED)}{lbl(w-DUO_STRIP/2, 160, "Back", sz=11)}{lbl(w-DUO_STRIP/2, 186, "Done", sz=11)}{lbl(w-DUO_STRIP/2, h-40, "tabs", sz=11, col=MUTED)}')
spec_outer = dev(OW, OH, 0.55, "Outer display, closed · 466 × 678 pt", strip_svg(OW, OH) + lbl((OW-DUO_STRIP)/2, OH/2, "content 406 pt", sz=18) + lbl((OW-DUO_STRIP)/2, OH/2+24, "compact width", sz=14, col=MUTED))
spec_wide = dev(WW, WH, 0.55, "Inner display, open wide · 951 × 669 pt", strip_svg(WW, WH) + f'<rect x="{FX0}" y="0" width="{DUO_FOLD}" height="{WH}" fill="#FFB3A1" opacity="0.6"></rect>'
    + lbl(LW/2, WH/2, "leading region", sz=20) + lbl(RX + RW/2, WH/2, "trailing region", sz=20) + lbl(WW/2, 30, "fold", sz=14, col="#A84A12") + lbl(WW/2 - DUO_STRIP/2, WH/2 + 30, "regular width", sz=15, col=MUTED))
spec_tall = dev(TW_, TH_, 0.55, "Inner display, open tall · 669 × 951 pt", f'<rect x="0" y="0" width="{TW_}" height="98" fill="#E6F8D2"></rect>' + lbl(TW_/2, 80, "status bar and navigation bar, horizontal", sz=15)
    + f'<rect x="0" y="{FY0}" width="{TW_}" height="{DUO_FOLD}" fill="#FFB3A1" opacity="0.6"></rect>' + lbl(TW_/2, FY0 + 26, "fold (tabletop pose)", sz=15, col="#A84A12")
    + lbl(TW_/2, (98 + FY0)/2, "top region: what you look at", sz=20) + lbl(TW_/2, (FY1 + TH_)/2, "bottom region: what you tap", sz=20))
spec_notes = "".join(f'<li style="margin: 0 0 6px">{t}</li>' for t in [
    "Sizes come from App Store Connect screenshot sizes (outer 1398 × 2034 px, inner 2007 × 2853 px) at 3×. Apple does not publish point sizes, so read them at run time.",
    "Closed: toolbars, tab bar, status bar and Dynamic Island sit in a strip on the trailing edge. Back goes at the top of the strip, then Done.",
    "Open wide: controls stay on the side. Open tall: standard horizontal bars.",
    "Partially folded, the fold divides the display. Keep buttons and text out of it; scrolling content may cross it.",
    "Tabletop pose: viewing content in the top region, tappable controls in the bottom region.",
    "Assumed, not published by Apple: a 60 pt side strip and a 40 pt fold band. Check both in the Xcode 27.1 iPhone Duo simulator.",
])
pages["Duo-Spec.dc.html"] = page("iPhone Duo specifications",
    f'<div style="width: 1500px; height: 800px; box-sizing: border-box; padding: 40px 48px; background: {WHITE}; color: {INK}; font-family: {FB}; display: flex; flex-direction: column; gap: 22px">'
    f'<div style="font-family: {FH}; font-weight: 700; font-size: 30px; line-height: 1.1">iPhone Duo: what each layout must respect</div>'
    f'<div style="display: flex; align-items: flex-start; gap: 40px">{spec_outer}{spec_wide}{spec_tall}</div>'
    f'<ul style="margin: 0; padding-left: 20px; font-size: 14px; line-height: 1.5; columns: 2; column-gap: 40px">{spec_notes}</ul></div>', w=1500, h=800)
DUO_SIZES["Duo-Spec"] = (1500, 800)

DUO_ROWS = [
 ("10 · iPhone Duo", ["Duo-Spec"]),
 ("11 · iPhone Duo, closed: outer display", ["Duo-Outer-Welcome", "Duo-Outer-Today-Idea", "Duo-Outer-Today", "Duo-Outer-Reflect", "Duo-Outer-Kept", "Duo-Outer-Mandala"]),
 ("12 · iPhone Duo, open wide: inner display", ["Duo-Wide-Welcome", "Duo-Wide-Choose", "Duo-Wide-Today", "Duo-Wide-Reflect"]),
 ("13 · iPhone Duo, open wide: inner display, continued", ["Duo-Wide-Kept", "Duo-Wide-Mandala", "Duo-Wide-Routines", "Duo-Wide-Complete"]),
 ("14 · iPhone Duo, open tall and tabletop pose", ["Duo-Tall-Mandala-Idea", "Duo-Tall-Today", "Duo-Tall-Reflect"]),
]
DUO_TITLES = {
 "Duo-Spec": "Specifications", "Duo-Outer-Welcome": "Welcome", "Duo-Outer-Today-Idea": "Only today", "Duo-Outer-Today": "Today", "Duo-Outer-Reflect": "How did it feel?",
 "Duo-Outer-Kept": "Today is kept", "Duo-Outer-Mandala": "Mandala progress", "Duo-Wide-Welcome": "Welcome", "Duo-Wide-Choose": "Choose one routine",
 "Duo-Wide-Today": "Today, two routines", "Duo-Wide-Reflect": "How did it feel?", "Duo-Wide-Kept": "Today is kept", "Duo-Wide-Mandala": "Mandala progress",
 "Duo-Wide-Routines": "Your routines", "Duo-Wide-Complete": "Mandala complete", "Duo-Tall-Mandala-Idea": "One mandala, open tall",
 "Duo-Tall-Today": "Today, tabletop pose", "Duo-Tall-Reflect": "How did it feel, tabletop pose"}
