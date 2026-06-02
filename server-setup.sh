#!/bin/bash
# Run this ONCE on the VPS to set up the backend
# ssh root@72.61.147.68 then paste this

# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# Install PM2
npm install -g pm2

# Create app directory
mkdir -p /home/wakeell/backend

# Clone the repo (replace YOUR_GITHUB_USERNAME)
git clone https://github.com/YOUR_GITHUB_USERNAME/wakeell.com.git /home/wakeell/repo
ln -s /home/wakeell/repo/backend /home/wakeell/backend

# Install dependencies
cd /home/wakeell/repo/backend
npm ci --omit=dev

# Create .env (fill in your values)
cat > /home/wakeell/repo/backend/.env << 'EOF'
PORT=3000
MONGO_URI=mongodb://localhost:27017/wakeell
JWT_SECRET=CHANGE_THIS_TO_A_LONG_RANDOM_STRING
JWT_EXPIRES_IN=7d
NODE_ENV=production
EOF

# Start with PM2
pm2 start server.js --name wakeell-backend
pm2 save
pm2 startup
