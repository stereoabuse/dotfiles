#!/usr/bin/env bash
# Regenerate manifests/ from the current system state.
# Run this before committing to capture new installs.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$REPO_ROOT/manifests"
mkdir -p "$OUT"

say() { printf "\033[1;34m==>\033[0m %s\n" "$*"; }

if command -v brew >/dev/null; then
  say "brew"
  brew bundle dump --describe --file="$OUT/Brewfile" --force
  brew leaves        > "$OUT/brew-leaves.txt"
  brew list --formula > "$OUT/brew-formulae.txt"
  brew list --cask    > "$OUT/brew-casks.txt"
  brew tap            > "$OUT/brew-taps.txt"
fi

if command -v mas >/dev/null; then
  say "mas (App Store)"
  mas list > "$OUT/mas.txt"
fi

if command -v npm >/dev/null; then
  say "npm global"
  # Drop the leading "<prefix>/lib" line so we don't commit a personal path.
  npm ls -g --depth=0 2>&1 | tail -n +2 > "$OUT/npm-global.txt" || true
fi

if command -v cargo >/dev/null; then
  say "cargo"
  cargo install --list > "$OUT/cargo-installed.txt" 2>&1 || true
fi

if command -v gem >/dev/null; then
  say "gem"
  gem list --local > "$OUT/gems.txt"
fi

if command -v pip3 >/dev/null; then
  say "pip3"
  pip3 list          > "$OUT/pip-all.txt"
  pip3 list --user   > "$OUT/pip-user.txt" 2>&1 || true
  pip3 freeze --user > "$OUT/pip-user-freeze.txt" 2>&1 || true
fi

if command -v pipx >/dev/null; then
  say "pipx"
  pipx list --short > "$OUT/pipx.txt" 2>&1 || true
fi

if command -v uv >/dev/null; then
  say "uv tools"
  uv tool list > "$OUT/uv-tools.txt" 2>&1 || true
fi

if command -v code >/dev/null; then
  say "vscode"
  code --list-extensions > "$OUT/vscode-extensions.txt"
fi

if command -v cursor >/dev/null; then
  say "cursor"
  cursor --list-extensions > "$OUT/cursor-extensions.txt" 2>&1 || true
fi

if command -v asdf >/dev/null; then
  say "asdf"
  asdf current > "$OUT/asdf-current.txt" 2>&1 || true
fi

if command -v mise >/dev/null; then
  say "mise"
  mise ls > "$OUT/mise-ls.txt" 2>&1 || true
fi

say "done — manifests written to $OUT"
