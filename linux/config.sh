#!/bin/bash

# Linux Configuration Script
# Supports Arch, Debian, and Fedora-based distributions

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[Linux]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[Linux]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[Linux]${NC} $1"
}

print_error() {
    echo -e "${RED}[Linux]${NC} $1"
}

# Function to detect Linux distribution
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        case "$ID" in
            arch|manjaro|endeavouros|artix|garuda)
                echo "arch"
                ;;
            ubuntu|debian|linuxmint|pop|elementary|zorin|kali)
                echo "debian"
                ;;
            fedora|rhel|centos|rocky|almalinux|nobara)
                echo "fedora"
                ;;
            *)
                # Try to detect based on package managers
                if command -v pacman >/dev/null 2>&1; then
                    echo "arch"
                elif command -v apt >/dev/null 2>&1; then
                    echo "debian"
                elif command -v dnf >/dev/null 2>&1; then
                    echo "fedora"
                else
                    echo "unknown"
                fi
                ;;
        esac
    else
        echo "unknown"
    fi
}

# Function to update package repositories
update_repos() {
    local distro="$1"
    
    print_status "Updating package repositories..."
    
    case "$distro" in
        "arch")
            sudo pacman -Sy
            ;;
        "debian")
            sudo apt update
            ;;
        "fedora")
            sudo dnf check-update || true  # dnf returns 100 if updates available
            ;;
    esac
}

# Function to install yay (AUR helper for Arch)
install_yay() {
    if command -v yay >/dev/null 2>&1; then
        print_success "yay is already installed"
        return
    fi
    
    print_status "Installing yay (AUR helper)..."
    
    # Install dependencies
    sudo pacman -S --needed --noconfirm base-devel git
    
    # Clone and build yay
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    rm -rf "$temp_dir"
    
    print_success "yay installed successfully"
}

# Function to enable non-free repositories for Debian-based systems
enable_nonfree_repos() {
    print_status "Checking and enabling non-free repositories..."
    
    local sources_file="/etc/apt/sources.list"
    local sources_dir="/etc/apt/sources.list.d"
    
    # Check if non-free is already enabled
    if grep -r "non-free" "$sources_file" "$sources_dir"/ 2>/dev/null | grep -v "^#" >/dev/null; then
        print_success "Non-free repositories already enabled"
        return
    fi
    
    # Detect if this is Ubuntu or Debian
    source /etc/os-release
    case "$ID" in
        ubuntu|pop|elementary|zorin|linuxmint)
            print_status "Ubuntu-based system detected, enabling universe and multiverse..."
            sudo add-apt-repository universe -y
            sudo add-apt-repository multiverse -y
            ;;
        debian)
            print_status "Debian system detected, enabling non-free and contrib..."
            # Backup original sources.list
            sudo cp "$sources_file" "$sources_file.backup"
            
            # Add non-free and contrib to existing entries
            sudo sed -i 's/main$/main contrib non-free/g' "$sources_file"
            ;;
        kali)
            print_status "Kali Linux detected, non-free repos should already be enabled"
            ;;
        *)
            print_warning "Unknown Debian-based distribution, manual repository configuration may be needed"
            ;;
    esac
    
    print_status "Updating package lists after repository changes..."
    sudo apt update
}

# Function to configure Fedora-based systems
configure_fedora() {
    print_status "Configuring Fedora-based system..."
    
    # Enable RPM Fusion repositories
    print_status "Enabling RPM Fusion repositories..."
    sudo dnf install -y \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm 2>/dev/null || true
    
    # Enable Flathub
    print_status "Enabling Flathub repository..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
    
    # Install development tools
    print_status "Installing development tools..."
    sudo dnf groupinstall -y "Development Tools" "Development Libraries" || true
    
    # Enable faster DNF downloads
    print_status "Configuring DNF for faster downloads..."
    echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf >/dev/null
    echo 'fastestmirror=True' | sudo tee -a /etc/dnf/dnf.conf >/dev/null
    
    print_success "Fedora configuration completed"
}

