#!/usr/bin/env bash
# Bootstrap a fresh Ubuntu machine: symlink ubuntu/ contents into $HOME,
# install oh-my-zsh and nvm, then restore packages from manifests/.
#
# Safe to re-run; existing files get backed up to $HOME/.dotfiles-backup-<ts>/

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO_ROOT"
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
NVM_VERSION="${NVM_VERSION:-v0.40.1}"

say()  { printf "\033[1;34m==>\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m!!\033[0m %s\n" "$*"; }

if [[ "$(uname)" != "Linux" ]]; then
  warn "this installer targets Linux; for macOS use ../install.sh"
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
  RUNZSH=no KEEP_ZSHRC=yes CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [[ ! -d "$HOME/.nvm" ]]; then
  say "installing nvm $NVM_VERSION"
  PROFILE=/dev/null bash -c \
    "curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash"
fi

say "symlinking \$HOME dotfiles"
for f in .zshrc .bashrc .profile .tmux.conf .vimrc; do
  [[ -e "$SRC/$f" ]] && link "$SRC/$f" "$HOME/$f"
done

say "symlinking ~/.vim"
[[ -d "$SRC/.vim" ]] && link "$SRC/.vim" "$HOME/.vim"

if [[ -x "$SRC/scripts/restore-manifests.sh" ]]; then
  say "restoring packages from manifests"
  bash "$SRC/scripts/restore-manifests.sh"
fi

say "done — see $BACKUP for any files that got replaced"
