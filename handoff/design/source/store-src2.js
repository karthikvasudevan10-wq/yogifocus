const puppeteer = require('puppeteer-core'); const fs = require('fs');
const S = '/home/claude/yogi/v2out/project/', OUT = '/home/claude/yogi/store/src2/';
const FF = [500,600,700].map(w=>`@font-face{font-family:'Baloo 2';font-weight:${w===700?'700 800':w};src:url(file:///home/claude/yogi/scratch/package/files/baloo-2-latin-${w}-normal.woff2) format('woff2')}`).join('') + [400,500,600,700].map(w=>`@font-face{font-family:'Inter';font-weight:${w};src:url(file:///home/claude/yogi/scratch/inter/package/files/inter-latin-${w}-normal.woff2) format('woff2')}`).join('');
function prep(f) {
  const s = fs.readFileSync(S + f + '.dc.html', 'utf8');
  const style = s.match(/<style>([\s\S]*?)<\/style>/)[1], body = s.split('</helmet>')[1].split('</x-dc>')[0];
  const tmp = OUT + '_' + f + '.html'; fs.writeFileSync(tmp, `<!doctype html><meta charset="utf-8"><style>${FF}${style}body{margin:0}</style><body>${body}</body>`); return 'file://' + tmp;
}
const jobs = [['V2-Today',390,844,3,800,'iphone-today'],['V2-Timer',390,844,3,800,'iphone-timer'],['V2-Not-Today',390,844,3,1500,'iphone-not-today'],
  ['V2-Nudges-Fade',390,844,3,1600,'iphone-fade'],['V2-Share-Video',390,844,3,800,'iphone-share'],['V2-Settings',390,1660,3,500,'iphone-settings']];
const crops = [['V2-Widgets',1000,860,3,1200,'div[style*="position: relative; overflow: hidden; height: 170px; border-radius: 24px"]',[0],'widget-medium'],
  ['V2-Widgets',1000,860,3,1200,'div[style*="width: 364px; height: 382px"]',[0],'widget-large'],
  ['V2-Live-Activity',1300,780,3,1200,'div[style*="width: 364px; box-sizing: border-box; padding: 16px 18px; border-radius: 26px"]',[0],'live-lock'],
  ['V2-Live-Activity',1300,780,3,1200,'div[style*="width: 370px; box-sizing: border-box; padding: 16px 20px 18px; border-radius: 44px"]',[1],'island'],
  ['V2-Watch',1030,736,2,1800,'div[style*="width: 208px; height: 248px"]',[0,3,2,4],'watch']];
(async () => {
  const b = await puppeteer.launch({executablePath:'/usr/bin/google-chrome', headless:'new', args:['--no-sandbox','--disable-gpu']});
  for (const [f,w,h,k,wait,name] of jobs) { const p = await b.newPage(); await p.setViewport({width:w,height:h,deviceScaleFactor:k});
    await p.goto(prep(f)); await p.evaluate(()=>document.fonts.ready); await new Promise(r=>setTimeout(r,wait));
    await p.screenshot({path: OUT+name+'.png', clip:{x:0,y:0,width:w,height:h}}); await p.close(); }
  for (const [f,w,h,k,wait,sel,idx,name] of crops) { const p = await b.newPage(); await p.setViewport({width:w,height:h,deviceScaleFactor:k});
    await p.goto(prep(f)); await p.evaluate(()=>document.fonts.ready); await new Promise(r=>setTimeout(r,wait));
    if (name==='watch') await p.$$eval(sel, es=>es.forEach(e=>{e.style.borderRadius='0'; e.style.boxShadow='none';})); const els = await p.$$(sel); for (const i of idx) await els[i].screenshot({path: OUT+`${name}-${i}.png`}); await p.close(); }
  await b.close();
})();
