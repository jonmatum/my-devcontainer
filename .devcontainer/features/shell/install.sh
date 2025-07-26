#!/bin/bash
set -e

USERNAME="${_REMOTE_USER:-vscode}"
USER_HOME="/home/$USERNAME"
ZSHRC="$USER_HOME/.zshrc"
OMZ_DIR="$USER_HOME/.oh-my-zsh"
ZSH_CUSTOM="${OMZ_DIR}/custom"

# Options
: "${INSTALLZSH:=true}"
: "${OHMYZSH:=true}"
: "${POWERLEVEL10K:=true}"
: "${AUTOSUGGESTIONS:=true}"
: "${SYNTAXHIGHLIGHTING:=true}"
: "${AUTOSUGGESTHIGHLIGHT:=fg=8}"
: "${OPINIONATED:=false}"

apt-get update

# Install Zsh if required
if [[ "$INSTALLZSH" == "true" ]]; then
  if ! command -v zsh &>/dev/null; then
    echo "Installing Zsh..."
    apt-get install -y zsh
  fi
  chsh -s "$(which zsh)" "$USERNAME"
fi

# Oh My Zsh setup
if [[ "$OHMYZSH" == "true" ]]; then
  if [ ! -d "$OMZ_DIR" ]; then
    echo "Installing Oh My Zsh..."
    su - "$USERNAME" -c "sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" --unattended"
  fi

  grep -qxF 'export ZSH="$HOME/.oh-my-zsh"' "$ZSHRC" || echo 'export ZSH="$HOME/.oh-my-zsh"' >>"$ZSHRC"
  grep -qxF 'ZSH_THEME="robbyrussell"' "$ZSHRC" || echo 'ZSH_THEME="robbyrussell"' >>"$ZSHRC"
fi

# Powerlevel10k theme
if [[ "$POWERLEVEL10K" == "true" ]]; then
  THEME_DIR="${ZSH_CUSTOM}/themes/powerlevel10k"
  if [ ! -d "$THEME_DIR" ]; then
    echo "Installing Powerlevel10k..."
    su - "$USERNAME" -c "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $THEME_DIR"
  fi
  sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSHRC" || true

  # 💡 Apply preconfigured .p10k.zsh only in opinionated mode
  if [[ "$OPINIONATED" == "true" ]]; then
    echo "Applying default Powerlevel10k configuration..."
    cp "$(dirname "$0")/assets/p10k.zsh" "$USER_HOME/.p10k.zsh"
    chown "$USERNAME:$USERNAME" "$USER_HOME/.p10k.zsh"
    grep -qxF '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' "$ZSHRC" || echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >>"$ZSHRC"
  fi
fi

# Autosuggestions plugin
if [[ "$AUTOSUGGESTIONS" == "true" ]]; then
  PLUGIN_DIR="${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
  if [ ! -d "$PLUGIN_DIR" ]; then
    echo "Installing zsh-autosuggestions..."
    su - "$USERNAME" -c "git clone https://github.com/zsh-users/zsh-autosuggestions $PLUGIN_DIR"
  fi
  grep -qxF "source ${PLUGIN_DIR}/zsh-autosuggestions.zsh" "$ZSHRC" || echo "source ${PLUGIN_DIR}/zsh-autosuggestions.zsh" >>"$ZSHRC"
  grep -qxF "ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='$AUTOSUGGESTHIGHLIGHT'" "$ZSHRC" || echo "ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='$AUTOSUGGESTHIGHLIGHT'" >>"$ZSHRC"
fi

# Syntax Highlighting plugin
if [[ "$SYNTAXHIGHLIGHTING" == "true" ]]; then
  PLUGIN_DIR="${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
  if [ ! -d "$PLUGIN_DIR" ]; then
    echo "Installing zsh-syntax-highlighting..."
    su - "$USERNAME" -c "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $PLUGIN_DIR"
  fi
  grep -qxF "source ${PLUGIN_DIR}/zsh-syntax-highlighting.zsh" "$ZSHRC" || echo "source ${PLUGIN_DIR}/zsh-syntax-highlighting.zsh" >>"$ZSHRC"
fi

# Ownership
chown -R "$USERNAME:$USERNAME" "$USER_HOME"
echo "✅ Shell configuration complete for $USERNAME"
[[ "$OPINIONATED" == "true" ]] && echo "(💡 opinionated Powerlevel10k config applied)"
