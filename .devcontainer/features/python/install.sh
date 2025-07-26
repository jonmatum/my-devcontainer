#!/bin/bash
set -euo pipefail

USERNAME="${_REMOTE_USER:-vscode}"
PYTHON_VERSION="${VERSION:-3.11.9}"
INSTALL_PIPENV="${PIPENV:-false}"
PYENV_ROOT="/home/${USERNAME}/.pyenv"
PROFILE_PATH="/home/${USERNAME}/.bashrc"
PYTHON_BIN="${PYENV_ROOT}/versions/${PYTHON_VERSION}/bin"

echo "Installing Python $PYTHON_VERSION for user $USERNAME..."

# Ensure dependencies are present
apt-get update
apt-get install -y --no-install-recommends \
  make build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev curl \
  wget llvm libncursesw5-dev xz-utils tk-dev \
  libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
  git ca-certificates

# Install pyenv if not already present
if [ ! -d "$PYENV_ROOT" ]; then
  echo "Installing pyenv..."
  su - "$USERNAME" -c "git clone https://github.com/pyenv/pyenv.git $PYENV_ROOT"
fi

# Add pyenv to shell profile if not already configured
if ! grep -q 'pyenv init' "$PROFILE_PATH"; then
  echo 'export PYENV_ROOT="$HOME/.pyenv"' >>"$PROFILE_PATH"
  echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >>"$PROFILE_PATH"
  echo 'eval "$(pyenv init --path)"' >>"$PROFILE_PATH"
  echo 'eval "$(pyenv init -)"' >>"$PROFILE_PATH"
fi

# Install requested Python version if not already present
if ! su - "$USERNAME" -c "PYENV_ROOT=$PYENV_ROOT PATH=\$PYENV_ROOT/bin:\$PATH pyenv versions --bare | grep -qx \"$PYTHON_VERSION\""; then
  echo "Installing Python $PYTHON_VERSION..."
  su - "$USERNAME" -c "PYENV_ROOT=$PYENV_ROOT PATH=\$PYENV_ROOT/bin:\$PATH pyenv install $PYTHON_VERSION"
fi

# Set global version
su - "$USERNAME" -c "PYENV_ROOT=$PYENV_ROOT PATH=\$PYENV_ROOT/bin:\$PATH pyenv global $PYTHON_VERSION"

# Symlink Python and Pip globally
ln -sf "$PYTHON_BIN/python" /usr/local/bin/python
ln -sf "$PYTHON_BIN/pip" /usr/local/bin/pip

# Optionally install pipenv
if [[ "$INSTALL_PIPENV" == "true" ]]; then
  echo "Installing pipenv..."
  su - "$USERNAME" -c "PATH=$PYTHON_BIN:\$PATH pip install --user pipenv"
fi

# Confirm
echo "Installed Python:"
/usr/local/bin/python --version
/usr/local/bin/pip --version
[[ "$INSTALL_PIPENV" == "true" ]] && su - "$USERNAME" -c "PATH=\$HOME/.local/bin:\$PATH pipenv --version" || true
