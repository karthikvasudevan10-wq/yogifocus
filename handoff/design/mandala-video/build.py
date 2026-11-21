# The shareable mandala clip: 1080 x 1920, every frame drawn from a time value t, no CSS animation.
import os, sys, json, random, math
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HERE))
from art import *
from art import RINGS, petal_path, ONACC

W, H = 1080, 1920
CX, CY, K = 540, 930, 3.0            # lotus centre and scale (lotus viewBox is -150..150)
BG_IN, BG_OUT = "#8FE356", "#3DBB45"
COLS = (WHITE, CREAMS, CREAM)         # inner, middle, outer ring, as on the mandala-complete screen
SEP = "#3DBB45"
FH = "'Baloo 2', sans-serif"; FB = "Inter, sans-serif"

petals = []
for k in (2, 1, 0):
    r, l, w, off = RINGS[k]
    for i in range(16):
        day = k * 16 + i + 1
        ang = i * 22.5 + off
        petals.append(f'<g transform="rotate({ang:g}) translate(0 {-r})"><path id="p{day}" d="{petal_path(l, w)}" fill="{COLS[k]}" stroke="{SEP}" stroke-width="1.6" '
                      f'style="transform-box: fill-box; transform-origin: 50% 100%; transform: scale(0); opacity: 0"></path></g>')
ghosts = []
for k in (2, 1, 0):
    r, l, w, off = RINGS[k]
    for i in range(16):
        ghosts.append(f'<path d="{petal_path(l, w)}" transform="rotate({i*22.5+off:g}) translate(0 {-r})" fill="rgba(255,255,255,0.16)" stroke="rgba(255,255,255,0.32)" stroke-width="1.2"></path>')

rnd = random.Random(49)
CONF = [dict(x=rnd.uniform(0, W), d=rnd.uniform(0, 1), v=rnd.uniform(260, 420), s=rnd.choice([22, 26, 30, 34]),
             sw=rnd.uniform(1.4, 2.6), a=rnd.uniform(20, 60), c=[WHITE, CREAM, CREAMS, SAFF, "#FFB3C7", WHITE][n % 6], r0=rnd.uniform(0, 360)) for n in range(46)]
conf = "".join(f'<span id="c{n}" style="position: absolute; left: 0; top: 0; width: {c["s"]}px; height: {c["s"]}px; border-radius: 0 100% 0 100%; background: {c["c"]}; opacity: 0"></span>' for n, c in enumerate(CONF))
BURST_C = [WHITE, CREAM, SAFF, WHITE, CREAMS, "#FF8FB1"] * 3
burst = "".join(f'<g transform="rotate({j*20})"><path id="b{j}" d="{petal_path(40, 15)}" fill="{BURST_C[j]}" style="opacity: 0"></path></g>' for j in range(18))

