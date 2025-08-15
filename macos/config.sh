#!/bin/bash

# macOS Configuration Script
# Links macOS-specific dotfiles and installs packages

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[macOS]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[macOS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[macOS]${NC} $1"
}

print_error() {
    echo -e "${RED}[macOS]${NC} $1"
}

# Function to backup existing files
backup_file() {
    local file="$1"
    local backup_dir="$HOME/.dotfiles-backup"
    
    if [[ -e "$file" && ! -L "$file" ]]; then
        # Create backup directory if it doesn't exist
        mkdir -p "$backup_dir"
        
        # Create backup with timestamp
        local timestamp=$(date +"%Y%m%d_%H%M%S")
        local basename=$(basename "$file")
        local backup_path="$backup_dir/${basename}.backup.$timestamp"
        
        print_warning "Backing up existing file: $file -> $backup_path"
        mv "$file" "$backup_path"
        return 0
    fi
    return 1
}

# Function to create symlinks for macOS-specific dotfiles using GNU Stow
link_macos_dotfiles() {
    print_status "Creating symlinks for macOS-specific dotfiles using GNU Stow..."
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local dotfiles_root="$(dirname "$script_dir")"  # Go up one level to dotfiles root
    
    # Check if stow is installed, install if not
    if ! command -v stow >/dev/null 2>&1; then
        print_status "GNU Stow not found, installing..."
        if command -v brew >/dev/null 2>&1; then
            brew install stow
        else
            print_error "Homebrew not found. Please install GNU Stow manually."
            return 1
        fi
    fi
    
    print_status "Using GNU Stow to manage dotfiles..."
    
    # Change to dotfiles root directory (parent of macos/)
    cd "$dotfiles_root"
    
    # Use stow with --adopt to handle existing files
    print_status "Using --adopt to handle existing dotfiles (they will be moved into the repo)"
    if stow --target="$HOME" --verbose --adopt macos; then
        print_success "GNU Stow successfully linked macOS dotfiles"
        print_status "Dotfiles from macos/ have been symlinked to your home directory"
        print_warning "Existing files were adopted into the dotfiles repo"
        print_status "You may want to review and commit any changes to your dotfiles repo"
    else
        print_error "GNU Stow failed to link dotfiles"
        print_status "Run 'stow --target=$HOME --verbose --adopt macos' from the dotfiles directory to retry"
        return 1
    fi
    
    # Return to original directory
    cd - >/dev/null
}

# Function to install Homebrew
install_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        print_success "Homebrew is already installed"
        return
    fi
    
    print_status "Installing Homebrew..."
    # Use non-interactive installation
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ "$(uname -m)" == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    
    print_success "Homebrew installed successfully"
}

# Function to install essential packages
install_packages() {
    print_status "Installing essential macOS packages..."
    
    # Update Homebrew
    brew update
    
    # Applications
    print_status "Installing applications..."
    local gui_apps=(
        "firefox"
        "maccy"
        "amethyst"
        "kitty"
    )
    
    for app in "${gui_apps[@]}"; do
        if brew list "$app" >/dev/null 2>&1; then
            print_status "✓ $app already installed"
        else
            print_status "Installing $app..."
            brew install "$app"
        fi
    done
    
    # Development Tools
    print_status "Installing development tools..."
    local dev_tools=(
        "font-hack-nerd-font"
        "neovim"
        "starship"
    )
    
    for tool in "${dev_tools[@]}"; do
        if brew list "$tool" >/dev/null 2>&1; then
            print_status "✓ $tool already installed"
        else
            print_status "Installing $tool..."
            brew install "$tool"
        fi
    done
    
    # GNU tools (replacing BSD versions)
    print_status "Installing GNU utilities..."
    local gnu_tools=(
        "stow"
        "wget"
        "curl"
        "grep"
        "make"
        "openssh"
        "bash"
        "coreutils"
        "findutils"
        "gnu-sed"
        "gnu-tar"
        "gawk"
        "gnutls"
        "gnu-indent"
        "gnu-which"
    )
    
    for tool in "${gnu_tools[@]}"; do
        if brew list "$tool" >/dev/null 2>&1; then
            print_status "✓ $tool already installed"
        else
            print_status "Installing $tool..."
            brew install "$tool"
        fi
    done
    
    # Modern CLI tools
    print_status "Installing modern tooling..."
    local modern_tools=(
        "ripgrep"
        "eza"
        "bat"
        "fd"
        "fzf"
        "git"
        "vim"
        "tmux"
        "htop"
        "tree"
        "jq"
        "delta"
        "lazygit"
    )
    
    for tool in "${modern_tools[@]}"; do
        if brew list "$tool" >/dev/null 2>&1; then
            print_status "✓ $tool already installed"
        else
            print_status "Installing $tool..."
            brew install "$tool"
        fi
    done
    
    # Zsh extensions and dependencies
    print_status "Installing zsh extensions and deps..."
    local zsh_tools=(
        "zsh-syntax-highlighting"
        "zsh-autosuggestions"
        "vivid"
    )
    
    for tool in "${zsh_tools[@]}"; do
        if brew list "$tool" >/dev/null 2>&1; then
            print_status "✓ $tool already installed"
        else
            print_status "Installing $tool..."
            brew install "$tool"
        fi
    done
    
    # Programming Language Support (commented out by default)
    # Uncomment if you want these installed automatically
    # print_status "Installing programming languages and toolchains..."
    # brew install node python3 go zig zls rustup-init llvm gcc
    # rustup-init -y
    # brew install rust-analyzer
}

