#!/bin/bash

set -e

IMAGE_TAG=${1:-latest}
APP_NAME="multicloud-app"

echo "🚀 Starting application deployment..."
echo "Image Tag: $IMAGE_TAG"

# Update application
cd /opt/$APP_NAME || exit 1

# Restart services
sudo systemctl restart $APP_NAME

# Wait for service
sleep 10

# Health check
echo "🔍 Performing health check..."
if curl -f http://localhost:3000/health; then
    echo "✅ Application deployed successfully!"
else
    echo "❌ Health check failed!"
    sudo systemctl status $APP_NAME
    exit 1
fi

echo "🎉 Deployment completed!"
