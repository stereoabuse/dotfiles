# dotfiles
mostly macos, with some windows and wsl (ubuntu) 

## macOS

```sh
xcode-select --install
git clone https://github.com/stereoabuse/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh
```

## Windows

```powershell
git clone https://github.com/stereoabuse/dotfiles.git $env:USERPROFILE\dotfiles
cd $env:USERPROFILE\dotfiles\windows
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

Flags: `-UseSymlinks`, `-SkipRestore`, `-InstallScoop`.

## Ubuntu

```sh
git clone https://github.com/stereoabuse/dotfiles.git ~/dotfiles
cd ~/dotfiles/ubuntu && ./install.sh
```