# Function to configure macOS settings
configure_macos() {
    print_status "Fixing various macOS Desktop Annoyances..."
    
    # Trackpad and Mouse Settings
    print_status "Configuring trackpad and mouse..."
    # Reverse trackpad scroll direction (natural scroll off)
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
    
    # Lower trackpad click weight
    defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 0
    defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int 0
    
    # Normalize trackpad tracking speed
    defaults write NSGlobalDomain com.apple.trackpad.scaling -float 1.0
    
    # Enable trackpad tap to click
    defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    
    # Keyboard Settings
    print_status "Configuring keyboard..."
    # Set keyboard repeat rates to highest values
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    
    # Disable automatic spelling correction
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
    
    # Display Settings
    print_status "Configuring display settings..."
    # Disable auto adjust display brightness
    defaults write com.apple.BezelServices dAuto -bool false
    defaults write com.apple.iokit.AmbientLightSensor "Automatic Display Enabled" -bool false
    
    # Sound Settings
    print_status "Configuring sound..."
    # Set alert sound to pong
    defaults write NSGlobalDomain com.apple.sound.beep.sound -string "/System/Library/Sounds/Pong.aiff"
    
    # Safari Privacy Settings (may require Safari to be closed)
    print_status "Configuring Safari privacy..."
    # Check if Safari is running and warn user
    if pgrep -x "Safari" > /dev/null; then
        print_warning "Safari is currently running. These settings may not apply until Safari is restarted."
    fi
    
    # Try to set Safari preferences (may fail due to sandboxing)
    defaults write com.apple.Safari UniversalSearchEnabled -bool false 2>/dev/null || print_warning "Could not set Safari UniversalSearchEnabled (Safari may need to be closed)"
    defaults write com.apple.Safari SuppressSearchSuggestions -bool true 2>/dev/null || print_warning "Could not set Safari SuppressSearchSuggestions (Safari may need to be closed)"
    defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true 2>/dev/null || print_warning "Could not set Safari SendDoNotTrackHTTPHeader (Safari may need to be closed)"
    
    print_status "Safari privacy settings attempted (some may require manual configuration)"
    print_status "Manual Safari configuration needed:"
    print_status "* Disable 'Include search engine suggestions' in Safari > Settings > Search"
    print_status "* Enable 'Ask websites not to track me' in Safari > Settings > Privacy"
    print_status "* Disable 'Include Spotlight Suggestions' in Safari > Settings > Search"
    
    # Window and Animation Settings
    print_status "Configuring animations and window behavior..."
    # Disable window transition animations and reduce motion
    defaults write com.apple.dock workspaces-auto-swoosh -bool false
    defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
    defaults write NSGlobalDomain NSScrollAnimationEnabled -bool false
    defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
    defaults write com.apple.universalaccess reduceMotion -bool true
    
    # Disable grouping windows by application
    defaults write NSGlobalDomain AppleWindowTabbingMode -string "manual"
    
    # Dock Settings
    print_status "Configuring Dock..."
    # Do not show recently viewed apps in dock
    defaults write com.apple.dock show-recents -bool false
    
    # Disable rearrange windows by group
    defaults write com.apple.dock expose-group-apps -bool false
    
    # Set dock to autohide with fast animations
    defaults write com.apple.dock autohide -bool true
    defaults write com.apple.dock autohide-delay -float 0
    defaults write com.apple.dock autohide-time-modifier -float 0.5
    
    # Swap genie to scale effect
    defaults write com.apple.dock mineffect -string "scale"
    
    # Stage Manager and Desktop Settings
    print_status "Configuring Stage Manager and Desktop..."
    # Do not show items on stage manager or desktop
    defaults write com.apple.WindowManager StageManagerHideWidgets -bool true
    defaults write com.apple.finder CreateDesktop -bool false
    
    # Disable stage manager
    defaults write com.apple.WindowManager GloballyEnabled -bool false
    
    # Finder Settings
    print_status "Configuring Finder..."
    # Show filename extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    
    # Show path bar
    defaults write com.apple.finder ShowPathbar -bool true
    
    # Display full POSIX path as Finder window title
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
    
    # Keep folders on top when sorting by name
    defaults write com.apple.finder _FXSortFoldersFirst -bool true
    
    # Show hidden files
    defaults write com.apple.finder AppleShowAllFiles -bool true
    
    # Disable the "Are you sure you want to open this application?" dialog
    defaults write com.apple.LaunchServices LSQuarantine -bool false
    
    # Show battery percentage
    defaults write com.apple.menuextra.battery ShowPercent -string "YES"
    
    print_success "macOS settings configured"
    
    # Apply changes by restarting system services
    print_status "Applying changes..."
    killall Dock 2>/dev/null || true
    killall Finder 2>/dev/null || true
    killall SystemUIServer 2>/dev/null || true
    
    print_warning "Some settings require a restart to take effect"
    print_status "Manual configuration still needed:"
    print_status "* Disable True Tone"
    print_status "* Remap CapsLock to Ctrl"
    print_status "* Delete any unused default applications (iMovie, Garageband, etc)"
    print_status "* Disable startup sound"
}

