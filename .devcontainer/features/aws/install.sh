#!/bin/bash
set -e

USERNAME="${_REMOTE_USER:-vscode}"
AWS_VERSION="${VERSION:-2}"
INSTALL_DIR="/usr/local/aws-cli"
BIN_LINK="/usr/local/bin/aws"

echo "Installing AWS CLI v$AWS_VERSION for user $USERNAME..."

# Check if AWS CLI is already installed and at correct version
if command -v aws >/dev/null 2>&1; then
    CURRENT_VERSION=$(aws --version 2>&1 | grep -oP 'aws-cli/\K[0-9]+\.[0-9]+')
    if [[ "$CURRENT_VERSION" == "$AWS_VERSION"* ]]; then
        echo "AWS CLI v$CURRENT_VERSION already installed. Skipping installation."
        exit 0
    else
        echo "Different AWS CLI version detected: $CURRENT_VERSION. Reinstalling v$AWS_VERSION..."
    fi
fi

# Determine architecture for correct binary
ARCH=$(uname -m)
if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
    AWS_CLI_URL="https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip"
else
    AWS_CLI_URL="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
fi

# Ensure dependencies
apt-get update && apt-get install -y curl unzip

# Clean previous downloads
rm -rf /tmp/awscliv2.zip /tmp/aws

# Download and extract
curl -sL "$AWS_CLI_URL" -o "/tmp/awscliv2.zip"
unzip -q /tmp/awscliv2.zip -d /tmp

# Install or update
/tmp/aws/install --update

# Clean up
rm -rf /tmp/aws /tmp/awscliv2.zip

# Verify and confirm install
echo "Verifying AWS CLI installation:"
if ! command -v aws >/dev/null; then
    echo "ERROR: AWS CLI failed to install properly."
    exit 1
fi

aws --version
