#!/bin/bash

set -euo pipefail

ensure_pipenv() {
    if ! command -v pipenv &>/dev/null; then
        echo "pipenv not found. Installing..."
        pip install pipenv
    fi
}

case "${1:-}" in
install)
    echo "Installing backend dependencies..."
    ensure_pipenv
    pipenv install --dev
    ;;
start)
    echo "Starting backend server with Uvicorn..."
    ensure_pipenv
    exec pipenv run uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
    ;;
*)
    echo "Unknown command: $1"
    echo "Usage: $0 {install|start}"
    exit 1
    ;;
esac
