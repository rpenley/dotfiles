#!/bin/bash

set -e

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPTS_DIR")"

source "$SCRIPTS_DIR/common.sh"

install_homebrew() {
	command -v brew >/dev/null 2>&1 && { print_success "Homebrew already installed"; return; }
	print_status "Installing Homebrew..."
	NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	if [[ "$(uname -m)" == "arm64" ]]; then
		echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
		eval "$(/opt/homebrew/bin/brew shellenv)"
	else
		echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
		eval "$(/usr/local/bin/brew shellenv)"
	fi
	print_success "Homebrew installed"
}

install_packages() {
	print_status "Installing packages via Brewfile..."
	brew update
	brew bundle install --file "$DOTFILES_DIR/Brewfile" --no-lock
	print_success "Packages installed"
}

install_vim_plug() {
	[[ -f ~/.vim/autoload/plug.vim ]] && { print_success "vim-plug already installed"; return; }
	print_status "Installing vim-plug..."
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	print_success "vim-plug installed"
}

configure_macos() {
	print_status "Configuring macOS defaults..."

	# Trackpad
	defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
	defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 0
	defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int 0
	defaults write NSGlobalDomain com.apple.trackpad.scaling -float 1.0
	defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
	defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
	defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

	# Keyboard
	defaults write NSGlobalDomain KeyRepeat -int 2
	defaults write NSGlobalDomain InitialKeyRepeat -int 15
	defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
	defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

	# Display
	defaults write com.apple.BezelServices dAuto -bool false
	defaults write com.apple.iokit.AmbientLightSensor "Automatic Display Enabled" -bool false

	# Sound
	defaults write NSGlobalDomain com.apple.sound.beep.sound -string "/System/Library/Sounds/Pong.aiff"

	# Animations
	defaults write com.apple.dock workspaces-auto-swoosh -bool false
	defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
	defaults write NSGlobalDomain NSScrollAnimationEnabled -bool false
	defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
	defaults write com.apple.universalaccess reduceMotion -bool true
	defaults write NSGlobalDomain AppleWindowTabbingMode -string "manual"

	# Dock
	defaults write com.apple.dock show-recents -bool false
	defaults write com.apple.dock expose-group-apps -bool false
	defaults write com.apple.dock autohide -bool true
	defaults write com.apple.dock autohide-delay -float 0
	defaults write com.apple.dock autohide-time-modifier -float 0.5
	defaults write com.apple.dock mineffect -string "scale"

	# Stage Manager / Desktop
	defaults write com.apple.WindowManager StageManagerHideWidgets -bool true
	defaults write com.apple.finder CreateDesktop -bool false
	defaults write com.apple.WindowManager GloballyEnabled -bool false

	# Finder
	defaults write NSGlobalDomain AppleShowAllExtensions -bool true
	defaults write com.apple.finder ShowPathbar -bool true
	defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
	defaults write com.apple.finder _FXSortFoldersFirst -bool true
	defaults write com.apple.finder AppleShowAllFiles -bool true
	defaults write com.apple.LaunchServices LSQuarantine -bool false
	defaults write com.apple.menuextra.battery ShowPercent -string "YES"

	killall Dock 2>/dev/null || true
	killall Finder 2>/dev/null || true
	killall SystemUIServer 2>/dev/null || true

	print_success "macOS defaults applied"
	print_warning "Manual steps still needed: disable True Tone, remap CapsLock to Ctrl, disable startup sound"
}

main() {
	print_status "Starting macOS configuration..."

	install_homebrew

	# stow needs to be available before stow_package runs
	command -v stow >/dev/null 2>&1 || brew install stow

	stow_package "$DOTFILES_DIR" home
	stow_package "$DOTFILES_DIR" macos

	install_packages
	install_vim_plug
	configure_macos

	print_success "macOS configuration complete"
	print_status "Restart your terminal or run: source ~/.zshrc"
}

main "$@"
