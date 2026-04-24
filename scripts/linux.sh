#!/bin/bash

set -e

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPTS_DIR")"

source "$SCRIPTS_DIR/common.sh"

detect_distro() {
	if [[ -f /etc/os-release ]]; then
		source /etc/os-release
		case "$ID" in
			arch|manjaro|endeavouros|artix|garuda) echo "arch" ;;
			ubuntu|debian|linuxmint|pop|elementary|zorin|kali) echo "debian" ;;
			fedora|rhel|centos|rocky|almalinux|nobara) echo "fedora" ;;
			*)
				if command -v pacman >/dev/null 2>&1; then echo "arch"
				elif command -v apt >/dev/null 2>&1; then echo "debian"
				elif command -v dnf >/dev/null 2>&1; then echo "fedora"
				else echo "unknown"
				fi
				;;
		esac
	else
		echo "unknown"
	fi
}

install_yay() {
	command -v yay >/dev/null 2>&1 && { print_success "yay already installed"; return; }
	print_status "Installing yay..."
	sudo pacman -S --needed --noconfirm base-devel git
	local temp_dir=$(mktemp -d)
	git clone https://aur.archlinux.org/yay.git "$temp_dir/yay"
	(cd "$temp_dir/yay" && makepkg -si --noconfirm)
	rm -rf "$temp_dir"
	print_success "yay installed"
}

enable_nonfree_repos() {
	print_status "Enabling non-free repositories..."
	local sources_file="/etc/apt/sources.list"

	if grep -r "non-free" "$sources_file" /etc/apt/sources.list.d/ 2>/dev/null | grep -v "^#" >/dev/null; then
		print_success "Non-free repos already enabled"; return
	fi

	source /etc/os-release
	case "$ID" in
		ubuntu|pop|elementary|zorin|linuxmint)
			sudo add-apt-repository universe -y
			sudo add-apt-repository multiverse -y
			;;
		debian)
			sudo cp "$sources_file" "$sources_file.backup"
			sudo sed -i 's/main$/main contrib non-free/g' "$sources_file"
			;;
	esac
	sudo apt update
}

configure_fedora() {
	print_status "Configuring Fedora extras..."
	sudo dnf install -y \
		https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
		https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm 2>/dev/null || true
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
	sudo dnf groupinstall -y "Development Tools" "Development Libraries" || true
	grep -q "max_parallel_downloads" /etc/dnf/dnf.conf || echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf >/dev/null
	grep -q "fastestmirror" /etc/dnf/dnf.conf || echo 'fastestmirror=True' | sudo tee -a /etc/dnf/dnf.conf >/dev/null
}

install_packages() {
	local distro="$1"
	local packages=(vim tmux htop git curl wget fish stow neovim fastfetch)

	print_status "Installing packages for $distro..."

	case "$distro" in
		arch)
			sudo pacman -S --needed --noconfirm "${packages[@]}"
			command -v starship >/dev/null 2>&1 || yay -S --needed --noconfirm starship
			;;
		debian)
			sudo apt install -y "${packages[@]}" 2>/dev/null || {
				# fastfetch may not be in older repos
				sudo apt install -y "${packages[@]/fastfetch/}" 2>/dev/null || true
				command -v fastfetch >/dev/null 2>&1 || {
					local temp_dir=$(mktemp -d)
					curl -sL https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb -o "$temp_dir/fastfetch.deb"
					sudo dpkg -i "$temp_dir/fastfetch.deb" || sudo apt install -f -y
					rm -rf "$temp_dir"
				}
			}
			command -v starship >/dev/null 2>&1 || curl -sS https://starship.rs/install.sh | sh -s -- -y
			;;
		fedora)
			sudo dnf install -y "${packages[@]}" || {
				sudo dnf install -y "${packages[@]/fastfetch/}" || true
				command -v fastfetch >/dev/null 2>&1 || {
					local temp_dir=$(mktemp -d)
					curl -sL https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.rpm -o "$temp_dir/fastfetch.rpm"
					sudo rpm -i "$temp_dir/fastfetch.rpm"
					rm -rf "$temp_dir"
				}
			}
			command -v starship >/dev/null 2>&1 || curl -sS https://starship.rs/install.sh | sh -s -- -y
			;;
	esac
	print_success "Packages installed"
}

main() {
	print_status "Starting Linux configuration..."

	local distro=$(detect_distro)
	print_status "Distro: $distro"

	[[ "$distro" == "unknown" ]] && { print_error "Unsupported distro"; exit 1; }

	case "$distro" in
		arch) sudo pacman -Sy; install_yay ;;
		debian) sudo apt update; enable_nonfree_repos ;;
		fedora) sudo dnf check-update || true; configure_fedora ;;
	esac

	install_packages "$distro"
	stow_package "$DOTFILES_DIR" home
	stow_package "$DOTFILES_DIR" linux

	print_success "Linux configuration complete"
	print_status "Restart your shell or run: source ~/.bashrc"
}

main "$@"
