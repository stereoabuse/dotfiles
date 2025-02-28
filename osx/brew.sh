#!/usr/bin/env bash

# Set up error handling
set -e  # Exit immediately if a command exits with a non-zero status
set -o pipefail  # Return value of a pipeline is the value of the last command to exit with non-zero status

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Installing now..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for the current session if it was just installed
    if [[ $(uname -m) == "arm64" ]]; then
        echo "Adding Homebrew to PATH for Apple Silicon..."
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo "Adding Homebrew to PATH for Intel Mac..."
        eval "$(/usr/local/bin/brew shellenv)"
    fi
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
        # Additional useful packages
        jq ripgrep fd bat exa fzf gh
    )

    echo "Installing/updating brew packages..."
    for package in "${packages[@]}"; do
        if brew list "$package" &>/dev/null; then
            echo "Upgrading $package..."
            brew upgrade "$package" || echo "Failed to upgrade $package, continuing..."
        else
            echo "Installing $package..."
            brew install "$package" || echo "Failed to install $package, continuing..."
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

    echo "Installing/updating cask applications..."
    for app in "${apps[@]}"; do
        if brew list --cask "$app" &>/dev/null; then
            echo "Upgrading $app..."
            brew upgrade --cask "$app" || echo "Failed to upgrade $app, continuing..."
        else
            echo "Installing $app..."
            brew install --cask "$app" || echo "Failed to install $app, continuing..."
        fi
    done
}

# Function to install Mac App Store apps using mas
install_mas_apps() {
    # Check if mas is installed
    if ! command -v mas &> /dev/null; then
        echo "Installing mas (Mac App Store command line interface)..."
        brew install mas
    fi

    # Check if user is signed in to the App Store
    if ! mas account &>/dev/null; then
        echo "⚠️ You are not signed in to the App Store. Please sign in to install Mac App Store apps."
    else
        echo "Installing Mac App Store apps..."
        # Add your Mac App Store apps here with their IDs
        # Format: mas install 123456789  # App Name
        # mas install 497799835  # Xcode
        # mas install 409183694  # Keynote
    fi
}

# Function to install Homebrew taps
install_taps() {
    local taps=(
        homebrew/cask-fonts
        homebrew/cask-versions
    )

    echo "Installing Homebrew taps..."
    for tap in "${taps[@]}"; do
        brew tap "$tap" || echo "Failed to tap $tap, continuing..."
    done
    
    # Install some fonts as an example
    brew install --cask font-fira-code font-jetbrains-mono
}

# Main execution
echo "Starting Homebrew setup..."

# Update Homebrew formulae
brew update

# Install taps first
install_taps

# Install packages and applications
install_brew_packages
install_cask_apps
install_mas_apps

echo "Cleaning up..."
brew cleanup

echo "Installation complete!"
echo "Some tools might require additional configuration. Check their documentation."