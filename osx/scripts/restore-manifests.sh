#!/usr/bin/env bash
# Reinstall everything listed in manifests/ onto a fresh machine.
# Safe to re-run: each tool is idempotent.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IN="$REPO_ROOT/manifests"

say() { printf "\033[1;34m==>\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m!!\033[0m %s\n" "$*"; }

# Homebrew (bootstrap if missing)
if ! command -v brew >/dev/null; then
  say "installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Load brew into this shell so the rest of the script can call it
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

if [[ -f "$IN/Brewfile" ]]; then
  say "brew bundle"
  brew bundle --file="$IN/Brewfile"
fi

# npm globals
if [[ -f "$IN/npm-global.txt" ]] && command -v npm >/dev/null; then
  say "npm -g"
  # Brewfile + node usually gets these; this is best-effort for the npm list format.
  # Strip tree decoration and the @version suffix; keep scope (@scope/pkg) intact
  # by only matching @<digit>... at end of line.
  awk '/── / {gsub(/^[│ └├─]+/,""); sub(/@[0-9][^ ]*$/,""); if ($0 != "") print}' "$IN/npm-global.txt" \
    | while read -r pkg; do
        [[ -z "$pkg" ]] && continue
        npm i -g "$pkg" || warn "npm i -g $pkg failed"
      done
fi

# cargo
if [[ -f "$IN/cargo-installed.txt" ]] && command -v cargo >/dev/null; then
  say "cargo install"
  awk '/^[a-zA-Z0-9_-]+ v/ {print $1}' "$IN/cargo-installed.txt" \
    | while read -r crate; do cargo install "$crate" || warn "cargo install $crate failed"; done
fi

# gems
if [[ -f "$IN/gems.txt" ]] && command -v gem >/dev/null; then
  say "gems"
  awk '{print $1}' "$IN/gems.txt" | grep -v '^$' \
    | while read -r g; do gem install "$g" || warn "gem install $g failed"; done
fi

# pip user
if [[ -f "$IN/pip-user-freeze.txt" ]] && command -v pip3 >/dev/null; then
  say "pip3 --user"
  pip3 install --user -r "$IN/pip-user-freeze.txt" || warn "some pip user installs failed"
fi

# pipx / uv
if [[ -f "$IN/pipx.txt" ]] && command -v pipx >/dev/null; then
  say "pipx"
  awk '{print $1}' "$IN/pipx.txt" | while read -r p; do pipx install "$p" || true; done
fi
if [[ -f "$IN/uv-tools.txt" ]] && command -v uv >/dev/null; then
  say "uv tool"
  awk '{print $1}' "$IN/uv-tools.txt" | while read -r t; do uv tool install "$t" || true; done
fi

# vscode / cursor
if [[ -f "$IN/vscode-extensions.txt" ]] && command -v code >/dev/null; then
  say "vscode extensions"
  while read -r ext; do [[ -n "$ext" ]] && code --install-extension "$ext" || true; done < "$IN/vscode-extensions.txt"
fi
if [[ -f "$IN/cursor-extensions.txt" ]] && command -v cursor >/dev/null; then
  say "cursor extensions"
  while read -r ext; do [[ -n "$ext" ]] && cursor --install-extension "$ext" || true; done < "$IN/cursor-extensions.txt"
fi

say "done — see manifests/manual-binaries.md for curl-installed tools"
