#!/bin/bash

## Assumes install on an arm64 Macbook
echo "Welcome to the FixMyMac utility"
echo "This Script will fix some annoying defaults"

## TRACKPAD
echo "Setting trackpad scroll direction"
defaults write NSGlobalDomain com.apple.swipescrolldirection bool false

echo "Setting trackpad click weight"
defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold int 0
defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold int 0

echo "Setting trackpad tracking speed"
defaults write NSGlobalDomain com.apple.trackpad.scaling float 1.0

echo "Enable trackpad tap to click"
defaults write com.apple.AppleMultitouchTrackpad Clicking bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior int 1

## KEYBOARD
echo "Setting keyboard repeat rates to highest values"
defaults write NSGlobalDomain KeyRepeat int 2
defaults write NSGlobalDomain InitialKeyRepeat int 15

## DISPLAY
echo "Disable auto adjust brightness"
defaults write com.apple.BezelServices dAuto bool false
defaults write com.apple.iokit.AmbientLightSensor "Automatic Display Enabled" bool false

## AUDIO
echo "Setting alert sound to pong"
defaults write NSGlobalDomain com.apple.sound.beep.sound string "/System/Library/Sounds/Pong.aiff"

## PRIVACY
echo "Disable tracking in Safari"
defaults write com.apple.Safari UniversalSearchEnabled bool false
defaults write com.apple.Safari SuppressSearchSuggestions bool true
defaults write com.apple.Safari SendDoNotTrackHTTPHeader bool true

## WORKSPACES
echo "Disable transition animations and reduce motion"
defaults write com.apple.dock workspaces-auto-swoosh bool false
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled bool false
defaults write NSGlobalDomain NSScrollAnimationEnabled bool false
defaults write NSGlobalDomain NSWindowResizeTime float 0.001
defaults write com.apple.universalaccess reduceMotion bool true

echo "Do not show recently viewed in dock"
defaults write com.apple.dock show-recents bool false

echo "Do not show items on stage manager or desktop"
defaults write com.apple.WindowManager StageManagerHideWidgets bool true
defaults write com.apple.finder CreateDesktop bool false

echo "Disable stage manager"
defaults write com.apple.WindowManager GloballyEnabled bool false

echo "Disable grouping window by application"
defaults write NSGlobalDomain AppleWindowTabbingMode string manual

echo "Disable rearange windows by group"
defaults write com.apple.dock expose-group-apps bool false

echo "Set dock to autohide"
defaults write com.apple.dock autohide bool true
defaults write com.apple.dock autohide-delay float 0
defaults write com.apple.dock autohide-time-modifier float 0.5

echo "Swap genie to scale effect"
defaults write com.apple.dock mineffect string scale

## FINDER
echo "Show filename extensions"
defaults write NSGlobalDomain AppleShowAllExtensions bool true

echo "Show path bar"
defaults write com.apple.finder ShowPathbar bool true

echo "Display full POSIX path as Finder window title"
defaults write com.apple.finder _FXShowPosixPathInTitle bool true

echo "Keep folders on top when sorting by name"
defaults write com.apple.finder _FXSortFoldersFirst bool true

echo "Show hidden files"
defaults write com.apple.finder AppleShowAllFiles bool true

# APPLY CHANGES
killall Dock
killall Finder
killall SystemUIServer

echo "Configured MacOS Settings\n"
echo "The following settings must be manually configured"
echo "Disable True Tone"
echo "Remap CapsLock to Ctrl"
echo "Delete iMovie, GarageBand, Pages, and Keynote"
echo "Disable startup sound"

## Install Homebrew
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found, installing..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew found, skipping install"
fi

# Applications
echo "Installing applications..."
brew install firefox maccy amethyst kitty

# Development Tools
echo "Installing development tools..."
brew install font-hack-nerd-font neovim starship

# Install GNU tools
echo "Installing GNU utilities..."
brew install wget curl grep make openssh bash coreutils findutils gnu-sed gnu-tar gawk gnutls gnu-indent gnu-which

# Install New tools
echo "Installing modern tooling"
brew install ripgrep eza bat fd

# Programming Language Support
echo "Installing programming languages and toolchains..."
brew install zig zls rustup-init llvm gcc

echo "Installing zsh extensions and deps"
brew install zsh-syntax-highlighting zsh-autocomplete vivid

# Install Rust support
rustup-init -y
brew install rust-analyzer

# Install vim plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "Setup complete! Some settings may require a restart to take full effect."
echo "Please restart your Mac to ensure all changes are applied properly."
echo "For settings that require manual intervention, follow the instructions provided."
