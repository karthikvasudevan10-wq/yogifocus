import re
D='/home/claude/yogi/icon2/'
INK="#14301F"; MUTED="#4F6355"
def svgx(name, px):
    s=open(D+name+'.svg').read()
    s=re.sub(r'<(\w+)([^<>]*?)/>', r'<\1\2></\1>', s).replace('xmlns="http://www.w3.org/2000/svg" ','')
    s=s.replace('<rect width="1024" height="1024"','<rect x="0" y="0" width="1024" height="1024"')
    return s.replace('<svg viewBox="0 0 1024 1024" width="1024" height="1024">', f'<svg viewBox="0 0 1024 1024" role="img" aria-label="App icon option" width="{px}" height="{px}" style="display: block">',1)
def tile(name, px, shape):
    r = f"{round(px*0.2237)}px" if shape=="ios" else "50%"
    return f'<div style="flex: none; width: {px}px; height: {px}px; border-radius: {r}; overflow: hidden">{svgx(name, px)}</div>'
rows=[("D","E-combo","A's yogi on B's lotus","Option A's head and shoulders in front of option B's bold eight-petal green lotus.", True),
      ("F","G-smile","D with smiling eyes","Option D with the closed eyes curved upward, like ^ ^. Still calm and meditative, but reads as happy and awake rather than sleepy.", True),
      ("E","F-gold","D with a golden lotus","The same, with the lotus a slightly darker yellow than the background, so the yogi carries all the colour.", True),
      ("A","D-bust","Head and shoulders","The face is big enough to read on the smallest watch icon; the robe and beads still say yogi.", False),
      ("B","C-face","Face only","The simplest and boldest. Clearest at tiny sizes, but loses the robe.", False),
      ("C","B-big-yogi","Whole yogi, bigger","The current yogi at almost twice the size. Most detail; turns to a blur below about 40 points.", False)]
out=""
for letter, d, title, note, hl in rows:
    big = "".join([tile(d+"-ios-light",220,"ios"), tile(d+"-ios-dark",220,"ios"), tile(d+"-watch",180,"watch")])
    small = "".join(f'<div style="display: flex; flex-direction: column; align-items: center; gap: 8px">{tile(d+suf,px,shape)}<span style="font-size: 12px; color: {MUTED}">{lab}</span></div>'
                    for suf,px,shape,lab in [("-ios-light",60,"ios","60 pt"),("-ios-light",40,"ios","40 pt"),("-ios-light",29,"ios","29 pt"),("-watch",48,"watch","Watch 48"),("-watch",32,"watch","Watch 32")])
    st = "background: #E6F8D2; border-radius: 28px; padding: 26px 24px; margin: 0 -24px;" if hl else "padding: 26px 0; border-top: 1px solid #E2EBD6;"
    out += (f'<div style="display: flex; align-items: center; gap: 40px; {st}">'
            f'<div style="width: 300px; flex: none; display: flex; flex-direction: column; gap: 6px"><div style="font-family: \'Baloo 2\', system-ui, sans-serif; font-weight: 700; font-size: 34px; line-height: 1.05">Option {letter}</div>'
            f'<div style="font-size: 17px; font-weight: 600">{title}</div><div style="font-size: 14.5px; line-height: 1.45; color: {MUTED}">{note}</div></div>'
            f'<div style="display: flex; align-items: center; gap: 22px">{big}</div>'
            f'<div style="display: flex; align-items: flex-end; gap: 22px; margin-left: 20px">{small}</div></div>')
W,H=1640,1920
html=f'''<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>App icon v2 options</title>
<script src="./support.js"></script>
</head>
<body>
<x-dc>
<helmet>
<link href="https://fonts.googleapis.com/css2?family=Baloo+2:wght@600;700&amp;family=Inter:wght@400;500;600&amp;display=swap" rel="stylesheet">
<style>
body{{margin:0}}
</style>
</helmet>
<div style="width: {W}px; height: {H}px; box-sizing: border-box; padding: 40px 48px; background: #FFFFFF; color: {INK}; font-family: Inter, system-ui, sans-serif; display: flex; flex-direction: column; gap: 12px">
<div style="font-family: 'Baloo 2', system-ui, sans-serif; font-weight: 700; font-size: 34px; line-height: 1.1">App icon v2: a bigger yogi</div>
<div style="margin: 0 0 6px; font-size: 16px; color: {MUTED}">Each option shown on iPhone (light and dark), on Apple Watch, and at the smallest sizes people see.</div>
{out}
</div>
</x-dc>
<script type="text/x-dc" data-dc-script data-props='{{"$preview":{{"width":{W},"height":{H}}}}}'>
class Component extends DCLogic {{
renderVals() {{
return {{}};
}}
}}
</script>
</body>
</html>
'''
open('/home/claude/yogi/v2root/project/App-Icon-V2.dc.html','w').write(html)
print(html.count('width="1024" height="1024" fill='))
