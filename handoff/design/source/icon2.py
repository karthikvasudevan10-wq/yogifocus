import os, sys, math
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
from art import *
OUT = os.path.join(HERE, "icon2")
G1, G2, G3 = TEALD, TEALM, TEAL
def petal(cx, cy, ang, l, w, fill, stroke=None, sw=0):
    d = f"M0 0C{w} {-0.35*l:.1f} {w} {-0.75*l:.1f} 0 {-l}C{-w} {-0.75*l:.1f} {-w} {-0.35*l:.1f} 0 0Z"
    st = f' stroke="{stroke}" stroke-width="{sw}" stroke-linejoin="round"' if stroke else ""
    return f'<path d="{d}" transform="translate({cx} {cy}) rotate({ang})" fill="{fill}"{st}/>'
def svg(body, bg):
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024"><rect width="1024" height="1024" fill="{bg}"/>{body}</svg>'

# ---- A. Bold glyph: a simplified yogi, drawn with few big shapes, on a five-petal lotus
def glyph(bg=CREAM, robe=SAFF, skin=SKIN, hair=HAIR, legs=WHITE, k=1.0, face="calm"):
    L = "".join([petal(512, 800, a, l, w, c, bg, 14) for a, l, w, c in
                 [(-74, 380, 120, G3), (74, 380, 120, G3), (-38, 430, 140, G2), (38, 430, 140, G2), (0, 470, 150, G1)]])
    eye = (f'<path d="M444 338q24 22 48 0M532 338q24 22 48 0" stroke="{hair}" stroke-width="18" stroke-linecap="round" fill="none"/>' if face == "calm" else
           f'<circle cx="468" cy="338" r="17" fill="{hair}"/><circle cx="556" cy="338" r="17" fill="{hair}"/>')
    fig = (f'<ellipse cx="512" cy="760" rx="300" ry="78" fill="{legs}"/>'
           f'<path d="M372 760Q360 520 512 470Q664 520 652 760Z" fill="{robe}"/>'
           f'<path d="M440 500Q512 610 640 700" stroke="{ROBED}" stroke-width="22" stroke-linecap="round" fill="none"/>'
           f'<path d="M512 560L486 664L538 664Z" fill="{skin}" stroke="{skin}" stroke-width="22" stroke-linejoin="round"/>'
           f'<rect x="480" y="410" width="64" height="80" rx="24" fill="{SKIND}"/>'
           f'<circle cx="512" cy="340" r="118" fill="{skin}"/>'
           f'<path d="M394 340A118 118 0 0 1 630 340Q596 270 512 284Q428 270 394 340Z" fill="{hair}"/>'
           f'<circle cx="512" cy="196" r="56" fill="{hair}"/><rect x="474" y="232" width="76" height="20" rx="10" fill="{robe}"/>'
           f'{eye}<path d="M478 396q34 28 68 0" stroke="{hair}" stroke-width="18" stroke-linecap="round" fill="none"/>')
    body = f'<g transform="translate(512 540) scale({k}) translate(-512 -540)">{L}{fig}</g>'
    return svg(body, bg)

# ---- B. The full yogi, much bigger, in front of a simple lotus halo
def big(bg=CREAM, k=1.0):
    halo = "".join(petal(512, 600, i * 30, 330, 120, (G3 if i % 2 else G2), bg, 14) for i in range(12))
    y = f'<g transform="translate(512 560) scale({4.9 * k}) translate(-100 -112)">{yogi_body(mat=False, dhoti=WHITE, dhoti_shade="#E9DDB8")}</g>'
    return svg(f'<g transform="translate(512 512) scale({k}) translate(-512 -512)">{halo}</g>{y}', bg)

# ---- C. Just the face: a large smiling head with its bun, on a green lotus
def face(bg=CREAM, k=1.0):
    halo = "".join(petal(512, 560, i * 45, 400, 150, (G2 if i % 2 else G3), bg, 16) for i in range(8))
    f = (f'<circle cx="512" cy="196" r="78" fill="{HAIR}"/><rect x="458" y="246" width="108" height="28" rx="14" fill="{SAFF}"/>'
         f'<circle cx="512" cy="540" r="250" fill="{SKIN}"/>'
         f'<path d="M262 540A250 250 0 0 1 762 540Q690 392 512 420Q334 392 262 540Z" fill="{HAIR}"/>'
         f'<circle cx="400" cy="610" r="34" fill="#F29C7B" opacity="0.6"/><circle cx="624" cy="610" r="34" fill="#F29C7B" opacity="0.6"/>'
         f'<path d="M402 548q46 40 92 0M530 548q46 40 92 0" stroke="{HAIR}" stroke-width="26" stroke-linecap="round" fill="none"/>'
         f'<path d="M452 652q60 50 120 0" stroke="{HAIR}" stroke-width="26" stroke-linecap="round" fill="none"/>'
         f'<circle cx="512" cy="470" r="14" fill="#C8102E"/>')
    return svg(f'<g transform="translate(512 512) scale({k}) translate(-512 -512)">{halo}{f}</g>', bg)

