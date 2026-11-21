const puppeteer = require('puppeteer-core'); const fs = require('fs');
const SL = '/home/claude/yogi/store/slides2/';
const jobs = JSON.parse(fs.readFileSync(SL + 'jobs.json', 'utf8'));
(async () => {
  const b = await puppeteer.launch({executablePath:'/usr/bin/google-chrome', headless:'new', args:['--no-sandbox','--disable-gpu','--allow-file-access-from-files']});
  for (const j of jobs) {
    const p = await b.newPage(); await p.setViewport({width:j.w, height:j.h, deviceScaleFactor:1});
    await p.goto('file://' + SL + j.file + '.html', {waitUntil:'load'}); await new Promise(r=>setTimeout(r, 500));
    await p.screenshot({path: SL + j.file + '.png', clip:{x:0,y:0,width:j.w,height:j.h}}); await p.close();
  }
  await b.close();
})();
