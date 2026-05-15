# dotfiles
mostly macos, with windows support


## macOS

```sh
xcode-select --install
git clone https://github.com/stereoabuse/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh
```

`install.sh` symlinks everything from `osx/` into `$HOME`, installs `oh-my-zsh`, and runs `osx/scripts/restore-manifests.sh` to `brew bundle` everything in `osx/manifests/`.

## Windows

```powershell
git clone https://github.com/stereoabuse/dotfiles.git $env:USERPROFILE\dotfiles
cd $env:USERPROFILE\dotfiles\windows
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

`windows/install.ps1` **copies** configs from `windows/` into `$env:USERPROFILE`, then runs `windows/scripts/restore-manifests.ps1` which `winget import`s, `scoop import`s, and reinstalls npm/VS Code/Cursor packages from `windows/manifests/`.

Pass `-UseSymlinks` if you want symlinks instead of copies (requires admin PowerShell *or* Windows Developer Mode enabled). Pass `-SkipRestore` to skip the package install step.
Pass `-InstallScoop` only if you want restore to bootstrap Scoop by running the official installer script from `https://get.scoop.sh`; without it, Scoop packages are restored only when Scoop is already installed.
Keep private Git identity details, like `user.email`, in an untracked `~/.gitconfig.local`; the committed Windows `.gitconfig` includes it if present.
