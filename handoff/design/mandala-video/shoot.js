const puppeteer = require('puppeteer-core'); const {spawn}=require('child_process'); const fs=require('fs');
(async () => {
  const [mode, ...rest] = process.argv.slice(2);
  const b = await puppeteer.launch({executablePath:'/usr/bin/google-chrome', headless:'new', args:['--no-sandbox','--disable-gpu']});
  const p = await b.newPage(); await p.setViewport({width:1080,height:1920});
  await p.goto('file:///home/claude/yogi/video/clip.html'); await p.evaluate(()=>document.fonts.ready);
  if (mode==='stills') { for (const t of rest) { await p.evaluate(t=>render(+t), t); await p.screenshot({path:`still-${t}.jpg`, type:'jpeg', quality:92}); } }
  else {
    const [out, dur] = rest; const fps=30, n=Math.round(+dur*fps);
    const ff = spawn('ffmpeg', ['-y','-loglevel','error','-f','image2pipe','-framerate',String(fps),'-c:v','mjpeg','-i','-','-c:v','libx264','-preset','veryfast','-crf','18','-pix_fmt','yuv420p','-movflags','+faststart',out], {stdio:['pipe','inherit','inherit']});
    for (let i=0;i<n;i++){ await p.evaluate(t=>render(t), i/fps); const buf=await p.screenshot({type:'jpeg',quality:92}); if(!ff.stdin.write(buf)) await new Promise(r=>ff.stdin.once('drain',r)); }
    ff.stdin.end(); await new Promise(r=>ff.on('close',c=>{ if(c) process.exit(c); r(); }));
  }
  await b.close();
})();
