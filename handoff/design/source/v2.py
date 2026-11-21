# Yogi Focus v2.0 artboards, in the agreed priority order (V2_TODO.md, 18 November 2026).
# Everything here runs on the device or through Apple services: no server of our own.
# Usage: python3 v2.py            -> light boards into v2out/project/
#        YF_THEME=dark python3 v2.py -> dark copies of the phone boards (*-Dark)
import os, json
HERE = os.path.dirname(os.path.abspath(__file__))
_src = open(os.path.join(HERE, "gen.py"), encoding="utf-8").read().split("# ---------- write, with a tag-balance guard")[0]
G = {"__file__": os.path.join(HERE, "gen.py"), "__name__": "gen_v2"}
exec(compile(_src, "gen.py", "exec"), G)
globals().update({k: v for k, v in G.items() if not k.startswith("__")})
BASE = pages                      # the 1.0 artboards, for reuse
V = {}                            # v2 artboards: name -> html
SIZES = {}                        # name -> (w, h)
DATE = "Thursday 19 November"

# ---------- small building blocks
def tphone(inner, h, bg=GROUND, color=INK, pad="56px 28px 34px"):
    return (f'<div style="width: 390px; height: {h}px; box-sizing: border-box; padding: {pad}; display: flex; flex-direction: column; '
            f'background: {bg}; color: {color}; font-family: {FB}; font-size: 16px; line-height: 1.55; overflow: hidden">\n{inner}\n</div>')
def sec(t, mt=22): return f'<div style="margin-top: {mt}px; padding-left: 4px; font-size: 13px; font-weight: 600; color: {MUTED}">{t}</div>'
def group(*rows, mt=8):
    out = []
    for i, r in enumerate(rows):
        out.append(r if i == 0 else r.replace('<div data-row style="', f'<div data-row style="border-top: 1px solid {LINE}; ', 1))
    return f'<div style="margin-top: {mt}px; border-radius: 22px; border: 1px solid {LINE}; background: {PAPER}; display: flex; flex-direction: column">{"".join(out)}</div>'
def two_line(t, s, tid=None):
    i = f' id="{tid}"' if tid else ""
    return (f'<span style="display: flex; flex-direction: column; flex: 1; min-width: 0"><span{i} style="font-size: 15.5px; font-weight: 500; line-height: 1.35">{t}</span>'
            + (f'<span style="font-size: 13px; line-height: 1.4; color: {MUTED}">{s}</span>' if s else "") + '</span>')
def row_sw(t, s, on, tid):
    return f'<div data-row style="padding: 8px 0 8px 18px; min-height: 60px; box-sizing: border-box; display: flex; align-items: center; gap: 10px">{two_line(t, s, tid)}{sw(on, tid)}</div>'
def row_go(ic, t, s, href="#", value=""):
    v = f'<span style="flex: none; font-size: 14px; color: {MUTED}">{value}</span>' if value else ""
    return (f'<div data-row style="display: flex"><a href="{href}" style="flex: 1; display: flex; align-items: center; gap: 14px; min-height: 64px; padding: 10px 14px 10px 18px; color: {INK}; text-decoration: none">'
            f'{icon(ic, 22, DEEP)}{two_line(t, s)}{v}{icon("chev_right", 20, MUTED)}</a></div>')
def pill(t, bg=CREAM, col=ONACC):
    return f'<span style="align-self: flex-start; padding: 4px 12px; border-radius: 14px; background: {bg}; color: {col}; font-size: 13px; font-weight: 600">{t}</span>'
def btn2(a, b, href_a="#", href_b="#", mt="auto"):
    """A main button with a quieter one beside it."""
    return (f'<div style="margin-top: {mt}; flex: none; display: flex; gap: 10px">'
            f'<a href="{href_a}" style="flex: 1.4; display: flex; align-items: center; justify-content: center; min-height: 56px; border-radius: 28px; background: {TEAL}; color: {ONACC}; font-size: 17px; font-weight: 600; text-decoration: none">{a}</a>'
            f'<a href="{href_b}" style="flex: 1; display: flex; align-items: center; justify-content: center; min-height: 56px; border-radius: 28px; border: 1.5px solid {DEEP}; color: {DEEP}; font-size: 16px; font-weight: 600; text-decoration: none">{b}</a></div>')
def textlink(t, href="#", mt=6, color=INK):
    return f'<a href="{href}" style="margin-top: {mt}px; align-self: center; display: flex; align-items: center; min-height: 44px; padding: 0 12px; color: {color}; font-size: 15px; font-weight: 500">{t}</a>'
def yogi(size, joyful=False, mat=True, extra=""):
    return f'<svg aria-hidden="true" viewBox="0 0 200 200" width="{size}" height="{size}" style="display: block; flex: none{extra}">{yogi_body(mat=mat, joyful=joyful)}</svg>'
def board(w, h, inner, pad="40px 48px", bg=None):
    return (f'<div style="width: {w}px; height: {h}px; box-sizing: border-box; padding: {pad}; background: {bg or NIGHT}; color: {INK}; font-family: {FB}; '
            f'font-size: 15px; line-height: 1.45; display: flex; flex-direction: column; overflow: hidden">\n{inner}\n</div>')
def btitle(kicker, t):
    return (f'<div style="font-size: 14px; font-weight: 600">{kicker}</div>'
            f'<div style="font-family: {FH}; font-weight: 700; font-size: 30px; line-height: 1.15">{t}</div>')
note = lambda t: f'<div style="display: flex; gap: 10px; align-items: flex-start"><span style="flex: none; width: 6px; height: 6px; margin-top: 8px; border-radius: 3px; background: {INK}"></span><span>{t}</span></div>'
def cap(t, sub=""):
    s = f'<span style="font-size: 12.5px; font-weight: 500">{sub}</span>' if sub else ""
    return f'<div style="min-height: 40px; display: flex; flex-direction: column; justify-content: flex-end; line-height: 1.3"><span style="font-size: 14px; font-weight: 600">{t}</span>{s}</div>'
def col(*parts, gap=10): return f'<div style="display: flex; flex-direction: column; gap: {gap}px">{"".join(parts)}</div>'
def add(name, title, html, w=390, h=844, css=""):
    V[name + ".dc.html"] = page(title, html, w=w, h=h, css=css); SIZES[name] = (w, h)

REPLY_NOT_TODAY = "That's all right. Tomorrow is a new day."
r_ = lambda ic, t: f'<div style="display: flex; align-items: center; gap: 12px; min-height: 30px">{icon(ic, 20, DEEP)}<span>{t}</span></div>'
ROUTINE_CARD = (f'<div style="margin-top: 22px; padding: 22px; border-radius: 26px; border: 1px solid {LINE}; background: {PAPER}; display: flex; flex-direction: column">'
                '{chip}<div style="margin-top: 10px; font-family: ' + FH + '; font-weight: 700; font-size: 32px; line-height: 1.1">Meditate</div>'
                f'<div style="margin-top: 10px; display: flex; flex-direction: column; gap: 4px; font-size: 16px">{r_("clock", "7:00 am, for 10 minutes")}{r_("pin", "The balcony")}{r_("bag", "Yoga mat, grey shawl")}</div></div>')
def home_head():
    return (f'<div style="display: flex; align-items: center; justify-content: space-between; height: 44px; flex: none"><div style="font-family: {FH}; font-weight: 700; font-size: 26px; line-height: 1; color: {DEEP}">Yogi Focus</div>'
            f'<a href="V2-Routines.dc.html" aria-label="Your routines" style="width: 44px; height: 44px; margin-right: -10px; color: {INK}; display: flex; align-items: center; justify-content: center">{icon("plan")}</a></div>'
            f'<div style="margin-top: 22px; font-size: 14px; font-weight: 500; color: {MUTED}">{DATE}</div>')

# =====================================================================
# 0 The plan: what v2.0 holds, in order, and where each item is drawn
# =====================================================================
PLAN = [
 ("1", "Restart a mandala", "Routine settings, a sheet, and the mandala screen after day 30"),
 ("2", "“Not today” as an answer", "Today, the reply, widgets, notification, Apple Watch"),
 ("10", "A two-minute version", "Setup step, Today, the timer, the kept screen"),
 ("24", "Open straight into the practice", "The practice timer; the nudge opens it"),
 ("25", "Ask “How did it feel?” less", "About once a week, set in routine settings"),
 ("26", "A missed day leaves no trace", "The morning after looks like any morning"),
 ("9", "Fading nudges", "Reminders settings, and one proud moment"),
 ("18", "Learn when they really do it", "Reminders settings"),
 ("14", "Siri, Shortcuts, Action button", "App Shortcuts board"),
 ("22", "A gentle alarm (AlarmKit)", "Lock Screen and watch"),
 ("4", "Dynamic Island, Live Activity", "Before, during, after; started by a tap"),
 ("6", "Share a completed mandala", "Mandala complete, the shared image"),
 ("32", "“Share Yogi Focus”", "Bottom of Your routines; mandala complete"),
 ("29", "Ask for a rating at a happy moment", "Apple's own prompt, on day 30 only"),
 ("3", "Do Not Disturb alternatives", "Quiet apps with Screen Time, plus a shortcut"),
]
plan_rows = "".join(
    f'<div style="display: grid; grid-template-columns: 34px 66px 1fr 1.25fr; align-items: center; min-height: 40px; border-top: 1px solid {LINE}">'
    f'<span style="font-family: {FH}; font-weight: 700; font-size: 18px; color: {DEEP}">{i+1}</span>'
    f'<span style="font-size: 13px; font-weight: 600; color: {MUTED}">Item {n}</span><span style="font-weight: 600">{t}</span><span style="color: {MUTED}">{w}</span></div>'
    for i, (n, t, w) in enumerate(PLAN))
add("V2-Plan", "v2.0 plan", board(1000, 1000, f"""{btitle("Yogi Focus 2.0 · agreed 18 November 2026", "What v2.0 holds, in build order")}
<div style="margin-top: 18px; border-radius: 22px; background: {PAPER}; padding: 6px 22px 10px; display: flex; flex-direction: column">{plan_rows}</div>
<div style="margin-top: 18px; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); column-gap: 24px; font-weight: 500">
{note("Everything runs on the phone, the watch or Apple services. No server of our own, no accounts.")}
{note("Left out as written: switching Do Not Disturb on by itself, detecting driving, posting straight to TikTok.")}
{note("The ten design rules stand. Nothing counts misses before day 30; nothing on these boards mentions them before then.")}
</div>""", bg=PAPER if DARK else WHITE), w=1000, h=870)

# =====================================================================
# 1 Restart, "Not today", two minutes
# =====================================================================
place_rows = group(
  f'<div data-row style="display: flex; align-items: center; gap: 14px; min-height: 64px; padding: 0 18px">{icon("clock", 22, DEEP)}<span style="display: flex; flex-direction: column; flex: 1"><span style="{lab}">When</span><span style="font-size: 17px; font-weight: 600">7:00 am, for 10 minutes</span></span>{icon("chev_right", 20, MUTED)}</div>',
  f'<div data-row style="display: flex; align-items: center; gap: 14px; min-height: 64px; padding: 0 18px">{icon("pin", 22, DEEP)}<span style="display: flex; flex-direction: column; flex: 1"><span style="{lab}">Where</span><span style="font-size: 17px; font-weight: 600">The balcony</span></span>{icon("chev_right", 20, MUTED)}</div>',
  f'<div data-row style="display: flex; align-items: center; gap: 14px; min-height: 64px; padding: 0 18px">{icon("bag", 22, DEEP)}<span style="display: flex; flex-direction: column; flex: 1"><span style="{lab}">With</span><span style="font-size: 17px; font-weight: 600">Yoga mat, grey shawl</span></span>{icon("chev_right", 20, MUTED)}</div>', mt=16)
