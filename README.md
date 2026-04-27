# dotfiles
mostly macos 


## setup

```sh
xcode-select --install
git clone https://github.com/stereoabuse/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh

```

`install.sh` symlinks everything from `osx/` into `$HOME`, installs `oh-my-zsh`, and runs `osx/scripts/restore-manifests.sh` to `brew bundle` everything in `osx/manifests/`.