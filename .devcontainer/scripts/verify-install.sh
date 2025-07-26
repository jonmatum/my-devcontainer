#!/bin/bash
set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
GRAY='\033[0;90m'
BOLD='\033[1m'
NC='\033[0m'

DEVCONTAINER_JSON="${1:-.devcontainer/devcontainer.json}"
TMP_JSON="/tmp/devcontainer-stripped.json"

echo -e "${BOLD}Verifying toolchain setup...${NC}"
echo

# Strip // comments and trailing commas to make JSON safe for jq
sed '/^\s*\/\//d' "$DEVCONTAINER_JSON" | sed 's/, *$//' >"$TMP_JSON" || true

enabled_features=""
if jq empty "$TMP_JSON" 2>/dev/null; then
    enabled_features=$(jq -r '.features | keys[]' "$TMP_JSON")
else
    echo -e "${GRAY}Warning: Could not parse devcontainer.json. Falling back to default checks.${NC}"
fi

check() {
    local label="$1"
    local cmd="$2"
    local version_cmd="$3"

    printf "  %-15s" "$label"
    if command -v "$cmd" >/dev/null 2>&1; then
        echo -en "${GREEN}✔ Installed${NC}  "
        { eval "$version_cmd" 2>/dev/null || echo "Version unknown"; } | head -n 1 || true
    else
        echo -e "${RED}✘ Not found${NC}"
    fi
}

if [[ -n "$enabled_features" ]]; then
    for feature in $enabled_features; do
        case "$feature" in
        *terraform*) check "Terraform" terraform "terraform --version" ;;
        *aws*) check "AWS CLI" aws "aws --version" ;;
        *node*) check "Node.js" node "node --version && npm --version" ;;
        *python*)
            check "Python" python "python --version && pip --version"
            check "Pipenv" pipenv "pipenv --version"
            ;;
        *shell*) check "Zsh" zsh "zsh --version" ;;
        *opentofu*) check "OpenTofu" tofu "tofu version" ;;
        *precommit*) check "Pre-commit" pre-commit "pre-commit --version" ;;
        esac
    done
else
    # Fallback
    check "AWS CLI" aws "aws --version"
    check "Node.js" node "node --version && npm --version"
    check "OpenTofu" tofu "tofu version"
    check "Pipenv" pipenv "pipenv --version"
    check "Pre-commit" pre-commit "pre-commit --version"
    check "Python" python "python --version && pip --version"
    check "Terraform" terraform "terraform --version"
    check "Zsh" zsh "zsh --version"
fi

echo
echo -e "${BOLD}All checks completed.${NC}"
