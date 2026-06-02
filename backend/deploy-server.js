const http = require('http');
const { exec } = require('child_process');

const SECRET = process.env.DEPLOY_SECRET;
const PORT = 9000;

const server = http.createServer((req, res) => {
  if (req.method !== 'POST' || req.url !== '/deploy') {
    res.writeHead(404); return res.end();
  }
  if (!SECRET || req.headers['x-deploy-secret'] !== SECRET) {
    res.writeHead(403); return res.end('Forbidden');
  }

  res.writeHead(200); res.end('Deploy started');

  const cmd = [
    'cd /home/wakeell/app',
    'git pull origin main',
    'cd backend',
    'npm ci --omit=dev',
    'pm2 restart wakeell-backend',
    'pm2 save',
  ].join(' && ');

  exec(cmd, (err, stdout, stderr) => {
    if (err) console.error('[deploy] error:', stderr);
    else console.log('[deploy] success:', stdout);
  });
});

server.listen(PORT, () => console.log(`Deploy webhook listening on port ${PORT}`));
