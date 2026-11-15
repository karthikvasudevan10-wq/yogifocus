import math
import os
DARK = os.environ.get("YF_THEME") == "dark"
# literals: the same in both appearances
ONACC="#14301F"                                   # text on bright green or bright yellow
TEAL="#6FD43A"; TEALM="#3DBB45"; TEALD="#17933F"; CREAM="#FFD21F"; CREAMS="#FFF3B0"; SAFF="#FF7A1A"
# roles: these change with the appearance
if DARK:
    INK="#EEF5E8"; MUTED="#A9B8A5"; DEEP="#8AE264"; SOFT="#1C3A21"; GROUND="#0E1A11"; LINE="#2C3D2E"; PAPER="#18271B"; SOFTY="#3A3512"
    BOARD="#0A130C"; HERO_Y="#111F10"; HERO_G="#0F2212"; PETAL_CLOSED="#233327"; PETAL_EDGE="#34483A"; PETAL_SEP=GROUND
else:
    INK="#14301F"; MUTED="#4F6355"; DEEP="#127A35"; SOFT="#E6F8D2"; GROUND="#FFFEF8"; LINE="#E2EBD6"; PAPER="#FFFFFF"; SOFTY=CREAMS
    BOARD=TEAL; HERO_Y=CREAM; HERO_G=TEAL; PETAL_CLOSED="#EEF4E6"; PETAL_EDGE="#D9E4CC"; PETAL_SEP="#FFFFFF"
BROWN="#5B3F33"; SKIN="#EDBE94"; WHITE="#FFFFFF"; NIGHT=BOARD

RINGS=[(30,44,13,0.0),(62,44,19,11.25),(96,48,25,0.0)]  # base r, length, ctrl width, angle offset

def petal_path(l,w):
    return f"M0 0C{w} {-0.35*l:.1f} {w} {-0.75*l:.1f} 0 {-l}C{-w} {-0.75*l:.1f} {-w} {-0.35*l:.1f} 0 0Z"

FB_BOX="transform-box: fill-box; transform-origin: 50% 50%"
MISSED="#E0453F"
def lotus_body(opened=0, today=None, open_cols=(TEALD,TEALM,TEAL), closed=PETAL_CLOSED, closed_stroke=PETAL_EDGE, sep=PETAL_SEP, today_col=SAFF, center=CREAM, motion=None, missed=()):
    """petals as svg markup, viewBox -150 -150 300 300. day n (1-based): ring (n-1)//16, index (n-1)%16.
    opened = the day reached; days in `missed` (up to that day) are drawn red, the rest green."""
    out=[]
    for k in (2,1,0):
        r,l,w,off=RINGS[k]
        d=petal_path(l,w)
        ring=[]
        for i in range(16):
            day=k*16+i+1
            ang=i*22.5+off
            is_open = day<=opened
            if today is not None and day==today: fill,stroke=today_col,sep
            elif is_open and day in missed: fill,stroke=MISSED,sep
            elif is_open: fill,stroke=open_cols[k],sep
            else: fill,stroke=closed,closed_stroke
            if motion=="bloom" and is_open:
                ring.append(f'<g transform="rotate({ang:g}) translate(0 {-r})"><path d="{d}" fill="{fill}" stroke="{stroke}" stroke-width="1.5" '
                            f'style="transform-box: fill-box; transform-origin: 50% 100%; animation: yf-open 0.6s cubic-bezier(0.3, 1.3, 0.5, 1) {0.3+day*0.06:.2f}s both"></path></g>')
            else:
                ring.append(f'<path d="{d}" transform="rotate({ang:g}) translate(0 {-r})" fill="{fill}" stroke="{stroke}" stroke-width="1.5"></path>')
        if motion=="breathe":
            out.append(f'<g style="{FB_BOX}; animation: yf-breathe 7s ease-in-out {k*0.5:g}s infinite">{"".join(ring)}</g>')
        else:
            out.append("".join(ring))
    if center: out.append(f'<circle cx="0" cy="0" r="27" fill="{center}"></circle>')
    return "".join(out)

def lotus_svg(size, label, **kw):
    return (f'<svg role="img" aria-label="{label}" viewBox="-150 -150 300 300" width="{size}" height="{size}" '
            f'style="display: block; grid-area: 1 / 1">{lotus_body(**kw)}</svg>')

