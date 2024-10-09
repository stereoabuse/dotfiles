#!/usr/bin/env bash

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Installing now..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed. Updating..."
    brew update
fi

# Function to install Brew packages
install_brew_packages() {
    local packages=(
        ffmpeg flac git graphviz htop imagemagick lame neofetch neovim nmap node
        openssl@1.1 pandoc pipenv pixman pkg-config pypy3 python@3.12 r sqlite
        srt svt-av1 tcl-tk tmux wget yt-dlp
    )

    for package in "${packages[@]}"; do
        if brew list "$package" &>/dev/null; then
            echo "$package is already installed. Skipping."
        else
            echo "Installing $package..."
            brew install "$package"
        fi
    done
}

# Function to install cask applications
install_cask_apps() {
    local apps=(
        camo-studio chromium dropbox electrum firefox flux github google-chrome
        google-drive gpg-suite guitar-pro iterm2 logitech-options mendeley
        microsoft-excel microsoft-powerpoint microsoft-word obs pycharm-ce
        reaper rectangle spotify steam sublime-text texstudio the-unarchiver
        tor-browser transmission tunnelbear ultimaker-cura virtualbox
        visual-studio-code vlc zoom
    )

    for app in "${apps[@]}"; do
        if brew list --cask "$app" &>/dev/null; then
            echo "$app is already installed. Skipping."
        else
            echo "Installing $app..."
            brew install --cask "$app"
        fi
    done
}

# Main execution
echo "Starting Homebrew package installation..."
install_brew_packages

echo "Starting cask application installation..."
install_cask_apps

echo "Cleaning up..."
brew cleanup

echo "Installation complete!"