# Function to install packages based on distribution
install_packages() {
    local distro="$1"
    
    print_status "Installing essential packages..."
    
    # Common packages we want to install
    local packages=(
        "vim"
        "tmux"
        "htop"
        "git"
        "curl"
        "wget"
        "fish"
        "stow"
    )
    
    case "$distro" in
        "arch")
            # Install packages with pacman
            for package in "${packages[@]}"; do
                if pacman -Qi "$package" >/dev/null 2>&1; then
                    print_status "✓ $package already installed"
                else
                    print_status "Installing $package..."
                    sudo pacman -S --needed --noconfirm "$package"
                fi
            done
            
            # Install neovim and fastfetch
            if pacman -Qi "neovim" >/dev/null 2>&1; then
                print_status "✓ neovim already installed"
            else
                print_status "Installing neovim..."
                sudo pacman -S --needed --noconfirm neovim
            fi
            
            if pacman -Qi "fastfetch" >/dev/null 2>&1; then
                print_status "✓ fastfetch already installed"
            else
                print_status "Installing fastfetch..."
                sudo pacman -S --needed --noconfirm fastfetch
            fi
            
            # Install starship via AUR with yay
            if command -v starship >/dev/null 2>&1; then
                print_status "✓ starship already installed"
            else
                print_status "Installing starship via yay..."
                yay -S --needed --noconfirm starship
            fi
            ;;
            
        "debian")
            # Install packages with apt
            for package in "${packages[@]}"; do
                if dpkg -l | grep -q "^ii  $package "; then
                    print_status "✓ $package already installed"
                else
                    print_status "Installing $package..."
                    sudo apt install -y "$package"
                fi
            done
            
            # Install neovim
            if dpkg -l | grep -q "^ii  neovim "; then
                print_status "✓ neovim already installed"
            else
                print_status "Installing neovim..."
                sudo apt install -y neovim
            fi
            
            # Install fastfetch (may need to build from source on older systems)
            if command -v fastfetch >/dev/null 2>&1; then
                print_status "✓ fastfetch already installed"
            else
                print_status "Installing fastfetch..."
                # Try to install from package first
                sudo apt install -y fastfetch 2>/dev/null || {
                    print_warning "fastfetch not available in repositories, installing from GitHub..."
                    local temp_dir=$(mktemp -d)
                    cd "$temp_dir"
                    curl -sL https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb -o fastfetch.deb
                    sudo dpkg -i fastfetch.deb || sudo apt install -f -y
                    cd ~
                    rm -rf "$temp_dir"
                }
            fi
            
            # Install starship
            if command -v starship >/dev/null 2>&1; then
                print_status "✓ starship already installed"
            else
                print_status "Installing starship..."
                curl -sS https://starship.rs/install.sh | sh -s -- -y
            fi
            ;;
            
        "fedora")
            # Install packages with dnf
            for package in "${packages[@]}"; do
                if rpm -q "$package" >/dev/null 2>&1; then
                    print_status "✓ $package already installed"
                else
                    print_status "Installing $package..."
                    sudo dnf install -y "$package"
                fi
            done
            
            # Install neovim
            if rpm -q "neovim" >/dev/null 2>&1; then
                print_status "✓ neovim already installed"
            else
                print_status "Installing neovim..."
                sudo dnf install -y neovim
            fi
            
            # Install fastfetch
            if command -v fastfetch >/dev/null 2>&1; then
                print_status "✓ fastfetch already installed"
            else
                print_status "Installing fastfetch..."
                sudo dnf install -y fastfetch || {
                    print_warning "fastfetch not available in repositories, installing from GitHub..."
                    local temp_dir=$(mktemp -d)
                    cd "$temp_dir"
                    curl -sL https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.rpm -o fastfetch.rpm
                    sudo rpm -i fastfetch.rpm
                    cd ~
                    rm -rf "$temp_dir"
                }
            fi
            
            # Install starship
            if command -v starship >/dev/null 2>&1; then
                print_status "✓ starship already installed"
            else
                print_status "Installing starship..."
                curl -sS https://starship.rs/install.sh | sh -s -- -y
            fi
            ;;
    esac
}

