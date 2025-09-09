#!/bin/bash

echo "🚀 Setting up Jenkins on macOS..."

# Check Homebrew
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install tools
echo "Installing tools..."
brew install openjdk@11 jenkins-lts terraform docker node awscli azure-cli

# Start Jenkins
echo "Starting Jenkins..."
brew services start jenkins-lts

echo "✅ Jenkins setup completed!"
echo "🌐 Access Jenkins at: http://localhost:8080"
echo "📝 Get password: cat /opt/homebrew/var/lib/jenkins/secrets/initialAdminPassword"
