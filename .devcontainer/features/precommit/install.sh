#!/bin/bash
set -e

USERNAME="${_REMOTE_USER:-vscode}"
INSTALL_GLOBAL="${GLOBAL:-true}"

echo "Installing pre-commit for user: $USERNAME..."

# Detect OS and architecture
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Get package manager based on OS
get_package_manager() {
    local os=$1
    case $os in
        "linux")
            if command -v apt-get >/dev/null 2>&1; then
                echo "apt"
            elif command -v yum >/dev/null 2>&1; then
                echo "yum"
            elif command -v dnf >/dev/null 2>&1; then
                echo "dnf"
            elif command -v apk >/dev/null 2>&1; then
                echo "apk"
            else
                echo "unknown"
            fi
            ;;
        "macos")
            if command -v brew >/dev/null 2>&1; then
                echo "brew"
            else
                echo "unknown"
            fi
            ;;
        "windows")
            if command -v choco >/dev/null 2>&1; then
                echo "choco"
            elif command -v winget >/dev/null 2>&1; then
                echo "winget"
            else
                echo "unknown"
            fi
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Install dependencies based on OS and package manager
install_dependencies() {
    local os=$1
    local pkg_mgr=$2
    
    echo "Detected OS: $os, Package Manager: $pkg_mgr"
    
    case $pkg_mgr in
        "apt")
            if ! command -v python3 >/dev/null 2>&1 || ! command -v pipx >/dev/null 2>&1; then
                echo "Installing Python and pipx via apt..."
                apt-get update
                apt-get install -y python3 python3-pip python3-venv pipx
            fi
            ;;
        "yum"|"dnf")
            if ! command -v python3 >/dev/null 2>&1 || ! command -v pipx >/dev/null 2>&1; then
                echo "Installing Python and pipx via $pkg_mgr..."
                $pkg_mgr install -y python3 python3-pip
                python3 -m pip install --user pipx
            fi
            ;;
        "apk")
            if ! command -v python3 >/dev/null 2>&1 || ! command -v pipx >/dev/null 2>&1; then
                echo "Installing Python and pipx via apk..."
                apk add --no-cache python3 py3-pip
                python3 -m pip install --user pipx --break-system-packages
            fi
            ;;
        "brew")
            if ! command -v python3 >/dev/null 2>&1; then
                echo "Installing Python via brew..."
                brew install python
            fi
            if ! command -v pipx >/dev/null 2>&1; then
                echo "Installing pipx via brew..."
                brew install pipx
            fi
            ;;
        "choco")
            if ! command -v python >/dev/null 2>&1; then
                echo "Installing Python via chocolatey..."
                choco install python -y
            fi
            if ! command -v pipx >/dev/null 2>&1; then
                echo "Installing pipx via pip..."
                python -m pip install --user pipx
            fi
            ;;
        "winget")
            if ! command -v python >/dev/null 2>&1; then
                echo "Installing Python via winget..."
                winget install Python.Python.3
            fi
            if ! command -v pipx >/dev/null 2>&1; then
                echo "Installing pipx via pip..."
                python -m pip install --user pipx
            fi
            ;;
        *)
            echo "Unknown package manager. Attempting pip installation..."
            if command -v python3 >/dev/null 2>&1; then
                if ! command -v pipx >/dev/null 2>&1; then
                    python3 -m pip install --user pipx --break-system-packages 2>/dev/null || \
                    python3 -m pip install --user pipx
                fi
            elif command -v python >/dev/null 2>&1; then
                if ! command -v pipx >/dev/null 2>&1; then
                    python -m pip install --user pipx
                fi
            else
                echo "Error: Python not found and cannot install dependencies"
                exit 1
            fi
            ;;
    esac
}

# Ensure pipx is in PATH
ensure_pipx_path() {
    local user_home
    if [[ "$USERNAME" == "root" ]]; then
        user_home="/root"
    else
        user_home="/home/$USERNAME"
    fi
    
    # Add pipx to PATH if not already there
    local pipx_bin="$user_home/.local/bin"
    if [[ ":$PATH:" != *":$pipx_bin:"* ]] && [[ -d "$pipx_bin" ]]; then
        export PATH="$pipx_bin:$PATH"
        echo "Added $pipx_bin to PATH"
    fi
}

# Check if pre-commit is already installed (idempotent check)
is_precommit_installed() {
    if command -v pre-commit >/dev/null 2>&1; then
        echo "pre-commit is already installed globally"
        return 0
    fi
    
    # Check user installation
    if su - "$USERNAME" -c "command -v pre-commit" >/dev/null 2>&1; then
        echo "pre-commit is already installed for user $USERNAME"
        return 0
    fi
    
    return 1
}

# Install pre-commit using pipx
install_precommit() {
    echo "Installing pre-commit using pipx..."
    
    # Ensure pipx is properly set up for the user
    su - "$USERNAME" -c "pipx ensurepath" 2>/dev/null || true
    
    # Install pre-commit
    if [[ "$INSTALL_GLOBAL" == "true" ]]; then
        # Install for user but make globally accessible
        su - "$USERNAME" -c "pipx install pre-commit"
        
        # Create symlink if needed and we have permissions
        local user_home
        if [[ "$USERNAME" == "root" ]]; then
            user_home="/root"
        else
            user_home="/home/$USERNAME"
        fi
        
        local precommit_bin="$user_home/.local/bin/pre-commit"
        if [[ -f "$precommit_bin" ]] && [[ ! -f "/usr/local/bin/pre-commit" ]] && [[ -w "/usr/local/bin" ]]; then
            ln -sf "$precommit_bin" /usr/local/bin/pre-commit
            echo "Created global symlink for pre-commit"
        fi
    else
        su - "$USERNAME" -c "pipx install pre-commit"
    fi
}

# Main execution
main() {
    # Idempotent check - exit early if already installed
    if is_precommit_installed; then
        echo "pre-commit installation is up to date. Skipping installation."
        exit 0
    fi
    
    # Detect environment
    local os=$(detect_os)
    local pkg_mgr=$(get_package_manager "$os")
    
    # Install dependencies
    install_dependencies "$os" "$pkg_mgr"
    
    # Ensure pipx is in PATH
    ensure_pipx_path
    
    # Install pre-commit
    install_precommit
    
    # Final verification
    echo "Verifying pre-commit installation:"
    if su - "$USERNAME" -c "pre-commit --version" 2>/dev/null; then
        echo "SUCCESS: pre-commit installation successful"
    else
        echo "WARNING: pre-commit installation verification failed"
        exit 1
    fi
}

# Run main function
main
