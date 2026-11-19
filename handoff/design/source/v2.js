const puppeteer = require('puppeteer-core'); const fs = require('fs');
(async () => {
  const b = await puppeteer.launch({executablePath:'/usr/bin/google-chrome', headless:'new', args:['--no-sandbox','--disable-gpu']});
  const dir='/home/claude/yogi/v2out/project/';
  const ff = [500,600,700].map(w=>`@font-face{font-family:'Baloo 2';font-weight:${w};src:url(file:///home/claude/yogi/scratch/package/files/baloo-2-latin-${w}-normal.woff2) format('woff2')}`).join('');
  fs.mkdirSync('/home/claude/yogi/pp/v2',{recursive:true});
  for (const f of fs.readdirSync(dir)) {
    const s = fs.readFileSync(dir+f,'utf8');
    const pv = JSON.parse(s.match(/data-props='([^']*)'/)[1].replace(/&#39;/g,"'").replace(/&amp;/g,'&'))['$preview'];
    const style = s.match(/<style>([\s\S]*?)<\/style>/)[1];
    const body = s.split('</helmet>')[1].split('</x-dc>')[0];
    const out='/home/claude/yogi/pp/v2/'+f.replace('.dc.html','');
    fs.writeFileSync(out+'.html', `<!doctype html><meta charset="utf-8"><style>${ff}${style}</style><body>${body}</body>`);
    const p = await b.newPage(); await p.setViewport({width:pv.width,height:pv.height});
    await p.goto('file://'+out+'.html'); await new Promise(r=>setTimeout(r,500));
    const ov = await p.evaluate(()=>{const r=[];document.querySelectorAll('body *').forEach(e=>{if(e.scrollWidth>e.clientWidth+2&&getComputedStyle(e).overflow!=='hidden'&&e.clientWidth>0&&!(e instanceof SVGElement))r.push(e.tagName+':'+(e.textContent||'').slice(0,30))});return r.slice(0,4)});
    if (ov.length) console.log(f, 'overflow', ov);
    await p.screenshot({path:out+'.png'}); await p.close();
  }
  await b.close();
})();