seg = (f'<div data-row style="padding: 12px 14px 14px 18px; display: flex; flex-direction: column; gap: 10px">{two_line("How often to ask", "Your answers still build up for later. There is no wrong answer.")}'
       f'<div role="radiogroup" aria-label="How often to ask how it felt" style="display: flex; padding: 3px; border-radius: 16px; background: {SOFT}">'
       f'<button type="button" role="radio" aria-checked="true" style="flex: 1; min-height: 40px; border-radius: 13px; border: none; background: {PAPER}; color: {INK}; font-size: 14.5px; font-weight: 600; box-shadow: 0 1px 3px rgba(20,48,31,0.14)">About once a week</button>'
       f'<button type="button" role="radio" aria-checked="false" style="flex: 1; min-height: 40px; border-radius: 13px; border: none; background: transparent; color: {INK}; font-size: 14.5px; font-weight: 500">Every day</button></div></div>')
add("V2-Settings", "Routine settings, v2", tphone(f"""{topbar("V2-Routines.dc.html")}
<div style="margin-top: 6px; font-size: 14px; font-weight: 600; color: {MUTED}">Routine</div>
{h1("Meditate", size=34, mt=0)}
{place_rows}
{sec("On a harder day")}
{group(row_go("lotus", "The two-minute version", "Sit on the mat for two minutes. It counts as kept.", "V2-Setup-Two.dc.html"))}
{sec("Reminders")}
{group(row_sw("A soft chime at 7:00 am", "", True, "v2chime"),
       row_sw("Ring like a gentle alarm", "With Start and Later, even when the phone is silent.", False, "v2alarm"),
       row_sw("Follow when I usually practise", "Reminders move quietly towards the time you tend to begin.", True, "v2follow"),
       row_sw("Keep every reminder", "Otherwise they grow lighter as the routine becomes yours.", False, "v2keep"))}
{sec("How did it feel?")}
{group(seg)}
{sec("Practice time")}
{group(row_go("settings", "Quiet distracting apps", "Instagram, TikTok and 2 more, 6:55 to 7:10 am", "V2-Quiet-Apps.dc.html"),
       row_go("clock", "Do Not Disturb with one tap", "Add a ready-made shortcut", "V2-Quiet-Apps.dc.html"))}
{sec("This routine")}
{group(row_sw("Pause this routine", "The widget goes quiet. Nothing is lost.", False, "v2pause"),
       row_go("lotus", "Begin this routine again", "A new mandala from today. Earlier days stay in your history.", "V2-Restart.dc.html"))}
<button type="button" style="margin-top: 10px; align-self: center; min-height: 44px; padding: 0 12px; border: none; background: transparent; color: {INK}; font-size: 15px; font-weight: 500; text-decoration: underline">Remove this routine</button>
{cta("Save", "V2-Routines.dc.html", mt="18px")}""", 1660), h=1660)

# Restart: a sheet over routine settings. Before day 30 it never mentions missed days.
sheet = lambda inner: (f'<div style="position: relative; width: 390px; height: 844px; overflow: hidden; font-family: {FB}; font-size: 16px; line-height: 1.55; color: {INK}; background: {GROUND}">'
                       f'<div aria-hidden="true" style="position: absolute; inset: 0; padding: 56px 28px; box-sizing: border-box; opacity: 0.35">{topbar()}{h1("Meditate", size=34, mt=6)}{place_rows}</div>'
                       f'<div aria-hidden="true" style="position: absolute; inset: 0; background: rgba(10,25,14,0.38)"></div>'
                       f'<div role="dialog" aria-modal="true" aria-labelledby="sheet-t" style="position: absolute; left: 0; right: 0; bottom: 0; box-sizing: border-box; padding: 12px 28px 34px; border-radius: 34px 34px 0 0; background: {GROUND}; display: flex; flex-direction: column">'
                       f'<span aria-hidden="true" style="align-self: center; width: 40px; height: 5px; border-radius: 3px; background: {LINE}"></span>{inner}</div></div>')
add("V2-Restart", "Begin this routine again", sheet(f"""<div style="margin-top: 8px; align-self: center">{lotus(150, 0, label="A lotus with every petal still closed")}</div>
<h2 id="sheet-t" style="margin: 14px 0 0; font-family: {FH}; font-weight: 700; font-size: 30px; line-height: 1.15; text-align: center">Begin Meditate again?</h2>
{p("A new mandala starts today, at day one. Every day so far stays in your history.", mt=8, extra="; text-align: center")}
{p("Same hour, same place, same things. Only the lotus starts fresh.", mt=8, size=15, color=MUTED, extra="; text-align: center")}
{cta("Begin again", "V2-Today.dc.html", mt="22px")}
{ghost("Not now", "V2-Settings.dc.html")}"""))

# After day 30 the mandala screen also offers it, quietly, under the routine line
m = BASE["Mandala.dc.html"]
m = m.replace('<a href="Routine-Edit.dc.html" style="display: flex; align-items: center; justify-content: center; min-width: 52px; min-height: 44px; font-size: 15px; font-weight: 600; text-decoration: none">Edit</a></div>',
              '<a href="V2-Settings.dc.html" style="display: flex; align-items: center; justify-content: center; min-width: 52px; min-height: 44px; font-size: 15px; font-weight: 600; text-decoration: none">Edit</a></div>'
              f'\n<a href="V2-Restart.dc.html" style="margin-top: 4px; align-self: center; display: flex; align-items: center; min-height: 40px; padding: 0 12px; color: {INK}; font-size: 14.5px; font-weight: 500">Begin a fresh mandala</a>')
m = m.replace('<div style="margin-top: 14px; font-size: 14px; font-weight: 600">How it has felt</div>', '<div style="margin-top: 10px; font-size: 14px; font-weight: 600">How it has felt</div>')
assert "Begin a fresh mandala" in m
V["V2-Mandala.dc.html"] = m.replace('href="Today.dc.html"', 'href="V2-Today.dc.html"'); SIZES["V2-Mandala"] = (390, 844)

# Today, v2: Start opens the timer; the two-minute version and Not today sit quietly beside it
add("V2-Today", "Today, v2", phone(f"""{home_head()}
{h1("A new day.", size=42, mt=2)}
{p("How will you keep your practice today?", mt=6)}
{ROUTINE_CARD.replace("{chip}", pill("In 20 minutes"))}
{under("This first week, stop at ten minutes, even if you would like more.")}
<a href="V2-Kept.dc.html" style="margin-top: 6px; align-self: flex-start; display: flex; align-items: center; gap: 8px; min-height: 44px; font-size: 15px; font-weight: 500">{icon("check", 18, DEEP, 2.4)}Already practised? Mark it kept</a>
{cta("Start, 10 minutes", "V2-Timer.dc.html")}
<div style="margin-top: 10px; flex: none; display: flex; gap: 10px">
<a href="V2-Timer-Two.dc.html" style="flex: 1; display: flex; align-items: center; justify-content: center; min-height: 50px; border-radius: 25px; border: 1.5px solid {DEEP}; color: {DEEP}; font-size: 15.5px; font-weight: 600; text-decoration: none">Just two minutes</a>
<a href="V2-Not-Today.dc.html" style="flex: 1; display: flex; align-items: center; justify-content: center; min-height: 50px; border-radius: 25px; border: 1.5px solid {LINE}; color: {INK}; font-size: 15.5px; font-weight: 600; text-decoration: none">Not today</a>
</div>"""))

# The reply to Not today: kind, short, and only about tomorrow
add("V2-Not-Today", "Not today", phone(f"""<div style="height: 30px; flex: none"></div>
<div style="align-self: center; display: grid; place-items: center">
<svg aria-hidden="true" viewBox="-150 -150 300 300" width="250" height="250" style="grid-area: 1 / 1; display: block; opacity: 0.55">{lotus_body(opened=48, open_cols=(SOFT, SOFT, SOFT), center=SOFT)}</svg>
<div style="grid-area: 1 / 1; padding-top: 40px; animation: yf-float 6s ease-in-out infinite">{yogi(190)}</div></div>
{h1("That's all right.", size=40, mt=10)}
{p("Tomorrow is a new day.", mt=4, size=20, extra="; font-family: " + FH + "; font-weight: 600")}
<div style="margin-top: 22px; padding: 16px 20px; border-radius: 22px; background: {CREAM}; color: {ONACC}; display: flex; flex-direction: column">
<span style="font-size: 13px; font-weight: 600">Tomorrow</span>
<span style="font-family: {FH}; font-weight: 700; font-size: 26px; line-height: 1.15">7:00 am, the balcony</span>
<span style="font-size: 14.5px; font-weight: 500">Yoga mat, grey shawl</span></div>
{p("No more reminders today.", size=14, color=MUTED, mt=12)}
{cta("Done", "V2-Today.dc.html")}"""))

# Setup: an optional step after the anchor, for the smallest version of the routine
tchip = lambda t, on=False: (f'<button type="button" aria-pressed="{"true" if on else "false"}" style="display: flex; align-items: center; min-height: 44px; padding: 0 16px; border-radius: 22px; '
                             f'border: 2px solid {DEEP if on else LINE}; background: {SOFT if on else PAPER}; color: {INK}; font-size: 15px; font-weight: {600 if on else 500}; text-align: left">{t}</button>')
add("V2-Setup-Two", "The two-minute version", phone(f"""{topbar("Anchor.dc.html", f'<a href="Widget-Setup.dc.html" style="display: flex; align-items: center; min-height: 44px; font-size: 15px; font-weight: 500; text-decoration: none">Skip</a>')}
{h1("And on a harder day?", size=34, mt=6)}
{p("Choose the smallest version of Meditate. On a day when ten minutes feels too much, two minutes still keeps the day.", mt=8)}
<div style="margin-top: 18px; display: flex; flex-wrap: wrap; gap: 8px">
{tchip("Sit on the mat for two minutes", True)}{tchip("Three slow breaths")}{tchip("Just unroll the mat")}{tchip("Write my own")}
</div>
<div style="margin-top: 20px; padding: 16px 22px; border-radius: 22px; background: {CREAM}; color: {ONACC}; display: flex; flex-direction: column; gap: 6px"><span style="font-size: 13px; font-weight: 600">On a harder day</span><div style="font-family: {FH}; font-weight: 600; font-size: 20px; line-height: 1.3">I go to the balcony and sit on the mat for two minutes.</div></div>
{p("It counts as kept. Showing up is the habit.", size=14, color=MUTED, mt=12)}
{cta("Keep this", "Widget-Setup.dc.html")}"""))

