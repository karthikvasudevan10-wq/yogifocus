import runpy, os, re, sys
HERE = os.path.dirname(os.path.abspath(__file__))
G = runpy.run_path(os.path.join(HERE, "gen.py"))
sys.path.insert(0, HERE)
from art import *
g = lambda k: G[k]
FH, FB = G["FH"], G["FB"]
w_small, lotus_svg, icon = G["w_small"], G["lotus_svg"], G["icon"]
SOFTY = G["SOFTY"]

def fluid(svg):  # let an illustration fill its column
    svg = re.sub(r' width="\d+" height="\d+" style="display: block; margin-top: \d+px; flex: none[^"]*"', ' style="display: block; width: 100%; height: auto"', svg, count=1)
    return svg
sun, same, journey = fluid(g("sun")), fluid(g("same")), fluid(g("journey"))
scene = g("welcome_scene")()
widgets = "".join(f'<div class="w">{x}</div>' for x in [
    w_small("Today", "7:00 am", "The balcony"),
    w_small("It's time", "Your mat is waiting.", bg=CREAM, dot=SAFF, done=True),
    w_small("Kept today", "See you tomorrow", "7:00 am", bg=SOFT, check=True)])
watches = "".join(f'<div class="w">{g(k)}</div>' for k in ("w_time", "w_ask", "w_kept"))
lot = lotus_svg(300, "A lotus on day 37 of 48: 34 green petals for days practised and 3 red petals for days missed", **G["SAMPLE"]).replace('width="300" height="300" style="display: block; grid-area: 1 / 1"', 'style="display: block; width: 100%; height: auto"')
feel = lambda ic, t: f'<span class="feel"><span class="fi">{icon(ic, 20)}</span>{t}</span>'
css_anim = g("KEYFRAMES") + g("CSS_TODAY") + g("CSS_SAME") + g("CSS_MANDALA") + g("CSS_WELCOME")

