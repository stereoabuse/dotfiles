#!/usr/bin/env bash
# Bootstrap a fresh macOS machine: symlink osx/ contents into $HOME,
# then run osx/scripts/restore-manifests.sh to reinstall packages.
#
# Safe to re-run; existing files get backed up to $HOME/.dotfiles-backup-<ts>/

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO_ROOT/osx"
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

say()  { printf "\033[1;34m==>\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m!!\033[0m %s\n" "$*"; }

if [[ "$(uname)" != "Darwin" ]]; then
  warn "this installer targets macOS; for Linux see ubuntu/"
  exit 1
fi

mkdir -p "$BACKUP"

link() {
  local src="$1" dest="$2"
  if [[ -L "$dest" ]]; then
    rm "$dest"
  elif [[ -e "$dest" ]]; then
    mkdir -p "$(dirname "$BACKUP/${dest#/}")"
    mv "$dest" "$BACKUP/${dest#/}"
    warn "backed up existing $dest -> $BACKUP/"
  fi
  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "  linked $dest"
}

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  say "installing oh-my-zsh"
  # KEEP_ZSHRC=yes: don't write a template (we symlink ours below)
  # RUNZSH=no:     don't drop into a fresh zsh at the end
  # CHSH=no:       skip 'chsh -s zsh' (zsh is already the default on modern macOS)
  RUNZSH=no KEEP_ZSHRC=yes CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

say "symlinking \$HOME dotfiles"
for f in .zshrc .zprofile .zshenv .profile .gitconfig; do
  [[ -e "$SRC/$f" ]] && link "$SRC/$f" "$HOME/$f"
done

say "symlinking ~/.vim"
[[ -d "$SRC/.vim" ]] && link "$SRC/.vim" "$HOME/.vim"

say "symlinking ~/.config/*"
mkdir -p "$HOME/.config"
for d in "$SRC"/.config/*/; do
  [[ -d "$d" ]] || continue
  link "${d%/}" "$HOME/.config/$(basename "$d")"
done

say "symlinking ~/.claude config"
mkdir -p "$HOME/.claude"
for f in settings.json keybindings.json statusline-command.sh; do
  [[ -f "$SRC/.claude/$f" ]] && link "$SRC/.claude/$f" "$HOME/.claude/$f"
done

if [[ -x "$SRC/scripts/restore-manifests.sh" ]]; then
  say "restoring packages from manifests"
  bash "$SRC/scripts/restore-manifests.sh"
fi

say "done — see $BACKUP for any files that got replaced"