# =====================================================================
# 2 Straight into the practice; ask less; no trace
# =====================================================================
CSS_TIMER = """@keyframes yf-timer{from{stroke-dashoffset:0}to{stroke-dashoffset:829}}
@keyframes yf-glow{0%,100%{opacity:0.35}50%{opacity:0.7}}
"""
def timer_screen(total, left, label, sub, two=False):
    ring = (f'<svg role="img" aria-label="{left} left of {total}" viewBox="0 0 300 300" width="300" height="300" style="display: block">'
            f'<circle cx="150" cy="150" r="132" fill="{SOFT}" style="animation: yf-glow 6s ease-in-out infinite"></circle>'
            f'<circle cx="150" cy="150" r="132" fill="none" stroke="{LINE}" stroke-width="12"></circle>'
            f'<circle cx="150" cy="150" r="132" fill="none" stroke="{TEALM}" stroke-width="12" stroke-linecap="round" stroke-dasharray="829" transform="rotate(-90 150 150)" '
            f'style="animation: yf-timer {"16s" if two else "40s"} linear {"-5.6s" if two else "-9.2s"} infinite"></circle>'
            f'<g transform="translate(62 46) scale(0.88)">{yogi_body(mat=False)}</g></svg>')
    return phone(f"""<div style="display: flex; align-items: center; justify-content: space-between; height: 44px; flex: none"><span style="font-size: 15px; font-weight: 600; color: {DEEP}">{label}</span><span style="display: flex; align-items: center; gap: 6px; font-size: 13.5px; font-weight: 500; color: {MUTED}">{icon("music", 16, MUTED)}Chime at the end</span></div>
<div style="margin-top: 26px; align-self: center; display: grid; place-items: center">{ring}</div>
<div style="margin-top: 14px; text-align: center; font-family: {FH}; font-weight: 700; font-size: 64px; line-height: 1; font-variant-numeric: tabular-nums">{left}</div>
<div style="margin-top: 6px; text-align: center; font-size: 15px; color: {MUTED}">{sub}</div>
{p("Sit, breathe and let the timer keep the time.", mt=22, extra="; text-align: center")}
<div style="margin-top: auto; display: flex; flex-direction: column; align-items: center">
<a href="V2-Kept{'-Two' if two else ''}.dc.html" style="display: flex; align-items: center; justify-content: center; min-height: 50px; padding: 0 26px; border-radius: 25px; border: 1.5px solid {LINE}; color: {INK}; font-size: 15.5px; font-weight: 600; text-decoration: none">Finish now</a>
<span style="margin-top: 8px; font-size: 13.5px; color: {MUTED}">Finishing early still counts as kept.</span></div>""")
add("V2-Timer", "The practice timer", timer_screen("10 minutes", "7:42", "Meditate · the balcony", "of 10 minutes"), css=CSS_TIMER)
add("V2-Timer-Two", "The two-minute timer", timer_screen("2 minutes", "1:18", "Meditate · two minutes", "of 2 minutes", two=True), css=CSS_TIMER)

k = BASE["Kept.dc.html"]
k2 = k.replace("Forever was never the job. Today was, and you did it.", "Two minutes, and you came. Showing up is the habit.").replace('href="Today.dc.html"', 'href="V2-Today.dc.html"')
assert k2 != k
V["V2-Kept-Two.dc.html"] = k2; SIZES["V2-Kept-Two"] = (390, 844)
V["V2-Kept.dc.html"] = k.replace('href="Today.dc.html"', 'href="V2-Today.dc.html"'); SIZES["V2-Kept"] = (390, 844)

# The flow when the timer ends: most days straight to kept, about once a week the question first
def flowbox(kicker, t, s, bg=PAPER, colr=INK):
    return (f'<div style="flex: 1; min-width: 0; padding: 18px 20px; border-radius: 22px; background: {bg}; color: {colr}; display: flex; flex-direction: column; gap: 4px">'
            f'<span style="font-size: 13px; font-weight: 600">{kicker}</span><span style="font-family: {FH}; font-weight: 700; font-size: 22px; line-height: 1.15">{t}</span><span style="font-size: 14px; line-height: 1.45">{s}</span></div>')
arrow = f'<span style="flex: none; align-self: center; display: flex; color: {INK}">{icon("chev_right", 24, "currentColor", 2.4)}</span>'
add("V2-Flow", "From the nudge to kept", board(1000, 700, f"""{btitle("Items 24, 25 and 26", "From the nudge to kept, in as few taps as possible")}
<div style="margin-top: 22px; display: flex; gap: 10px">
{flowbox("At 7:00 am", "The nudge", "“It's time. Meditate. Your mat is waiting.” One tap opens the timer, already running.", CREAM, ONACC)}{arrow}
{flowbox("For 10 minutes", "The timer", "A ring, the yogi and the time left. A chime at the end marks the day kept.")}{arrow}
{flowbox("Most days", "That's today, kept.", "Straight to the kept screen. No question.", TEAL, ONACC)}
</div>
<div style="margin-top: 12px; display: flex; gap: 10px; padding-left: 0">
<div style="flex: 1"></div><div style="flex: none; width: 24px"></div><div style="flex: 1"></div><div style="flex: none; width: 24px"></div>
{flowbox("About once a week", "How did it feel?", "Asked first, then kept. Every day if they choose that in settings.", SOFT)}
</div>
<div style="margin-top: 26px; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); column-gap: 24px; font-weight: 500">
{note("Cut Sugar has no length, so its nudge opens straight to Done.")}
{note("Finishing early still counts as kept, as does the two-minute version.")}
{note("The morning after a miss looks exactly like any other morning: same words, same warmth, no “welcome back”.")}
</div>
<div style="margin-top: 26px; padding: 18px 22px; border-radius: 22px; background: {SOFT}; display: flex; flex-direction: column; gap: 6px">
<span style="font-size: 14px; font-weight: 600">Words that change in v2 because they looked back at yesterday</span>
<span><b>Today, after a missed day:</b> “Yesterday is finished. Nothing to catch up…” becomes the usual “A new day. How will you keep your practice today?”</span>
<span><b>Widget, the morning after a miss:</b> “Nothing to catch up. Just start.” becomes the usual line for that stage.</span>
<span><b>Still the same:</b> “Still today” after the hour, which is about today only.</span>
</div>""", bg=PAPER if DARK else WHITE), w=1000, h=700)

# =====================================================================
# 3 Reminders that learn and fade; the gentle alarm
# =====================================================================
def dial():
    # a gentle clock arc: the set time and where reminders now land
    import math
    def pt(mins, r):
        a = math.radians(-90 + mins / 60 * 360)
        return 110 + r * math.cos(a), 110 + r * math.sin(a)
    x0, y0 = pt(0, 84); x1, y1 = pt(40, 84)
    ticks = "".join(f'<line x1="{pt(m, 96)[0]:.1f}" y1="{pt(m, 96)[1]:.1f}" x2="{pt(m, 102)[0]:.1f}" y2="{pt(m, 102)[1]:.1f}" stroke="{MUTED}" stroke-width="2" stroke-linecap="round"></line>' for m in range(0, 60, 5))
    return (f'<svg role="img" aria-label="Set for 7:00 am, reminders now come at about 7:40" viewBox="0 0 220 220" width="132" height="132" style="display: block; flex: none">'
            f'<circle cx="110" cy="110" r="102" fill="{PAPER}"></circle>{ticks}'
            f'<path d="M{x0:.1f} {y0:.1f} A84 84 0 0 1 {x1:.1f} {y1:.1f}" fill="none" stroke="{CREAM}" stroke-width="14" stroke-linecap="round"></path>'
            f'<circle cx="{x0:.1f}" cy="{y0:.1f}" r="9" fill="{MUTED}"></circle><circle cx="{x1:.1f}" cy="{y1:.1f}" r="11" fill="{TEALM}"></circle>'
            f'<text x="110" y="104" text-anchor="middle" font-family="Baloo 2, sans-serif" font-weight="700" font-size="30" fill="{INK}">7:40</text>'
            f'<text x="110" y="128" text-anchor="middle" font-family="Inter, sans-serif" font-weight="500" font-size="13" fill="{MUTED}">reminders now</text></svg>')
add("V2-Reminders", "Reminders", phone(f"""{topbar("V2-Settings.dc.html")}
<div style="margin-top: 6px; font-size: 14px; font-weight: 600; color: {MUTED}">Meditate</div>
{h1("Reminders", size=34, mt=0)}
<div style="margin-top: 14px; padding: 14px 16px; border-radius: 24px; background: {SOFT}; display: flex; align-items: center; gap: 14px">{dial()}
<div style="display: flex; flex-direction: column; gap: 4px"><span style="font-family: {FH}; font-weight: 700; font-size: 19px; line-height: 1.2">They follow you.</span><span style="font-size: 13.5px; line-height: 1.45">You set 7:00 am and tend to begin nearer 7:40, so the reminders come then.</span></div></div>
{group(row_sw("Follow when I usually practise", "", True, "r1"),
       row_sw("Ring like a gentle alarm", "Start and Later on the Lock Screen and your watch, even when the phone is silent.", False, "r2"),
       row_sw("Keep every reminder", "Otherwise, once the routine is yours, they grow lighter.", False, "r3"), mt=16)}
{p("Your routine still says 7:00 am. Reminders never move more than 45 minutes from it.", size=14, color=MUTED, mt=12)}
{cta("Done", "V2-Settings.dc.html")}"""))

# The one proud moment when nudges fade: after day 30, once most days were kept before the reminder
add("V2-Nudges-Fade", "You don't need my reminder", f'''<div style="position: relative; width: 390px; height: 844px; box-sizing: border-box; padding: 56px 28px 34px; display: flex; flex-direction: column; background: {HERO_Y}; color: {INK}; font-family: {FB}; font-size: 16px; line-height: 1.55; overflow: hidden">
{rays(195, 230, r=700, fill="#182B17" if DARK else "#FFDF52")}
<div style="position: relative; flex: 1; min-height: 0; display: flex; flex-direction: column">
<div style="height: 20px; flex: none"></div>
<div style="align-self: center; animation: yf-levitate 4.5s ease-in-out infinite">{yogi(230, joyful=True, mat=False)}</div>
{h1("You don't need my reminder any more.", size=36, mt=18)}
{p("Most days lately, you began before I even asked. That is what a habit looks like. From now on I'll stay quieter, and the hour is yours.", mt=10)}
{cta("Thank you", "V2-Today.dc.html", **HBTN)}
{textlink("Keep every reminder", "V2-Reminders.dc.html")}
</div></div>''')

# AlarmKit: Lock Screen alarm and the same on the watch
WALL = "linear-gradient(180deg, #1D6B3A 0%, #2E9B48 55%, #7ACB4A 100%)"
def lockscreen(inner, time="6:59", date=DATE, h=844):
    return (f'<div style="position: relative; width: 390px; height: {h}px; overflow: hidden; border-radius: 44px; background: {WALL}; color: #FFFFFF; font-family: {FB}">'
            f'<div style="position: absolute; left: 0; right: 0; top: 58px; text-align: center; font-size: 17px; font-weight: 600">{date}</div>'
            f'<div style="position: absolute; left: 0; right: 0; top: 76px; text-align: center; font-size: 96px; font-weight: 700; line-height: 1.1; letter-spacing: -2px">{time}</div>'
            f'<div style="position: absolute; left: 0; right: 0; top: 0; bottom: 0">{inner}</div></div>')
