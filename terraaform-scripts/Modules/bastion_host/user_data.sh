#!/bin/bash
set -e

# Update system
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y

# Install useful tools
apt-get install -y \
    vim \
    git \
    htop \
    wget \
    curl \
    jq \
    dnsutils

# Install Docker (for troubleshooting)
apt-get install -y docker.io
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Install Session Manager plugin
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
dpkg -i session-manager-plugin.deb
rm -f session-manager-plugin.deb

# Configure AWS CLI region
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
mkdir -p /home/ubuntu/.aws
cat > /home/ubuntu/.aws/config << EOF
[default]
region = $REGION
output = json
EOF
chown -R ubuntu:ubuntu /home/ubuntu/.aws
