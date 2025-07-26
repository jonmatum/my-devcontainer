#!/bin/bash
set -euo pipefail

USERNAME="${_REMOTE_USER:-vscode}"
TOFU_VERSION="${VERSION:-1.6.2}"
TOFU_BIN="/usr/local/bin/tofu"
TMP_DIR="/tmp/opentofu"

# Install dependencies
apt-get update
apt-get install -y curl unzip gnupg software-properties-common lsb-release

# Check if OpenTofu is already installed and is the correct version
if command -v tofu >/dev/null 2>&1; then
    CURRENT_VERSION=$(tofu version | grep -oP 'OpenTofu v\K[0-9.]+')
    if [[ "$CURRENT_VERSION" == "$TOFU_VERSION" ]]; then
        echo "OpenTofu v$TOFU_VERSION already installed. Skipping installation."
        exit 0
    else
        echo "OpenTofu version mismatch. Reinstalling v$TOFU_VERSION..."
        rm -f "$TOFU_BIN"
    fi
fi

# Download OpenTofu binary
echo "Downloading OpenTofu v$TOFU_VERSION..."
mkdir -p "$TMP_DIR"
curl -sL "https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_linux_amd64.zip" -o "$TMP_DIR/tofu.zip"

# Unzip and move binary
unzip -qo "$TMP_DIR/tofu.zip" -d "$TMP_DIR"
chmod +x "$TMP_DIR/tofu"
mv "$TMP_DIR/tofu" "$TOFU_BIN"

# Cleanup
rm -rf "$TMP_DIR"

# Verify installation
echo "OpenTofu installed at: $(which tofu)"
tofu version
