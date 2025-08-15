#!/bin/bash

# Dotfiles Installation Script
# Supports macOS and Linux (Debian, Arch, Fedora)

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to detect operating system
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

# Function to create symlinks for generic dotfiles
link_generic_dotfiles() {
    print_status "Creating symlinks for generic dotfiles..."
    
    local dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local home_dir="$HOME"
    
    # Find all dotfiles and dotfolders in root (excluding OS-specific directories)
    for item in "$dotfiles_dir"/.* "$dotfiles_dir"/.*; do
        # Skip if item doesn't exist, is . or .., or is git-related
        [[ ! -e "$item" ]] && continue
        [[ "$(basename "$item")" == "." ]] && continue
        [[ "$(basename "$item")" == ".." ]] && continue
        [[ "$(basename "$item")" == ".git" ]] && continue
        [[ "$(basename "$item")" == ".gitignore" ]] && continue
        
        local item_name="$(basename "$item")"
        local target="$home_dir/$item_name"
        
        # Skip OS-specific directories
        [[ "$item_name" == "macos" ]] && continue
        [[ "$item_name" == "linux" ]] && continue
        
        if [[ -L "$target" ]]; then
            print_warning "Symlink already exists: $target"
        elif [[ -e "$target" ]]; then
            print_warning "File/directory already exists: $target (skipping)"
        else
            ln -s "$item" "$target"
            print_success "Created symlink: $target -> $item"
        fi
    done
}

# Main installation function
main() {
    print_status "Starting dotfiles installation..."
    
    # Detect operating system
    local os=$(detect_os)
    print_status "Detected operating system: $os"
    
    # Get the directory where this script is located
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    case "$os" in
        "macos")
            local config_script="$script_dir/macos/config.sh"
            if [[ -f "$config_script" ]]; then
                print_status "Running macOS configuration..."
                chmod +x "$config_script"
                "$config_script"
            else
                print_error "macOS config script not found: $config_script"
                exit 1
            fi
            ;;
        "linux")
            local config_script="$script_dir/linux/config.sh"
            if [[ -f "$config_script" ]]; then
                print_status "Running Linux configuration..."
                chmod +x "$config_script"
                "$config_script"
            else
                print_error "Linux config script not found: $config_script"
                exit 1
            fi
            ;;
        "unknown")
            print_error "Unsupported operating system: $OSTYPE"
            print_error "This script supports macOS and Linux only."
            exit 1
            ;;
    esac
    
    # Create symlinks for generic dotfiles
    link_generic_dotfiles
    
    print_success "Dotfiles installation completed!"
    print_status "You may need to restart your shell or source your configuration files."
}

# Show help message
show_help() {
    cat << EOF
Dotfiles Installation Script

Usage: $0 [OPTIONS]

OPTIONS:
    -h, --help      Show this help message
    --dry-run       Show what would be done without making changes
    --force         Force overwrite existing files (use with caution)

This script will:
1. Detect your operating system (macOS or Linux)
2. Run the appropriate OS-specific configuration script
3. Create symlinks for generic dotfiles in the repository root

Directory Structure Expected:
├── install.sh          # This script
├── macos/
│   └── config.sh       # macOS-specific configuration
├── linux/
│   └── config.sh       # Linux-specific configuration
├── .vimrc              # Generic dotfiles
├── .bashrc
└── ...

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        --dry-run)
            print_warning "Dry run mode not yet implemented"
            exit 0
            ;;
        --force)
            print_warning "Force mode not yet implemented"
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Run main function
main
