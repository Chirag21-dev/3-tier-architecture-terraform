#!/bin/bash
set -e

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/user-data.log
}

log "Starting backend setup..."

# Update system
log "Updating system packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y

# Install Docker and dependencies
log "Installing Docker and utilities..."
apt-get install -y docker.io jq netcat-openbsd dnsutils unzip curl
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu
log "✅ Docker installed and started successfully"

# Install AWS CLI v2
log "Installing AWS CLI v2..."
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip
