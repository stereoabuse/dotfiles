#!/usr/bin/env bash
# Restore apt + npm-global packages from ubuntu/manifests/.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFESTS="$REPO_ROOT/manifests"

say() { printf "\033[1;34m==>\033[0m %s\n" "$*"; }

if [[ -f "$MANIFESTS/apt.txt" ]]; then
  say "apt install (from manifests/apt.txt)"
  mapfile -t pkgs < <(grep -vE '^\s*(#|$)' "$MANIFESTS/apt.txt")
  if ((${#pkgs[@]})); then
    sudo apt-get update
    sudo apt-get install -y "${pkgs[@]}"
  fi
fi

if [[ -f "$MANIFESTS/npm-global.txt" ]] && command -v npm >/dev/null 2>&1; then
  say "npm install -g (from manifests/npm-global.txt)"
  mapfile -t npkgs < <(grep -vE '^\s*(#|$)' "$MANIFESTS/npm-global.txt")
  if ((${#npkgs[@]})); then
    npm install -g "${npkgs[@]}"
  fi
fi