# Function to setup development directories
setup_dev_environment() {
    print_status "Setting up development environment..."
    
    # Ensure .config directory exists for dotfile symlinking
    if [[ ! -d "$HOME/.config" ]]; then
        mkdir -p "$HOME/.config"
        print_success "Created directory: ~/.config"
    else
        print_status "✓ Directory exists: ~/.config"
    fi
}

# Function to setup shell
setup_shell() {
    print_status "Setting up shell environment..."
    
    # Install vim-plug for vim/neovim
    print_status "Installing vim-plug..."
    if [[ ! -f ~/.vim/autoload/plug.vim ]]; then
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        print_success "vim-plug installed"
    else
        print_status "✓ vim-plug already installed"
    fi
    
    # Configure zsh with Homebrew plugins (no Oh My Zsh)
    if [[ "$SHELL" == *"zsh"* ]]; then
        print_status "Configuring zsh with Homebrew plugins..."
        print_status "✓ Using zsh with starship, syntax-highlighting, and autosuggestions from Homebrew"
    else
        print_status "✓ Not using zsh, skipping zsh configuration"
    fi
}

# Main function
main() {
    print_status "Starting macOS configuration..."
    
    # Link macOS-specific dotfiles first
    link_macos_dotfiles
    
    # Install Homebrew
    install_homebrew
    
    # Install packages
    install_packages
    
    # Setup development environment
    setup_dev_environment
    
    # Setup shell
    setup_shell
    
    # Configure macOS settings
    configure_macos
    
    print_success "macOS configuration completed!"
    print_status "Restart your terminal or source ~/.zshrc to load new configurations"
    print_status "Some macOS settings may require a restart"
}

# Run main function
main "$@"
