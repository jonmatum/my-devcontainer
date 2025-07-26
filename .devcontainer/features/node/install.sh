#!/bin/bash
set -e

USERNAME="${_REMOTE_USER:-vscode}"
NODE_VERSION="${VERSION:-lts/*}"
NVM_VERSION="v0.40.3"
NVM_DIR="/home/$USERNAME/.nvm"

echo "Installing nvm $NVM_VERSION for user $USERNAME and Node.js $NODE_VERSION..."

# Ensure nvm directory and permissions
mkdir -p "$NVM_DIR"
chown -R $USERNAME: "$NVM_DIR"

# Install dependencies
apt-get update && apt-get install -y curl ca-certificates

# Install nvm only if not already installed
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    su - $USERNAME -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | PROFILE=/dev/null bash"
else
    echo "nvm already installed at $NVM_DIR, skipping install."
fi

# Load nvm into current shell
export NVM_DIR="$NVM_DIR"
source "$NVM_DIR/nvm.sh"

# Install requested Node.js version (nvm is idempotent here)
su - $USERNAME -c "export NVM_DIR=$NVM_DIR && source \$NVM_DIR/nvm.sh && nvm install $NODE_VERSION && nvm alias default $NODE_VERSION"

# Symlink node and npm to global bin if not already set
NODE_PATH="$(su - $USERNAME -c "export NVM_DIR=$NVM_DIR && source \$NVM_DIR/nvm.sh && nvm which $NODE_VERSION")"
ln -sf "$NODE_PATH" /usr/local/bin/node
ln -sf "$(dirname $NODE_PATH)/npm" /usr/local/bin/npm
ln -sf "$(dirname $NODE_PATH)/npx" /usr/local/bin/npx

# Final verification
echo "Verifying installation:"
/usr/local/bin/node -v
/usr/local/bin/npm -v