html = f'''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Yogi Focus</title>
<meta name="description" content="Yogi Focus helps you keep one small routine, one day at a time. Free for everyone, on iPhone, iPhone Duo and Apple Watch.">
<link href="https://fonts.googleapis.com/css2?family=Baloo+2:wght@500;600;700;800&amp;family=Inter:wght@400;500;600&amp;display=swap" rel="stylesheet">
<style>
:root {{
  /* Layout idea: one sunny hero with the floating yogi, then calm white sections that each show one thing, closed by a dark green verse and a sunny call to begin. */
  --yellow: {CREAM}; --green: {TEAL}; --deep: {DEEP}; --ink: {INK}; --muted: {MUTED}; --ground: {GROUND}; --soft: {SOFT}; --saffron: {SAFF}; --line: {LINE}; --paper: #FFFFFF;
  --display: 'Baloo 2', 'Trebuchet MS', system-ui, sans-serif; --body: Inter, system-ui, -apple-system, sans-serif;
  color-scheme: light;
}}
* {{ box-sizing: border-box; }}
html {{ scroll-behavior: smooth; }}
body {{ margin: 0; background: var(--ground); color: var(--ink); font-family: var(--body); font-size: 17px; line-height: 1.6; overflow-x: clip; }}
h1, h2, h3 {{ font-family: var(--display); line-height: 1.08; margin: 0; text-wrap: balance; }}
h1 {{ font-size: clamp(36px, 6.4vw, 76px); font-weight: 800; letter-spacing: -0.01em; }}
h2 {{ font-size: clamp(32px, 4.4vw, 50px); font-weight: 700; }}
h3 {{ font-size: 25px; font-weight: 700; }}
p {{ margin: 0; text-wrap: pretty; }}
a {{ color: var(--deep); }}
a:focus-visible, button:focus-visible {{ outline: 3px solid var(--ink); outline-offset: 3px; }}
.wrap {{ width: min(1120px, 100% - 40px); margin-inline: auto; }}
.lead {{ font-size: clamp(18px, 2vw, 21px); max-width: 34em; }}
.muted {{ color: var(--muted); }}
.btn {{ display: inline-flex; align-items: center; justify-content: center; min-height: 58px; padding: 0 30px; border-radius: 29px; background: var(--ink); color: #FFFFFF; font-weight: 600; font-size: 18px; text-decoration: none; }}
.btn:hover {{ background: #0B2014; }}
.btn.green {{ background: var(--green); color: var(--ink); }}
.btn.green:hover {{ background: #63C431; }}
header {{ background: var(--yellow); overflow: hidden; }}
nav {{ display: flex; align-items: center; justify-content: space-between; gap: 16px; padding: 18px 0; }}
.brand {{ font-family: var(--display); font-weight: 800; font-size: 28px; color: var(--deep); text-decoration: none; }}
nav .btn {{ min-height: 46px; padding: 0 22px; font-size: 16px; }}
.hero {{ display: flex; flex-direction: column; align-items: center; gap: 4px; padding: 0 0 56px; text-align: center; }}
.hero .copy {{ display: flex; flex-direction: column; gap: 22px; align-items: center; max-width: 760px; }}
.hero .lead {{ margin-inline: auto; }}
.hero small {{ font-size: 15px; font-weight: 500; }}
.scene-wrap {{ --k: 1.12; position: relative; width: calc(390px * var(--k)); height: calc(470px * var(--k)); justify-self: center; max-width: 100%; }}
.scene {{ position: absolute; left: 0; top: 0; width: 390px; height: 470px; transform: scale(var(--k)); transform-origin: 0 0; }}
section {{ padding: clamp(56px, 8vw, 104px) 0; }}
.stack {{ display: flex; flex-direction: column; gap: 18px; }}
.for {{ display: grid; grid-template-columns: minmax(0, 1fr) minmax(0, 1fr); gap: clamp(24px, 5vw, 64px); align-items: center; }}
.nos {{ display: flex; flex-wrap: wrap; gap: 10px; list-style: none; margin: 0; padding: 0; }}
.nos li {{ padding: 10px 18px; border-radius: 24px; background: var(--soft); font-weight: 600; }}
.ideas {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(min(290px, 100%), 1fr)); gap: 22px; margin-top: 36px; }}
.idea {{ display: flex; flex-direction: column; gap: 14px; padding: 18px 18px 24px; border-radius: 30px; background: var(--paper); border: 1px solid var(--line); }}
.idea .n {{ font-family: var(--display); font-weight: 700; color: var(--deep); font-size: 17px; }}
.band {{ background: var(--soft); }}
.two {{ display: grid; grid-template-columns: minmax(0, 1fr) minmax(0, 1fr); gap: clamp(28px, 6vw, 72px); align-items: center; }}
.graph {{ padding: 14px; border-radius: 34px; background: var(--paper); }}
.paths {{ display: flex; flex-direction: column; gap: 16px; margin-top: 8px; }}
.path {{ display: flex; gap: 14px; align-items: flex-start; }}
.path svg {{ flex: none; margin-top: 9px; }}
.path b {{ display: block; font-size: 18px; }}
.feature {{ display: grid; grid-template-columns: minmax(0, 1fr) minmax(0, 1.1fr); gap: clamp(28px, 6vw, 72px); align-items: center; padding: clamp(28px, 4vw, 48px) 0; }}
.feature.flip .text {{ order: 2; }}
.shots {{ display: flex; flex-wrap: wrap; gap: 16px; justify-content: center; padding: 26px 18px; border-radius: 34px; background: var(--green); }}
.shots.yellow {{ background: var(--yellow); }}
.shots .w {{ flex: none; }}
.lotus {{ max-width: 340px; margin-inline: auto; width: 100%; }}
.key {{ display: flex; flex-wrap: wrap; gap: 18px; justify-content: center; margin-top: 14px; font-size: 14.5px; font-weight: 500; }}
.key span {{ display: inline-flex; align-items: center; gap: 7px; }}
.key i {{ width: 12px; height: 12px; border-radius: 6px; display: inline-block; }}
.feels {{ display: flex; flex-direction: column; gap: 10px; padding: 26px; border-radius: 34px; background: var(--paper); border: 1px solid var(--line); }}
.feel {{ display: flex; align-items: center; gap: 12px; min-height: 60px; padding: 0 16px; border-radius: 20px; border: 2px solid var(--line); font-weight: 600; }}
.feel.on {{ border-color: var(--deep); background: var(--soft); }}
.fi {{ width: 40px; height: 40px; border-radius: 20px; background: var(--yellow); display: inline-flex; align-items: center; justify-content: center; flex: none; }}
.reply {{ margin-top: 4px; padding: 16px 20px; border-radius: 20px; background: var(--yellow); font-family: var(--display); font-weight: 600; font-size: 20px; line-height: 1.3; }}
.verse {{ background: var(--ink); color: #EEF5E8; text-align: center; }}
.verse .sa {{ font-family: var(--display); font-weight: 600; font-size: clamp(22px, 3.4vw, 34px); line-height: 1.4; color: var(--yellow); overflow-wrap: anywhere; }}
.verse .tr {{ font-style: italic; font-size: 17px; margin-top: 8px; }}
.verse .en {{ font-family: var(--display); font-weight: 600; font-size: clamp(22px, 3vw, 30px); line-height: 1.3; max-width: 22em; margin: 26px auto 0; text-wrap: balance; }}
.verse .src {{ margin-top: 12px; font-size: 14.5px; font-weight: 600; color: #A9B8A5; }}
.cta {{ background: var(--yellow); text-align: center; }}
.faq {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(min(420px, 100%), 1fr)); gap: 18px; margin-top: 32px; }}
.qa {{ display: flex; flex-direction: column; gap: 10px; padding: 24px 26px; border-radius: 26px; background: var(--paper); border: 1px solid var(--line); }}
.qa h3 {{ font-size: 21px; }}
.qa p {{ color: var(--muted); }}
.qa i {{ font-style: normal; font-weight: 600; color: var(--ink); }}
.cta .stack {{ align-items: center; }}
footer {{ padding: 28px 0 40px; font-size: 14.5px; color: var(--muted); }}
footer .wrap {{ display: flex; flex-wrap: wrap; gap: 8px 24px; justify-content: space-between; }}
@media (max-width: 900px) {{
  .hero, .for, .two, .feature {{ grid-template-columns: minmax(0, 1fr); }}
  .feature.flip .text {{ order: 0; }}
  .scene-wrap {{ --k: 0.92; }}
}}
@media (max-width: 420px) {{ .scene-wrap {{ --k: 0.8; }} nav .btn {{ display: none; }} }}
{css_anim}
</style>
</head>
<body>
<header>
<div class="wrap">
<nav aria-label="Main"><a class="brand" href="#top">Yogi Focus</a><span style="display: flex; align-items: center; gap: 20px"><a href="#faq" style="color: var(--ink); font-weight: 600; text-decoration: none">Questions</a><a class="btn" href="#get">Get it free</a></span></nav>
<div class="hero" id="top">
<div class="scene-wrap"><div class="scene">{scene}</div></div>
<div class="copy">
<h1>One small routine.<br>One day at a time.</h1>
<p class="lead">Yogi Focus helps you keep a routine the way yogis have for centuries: at the same hour, in the same place, with a kind word where other apps keep score.</p>
<a class="btn" href="#get">Get it free</a>
<small>Free for everyone. For iPhone, iPhone Duo and Apple Watch.</small>
</div>

</div>
</div>
</header>
<main>
<section>
<div class="wrap for">
<div class="stack">
<h2>Made for minds that wander</h2>
<p class="lead">If you lose focus easily, find routines hard to keep, or have a drawer full of habits that never stuck, Yogi Focus was made with you in mind. It never asks for forever. It asks about today.</p>
</div>
<ul class="nos"><li>No streaks to break</li><li>No guilt</li><li>No sad mascot</li><li>No red badges</li><li>No nagging</li><li>Only encouragement</li></ul>
</div>
</section>
<section class="band">
<div class="wrap">
<div class="stack"><h2>Three ideas, borrowed from yogis</h2><p class="lead">In India, yogis use the same simple method to master any practice. Yogi Focus is built on it.</p></div>
<div class="ideas">
<article class="idea"><div>{sun}</div><span class="n">Idea one</span><h3>Only today</h3><p>“For the rest of your life” is too heavy to carry, so a yogi doesn't carry it. Each morning they ask one question: this is a new day, how will I keep my practice today?</p></article>
<article class="idea"><div>{same}</div><span class="n">Idea two</span><h3>Same time, same place, same things</h3><p>The exact hour, the exact spot, the same mat and the same clothes. When nothing around the routine changes, there is nothing to decide and nothing to remember.</p></article>
<article class="idea"><div class="lotus" style="max-width: 228px">{lotus_svg(228, "An open lotus of 48 petals", opened=48).replace('width="228" height="228" style="display: block; grid-area: 1 / 1"', 'style="display: block; width: 100%; height: auto"')}</div><span class="n">Idea three</span><h3>One mandala is 48 days</h3><p>Yogis hold that a practice kept for one mandala, 48 days, starts to show its real benefits and is likely to stay with you for life.</p></article>
</div>
</div>
</section>
<section>
<div class="wrap two">
<div class="graph" id="graph">{journey}</div>
<div class="stack">
<h2>How the 48 days tend to go</h2>
<p class="lead">Somewhere around day seven the novelty wears off. That stretch is the boring middle, and it is where most routines quietly end.</p>
<div class="paths">
<div class="path"><svg aria-hidden="true" viewBox="0 0 26 12" width="30" height="14"><path d="M2 6L24 6" stroke="#E8792B" stroke-width="4" stroke-linecap="round" stroke-dasharray="0.1 7.3" fill="none"></path></svg><p><b>Willpower alone</b>A burst of effort, a crash in the boring middle, and then interest quietly dies.</p></div>
<div class="path"><svg aria-hidden="true" viewBox="0 0 26 12" width="30" height="14"><path d="M2 6L24 6" stroke="{DEEP}" stroke-width="4.5" stroke-linecap="round" fill="none"></path></svg><p><b>With Yogi Focus</b>A gentle ten-minute start, a shallow dip, a nudge to just start, and by the end it runs on its own.</p></div>
</div>
</div>
</div>
</section>
<section class="band">
<div class="wrap">
<h2>How Yogi Focus helps</h2>
<div class="feature">
<div class="text stack"><h3>A widget that does the remembering</h3><p>It sits on your Home Screen and shows today's routine: the hour, the place and what to bring. At the hour it says “It's time”. Tap Done when you have practised.</p></div>
<div class="shots">{widgets}</div>
</div>
<div class="feature flip">
<div class="text stack"><h3>A gentle tap on your wrist</h3><p>Apple Watch nudges you twenty minutes before, and again at the hour. Afterwards it asks how it felt, and you can answer right there.</p></div>
<div class="shots yellow">{watches}</div>
</div>
<div class="feature">
<div class="text stack"><h3>One kind question</h3><p>After you practise, Yogi Focus asks how it felt. Scattered, steady or absorbed: every answer is a good one, and every answer earns a kind word.</p></div>
<div class="feels">{feel("scattered", "Scattered")}<span class="feel on"><span class="fi">{icon("steady", 20)}</span>Steady</span>{feel("absorbed", "Absorbed")}<div class="reply">Steady is exactly how a practice grows.</div></div>
</div>
<div class="feature flip">
<div class="text stack"><h3>A lotus that blooms with you</h3><p>Each day you practise opens a petal. Yogi Focus keeps the lotus out of sight for the first 30 days, so every day can simply be today. Then it shows you what you have grown.</p><p>Miss a day? Nothing resets. That petal turns red, and tomorrow is a new day.</p></div>
<div><div class="lotus">{lot}</div><div class="key"><span><i style="background: {TEALM}"></i>Practised</span><span><i style="background: {G["MISSED"]}"></i>Missed</span><span><i style="background: #EEF4E6; box-shadow: inset 0 0 0 1px #B9C7AC"></i>To come</span></div></div>
</div>
</div>
</section>
<section id="faq">
<div class="wrap">
<h2>Questions, answered gently</h2>
<div class="faq"><div class="qa"><h3>What if I miss a day, or don't practise on time?</h3><p>Nothing resets. If the hour slips by, Yogi Focus simply says <i>Still today: just start when you can</i>. If a whole day goes by, the next morning is a new day, with nothing to catch up.</p><p>After day 30, when your lotus appears, a missed day shows as a red petal and Yogi Focus tells you plainly how many days you missed. Your mandala still carries on to 48 days.</p></div><div class="qa"><h3>I travel a lot. How can Yogi Focus help me?</h3><p>Ten minutes fits into any day, wherever you are. Take your <i>same things</i> with you, such as your mat or your shawl: they bring the routine into a hotel room. Choose the spot that feels closest to your usual one.</p><p>If a journey moves your hour, just start when you can. If you miss a day, nothing resets. And if travel becomes your normal life, you can change the hour or the place in your routine's settings.</p></div><div class="qa"><h3>Why can I only start with one routine?</h3><p>One routine is something you can keep. Five is a plan that falls apart in the second week. When your first mandala of 48 days is complete, Yogi Focus will invite you to add another.</p></div><div class="qa"><h3>Why ten minutes?</h3><p>It is short enough to fit into any day and long enough to matter. In the first week Yogi Focus will even ask you to stop at ten minutes when you would like more, so you finish fresh and want to come back tomorrow.</p></div><div class="qa"><h3>Why can't I see my progress straight away?</h3><p>Counting days turns a calm practice into a score to protect. For the first 30 days Yogi Focus keeps the count out of sight, so every day can simply be today. Your petals are still opening; on day 30 you get to see them.</p></div><div class="qa"><h3>What is the boring middle?</h3><p>Somewhere around day seven the novelty wears off, and it often stays dull until about day 27. It is normal and it passes. In those weeks Yogi Focus has one message for you: just start.</p></div><div class="qa"><h3>Do I need an Apple Watch?</h3><p>No. The iPhone app and its Home Screen widget do everything. With an Apple Watch you also get a gentle tap before your routine and can say how it felt from your wrist.</p></div><div class="qa"><h3>Is it really free?</h3><p>Yes. Yogi Focus is free for everyone, always. There is no subscription and nothing to buy inside the app.</p></div></div>
</div>
</section>
<section class="verse">
<div class="wrap">
<p class="sa" lang="sa">स तु दीर्घकालनैरन्तर्यसत्कारासेवितो दृढभूमिः</p>
<p class="tr" lang="sa-Latn">sa tu dīrgha-kāla-nairantarya-satkārāsevito dṛḍha-bhūmiḥ</p>
<p class="en">Practice finds firm ground when it is tended for a long time, steadily and with care.</p>
<p class="src">Yoga Sūtra 1.14</p>
</div>
</section>
<section class="cta" id="get">
<div class="wrap stack">
<h2>Ten minutes a day is all it takes to begin</h2>
<p class="lead">Choose one small routine. Give it an hour, a place and its things. Yogi Focus will take it from there, one day at a time.</p>
<a class="btn" href="#get">Download on the App Store</a>
<p><b>Free for everyone, always.</b> iPhone, iPhone Duo and Apple Watch.</p>
<p class="muted" style="font-size: 14.5px">[APP STORE LINK TO ADD]</p>
</div>
</section>
</main>
<footer><div class="wrap"><span>Yogi Focus. One small routine, one day at a time.</span><span>[CONTACT AND PRIVACY LINKS TO ADD]</span></div></footer>
<script>
// Replay the 48-day graph once, when it first scrolls into view. Without this it has simply already played.
(function () {{
  var box = document.getElementById('graph');
  if (!box || !('IntersectionObserver' in window) || matchMedia('(prefers-reduced-motion: reduce)').matches) return;
  var io = new IntersectionObserver(function (entries) {{
    if (!entries[0].isIntersecting) return;
    io.disconnect();
    var svg = box.firstElementChild; box.replaceChild(svg.cloneNode(true), svg);
  }}, {{ threshold: 0.5 }});
  io.observe(box);
}})();
</script>
</body>
</html>
'''
assert "[[" not in html
open(os.path.join(HERE, "site", "index.html"), "w", encoding="utf-8").write(html)
print(len(html) // 1024, "KB")
