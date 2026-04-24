#!/bin/bash

# One-line install:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/USER/dotfiles/main/install.sh)"
# or clone and run:
#   git clone https://github.com/USER/dotfiles ~/dotfiles && ~/dotfiles/install.sh

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$DOTFILES_DIR/scripts/common.sh"

detect_os() {
	case "$OSTYPE" in
		darwin*) echo "macos" ;;
		linux-gnu*) echo "linux" ;;
		*) echo "unknown" ;;
	esac
}

main() {
	print_status "Starting dotfiles install..."

	local os=$(detect_os)
	print_status "OS: $os"

	case "$os" in
		macos)
			chmod +x "$DOTFILES_DIR/scripts/macos.sh"
			"$DOTFILES_DIR/scripts/macos.sh"
			;;
		linux)
			chmod +x "$DOTFILES_DIR/scripts/linux.sh"
			"$DOTFILES_DIR/scripts/linux.sh"
			;;
		unknown)
			print_error "Unsupported OS: $OSTYPE"
			print_status "For Windows run: windows\\install.ps1"
			exit 1
			;;
	esac

	print_success "Done! Restart your shell to pick up all changes."
}

main "$@"