html = f'''<!doctype html><html><head><meta charset="utf-8"><style>
@font-face{{font-family:'Baloo 2';font-weight:600;src:url(file:///home/claude/yogi/scratch/package/files/baloo-2-latin-600-normal.woff2)}}
@font-face{{font-family:'Baloo 2';font-weight:700;src:url(file:///home/claude/yogi/scratch/package/files/baloo-2-latin-700-normal.woff2)}}
html,body{{margin:0;width:{W}px;height:{H}px;overflow:hidden;background:{BG_OUT}}}
.t{{position:absolute;left:0;right:0;text-align:center;color:{ONACC}}}
</style></head><body>
<div style="position:absolute;inset:0;background:radial-gradient(circle at {CX}px {CY}px, {BG_IN} 0%, {BG_OUT} 75%)"></div>
<div id="rays" style="position:absolute;left:{CX-1300}px;top:{CY-1300}px;width:2600px;height:2600px;border-radius:50%;background:repeating-conic-gradient(from -5.2deg, rgba(255,255,255,0.13) 0deg 10.4deg, transparent 10.4deg 22.5deg);opacity:0"></div>
<div id="glow" style="position:absolute;left:{CX-520}px;top:{CY-520}px;width:1040px;height:1040px;border-radius:50%;background:radial-gradient(circle, rgba(255,246,190,0.75) 0%, rgba(255,246,190,0) 65%);opacity:0"></div>
<div id="kick" class="t" style="top:178px;font:600 46px {FB};opacity:0">My 3rd mandala</div>
<div id="title" class="t" style="top:236px;font:700 168px/1 {FH};opacity:0">Meditate</div>
<svg width="{W}" height="{H}" viewBox="0 0 {W} {H}" style="position:absolute;left:0;top:0;overflow:visible">
<g transform="translate({CX} {CY}) scale({K})"><g id="lotus">{"".join(ghosts)}{"".join(petals)}<circle id="ctr" r="27" fill="{SAFF}" style="opacity:0"></circle></g></g>
<circle id="halo" cx="{CX}" cy="{CY}" r="200" fill="none" stroke="{WHITE}" stroke-width="16" style="opacity:0"></circle>
<g transform="translate({CX} {CY})">{burst}</g>
<ellipse id="shadow" cx="{CX}" cy="{CY+190}" rx="150" ry="26" fill="#0B3D1A" style="opacity:0"></ellipse>
<g id="yogi" style="opacity:0"><g transform="translate({CX-210} {CY-300}) scale(2.1)">{yogi_body(mat=False, joyful=True)}</g></g>
</svg>
<div id="conf" style="position:absolute;inset:0;overflow:hidden">{conf}</div>
<div id="count" class="t" style="top:1450px;font:700 150px/1 {FH};opacity:0">Day 1</div>
<div id="line" class="t" style="top:1620px;font:500 50px {FB};opacity:0">One day at a time.</div>
<div id="mark" style="position:absolute;left:0;right:0;top:1760px;display:flex;justify-content:center;align-items:center;gap:18px;color:{ONACC};font:600 42px {FB};opacity:0">
<span style="width:70px;height:70px;border-radius:16px;background:{CREAM};display:grid;place-items:center"><svg viewBox="-150 -150 300 300" width="58" height="58">{lotus_body(opened=48, sep=CREAM)}</svg></span>Yogi Focus</div>
<script>
const CONF={json.dumps(CONF)};
const cl=(x,a=0,b=1)=>Math.max(a,Math.min(b,x));
const ease=x=>1-Math.pow(1-cl(x),3);
const back=x=>{{x=cl(x);const c=1.9;return 1+(c+1)*Math.pow(x-1,3)+c*Math.pow(x-1,2);}};
const $=id=>document.getElementById(id);
const OPEN0=1.1, STEP=0.1, OPEN_DUR=0.5, FULL=OPEN0+47*STEP+OPEN_DUR;   // about 6.3 s
function render(t){{
  $('rays').style.opacity=ease((t-0.1)/1.2);
  $('rays').style.transform=`rotate(${{t*3}}deg)`;
  $('kick').style.opacity=ease((t-0.5)/0.6); $('kick').style.transform=`translateY(${{(1-ease((t-0.5)/0.6))*24}}px)`;
  $('title').style.opacity=ease((t-0.2)/0.7); $('title').style.transform=`translateY(${{(1-ease((t-0.2)/0.7))*40}}px)`;
  let day=0;
  for(let d=1;d<=48;d++){{
    const p=(t-(OPEN0+(d-1)*STEP))/OPEN_DUR, el=$('p'+d);
    el.style.opacity=cl(p*3); el.style.transform=`scale(${{p<=0?0:back(p)}})`;
    if(p>0) day=d;
  }}
  $('lotus').setAttribute('transform',`rotate(${{Math.max(0,t-FULL)*2.2}})`);
  $('ctr').style.opacity=ease((t-0.9)/0.5);
  const c=$('count');
  if(t<FULL+0.3){{ c.textContent= day? 'Day '+day : ''; c.style.opacity=day?1:0; c.style.transform='scale(1)'; }}
  else {{ const q=ease((t-FULL-0.3)/0.6); c.textContent='48 days'; c.style.opacity=q; c.style.transform=`scale(${{0.8+0.2*back((t-FULL-0.3)/0.6)}})`; }}
  if(t<FULL+0.3 && t>FULL) c.style.opacity=1-ease((t-FULL)/0.3);
  $('line').style.opacity=ease((t-FULL-1.0)/0.7);
  $('mark').style.opacity=ease((t-FULL-1.8)/0.7);
  // the yogi arrives once the lotus is full
  const y=(t-FULL+0.2)/0.9, yo=$('yogi');
  const lev=t>FULL? Math.sin((t-FULL)*2*Math.PI/4.5)*-14 : 0;
  yo.style.opacity=ease(y*1.6);
  yo.style.transform=`translateY(${{(1-ease(y))*160+lev}}px)`;
  $('shadow').style.opacity=0.22*ease(y)*(1+lev/40);
  $('glow').style.opacity=ease((t-FULL+0.3)/0.6)*(0.85+0.15*Math.sin(t*2));
  const h=(t-FULL-0.1)/1.4, ha=$('halo');
  ha.style.opacity=h>0&&h<1?0.9*(1-h):0; ha.setAttribute('r',200+h*420);
  for(let j=0;j<18;j++){{ const b=$('b'+j), q=(t-FULL-0.05-j*0.012)/1.6;
    if(q<=0||q>=1){{b.style.opacity=0;continue;}}
    b.style.opacity=q<0.15?q/0.15:1-ease((q-0.5)/0.5); b.setAttribute('transform',`translate(0 ${{-200-ease(q)*520}}) scale(${{0.5+ease(q)*0.9}})`); }}
  CONF.forEach((c,n)=>{{ const el=$('c'+n), s=t-(FULL+0.1)-c.d*1.2;
    if(s<0){{el.style.opacity=0;return;}}
    const yy=-60+((s*c.v)%(2060)), xx=c.x+Math.sin(s*c.sw*2)*c.a;
    el.style.opacity=1; el.style.transform=`translate(${{xx}}px, ${{yy}}px) rotate(${{c.r0+s*140}}deg)`; }});
}}
window.render=render; render(0);
</script></body></html>'''
open(os.path.join(HERE, "clip.html"), "w").write(html)
print("ok")