alarm_ls = lockscreen(f'''<div style="position: absolute; left: 50%; top: 11px; transform: translateX(-50%); width: 126px; height: 37px; border-radius: 19px; background: #000000"></div>
<div style="position: absolute; left: 14px; right: 14px; top: 250px; padding: 18px 18px 16px; border-radius: 30px; background: rgba(12,30,18,0.72); display: flex; flex-direction: column; gap: 2px">
<div style="display: flex; align-items: center; gap: 10px">{lotus_svg(34, "Yogi Focus", opened=48).replace("grid-area: 1 / 1", "flex: none")}<span style="font-size: 14px; font-weight: 600; color: {CREAM}">Yogi Focus · 7:00 am</span></div>
<div style="margin-top: 8px; font-family: {FH}; font-weight: 700; font-size: 34px; line-height: 1.05">Meditate</div>
<div style="font-size: 15px; font-weight: 500">The balcony · yoga mat, grey shawl</div>
<div style="margin-top: 14px; display: flex; gap: 10px">
<button type="button" style="flex: 1; min-height: 56px; border-radius: 28px; border: none; background: {TEAL}; color: {ONACC}; font-size: 18px; font-weight: 600">Start</button>
<button type="button" style="flex: 1; min-height: 56px; border-radius: 28px; border: none; background: rgba(255,255,255,0.2); color: #FFFFFF; font-size: 18px; font-weight: 600">Later</button></div></div>
<div style="position: absolute; left: 0; right: 0; bottom: 40px; text-align: center; font-size: 14px; font-weight: 500; opacity: 0.85">A soft chime, short, not a ring tone</div>''')
WATCH_BTN2 = lambda a, b: (f'<div style="margin-top: auto; padding: 0 12px 6px; display: flex; gap: 5px"><button type="button" style="flex: 0.8; min-height: 42px; padding: 0 4px; border-radius: 21px; border: none; background: {TEAL}; color: #14301F; font-size: 14px; font-weight: 600; white-space: nowrap">{a}</button>'
                           f'<button type="button" style="flex: 1.2; min-height: 42px; padding: 0 4px; border-radius: 21px; border: none; background: #2A332A; color: #FFFFFF; font-size: 14px; font-weight: 600; white-space: nowrap">{b}</button></div>')
w_alarm = watch(wyogi(70, 4, 8, mat=False) + wlabel("7:00 am", dot=True) + wtitle() + wline("The balcony", WSEC) + WATCH_BTN2("Start", "Later"))
add("V2-Alarm", "A gentle alarm", board(1000, 1000, f"""{btitle("Item 22 · AlarmKit, off unless chosen", "A gentle alarm at the hour")}
<div style="margin-top: 22px; display: flex; gap: 48px; align-items: flex-start">
{col(cap("Lock Screen, at 7:00 am", "Breaks through silent mode, as an alarm should"), alarm_ls)}
<div style="display: flex; flex-direction: column; gap: 28px">
{col(cap("Apple Watch, at the same moment", "Haptic: the alarm pattern, softened"), w_alarm)}
<div style="max-width: 420px; display: flex; flex-direction: column; gap: 12px; font-weight: 500">
{note("Start opens the practice timer and the Live Activity. Later rings once more in 10 minutes, then never again that day.")}
{note("Turned on per routine in Reminders. Off by default, so nobody is woken by surprise.")}
{note("Uses Apple's AlarmKit (iOS 26) on the phone itself. Nothing to set up and no server.")}
</div></div></div>""", bg=PAPER if DARK else WHITE), w=1000, h=1000)

# =====================================================================
# 4 Siri and Shortcuts; Live Activity; widgets; notification; watch
# =====================================================================
def snippet(ask, title, line):
    return (f'<div style="width: 364px; display: flex; flex-direction: column; gap: 10px">'
            f'<div style="align-self: flex-end; max-width: 300px; padding: 10px 16px; border-radius: 20px; background: rgba(255,255,255,0.22); color: #FFFFFF; font-size: 16px; font-weight: 500">“{ask}”</div>'
            f'<div style="padding: 16px 18px; border-radius: 26px; background: rgba(12,30,18,0.8); color: #FFFFFF; display: flex; align-items: center; gap: 14px">'
            f'<svg aria-hidden="true" viewBox="0 0 200 200" width="70" height="70" style="display: block; flex: none">{yogi_body(mat=False, joyful=True)}</svg>'
            f'<div style="display: flex; flex-direction: column"><span style="font-size: 13px; font-weight: 600; color: {CREAM}">Yogi Focus</span><span style="font-family: {FH}; font-weight: 700; font-size: 23px; line-height: 1.15">{title}</span><span style="font-size: 14.5px">{line}</span></div></div></div>')
def shortcut_tile(t, s, bg):
    return (f'<div style="width: 170px; height: 104px; box-sizing: border-box; padding: 14px; border-radius: 22px; background: {bg}; color: {ONACC}; display: flex; flex-direction: column; justify-content: space-between">'
            f'{lotus_svg(30, "", opened=48).replace("grid-area: 1 / 1", "flex: none").replace(" aria-label=\"\"", "")}<div style="display: flex; flex-direction: column; line-height: 1.25"><span style="font-size: 15px; font-weight: 700">{t}</span><span style="font-size: 12.5px; font-weight: 500">{s}</span></div></div>')
siri_bg = f'<div style="padding: 24px; border-radius: 30px; background: {WALL}; display: flex; flex-direction: column; gap: 22px">'
add("V2-Siri", "Siri, Shortcuts and the Action button", board(1000, 820, f"""{btitle("Item 14 · App Shortcuts, with nothing to set up", "Siri, Spotlight, Shortcuts and the Action button")}
<div style="margin-top: 22px; display: flex; gap: 40px; align-items: flex-start">
{col(cap("Hey Siri, I've done my meditation"), siri_bg + snippet("I've done my meditation", "That's today, kept.", "Only tomorrow is next.") + '</div>')}
{col(cap("Hey Siri, how am I doing with Meditate?", "Before day 30: kindness and time, never a count"), siri_bg + snippet("How am I doing with Meditate?", "One day at a time.", "Today is still yours. 7:00 am, the balcony.") + '</div>')}
</div>
<div style="margin-top: 26px; display: flex; gap: 40px; align-items: flex-start">
{col(cap("In Shortcuts and Spotlight", "The same three actions, for every routine"), '<div style="display: flex; gap: 12px">' + shortcut_tile("Start Meditate", "Opens the timer", TEAL) + shortcut_tile("Two minutes", "The smaller version", CREAM) + shortcut_tile("Done", "Mark today kept", "#B9EC8E") + '</div>')}
<div style="padding-top: 48px; max-width: 340px; display: flex; flex-direction: column; gap: 12px; font-weight: 500">
{note("Action button: choose Shortcut, then Yogi Focus, then Start. One press opens the timer.")}
{note("These reuse the Done action the widget already has, offered to the system with AppShortcutsProvider.")}
</div></div>""", bg=PAPER if DARK else WHITE), w=1000, h=720)

# Live Activity and the Dynamic Island
CSS_LA = """@keyframes yf-la{from{stroke-dashoffset:0}to{stroke-dashoffset:113}}
"""
def mini_ring(size, pct, anim=False):
    r = 18; c = 113
    off = round(c * (1 - pct), 1)
    a = "; animation: yf-la 40s linear -9.2s infinite" if anim else ""
    return (f'<svg aria-hidden="true" viewBox="0 0 44 44" width="{size}" height="{size}" style="display: block; flex: none"><circle cx="22" cy="22" r="{r}" fill="none" stroke="#2C3A2E" stroke-width="5"></circle>'
            f'<circle cx="22" cy="22" r="{r}" fill="none" stroke="{TEAL}" stroke-width="5" stroke-linecap="round" stroke-dasharray="{c}" stroke-dashoffset="{off}" transform="rotate(-90 22 22)" style="{a[2:] if a else ""}"></circle></svg>')
LA_LOTUS = lambda s: lotus_svg(s, "", opened=48).replace("grid-area: 1 / 1", "flex: none").replace(' aria-label=""', "")
def island_compact(lead, trail):
    return (f'<div style="width: 250px; height: 37px; box-sizing: border-box; padding: 0 12px 0 8px; border-radius: 19px; background: #000000; color: #FFFFFF; display: flex; align-items: center; justify-content: space-between">'
            f'{lead}<span style="width: 110px"></span><span style="font-size: 14px; font-weight: 600; color: {TEAL}; font-variant-numeric: tabular-nums">{trail}</span></div>')
def island_expanded(inner):
    return f'<div style="width: 370px; box-sizing: border-box; padding: 16px 20px 18px; border-radius: 44px; background: #000000; color: #FFFFFF; display: flex; flex-direction: column">{inner}</div>'
def la_btn(t, main=True):
    return (f'<button type="button" style="min-height: 44px; padding: 0 20px; border-radius: 22px; border: none; background: {TEAL if main else "#2A332A"}; color: {"#14301F" if main else "#FFFFFF"}; font-size: 15px; font-weight: 600">{t}</button>')
ex_before = island_expanded(f'''<div style="display: flex; align-items: center; gap: 12px">{LA_LOTUS(40)}<div style="flex: 1; display: flex; flex-direction: column"><span style="font-size: 13px; font-weight: 600; color: {CREAM}">In 12 minutes</span><span style="font-family: {FH}; font-weight: 700; font-size: 24px; line-height: 1.1">Meditate</span></div><span style="font-size: 26px; font-weight: 600; color: {TEAL}">6:48</span></div>
<div style="margin-top: 10px; font-size: 14px; color: #C2CDBE">The balcony · yoga mat, grey shawl</div>
<div style="margin-top: 12px; display: flex; gap: 8px">{la_btn("I'm starting")}{la_btn("Two minutes", False)}</div>''')
ex_during = island_expanded(f'''<div style="display: flex; align-items: center; gap: 14px">{mini_ring(56, 0.23, anim=True)}<div style="flex: 1; display: flex; flex-direction: column"><span style="font-size: 13px; font-weight: 600; color: {CREAM}">Meditating · the balcony</span><span style="font-family: {FH}; font-weight: 700; font-size: 30px; line-height: 1.05; font-variant-numeric: tabular-nums">7:42 left</span></div></div>
<div style="margin-top: 12px; display: flex; gap: 8px">{la_btn("Done")}</div>''')
ex_after = island_expanded(f'''<div style="display: flex; align-items: center; gap: 12px"><svg aria-hidden="true" viewBox="0 0 200 200" width="54" height="54" style="display: block; flex: none">{yogi_body(mat=False, joyful=True)}</svg><div style="display: flex; flex-direction: column"><span style="font-family: {FH}; font-weight: 700; font-size: 24px; line-height: 1.1; color: {CREAM}">That's today, kept.</span><span style="font-size: 14px">Only tomorrow is next.</span></div></div>''')
la_lock = (f'<div style="width: 364px; box-sizing: border-box; padding: 16px 18px; border-radius: 26px; background: rgba(12,30,18,0.82); color: #FFFFFF; display: flex; align-items: center; gap: 14px">'
           f'{mini_ring(64, 0.23, anim=True)}<div style="flex: 1; display: flex; flex-direction: column"><span style="font-size: 13px; font-weight: 600; color: {CREAM}">Meditate · the balcony</span>'
           f'<span style="font-family: {FH}; font-weight: 700; font-size: 30px; line-height: 1.05; font-variant-numeric: tabular-nums">7:42 left</span><span style="font-size: 13px; color: #C2CDBE">Chime at 7:10 am</span></div>{la_btn("Done")}</div>')
la_lock30 = (f'<div style="width: 364px; box-sizing: border-box; padding: 16px 18px; border-radius: 26px; background: rgba(12,30,18,0.82); color: #FFFFFF; display: flex; align-items: center; gap: 14px">'
             f'<div style="display: grid; place-items: center">{lotus_svg(64, "Lotus with 34 petals open", **SAMPLE)}</div><div style="flex: 1; display: flex; flex-direction: column"><span style="font-size: 13px; font-weight: 600; color: {CREAM}">After day 30</span>'
             f'<span style="font-family: {FH}; font-weight: 700; font-size: 24px; line-height: 1.1">34 petals open</span><span style="font-size: 13px; color: #C2CDBE">Tomorrow, one more</span></div></div>')