HAIR="#4A3229"; SKIND="#DDA77C"; ROBED="#E2600A"; ROBEL="#FF9D4D"; DHOTI="#FFD21F"; DHOTID="#EFB40C"

def yogi_body(mat=True, dhoti=DHOTI, dhoti_shade=DHOTID, joyful=False, namaste=False):
    """Seated yogi, viewBox 0 0 200 200. Slim torso, crossed legs, hands resting on the knees."""
    ln=f'stroke="{HAIR}" stroke-linecap="round" fill="none"'
    return (
     (f'<rect x="34" y="174" width="132" height="9" rx="4.5" fill="{DEEP}"></rect>' if mat else "") +
     # crossed legs
     f'<path d="M66 150Q100 134 134 150L128 168L72 168Z" fill="{dhoti}"></path>'
     f'<path d="M56 160Q86 142 122 165" stroke="{dhoti}" stroke-width="18" stroke-linecap="round" fill="none"></path>'
     f'<path d="M144 160Q114 142 78 165" stroke="{dhoti}" stroke-width="18" stroke-linecap="round" fill="none"></path>'
     f'<path d="M70 163Q92 150 114 164" stroke="{dhoti_shade}" stroke-width="2" stroke-linecap="round" fill="none"></path>'
     f'<path d="M134 156Q120 150 106 156" stroke="{dhoti_shade}" stroke-width="2" stroke-linecap="round" fill="none"></path>'
     f'<ellipse cx="80" cy="170" rx="10" ry="4.5" fill="{SKIN}"></ellipse><ellipse cx="121" cy="170" rx="10" ry="4.5" fill="{SKIN}"></ellipse>'
     # arms behind the torso edge: upper arm in robe, forearm bare
     + ((f'<path d="M80 92Q69 106 68 122" stroke="{SAFF}" stroke-width="12" stroke-linecap="round" fill="none"></path>'
         f'<path d="M120 92Q131 106 132 122" stroke="{SKIN}" stroke-width="9" stroke-linecap="round" fill="none"></path>') if namaste else (
     f'<path d="M80 92Q70 107 66 126" stroke="{SAFF}" stroke-width="12" stroke-linecap="round" fill="none"></path>'
     f'<path d="M120 92Q130 107 134 126" stroke="{SKIN}" stroke-width="9" stroke-linecap="round" fill="none"></path>'
     f'<path d="M66 127Q61 140 58 151" stroke="{SKIN}" stroke-width="8" stroke-linecap="round" fill="none"></path>'
     f'<path d="M134 127Q139 140 142 151" stroke="{SKIN}" stroke-width="8" stroke-linecap="round" fill="none"></path>'
     f'<circle cx="56" cy="154" r="5.5" fill="{SKIN}"></circle><circle cx="144" cy="154" r="5.5" fill="{SKIN}"></circle>'
     f'<circle cx="52.5" cy="157.5" r="2.6" fill="none" stroke="{SKIND}" stroke-width="1.6"></circle><circle cx="147.5" cy="157.5" r="2.6" fill="none" stroke="{SKIND}" stroke-width="1.6"></circle>')) +
     # torso: bare right shoulder, robe draped from the left
     f'<path d="M77 92Q77 81 89 80L111 80Q123 81 123 92L117 149Q100 154 83 149Z" fill="{SKIN}"></path>'
     f'<path d="M77 92Q77 81 89 80L98 80Q112 100 121 118L117 149Q100 154 83 149Z" fill="{SAFF}"></path>'
     f'<path d="M89 80L98 80Q112 100 121 118L120 128Q104 108 89 80Z" fill="{ROBEL}"></path>'
     f'<path d="M84 104Q94 122 112 140M82 120Q90 134 102 146" stroke="{ROBED}" stroke-width="1.8" stroke-linecap="round" fill="none"></path>'
     f'<path d="M83 149Q100 154 117 149L116 156Q100 160 84 156Z" fill="{ROBED}"></path>'
     + ((f'<path d="M68 123Q80 124 97 113" stroke="{SKIN}" stroke-width="8.5" stroke-linecap="round" fill="none"></path>'
         f'<path d="M132 123Q120 124 103 113" stroke="{SKIN}" stroke-width="8.5" stroke-linecap="round" fill="none"></path>'
         f'<path d="M100 95Q93 106 95.5 118L104.5 118Q107 106 100 95Z" fill="{SKIN}" stroke="{SKIND}" stroke-width="1.2" stroke-linejoin="round"></path>'
         f'<path d="M100 99L100 117" stroke="{SKIND}" stroke-width="1.2" stroke-linecap="round" fill="none"></path>') if namaste else "") +
     # neck, beads
     f'<rect x="94" y="66" width="12" height="17" rx="5" fill="{SKIND}"></rect>'
     f'<path d="M89 82Q100 104 111 82" stroke="#8A3B2E" stroke-width="2.6" stroke-linecap="round" stroke-dasharray="0.1 4.2" fill="none"></path>'
     # head
     f'<circle cx="80.5" cy="55" r="4" fill="{SKIND}"></circle><circle cx="119.5" cy="55" r="4" fill="{SKIND}"></circle>'
     f'<circle cx="100" cy="53" r="20" fill="{SKIN}"></circle>'
     f'<path d="M80 53A20 20 0 0 1 120 53Q113 41 100 44Q87 41 80 53Z" fill="{HAIR}"></path>'
     f'<circle cx="100" cy="27" r="8.5" fill="{HAIR}"></circle><path d="M94 34.5L106 34.5" stroke="{SAFF}" stroke-width="3" stroke-linecap="round" fill="none"></path>'
     f'<circle cx="89" cy="61" r="3.2" fill="#F29C7B" opacity="0.55"></circle><circle cx="111" cy="61" r="3.2" fill="#F29C7B" opacity="0.55"></circle>'
     + ((f'<path d="M88.5 48.5q4.5 -3 8.5 -0.5" {ln} stroke-width="1.5"></path><path d="M103 48q4 -2.500 8.500 0.500" {ln} stroke-width="1.5"></path>'
       f'<circle cx="93.500" cy="55" r="3" fill="{HAIR}"></circle><circle cx="106.500" cy="55" r="3" fill="{HAIR}"></circle>'
       f'<circle cx="94.500" cy="54" r="1" fill="{WHITE}"></circle><circle cx="107.500" cy="54" r="1" fill="{WHITE}"></circle>'
       f'<path d="M92.500 61.500Q100 71.500 107.500 61.500Z" fill="#7A2B1E" stroke="#7A2B1E" stroke-width="1.5" stroke-linejoin="round"></path>'
       f'<path d="M94.500 62.200L105.500 62.200Q103.500 64.800 100 64.800Q96.500 64.800 94.500 62.200Z" fill="{WHITE}"></path>').replace(".500", ".5")
      if joyful else
      (f'<path d="M89 50.5q4.5 -2.5 8.5 0" {ln} stroke-width="1.5"></path><path d="M102.5 50.5q4 -2.5 8.5 0" {ln} stroke-width="1.5"></path>'
       f'<path d="M89.5 56q4 3.5 8 0" {ln} stroke-width="2"></path><path d="M102.5 56q4 3.5 8 0" {ln} stroke-width="2"></path>'
       f'<path d="M95 63.5q5 4 10 0" {ln} stroke-width="2"></path>')))

def hero_svg(size, bg, cols, dhoti=DHOTI, dhoti_shade=DHOTID, joyful=False):
    """Yogi levitating above a large open lotus seen at an angle; the lotus turns slowly. viewBox 0 0 300 344."""
    body=lotus_body(opened=48, open_cols=cols, sep=bg, center=None, motion="breathe")
    return (f'<svg role="img" aria-label="A yogi floating above a slowly turning lotus" viewBox="0 0 300 344" width="{size}" height="{round(size*344/300)}" style="display: block; overflow: visible">'
            f'<g transform="translate(150 262) scale(1.28 0.54)"><g style="{FB_BOX}; animation: yf-spin 48s linear infinite">{body}</g></g>'
            f'<ellipse cx="150" cy="262" rx="56" ry="12" fill="#0B3D1A" style="{FB_BOX}; opacity: 0.24; animation: yf-shadow 4.5s ease-in-out infinite"></ellipse>'
            f'<g style="animation: yf-levitate 4.5s ease-in-out infinite"><g transform="translate(35 -4) scale(1.15)">{yogi_body(mat=False, dhoti=dhoti, dhoti_shade=dhoti_shade, joyful=joyful)}</g></g></svg>')