# Function to create symlinks for Linux-specific dotfiles using GNU Stow
link_linux_dotfiles() {
    print_status "Creating symlinks for Linux-specific dotfiles using GNU Stow..."
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local dotfiles_root="$(dirname "$script_dir")"  # Go up one level to dotfiles root
    
    # Check if there are any Linux-specific dotfiles
    if [[ ! -d "$script_dir" ]] || [[ -z "$(find "$script_dir" -maxdepth 1 -name ".*" -not -name "." -not -name ".." 2>/dev/null)" ]]; then
        print_status "No Linux-specific dotfiles found, skipping..."
        return 0
    fi
    
    print_status "Using GNU Stow to manage Linux dotfiles..."
    
    # Change to dotfiles root directory (parent of linux/)
    cd "$dotfiles_root"
    
    # Use stow with --adopt to handle existing files
    if stow --target="$HOME" --verbose --adopt linux; then
        print_success "GNU Stow successfully linked Linux dotfiles"
    else
        print_error "GNU Stow failed to link Linux dotfiles"
        return 1
    fi
    
    # Return to original directory
    cd - >/dev/null
}

# Function to setup shell environment
setup_shell() {
    print_status "Setting up shell environment..."
    
    # Add starship to shell profiles if not already present
    local shells_configured=0
    
    # Configure bash
    if [[ -f "$HOME/.bashrc" ]]; then
        if ! grep -q "starship init bash" "$HOME/.bashrc"; then
            echo 'eval "$(starship init bash)"' >> "$HOME/.bashrc"
            print_success "Added starship to ~/.bashrc"
            ((shells_configured++))
        fi
    fi
    
    # Configure fish
    if command -v fish >/dev/null 2>&1; then
        local fish_config_dir="$HOME/.config/fish"
        local fish_config="$fish_config_dir/config.fish"
        
        if [[ ! -d "$fish_config_dir" ]]; then
            mkdir -p "$fish_config_dir"
        fi
        
        if [[ ! -f "$fish_config" ]] || ! grep -q "starship init fish" "$fish_config"; then
            echo 'starship init fish | source' >> "$fish_config"
            print_success "Added starship to fish config"
            ((shells_configured++))
        fi
    fi
    
    # Configure zsh if present
    if [[ -f "$HOME/.zshrc" ]]; then
        if ! grep -q "starship init zsh" "$HOME/.zshrc"; then
            echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
            print_success "Added starship to ~/.zshrc"
            ((shells_configured++))
        fi
    fi
    
    if [[ $shells_configured -eq 0 ]]; then
        print_status "Starship already configured or no shell configs found"
    fi
}

# Main function
main() {
    print_status "Starting Linux configuration..."
    
    # Detect distribution
    local distro=$(detect_distro)
    print_status "Detected distribution type: $distro"
    
    if [[ "$distro" == "unknown" ]]; then
        print_error "Unsupported Linux distribution"
        print_error "This script supports Arch, Debian, and Fedora-based distributions"
        exit 1
    fi
    
    # Update repositories
    update_repos "$distro"
    
    # Distribution-specific configuration
    case "$distro" in
        "arch")
            install_yay
            ;;
        "debian")
            enable_nonfree_repos
            ;;
        "fedora")
            configure_fedora
            ;;
    esac
    
    # Install common packages
    install_packages "$distro"
    
    # Link Linux-specific dotfiles
    link_linux_dotfiles
    
    # Setup shell environment
    setup_shell
    
    print_success "Linux configuration completed!"
    print_status "Installed packages: vim, neovim, tmux, htop, fastfetch, fish, starship, stow"
    print_status "Next steps:"
    print_status "1. Restart your terminal or run 'source ~/.bashrc'"
    print_status "2. Try running 'fastfetch' to see system info"
    print_status "3. Consider switching to fish shell with 'chsh -s \$(which fish)'"
}

# Run main function
main "$@"
