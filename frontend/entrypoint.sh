#!/bin/bash

set -euo pipefail

ensure_pnpm() {
    if ! command -v pnpm &>/dev/null; then
        echo "pnpm not found. Installing pnpm globally..."
        npm install -g pnpm
    fi
}

ensure_installed() {
    if [ ! -d node_modules ]; then
        echo "node_modules missing, running pnpm install..."
        pnpm install
    else
        echo "node_modules already exists. Skipping install."
    fi
}

run_app() {
    if grep -q '"start"' package.json; then
        echo "Running pnpm start..."
        pnpm start
    else
        echo "Running pnpm run dev..."
        pnpm run dev -- --host 0.0.0.0
    fi
}

case "${1:-}" in
install)
    if [ -f package.json ]; then
        ensure_pnpm
        ensure_installed
    else
        echo "No package.json found, skipping dependency installation."
    fi
    ;;
start)
    if [ -f package.json ]; then
        ensure_pnpm
        ensure_installed
        echo "Starting frontend app..."
        run_app
    else
        echo "No package.json found. Exiting."
        exit 1
    fi
    ;;
*)
    echo "Unknown command: $1"
    exit 1
    ;;
esac