dark_panel = lambda inner: f'<div style="padding: 22px; border-radius: 30px; background: {WALL}; display: flex; flex-direction: column; align-items: center; gap: 14px">{inner}</div>'
add("V2-Live-Activity", "Dynamic Island and Live Activity", board(1300, 920, f"""{btitle("Item 4 · started by a tap, never by a server", "Dynamic Island and the Lock Screen")}
<div style="margin-top: 22px; display: grid; grid-template-columns: repeat(3, 370px); justify-content: space-between; row-gap: 26px">
{col(cap("Before, compact", "Starts when they tap the 20-minute nudge, the widget or the alarm"), dark_panel(island_compact(LA_LOTUS(24), "12 min")))}
{col(cap("During, compact", "The ring fills over the routine's length"), dark_panel(island_compact(mini_ring(24, 0.23, anim=True), "7:42")))}
{col(cap("After, compact", "A moment, then it ends itself"), dark_panel(island_compact(icon("check", 22, TEAL, 2.6), "Kept")))}
{col(cap("Before, expanded"), ex_before)}
{col(cap("During, expanded"), ex_during)}
{col(cap("After, expanded"), ex_after)}
{col(cap("Lock Screen, during"), dark_panel(la_lock))}
{col(cap("Lock Screen, after day 30, once kept", "Counts appear only from day 30"), dark_panel(la_lock30))}
<div style="padding-top: 48px; display: flex; flex-direction: column; gap: 12px; font-weight: 500">
{note("On Apple Watch it shows in the Smart Stack by itself.")}
{note("Before day 30, only time: never days or petals.")}
{note("Done and I'm starting are App Intents, so the app needn't open.")}
</div></div>""", bg=PAPER if DARK else WHITE), w=1300, h=780, css=CSS_LA)

# Widgets with Not today, and the notification's actions
def two_btns(a, b, h=44, fs=14):
    return (f'<div style="margin-top: auto; display: flex; gap: 8px"><button type="button" style="flex: 1; min-height: {h}px; border-radius: {h//2}px; border: none; background: {TEAL}; color: {ONACC}; font-size: {fs}px; font-weight: 600">{a}</button>'
            f'<button type="button" style="flex: 1; min-height: {h}px; border-radius: {h//2}px; border: 1.5px solid rgba(20,48,31,0.35); background: transparent; color: {ONACC}; font-size: {fs}px; font-weight: 600">{b}</button></div>')
DONE_M = f'<button type="button" style="margin-top: auto; min-height: 44px; border-radius: 22px; border: none; background: {TEAL}; color: {ONACC}; font-size: 14px; font-weight: 600">Done</button>'
DONE_L = f'<button type="button" style="margin-top: auto; min-height: 48px; border-radius: 24px; border: none; background: {TEAL}; color: {ONACC}; font-size: 15px; font-weight: 600">Done</button>'
wm = w_med("It's time", "Don't decide. Just start.", bg=CREAM, dot=True, done=True)
assert DONE_M in wm
wm2 = wm.replace(DONE_M, two_btns("Done", "Not today"))
wl = w_large("It's time", "Dull is normal now. Don't decide. Just start.", bg=CREAM, dot=True, done=True)
assert DONE_L in wl
wl2 = wl.replace(DONE_L, f'<div style="margin-top: auto; display: flex; flex-direction: column; gap: 8px">' + two_btns("Done", "Two minutes", 48, 15).replace("margin-top: auto; ", "") +
                 f'<button type="button" style="min-height: 40px; border: none; background: transparent; color: {ONACC}; font-size: 14.5px; font-weight: 600; text-decoration: underline">Not today</button></div>')
wm_after = w_med("Tomorrow", "Tomorrow is a new day.", foot=("Tomorrow, 7:00 am · The balcony",))
ws = w_small("It's time", "Don't decide. Just start.", bg=CREAM, dot=SAFF, done=True)
def notif(title, body, actions):
    acts = "".join(f'<div style="min-height: 50px; padding: 0 18px; display: flex; align-items: center; border-top: 1px solid rgba(20,48,31,0.12); font-size: 16px; font-weight: {600 if i == 0 else 500}; color: #14301F">{a}</div>' for i, a in enumerate(actions))
    return (f'<div style="width: 364px; display: flex; flex-direction: column; gap: 8px">'
            f'<div style="padding: 14px 16px; border-radius: 24px; background: rgba(255,255,255,0.92); color: #14301F; display: flex; gap: 12px">'
            f'<div style="flex: none; width: 38px; height: 38px; border-radius: 9px; overflow: hidden">{lotus_svg(38, "", opened=48).replace(" aria-label=\"\"", "")}</div>'
            f'<div style="display: flex; flex-direction: column; line-height: 1.35"><span style="font-size: 15px; font-weight: 600">{title}</span><span style="font-size: 15px">{body}</span></div></div>'
            f'<div style="border-radius: 20px; background: rgba(255,255,255,0.88); overflow: hidden; display: flex; flex-direction: column">{acts.replace("border-top: 1px solid rgba(20,48,31,0.12); ", "", 1)}</div></div>')
nt = notif("It's time", "Meditate. Don't decide. Just start.", ["Start", "Just two minutes", "Not today"])
add("V2-Widgets", "Widgets and nudges with Not today", board(1000, 1060, f"""{btitle("Items 2 and 10", "Not today, and two minutes, wherever the question is asked")}
<div style="margin-top: 22px; display: grid; grid-template-columns: 364px 364px; column-gap: 48px; row-gap: 24px">
{col(cap("Medium, at the hour", "Done and Not today"), wm2)}
{col(cap("Medium, after Not today", "Calm, not green and never red. No more nudges today"), wm_after)}
{col(cap("Large, at the hour", "Room for the two-minute version too"), wl2)}
<div style="display: flex; flex-direction: column; gap: 24px">
{col(cap("Small, at the hour", "Room for Done only, as before"), ws)}
{col(cap("Notification, pressed and held", "Start opens the timer; the others answer in place"), f'<div style="padding: 16px; border-radius: 30px; background: {WALL}">{nt}</div>')}
</div></div>""", bg=NIGHT), w=1000, h=860)

# Apple Watch v2: Not today, the timer, and the alarm
CSS_WT = """@keyframes yf-wt{from{stroke-dashoffset:0}to{stroke-dashoffset:503}}
@keyframes yf-halo{0%{transform:scale(0.6);opacity:0}12%{opacity:0.9}62%,100%{transform:scale(1.9);opacity:0}}
"""
w_time2 = watch(wyogi(70, 4, 8, mat=False) + wlabel("It's time", dot=True) + wtitle() + f'<div style="margin-top: 8px; font-family: {FH}; font-weight: 600; font-size: 17px; line-height: 1.2; max-width: 140px">Your mat is waiting.</div>' + WATCH_BTN2("Done", "Not today"))
w_still2 = watch(wlabel("Still today") + wtitle() + f'<div style="margin-top: 8px; font-family: {FH}; font-weight: 600; font-size: 17px; line-height: 1.2">Just start when you can.</div>'
                 + f'<button type="button" style="margin-top: auto; min-height: 40px; border-radius: 20px; border: none; background: #2A332A; color: #FFFFFF; font-size: 14px; font-weight: 600">Just two minutes</button>' + WATCH_BTN2("Done", "Not today").replace("margin-top: auto", "margin-top: 6px"))
w_nt = watch(f'<svg aria-hidden="true" viewBox="0 0 200 200" width="92" height="92" style="display: block; align-self: center; margin-top: 2px">{yogi_body(mat=False)}</svg>'
             f'<div style="margin-top: 10px; font-family: {FH}; font-weight: 700; font-size: 21px; line-height: 1.1; text-align: center; color: {CREAM}">That\'s all right.</div>'
             f'<div style="margin-top: 4px; font-size: 14.5px; font-weight: 500; text-align: center">Tomorrow is a new day.</div><div style="font-size: 13px; text-align: center; color: {WSEC}">7:00 am, the balcony</div>', lotus=False)
w_timer = watch(f'<svg role="img" aria-label="7:42 left of 10 minutes" viewBox="0 0 180 180" width="168" height="168" style="display: block; align-self: center; margin-top: -4px">'
                f'<circle cx="90" cy="90" r="80" fill="none" stroke="#1F2A1F" stroke-width="10"></circle><circle cx="90" cy="90" r="80" fill="none" stroke="{TEAL}" stroke-width="10" stroke-linecap="round" stroke-dasharray="503" transform="rotate(-90 90 90)" style="animation: yf-wt 40s linear -9.2s infinite"></circle>'
                f'<text x="90" y="88" text-anchor="middle" font-family="Baloo 2, sans-serif" font-weight="700" font-size="40" fill="#FFFFFF">7:42</text><text x="90" y="112" text-anchor="middle" font-family="Inter, sans-serif" font-weight="500" font-size="14" fill="{WSEC}">Meditate</text></svg>'
                f'<div style="margin-top: auto; text-align: center; font-size: 13px; color: {WSEC}">A soft tap when it ends</div>', lotus=False)
add("V2-Watch", "Apple Watch, v2", board(1030, 736, f"""<div style="display: grid; grid-template-columns: repeat(4, 208px); justify-content: space-between; row-gap: 30px; align-content: start">
{wcell("At the hour", "Haptic: a firmer double tap", w_time2)}
{wcell("If the hour slips by", "Haptic: one gentle tap, once", w_still2)}
{wcell("After Not today", "No haptic", w_nt)}
{wcell("After Start: the timer", "Wrist down, it keeps running", w_timer)}
{wcell("The gentle alarm", "Haptic: the alarm pattern, softened", w_alarm)}
<div style="grid-column: span 3; padding-top: 60px; display: flex; flex-direction: column; gap: 12px; font-size: 15px; font-weight: 500; color: {INK}">
{note("Not today closes the day at once and stops the rest of today's nudges, including How did it feel?")}
{note("It changes nothing anyone sees until day 30, when that day shows as a red petal, as any missed day does.")}
{note("The Live Activity appears in the Smart Stack by itself while the timer runs.")}
</div></div>""", bg=NIGHT), w=1030, h=736, css=CSS_WT)

# =====================================================================
# 5 Sharing, rating and practice time
# =====================================================================
share_inner = f"""<div style="display: flex; justify-content: center; margin-top: 4px; flex: none">{hero_svg(224, HERO_G, (WHITE, CREAMS, CREAM), joyful=True)}</div>
<span style="margin-top: 16px; align-self: center; padding: 5px 14px; border-radius: 16px; background: {ONACC}; color: {CREAM}; font-size: 14px; font-weight: 600">Your 3rd mandala · Meditate</span>
{h1("One mandala.", size=46, mt=10)}
{p("Out of 48 days, you practised 45. Very few people ever keep a practice this long. This is a special place to be.", mt=4)}
<a href="V2-Share-Making.dc.html" style="margin-top: auto; flex: none; display: flex; align-items: center; justify-content: center; gap: 10px; min-height: 56px; border-radius: 28px; background: {HBTN["bg"]}; color: {HBTN["color"]}; font-size: 17px; font-weight: 600; text-decoration: none"><svg aria-hidden="true" viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 15V3M7 8l5-5 5 5"></path><path d="M5 12v7a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2v-7"></path></svg>Share my mandala</a>
<div style="margin-top: 8px; flex: none; display: flex; gap: 8px">
<a href="V2-Today.dc.html" style="flex: 1; display: flex; align-items: center; justify-content: center; min-height: 48px; border-radius: 24px; border: 1.5px solid {INK}; color: {INK}; font-size: 15.5px; font-weight: 600; text-decoration: none">New mandala</a>
<a href="Choose-Routine.dc.html" style="flex: 1; display: flex; align-items: center; justify-content: center; min-height: 48px; border-radius: 24px; border: 1.5px solid {INK}; color: {INK}; font-size: 15.5px; font-weight: 600; text-decoration: none">Add a routine</a></div>
<a href="V2-Routines.dc.html" style="margin-top: 6px; align-self: center; display: flex; align-items: center; min-height: 40px; padding: 0 12px; color: {INK}; font-size: 14.5px; font-weight: 500">Share Yogi Focus with a friend</a>"""
add("V2-Complete-Share", "Mandala complete, with sharing", f'''<div style="position: relative; width: 390px; height: 844px; box-sizing: border-box; padding: 56px 28px 30px; display: flex; flex-direction: column; background: {HERO_G}; color: {INK}; font-family: {FB}; font-size: 16px; line-height: 1.55; overflow: hidden">
{rays(195, 180, fill="#173019" if DARK else "#7EDC49")}
{confetti()}
<div style="position: relative; flex: 1; min-height: 0; display: flex; flex-direction: column">
{share_inner}
</div></div>''')

