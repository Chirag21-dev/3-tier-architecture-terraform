#!/bin/bash
# Frontend deployment script - Simplified version
set -e
exec > >(tee -a /var/log/user-data.log) 2>&1

echo "=== Frontend Deployment Started at $(date) ==="

# Update and install dependencies
echo "Installing system packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y docker.io curl unzip netcat-openbsd

# Start Docker
echo "Starting Docker service..."
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

# Install AWS CLI v2
echo "Installing AWS CLI..."
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip
