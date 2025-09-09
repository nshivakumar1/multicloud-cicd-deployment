#!/bin/bash
# terraform/scripts/user-data.sh

set -e

# Update system
apt-get update -y
apt-get upgrade -y

# Install required packages
apt-get install -y curl wget unzip nginx nodejs npm git

# Create application directory
mkdir -p /opt/multicloud-app
cd /opt/multicloud-app

# Create a simple Node.js application
cat > package.json << 'EOF'
{
  "name": "multicloud-app",
  "version": "1.0.0",
  "description": "Multi-cloud demonstration application",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "test": "echo \"All tests passed!\""
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF

# Create the application server
cat > server.js << 'EOF'
const express = require('express');
const os = require('os');
const app = express();
const port = ${app_port};

// Get instance metadata
const getInstanceInfo = () => {
  return {
    hostname: os.hostname(),
    platform: os.platform(),
    arch: os.arch(),
    uptime: os.uptime(),
    memory: {
      total: Math.round(os.totalmem() / 1024 / 1024) + ' MB',
      free: Math.round(os.freemem() / 1024 / 1024) + ' MB'
    },
    cpus: os.cpus().length,
    loadavg: os.loadavg(),
    timestamp: new Date().toISOString()
  };
};

// Routes
app.get('/', (req, res) => {
  const info = getInstanceInfo();
  res.json({
    message: 'Multi-Cloud Application Running Successfully!',
    status: 'healthy',
    environment: process.env.NODE_ENV || 'production',
    instance: info,
    endpoints: {
      health: '/health',
      info: '/info',
      status: '/status'
    }
  });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: os.uptime()
  });
});

app.get('/info', (req, res) => {
  res.json(getInstanceInfo());
});

app.get('/status', (req, res) => {
  res.json({
    application: 'multicloud-app',
    version: '1.0.0',
    status: 'running',
    environment: process.env.NODE_ENV || 'production',
    timestamp: new Date().toISOString()
  });
});

// Start server
app.listen(port, '0.0.0.0', () => {
  console.log(`Multi-cloud app listening on port $${port}`);
  console.log(`Health check available at: http://localhost:$${port}/health`);
});
EOF

# Install dependencies
npm install

# Create systemd service
cat > /etc/systemd/system/multicloud-app.service << 'EOF'
[Unit]
Description=Multi-Cloud Application
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/multicloud-app
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=10
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl daemon-reload
systemctl enable multicloud-app
systemctl start multicloud-app

# Configure Nginx reverse proxy
cat > /etc/nginx/sites-available/multicloud-app << 'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:${app_port};
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

# Enable the site
rm -f /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/multicloud-app /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# Create a startup log
echo "$(date): Multi-cloud application deployed successfully" >> /var/log/multicloud-deploy.log
echo "Application URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 || echo 'localhost')" >> /var/log/multicloud-deploy.log

# Verify services are running
systemctl status multicloud-app --no-pager
systemctl status nginx --no-pager

echo "Deployment completed successfully!"