# The image they share: story size, nothing private (no place, things, feelings or times)
img = f'''<div role="img" aria-label="Shared image: a fully open lotus with the yogi, Meditate, 48 days, my 3rd mandala" style="position: relative; width: 540px; height: 960px; overflow: hidden; background: radial-gradient(circle at 270px 465px, #8FE356 0%, #3DBB45 75%); color: #14301F; font-family: {FB}">
<div aria-hidden="true" style="position: absolute; left: -380px; top: -185px; width: 1300px; height: 1300px; border-radius: 50%; background: repeating-conic-gradient(from -5.2deg, rgba(255,255,255,0.13) 0deg 10.4deg, transparent 10.4deg 22.5deg)"></div>
<div aria-hidden="true" style="position: absolute; left: 10px; top: 205px; width: 520px; height: 520px; border-radius: 50%; background: radial-gradient(circle, rgba(255,246,190,0.75) 0%, rgba(255,246,190,0) 65%)"></div>
<div style="position: absolute; left: 0; right: 0; top: 89px; text-align: center; font-size: 23px; font-weight: 600">My 3rd mandala</div>
<div style="position: absolute; left: 0; right: 0; top: 118px; text-align: center; font-family: {FH}; font-weight: 700; font-size: 84px; line-height: 1">Meditate</div>
<svg aria-hidden="true" viewBox="-150 -150 300 300" width="450" height="450" style="position: absolute; left: 45px; top: 240px; display: block">{lotus_body(opened=48, open_cols=(WHITE, CREAMS, CREAM), sep="#3DBB45", center=SAFF)}</svg>
<svg aria-hidden="true" viewBox="0 0 200 200" width="210" height="210" style="position: absolute; left: 165px; top: 315px; display: block">{yogi_body(mat=False, joyful=True)}</svg>
<div style="position: absolute; left: 0; right: 0; top: 722px; text-align: center; font-family: {FH}; font-weight: 700; font-size: 75px; line-height: 1">48 days</div>
<div style="position: absolute; left: 0; right: 0; top: 808px; text-align: center; font-size: 25px; font-weight: 500">One day at a time.</div>
<div style="position: absolute; left: 0; right: 0; top: 876px; display: flex; justify-content: center; align-items: center; gap: 9px; font-size: 21px; font-weight: 600"><span style="width: 35px; height: 35px; border-radius: 8px; background: {CREAM}; display: grid; place-items: center"><svg aria-hidden="true" viewBox="-150 -150 300 300" width="29" height="29" style="display: block">{lotus_body(opened=48, open_cols=(TEALD, TEALM, "#6FD43A"), sep=CREAM, center=CREAM)}</svg></span>Yogi Focus</div></div>'''
share_sheet = (f'<div style="width: 364px; box-sizing: border-box; padding: 16px; border-radius: 26px; background: {PAPER}; display: flex; flex-direction: column; gap: 12px">'
               f'<span style="font-size: 14px; font-weight: 600">Share sheet, then</span>'
               + "".join(f'<div style="min-height: 46px; padding: 8px 14px; box-sizing: border-box; border-radius: 14px; background: {SOFT}; display: flex; flex-direction: column; justify-content: center; line-height: 1.3; font-size: 15px; font-weight: 500"><span>{a}</span><span style="font-size: 13px; color: {MUTED}">{b}</span></div>'
                       for a, b in [("Instagram Stories", "with a free Facebook App ID"), ("Instagram, TikTok, Messages…", "through the share sheet"), ("Save image", "to Photos"), ("Or the 12-second video", "made on the phone, same choices")]) + '</div>')
add("V2-Share-Image", "The shared mandala image", board(1000, 1080, f"""{btitle("Item 6 · only when they tap Share", "The still image, the other choice beside the video")}
<div style="margin-top: 22px; display: flex; gap: 40px; align-items: flex-start">
<div style="border-radius: 28px; overflow: hidden; flex: none">{img}</div>
<div style="display: flex; flex-direction: column; gap: 18px">{share_sheet}
<div style="max-width: 364px; display: flex; flex-direction: column; gap: 12px; font-weight: 500">
{note("Nothing private: no place, no things, no feelings, no times.")}
{note("The number of mandalas comes from the routine itself. No made-up statistics about other people.")}
{note("1080 by 1920 pixels for Stories, drawn by the app from the same vector art.")}
</div></div></div>""", bg=PAPER if DARK else WHITE), w=1000, h=1080)


# Share: the app makes the video on the phone when they tap Share my mandala, then offers it
def thumb(dim=False, k=0.44):
    t = (f'<div style="position: relative; width: {round(540*k)}px; height: {round(960*k)}px; border-radius: 22px; overflow: hidden; flex: none; align-self: center; box-shadow: 0 10px 30px rgba(10,40,20,0.22)">'
         f'<div style="width: 540px; height: 960px; transform: scale({k}); transform-origin: 0 0{"; filter: saturate(0.5) brightness(0.8)" if dim else ""}">{img}</div>')
    if dim:
        t += (f'<div style="position: absolute; inset: 0; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 10px; color: #FFFFFF">'
              f'<svg aria-hidden="true" viewBox="0 0 80 80" width="76" height="76" style="display: block"><circle cx="40" cy="40" r="32" fill="none" stroke="rgba(255,255,255,0.3)" stroke-width="8"></circle>'
              f'<circle cx="40" cy="40" r="32" fill="none" stroke="#FFFFFF" stroke-width="8" stroke-linecap="round" stroke-dasharray="201" stroke-dashoffset="80" transform="rotate(-90 40 40)"></circle></svg>'
              f'<span style="font-size: 15px; font-weight: 600; text-shadow: 0 1px 4px rgba(0,0,0,0.35)">Making your video</span></div>')
    else:
        t += (f'<div style="position: absolute; left: 12px; right: 12px; top: 12px; display: flex; align-items: center; gap: 8px; color: #FFFFFF; font-size: 12px; font-weight: 600">'
              f'<span style="width: 26px; height: 26px; border-radius: 13px; background: rgba(0,0,0,0.35); display: grid; place-items: center"><svg aria-hidden="true" viewBox="0 0 24 24" width="12" height="12"><path d="M7 4l13 8-13 8z" fill="#FFFFFF"></path></svg></span>'
              f'<span style="flex: 1; height: 4px; border-radius: 2px; background: rgba(255,255,255,0.35); display: flex"><span style="width: 58%; border-radius: 2px; background: #FFFFFF"></span></span><span>0:12</span></div>')
    return t + '</div>'
def share_seg(video=True):
    on = f'background: {PAPER}; font-weight: 600; box-shadow: 0 1px 3px rgba(20,48,31,0.14)'
    off = 'background: transparent; font-weight: 500'
    return (f'<div role="radiogroup" aria-label="What to share" style="margin-top: 14px; display: flex; padding: 3px; border-radius: 16px; background: {SOFT}">'
            f'<button type="button" role="radio" aria-checked="{"true" if video else "false"}" style="flex: 1; min-height: 40px; border-radius: 13px; border: none; color: {INK}; font-size: 15px; {on if video else off}">Video</button>'
            f'<button type="button" role="radio" aria-checked="{"false" if video else "true"}" style="flex: 1; min-height: 40px; border-radius: 13px; border: none; color: {INK}; font-size: 15px; {off if video else on}">Image</button></div>')
def share_screen(making):
    dis = "; opacity: 0.4; pointer-events: none" if making else ""
    return phone(f"""{topbar("V2-Complete-Share.dc.html")}
{h1("Share your mandala", size=32, mt=2)}
{share_seg()}
<div style="margin-top: 16px; display: flex; flex-direction: column">{thumb(making)}</div>
{p("Made on your phone. Nothing is sent anywhere until you choose where it goes." if not making else "A few seconds. It's made here on your phone, from your own mandala.", size=14, color=MUTED, mt=12, extra="; text-align: center")}
<div style="margin-top: auto; display: flex; flex-direction: column{dis}">
<a href="#" style="display: flex; align-items: center; justify-content: center; gap: 10px; min-height: 56px; border-radius: 28px; background: {TEAL}; color: {ONACC}; font-size: 17px; font-weight: 600; text-decoration: none">Instagram Stories</a>
<div style="margin-top: 8px; display: flex; gap: 8px">
<a href="#" style="flex: 1; display: flex; align-items: center; justify-content: center; min-height: 50px; border-radius: 25px; border: 1.5px solid {DEEP}; color: {DEEP}; font-size: 15.5px; font-weight: 600; text-decoration: none">Save video</a>
<a href="#" style="flex: 1; display: flex; align-items: center; justify-content: center; min-height: 50px; border-radius: 25px; border: 1.5px solid {DEEP}; color: {DEEP}; font-size: 15.5px; font-weight: 600; text-decoration: none">More</a></div></div>""")
add("V2-Share-Making", "Making your video", share_screen(True))
add("V2-Share-Video", "Share your mandala", share_screen(False))

# Your routines, with quiet links at the bottom
rr = BASE["Routines.dc.html"]
rr2 = rr.replace(p("Add slowly. Give each routine a full mandala before you start the next.", size=14, color=MUTED, mt=12),
                 p("Add slowly. Give each routine a full mandala before you start the next.", size=14, color=MUTED, mt=12) +
                 f'\n<div style="margin-top: auto; padding-top: 12px; border-top: 1px solid {LINE}; display: flex; justify-content: center; gap: 8px">'
                 f'<a href="#" style="display: flex; align-items: center; gap: 8px; min-height: 44px; padding: 0 8px; white-space: nowrap; color: {INK}; font-size: 14.5px; font-weight: 500; text-decoration: none">{icon("heart", 18, DEEP)}Share Yogi Focus</a>'
                 f'<a href="#" style="display: flex; align-items: center; gap: 8px; min-height: 44px; padding: 0 8px; white-space: nowrap; color: {INK}; font-size: 14.5px; font-weight: 500; text-decoration: none">{icon("lotus", 18, DEEP)}Rate Yogi Focus</a></div>')
assert rr2 != rr
V["V2-Routines.dc.html"] = rr2.replace('href="Routine-Edit.dc.html"', 'href="V2-Settings.dc.html"').replace('href="Today.dc.html"', 'href="V2-Today.dc.html"'); SIZES["V2-Routines"] = (390, 844)

