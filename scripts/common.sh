#!/bin/bash

# Shared helpers sourced by linux.sh and macos.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status()  { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[OK]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

backup_file() {
	local file="$1"
	local backup_dir="$HOME/.dotfiles-backup"

	if [[ -e "$file" && ! -L "$file" ]]; then
		mkdir -p "$backup_dir"
		local timestamp=$(date +"%Y%m%d_%H%M%S")
		local backup_path="$backup_dir/$(basename "$file").backup.$timestamp"
		print_warning "Backing up: $file -> $backup_path"
		mv "$file" "$backup_path"
	fi
}

stow_package() {
	local dotfiles_dir="$1"
	local package="$2"

	if [[ ! -d "$dotfiles_dir/$package" ]]; then
		print_warning "Package '$package' not found, skipping"
		return 0
	fi

	print_status "Stowing '$package'..."

	# Backup any existing real files that stow would collide with
	while IFS= read -r -d '' file; do
		local rel="${file#$dotfiles_dir/$package/}"
		local target="$HOME/$rel"
		backup_file "$target"
	done < <(find "$dotfiles_dir/$package" -maxdepth 5 -not -type d -not -name ".stow-local-ignore" -print0)

	cd "$dotfiles_dir"
	if stow --no-folding --target="$HOME" --restow "$package"; then
		print_success "Stowed '$package'"
	else
		print_error "stow failed for '$package'"
		return 1
	fi
}