# ---- D. Bust: big head and shoulders in front of the lotus. Crops off the bottom edge.
def bust(bg=CREAM, k=1.0):
    halo = "".join(petal(512, 600, i * 30, 360, 128, (G3 if i % 2 else G2), bg, 14) for i in range(12))
    f = (f'<path d="M150 1024Q170 760 512 720Q854 760 874 1024Z" fill="{SKIN}"/>'
         f'<path d="M150 1024Q170 760 400 730L690 1024Z" fill="{SAFF}"/>'
         f'<path d="M400 730Q560 860 690 1024" stroke="{ROBED}" stroke-width="26" fill="none"/>'
         f'<path d="M424 742Q512 850 600 742" stroke="#8A3B2E" stroke-width="18" stroke-linecap="round" stroke-dasharray="0.1 34" fill="none"/>'
         f'<rect x="452" y="600" width="120" height="150" rx="40" fill="{SKIND}"/>'
         f'<circle cx="512" cy="196" r="74" fill="{HAIR}"/><rect x="460" y="244" width="104" height="28" rx="14" fill="{SAFF}"/>'
         f'<circle cx="332" cy="470" r="34" fill="{SKIND}"/><circle cx="692" cy="470" r="34" fill="{SKIND}"/>'
         f'<circle cx="512" cy="450" r="188" fill="{SKIN}"/>'
         f'<path d="M324 450A188 188 0 0 1 700 450Q648 322 512 346Q376 322 324 450Z" fill="{HAIR}"/>'
         f'<circle cx="420" cy="520" r="28" fill="#F29C7B" opacity="0.6"/><circle cx="604" cy="520" r="28" fill="#F29C7B" opacity="0.6"/>'
         f'<path d="M414 462q34 30 68 0M542 462q34 30 68 0" stroke="{HAIR}" stroke-width="22" stroke-linecap="round" fill="none"/>'
         f'<path d="M462 548q50 40 100 0" stroke="{HAIR}" stroke-width="22" stroke-linecap="round" fill="none"/>')
    return svg(f'<g transform="translate(512 512) scale({k}) translate(-512 -512)">{halo}{f}</g>', bg)

# E. Option A's head and shoulders on option B's eight-petal lotus
def combo(bg=CREAM, k=1.0):
    halo = "".join(petal(512, 470, i * 45, 420, 158, (G2 if i % 2 else G3), bg, 16) for i in range(8))
    b = bust(bg, 1.0)
    fig = b[b.index('<path d="M150 1024'):b.rindex('</g>')]
    return svg(f'<g transform="translate(512 512) scale({k}) translate(-512 -512)">{halo}{fig}</g>', bg)

# F (shown as option E). Same as the combination, with the lotus a slightly darker yellow than the background
def combo_gold(bg=CREAM, k=1.0):
    a, b = ("#F2C300", "#E8B500") if bg == CREAM else ("#2A3D17", "#22351A")
    halo = "".join(petal(512, 470, i * 45, 420, 158, (a if i % 2 else b), bg, 16) for i in range(8))
    bb = bust(bg, 1.0)
    fig = bb[bb.index('<path d="M150 1024'):bb.rindex('</g>')]
    return svg(f'<g transform="translate(512 512) scale({k}) translate(-512 -512)">{halo}{fig}</g>', bg)

# C, revised: eyes higher and rounder so they never read as a moustache
def face2(bg=CREAM, k=1.0):
    halo = "".join(petal(512, 560, i * 45, 400, 150, (G2 if i % 2 else G3), bg, 16) for i in range(8))
    f = (f'<circle cx="512" cy="190" r="76" fill="{HAIR}"/><rect x="458" y="240" width="108" height="28" rx="14" fill="{SAFF}"/>'
         f'<circle cx="270" cy="560" r="44" fill="{SKIND}"/><circle cx="754" cy="560" r="44" fill="{SKIND}"/>'
         f'<circle cx="512" cy="550" r="244" fill="{SKIN}"/>'
         f'<path d="M268 540A244 244 0 0 1 756 540Q680 380 512 408Q344 380 268 540Z" fill="{HAIR}"/>'
         f'<circle cx="388" cy="640" r="36" fill="#F29C7B" opacity="0.6"/><circle cx="636" cy="640" r="36" fill="#F29C7B" opacity="0.6"/>'
         f'<path d="M382 566q46 -40 92 0M550 566q46 -40 92 0" stroke="{HAIR}" stroke-width="28" stroke-linecap="round" fill="none"/>'
         f'<path d="M446 660q66 60 132 0" stroke="{HAIR}" stroke-width="28" stroke-linecap="round" fill="none"/>')
    return svg(f'<g transform="translate(512 512) scale({k}) translate(-512 -512)">{halo}{f}</g>', bg)

DARKBG = "#10281A"
sets = {
 "B-big-yogi": (big(), big(bg=DARKBG), big(k=0.94)),
 "D-bust": (bust(), bust(bg=DARKBG), bust(k=1.0)),
 "C-face": (face2(), face2(bg=DARKBG), face2(k=0.9)),
 "E-combo": (combo(), combo(bg=DARKBG), combo(k=1.0)),
 "F-gold": (combo_gold(), combo_gold(bg=DARKBG), combo_gold(k=1.0)),
 "G-smile": tuple(x.replace("M414 462q34 30 68 0M542 462q34 30 68 0", "M414 474q34 -30 68 0M542 474q34 -30 68 0") for x in (combo(), combo(bg=DARKBG), combo(k=1.0))),
}
for name, (light, dark, watch) in sets.items():
    for tag, s in (("ios-light", light), ("ios-dark", dark), ("watch", watch)):
        open(os.path.join(OUT, f"{name}-{tag}.svg"), "w").write(s)
print("ok")