# Rating: Apple's own prompt, once, on the mandala screen on day 30. Never after a miss or Not today.
stars = "".join(f'<svg aria-hidden="true" viewBox="0 0 24 24" width="30" height="30" style="display: block"><path d="M12 3l2.7 5.6 6.1.9-4.4 4.3 1 6.1L12 17l-5.4 2.9 1-6.1L3.2 9.5l6.1-.9z" fill="none" stroke="#0A84FF" stroke-width="1.6" stroke-linejoin="round"></path></svg>' for _ in range(5))
md = BASE["Mandala.dc.html"]
rate_overlay = (f'<div aria-hidden="true" style="position: absolute; inset: 0; background: rgba(10,25,14,0.42)"></div>'
                f'<div role="dialog" aria-label="Apple\'s rating prompt" style="position: absolute; left: 50%; top: 290px; transform: translateX(-50%); width: 270px; border-radius: 14px; background: rgba(242,242,247,0.97); color: #000000; font-family: -apple-system, system-ui, sans-serif; text-align: center; overflow: hidden">'
                f'<div style="padding: 18px 16px 12px; display: flex; flex-direction: column; align-items: center; gap: 4px"><div style="width: 56px; height: 56px; border-radius: 13px; overflow: hidden; background: {CREAM}; display: grid; place-items: center">{lotus_svg(48, "", opened=48).replace(" aria-label=\"\"", "")}</div>'
                f'<span style="margin-top: 6px; font-size: 17px; font-weight: 600">Enjoying Yogi Focus?</span><span style="font-size: 13px; line-height: 1.35">Tap a star to rate it on the App Store.</span>'
                f'<div style="margin-top: 8px; display: flex; gap: 6px">{stars}</div></div>'
                f'<div style="border-top: 1px solid rgba(60,60,67,0.29); min-height: 44px; display: flex; align-items: center; justify-content: center; font-size: 17px; color: #0A84FF">Not Now</div></div>')
idx = md.rfind("</div>\n</x-dc>")
assert idx > 0
inner_start = md.index('<div style="width: 390px; height: 844px;')
md2 = md[:inner_start] + '<div style="position: relative; width: 390px; height: 844px; overflow: hidden">' + md[inner_start:idx] + "</div>" + rate_overlay + "</div>" + md[idx + len("</div>"):]
V["V2-Rating.dc.html"] = md2; SIZES["V2-Rating"] = (390, 844)

# Practice time: quiet distracting apps (Screen Time), plus the Do Not Disturb shortcut
appchip = lambda t, c: f'<span style="display: flex; align-items: center; gap: 8px; min-height: 36px; padding: 0 12px 0 6px; border-radius: 18px; background: {SOFT}; font-size: 14.5px; font-weight: 500"><span style="width: 24px; height: 24px; border-radius: 6px; background: {c}"></span>{t}</span>'
add("V2-Quiet-Apps", "Keep practice time clear", phone(f"""{topbar("V2-Settings.dc.html")}
<div style="margin-top: 6px; font-size: 14px; font-weight: 600; color: {MUTED}">Meditate</div>
{h1("Keep practice time clear", size=32, mt=0)}
{p("From five minutes before until your ten minutes are up.", mt=6, size=15.5, color=MUTED)}
<div style="margin-top: 16px; padding: 16px 18px; border-radius: 22px; border: 1px solid {LINE}; background: {PAPER}; display: flex; flex-direction: column; gap: 10px">
<div style="display: flex; align-items: center; gap: 10px">{two_line("Quiet distracting apps", "6:55 to 7:10 am, every day", "qa")}{sw(True, "qa")}</div>
<div style="display: flex; flex-wrap: wrap; gap: 6px">{appchip("Instagram", "#E1306C")}{appchip("TikTok", "#111111")}{appchip("YouTube", "#FF0000")}{appchip("News", "#FA3D50")}</div>
<a href="#" style="align-self: flex-start; display: flex; align-items: center; min-height: 40px; font-size: 15px; font-weight: 600; text-decoration: none">Choose apps</a></div>
<div style="margin-top: 12px; padding: 16px 18px; border-radius: 22px; border: 1px solid {LINE}; background: {PAPER}; display: flex; flex-direction: column; gap: 8px">
{two_line("Do Not Disturb with one tap", "Your iPhone asks you to add a ready-made shortcut. It turns Do Not Disturb on at 6:55 am and off at 7:10 am.")}
<a href="#" style="align-self: flex-start; display: flex; align-items: center; justify-content: center; min-height: 44px; padding: 0 18px; border-radius: 22px; background: {SOFT}; color: {DEEP}; font-size: 15px; font-weight: 600; text-decoration: none">Add the shortcut</a></div>
{p("If you change the hour or length, you'll see a reminder here to update the shortcut.", size=13.5, color=MUTED, mt=10)}
{cta("Done", "V2-Settings.dc.html")}"""))

# The shield people see if they open a quieted app during practice time
add("V2-Shield", "It's practice time", f'''<div style="position: relative; width: 390px; height: 844px; box-sizing: border-box; padding: 0 32px 40px; display: flex; flex-direction: column; align-items: center; background: {HERO_Y}; color: {INK}; font-family: {FB}; text-align: center; overflow: hidden">
<div style="margin-top: 210px; width: 96px; height: 96px; border-radius: 22px; overflow: hidden; background: {CREAM}; display: grid; place-items: center">{lotus_svg(84, "", opened=48).replace(' aria-label=""', "")}</div>
<div style="margin-top: 24px; font-family: {FH}; font-weight: 700; font-size: 34px; line-height: 1.1">It's practice time.</div>
<div style="margin-top: 10px; font-size: 17px; line-height: 1.5">Meditate on the balcony. This app opens again at 7:10 am.</div>
<button type="button" style="margin-top: auto; width: 100%; min-height: 56px; border-radius: 28px; border: none; background: {HBTN["bg"]}; color: {HBTN["color"]}; font-size: 17px; font-weight: 600">Go to Yogi Focus</button>
<button type="button" style="margin-top: 8px; min-height: 44px; border: none; background: transparent; color: {INK}; font-size: 15px; font-weight: 500">Close</button></div>''')


# =====================================================================
# 6 iPhone Duo, v2: outer display (466 x 678) and the open inner display, wide (951 x 669)
# =====================================================================
def ring_svg(size, two=False):
    return (f'<svg role="img" aria-label="7:42 left of 10 minutes" viewBox="0 0 300 300" width="{size}" height="{size}" style="display: block; flex: none">'
            f'<circle cx="150" cy="150" r="132" fill="{SOFT}" style="animation: yf-glow 6s ease-in-out infinite"></circle>'
            f'<circle cx="150" cy="150" r="132" fill="none" stroke="{LINE}" stroke-width="12"></circle>'
            f'<circle cx="150" cy="150" r="132" fill="none" stroke="{TEALM}" stroke-width="12" stroke-linecap="round" stroke-dasharray="829" transform="rotate(-90 150 150)" '
            f'style="animation: yf-timer 40s linear -9.2s infinite"></circle>'
            f'<g transform="translate(62 46) scale(0.88)">{yogi_body(mat=False)}</g></svg>')
def pair(a_label, a_href, b_label, b_href, h=50):
    return (f'<div style="display: flex; gap: 8px"><a href="{a_href}" style="flex: 1; display: flex; align-items: center; justify-content: center; min-height: {h}px; border-radius: {h//2}px; border: 1.5px solid {DEEP}; color: {DEEP}; font-size: 15.5px; font-weight: 600; text-decoration: none">{a_label}</a>'
            f'<a href="{b_href}" style="flex: 1; display: flex; align-items: center; justify-content: center; min-height: {h}px; border-radius: {h//2}px; border: 1.5px solid {LINE}; color: {INK}; font-size: 15.5px; font-weight: 600; text-decoration: none">{b_label}</a></div>')
DUO_V2 = []
def keep_duo(name):
    V[name + ".dc.html"] = pages[name + ".dc.html"]; SIZES[name] = DUO_SIZES[name]; DUO_V2.append(name)
ROW3 = [("clock", "7:00 am, for 10 minutes"), ("pin", "The balcony"), ("bag", "Yoga mat, grey shawl")]

outer("Duo-V2-Outer-Today.dc.html", "Today v2, outer display", f"""<div style="font-size: 14px; font-weight: 500; color: {MUTED}">{DATE}</div>
{h1("A new day.", size=36, mt=0)}
{p("How will you keep your practice today?", mt=2, size=16)}
<div style="margin-top: 12px">{card_routine("Meditate", "In 20 minutes", ROW3)}</div>
{p("This first week, stop at ten minutes, even if you would like more.", size=14, color=MUTED, mt=10)}
<div style="margin-top: auto; display: flex; flex-direction: column; gap: 8px">{btn("Start, 10 minutes", "Duo-V2-Outer-Timer.dc.html")}{pair("Just two minutes", "#", "Not today", "Duo-V2-Outer-Not-Today.dc.html")}</div>""",
      items=(sbtn("plan", "Your routines", "V2-Routines.dc.html"),))
keep_duo("Duo-V2-Outer-Today")

outer("Duo-V2-Outer-Timer.dc.html", "The practice timer, outer display", f"""<div style="display: flex; align-items: center; justify-content: space-between; min-height: 30px"><span style="font-size: 15px; font-weight: 600; color: {DEEP}">Meditate · the balcony</span></div>
<div style="margin-top: 8px; align-self: center">{ring_svg(268)}</div>
<div style="margin-top: 10px; text-align: center; font-family: {FH}; font-weight: 700; font-size: 56px; line-height: 1; font-variant-numeric: tabular-nums">7:42</div>
<div style="margin-top: 4px; text-align: center; font-size: 14.5px; color: {MUTED}">of 10 minutes · chime at the end</div>
<div style="margin-top: auto; display: flex; flex-direction: column; align-items: center"><a href="Duo-Outer-Kept.dc.html" style="display: flex; align-items: center; justify-content: center; min-height: 48px; padding: 0 26px; border-radius: 24px; border: 1.5px solid {LINE}; color: {INK}; font-size: 15.5px; font-weight: 600; text-decoration: none">Finish now</a>
<span style="margin-top: 6px; font-size: 13px; color: {MUTED}">Finishing early still counts as kept.</span></div>""",
      items=(back("Duo-V2-Outer-Today.dc.html"),), css=CSS_TIMER)
keep_duo("Duo-V2-Outer-Timer")

outer("Duo-V2-Outer-Not-Today.dc.html", "Not today, outer display", f"""<div style="margin-top: 6px; align-self: center; display: grid; place-items: center">
<svg aria-hidden="true" viewBox="-150 -150 300 300" width="210" height="210" style="grid-area: 1 / 1; display: block; opacity: 0.55">{lotus_body(opened=48, open_cols=(SOFT, SOFT, SOFT), center=SOFT)}</svg>
<div style="grid-area: 1 / 1; padding-top: 34px; animation: yf-float 6s ease-in-out infinite">{yogi(160)}</div></div>
{h1("That's all right.", size=34, mt=8)}
{p("Tomorrow is a new day.", mt=2, size=19, extra="; font-family: " + FH + "; font-weight: 600")}
<div style="margin-top: 12px; padding: 14px 18px; border-radius: 20px; background: {CREAM}; color: {ONACC}; display: flex; flex-direction: column">
<span style="font-size: 13px; font-weight: 600">Tomorrow</span><span style="font-family: {FH}; font-weight: 700; font-size: 23px; line-height: 1.15">7:00 am, the balcony</span></div>
{p("No more reminders today.", size=14, color=MUTED, mt=10)}
<div style="margin-top: auto">{btn("Done", "Duo-V2-Outer-Today.dc.html")}</div>""")
keep_duo("Duo-V2-Outer-Not-Today")

