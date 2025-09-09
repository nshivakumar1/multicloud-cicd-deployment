#!/bin/bash

# Update system
apt-get update -y
apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker adminuser

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Install Nginx
apt-get install -y nginx
systemctl start nginx
systemctl enable nginx

# Create application directory
mkdir -p /opt/${app_name}
chown adminuser:adminuser /opt/${app_name}

# Create package.json
cat > /opt/${app_name}/package.json << 'PKGJSON'
{
  "name": "multicloud-app",
  "version": "1.0.0",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5"
  }
}
PKGJSON

# Create server.js
cat > /opt/${app_name}/server.js << 'SERVERJS'
const express = require('express');
const cors = require('cors');
const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
    res.json({
        message: 'Hello from Azure Multi-Cloud Application!',
        cloud: 'Azure',
        timestamp: new Date().toISOString(),
        hostname: require('os').hostname()
    });
});

app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        cloud: 'Azure',
        uptime: process.uptime(),
        timestamp: new Date().toISOString()
    });
});

app.listen(port, '0.0.0.0', () => {
    console.log('Azure Multi-cloud app listening at http://0.0.0.0:' + port);
});
SERVERJS

# Install dependencies
cd /opt/${app_name}
npm install
chown -R adminuser:adminuser /opt/${app_name}

# Create systemd service
cat > /etc/systemd/system/${app_name}.service << SYSTEMDSERVICE
[Unit]
Description=${app_name} Node.js Application
After=network.target

[Service]
Type=simple
User=adminuser
WorkingDirectory=/opt/${app_name}
ExecStart=/usr/bin/node server.js
Restart=on-failure
Environment=NODE_ENV=production
Environment=CLOUD_PROVIDER=Azure

[Install]
WantedBy=multi-user.target
SYSTEMDSERVICE

# Configure Nginx
cat > /etc/nginx/sites-available/${app_name} << 'NGINXCONFIG'
server {
    listen 80;
    server_name _;
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
NGINXCONFIG

# Enable site
ln -s /etc/nginx/sites-available/${app_name} /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl restart nginx

# Start application
systemctl daemon-reload
systemctl enable ${app_name}
systemctl start ${app_name}