wide("Duo-V2-Wide-Today.dc.html", "Today v2, inner display wide",
     f"""<div style="margin-top: auto; font-size: 14px; font-weight: 500; color: {MUTED}">{DATE}</div>
{h1("A new day.", size=42, mt=0)}
{p("How will you keep your practice today?", mt=4, size=17)}
<div style="margin-top: 18px">{card_routine("Meditate", "In 20 minutes", ROW3)}</div>
<div style="margin-bottom: auto">{p("This first week, stop at ten minutes, even if you would like more.", size=14, color=MUTED, mt=12)}</div>""",
     f"""<div style="margin-top: auto; padding: 18px 22px; border-radius: 22px; background: {CREAM}; color: {ONACC}; display: flex; flex-direction: column; gap: 4px"><span style="font-size: 13px; font-weight: 600">On a harder day</span><span style="font-family: {FH}; font-weight: 600; font-size: 20px; line-height: 1.3">Sit on the mat for two minutes. It still keeps the day.</span></div>
<div style="margin-top: 22px; display: flex; flex-direction: column; gap: 10px">{btn("Start, 10 minutes", "Duo-V2-Wide-Timer.dc.html")}{pair("Just two minutes", "#", "Not today", "Duo-V2-Outer-Not-Today.dc.html", h=52)}</div>
<a href="#" style="margin-top: 8px; margin-bottom: auto; align-self: center; display: flex; align-items: center; gap: 8px; min-height: 44px; font-size: 15px; font-weight: 500">{icon("check", 18, DEEP, 2.4)}Already practised? Mark it kept</a>""",
     items=(sbtn("plan", "Your routines", "V2-Routines.dc.html"),))
keep_duo("Duo-V2-Wide-Today")

wide("Duo-V2-Wide-Timer.dc.html", "The practice timer, inner display wide",
     f'<div style="flex: 1; display: flex; align-items: center; justify-content: center">{ring_svg(370)}</div>',
     f"""<div style="margin-top: auto; font-size: 15px; font-weight: 600; color: {DEEP}">Meditate · the balcony</div>
<div style="margin-top: 6px; font-family: {FH}; font-weight: 700; font-size: 96px; line-height: 1; font-variant-numeric: tabular-nums">7:42</div>
<div style="margin-top: 6px; font-size: 16px; color: {MUTED}">of 10 minutes</div>
{p("Sit, breathe and let the timer keep the time. A soft chime marks the end.", mt=18, size=17)}
<div style="margin-top: 26px; margin-bottom: auto; display: flex; align-items: center; gap: 14px"><a href="Duo-Wide-Kept.dc.html" style="display: flex; align-items: center; justify-content: center; min-height: 50px; padding: 0 26px; border-radius: 25px; border: 1.5px solid {LINE}; color: {INK}; font-size: 15.5px; font-weight: 600; text-decoration: none">Finish now</a><span style="font-size: 13.5px; color: {MUTED}; max-width: 170px; line-height: 1.35">Finishing early still counts as kept.</span></div>""",
     items=(back("Duo-V2-Wide-Today.dc.html"),), css=CSS_TIMER)
keep_duo("Duo-V2-Wide-Timer")

wide("Duo-V2-Wide-Share.dc.html", "Share your mandala, inner display wide",
     f'<div style="flex: 1; display: flex; align-items: center; justify-content: center">{thumb(k=0.62)}</div>',
     f"""<div style="margin-top: auto">{h1("Share your mandala", size=38, mt=0)}</div>
{p("A short video of your lotus opening, made right here on your phone. Nothing is sent anywhere until you choose where it goes.", mt=8, size=16)}
{share_seg()}
<div style="margin-top: 22px; margin-bottom: auto; display: flex; flex-direction: column; gap: 8px">
{btn("Instagram Stories", "#")}
<div style="display: flex; gap: 8px">
<a href="#" style="flex: 1; display: flex; align-items: center; justify-content: center; min-height: 50px; border-radius: 25px; border: 1.5px solid {DEEP}; color: {DEEP}; font-size: 15.5px; font-weight: 600; text-decoration: none">Save video</a>
<a href="#" style="flex: 1; display: flex; align-items: center; justify-content: center; min-height: 50px; border-radius: 25px; border: 1.5px solid {DEEP}; color: {DEEP}; font-size: 15.5px; font-weight: 600; text-decoration: none">More</a></div></div>""",
     items=(back("Duo-Wide-Complete.dc.html"),))
keep_duo("Duo-V2-Wide-Share")

# =====================================================================
# layout and write
# =====================================================================
V2_ROWS = [
 ("15 · v2.0 · The plan, in build order", ["V2-Plan"]),
 ("16 · v2.0 · Restart, Not today, two minutes (items 1, 2, 10)", ["V2-Settings", "V2-Restart", "V2-Mandala", "V2-Today", "V2-Not-Today", "V2-Setup-Two"]),
 ("17 · v2.0 · Straight into the practice; ask less; no trace (items 24, 25, 26)", ["V2-Timer", "V2-Timer-Two", "V2-Kept-Two", "V2-Kept", "V2-Flow"]),
 ("18 · v2.0 · Reminders that learn and fade; a gentle alarm (items 9, 18, 22)", ["V2-Reminders", "V2-Nudges-Fade", "V2-Alarm"]),
 ("19 · v2.0 · Siri, Live Activity, widgets and watch (items 14, 4, 2)", ["V2-Siri", "V2-Live-Activity", "V2-Widgets", "V2-Watch"]),
 ("20 · v2.0 · Sharing, rating and practice time (items 6, 32, 29, 3)", ["V2-Complete-Share", "V2-Share-Image", "V2-Routines", "V2-Rating", "V2-Quiet-Apps", "V2-Shield", "V2-Share-Making", "V2-Share-Video"]),
]
V2_DUO_ROW = ("23 · v2.0 · iPhone Duo: outer display and open wide", ["Duo-V2-Outer-Today", "Duo-V2-Outer-Timer", "Duo-V2-Outer-Not-Today", "Duo-V2-Wide-Today", "Duo-V2-Wide-Timer", "Duo-V2-Wide-Share"])
PHONES = [n for _, names in V2_ROWS for n in names if SIZES[n][0] == 390]
V2_DARK_ROWS = [("21 · v2.0 · Dark appearance", PHONES[:9]), ("22 · v2.0 · Dark appearance, continued", PHONES[9:])]
TITLES = {"V2-Plan": "v2.0 · The plan, in build order", "V2-Settings": "Routine settings, v2 · full scroll", "V2-Restart": "Begin this routine again",
          "V2-Mandala": "Mandala, after day 30 · begin a fresh mandala", "V2-Today": "Today, v2 · Start, two minutes, Not today", "V2-Not-Today": "Not today · the reply",
          "V2-Setup-Two": "Setup · the two-minute version", "V2-Timer": "The practice timer", "V2-Timer-Two": "The two-minute timer", "V2-Kept-Two": "Kept, after two minutes",
          "V2-Kept": "Kept, straight after the timer", "V2-Flow": "From the nudge to kept", "V2-Reminders": "Reminders that follow and fade",
          "V2-Nudges-Fade": "You don't need my reminder any more", "V2-Alarm": "A gentle alarm (AlarmKit)", "V2-Siri": "Siri, Shortcuts, Action button",
          "V2-Live-Activity": "Dynamic Island and Live Activity", "V2-Widgets": "Widgets and notification with Not today", "V2-Watch": "Apple Watch, v2",
          "V2-Complete-Share": "Mandala complete, with sharing", "V2-Share-Image": "The shared mandala image", "V2-Routines": "Your routines · Share and Rate",
          "V2-Rating": "Rating prompt, day 30 only", "V2-Quiet-Apps": "Keep practice time clear", "V2-Shield": "Quieted app · It's practice time", "V2-Share-Making": "Share · making the video on the phone", "V2-Share-Video": "Share · the video, ready",
          "Duo-V2-Outer-Today": "iPhone Duo · Today, v2", "Duo-V2-Outer-Timer": "iPhone Duo · The practice timer", "Duo-V2-Outer-Not-Today": "iPhone Duo · Not today",
          "Duo-V2-Wide-Today": "iPhone Duo · Today, v2", "Duo-V2-Wide-Timer": "iPhone Duo · The practice timer", "Duo-V2-Wide-Share": "iPhone Duo · Share your mandala"}

def layout(y0=17896, gap=80):
    boards, notes, y = {}, {}, y0
    ALL = V2_ROWS + V2_DARK_ROWS + [V2_DUO_ROW, ("24 · v2.0 · iPhone Duo, dark appearance", V2_DUO_ROW[1])]
    for ri, (rt, names) in enumerate(ALL):
        x, hmax = 0, 0
        dark = len(V2_ROWS) <= ri < len(V2_ROWS) + len(V2_DARK_ROWS) or ri == len(ALL) - 1
        for n in names:
            w, h = SIZES[n]
            nm = n + ("-Dark" if dark else "")
            b = {"x": x, "y": y, "w": w, "h": h, "title": TITLES[n] + (" · dark" if dark else ""), "radius": 44 if w == 390 and n != "V2-Settings" else (44 if n == "V2-Settings" else 28)}
            if n.startswith("Duo-V2"):
                b["radius"] = 30
                if n in DUO_GUIDES: b["guides"] = DUO_GUIDES[n]
            boards[nm + ".dc.html"] = b; x += w + gap; hmax = max(hmax, h)
        notes[f"row{15 + ri}"] = {"x": 0, "y": y - 300, "text": rt, "kind": "title1", "maxW": x - gap, "w": 240}
        y += hmax + 420
    return boards, notes

OUTV = os.path.join(HERE, "v2out", "project")
os.makedirs(OUTV, exist_ok=True)
def check(name, src):
    assert 'aria-label=""' not in src, name
    b = Bal(); b.feed(src); assert not b.st, (name, b.st)
    assert "[[" not in src and "—" not in src, name
from html.parser import HTMLParser
VOID = {"meta", "link", "br", "input", "img", "hr"}
class Bal(HTMLParser):
    def __init__(s): super().__init__(); s.st = []
    def handle_starttag(s, t, a):
        if t not in VOID: s.st.append(t)
    def handle_endtag(s, t):
        assert s.st and s.st[-1] == t, f"unbalanced </{t}> stack={s.st[-4:]}"
        s.st.pop()
for n in SIZES: assert n + ".dc.html" in V, n
for n in V: V[n] = V[n].replace('role="img" aria-label=""', 'aria-hidden="true"').replace('role="img" viewBox', 'aria-hidden="true" viewBox')
if DARK:
    for n in PHONES + DUO_V2:
        src = V[n + ".dc.html"]
        for m in PHONES + DUO_V2: src = src.replace(f'href="{m}.dc.html"', f'href="{m}-Dark.dc.html"')
        check(n, src); open(os.path.join(OUTV, n + "-Dark.dc.html"), "w", encoding="utf-8").write(src)
    print(len(PHONES) + len(DUO_V2), "dark v2 boards")
else:
    for name, src in V.items():
        check(name, src); open(os.path.join(OUTV, name), "w", encoding="utf-8").write(src)
    boards, notes = layout()
    json.dump({"boards": boards, "notes": notes, "order": list(boards)}, open(os.path.join(HERE, "v2out", "layout.json"), "w"), indent=1)
    print(len(V), "v2 boards; layout rows", len(notes))
