#!/bin/bash
# RUN AS YOUR USER NOT ROOT
package_list='vim kitty tmux'
      printf  "===========================================================\n"
      echo -n "Welcome the dotfile install script (for arch/manjaro linux)"
      printf  "\n=========================================================\n\n"
      echo -e "The following packages are required: \033[31m$packages\033[0m"
      read -p "Would you like to install these packages now? " -n 1 -r
      if [[ $REPLY =~ ^[Yy]$ ]]
        then
        printf "\n"
        sudo pacman -S $packages
        printf "\n"
      fi
      printf "\nWould you like to move dotfiles from \033[31m${PWD}\033[0m to \033[31m$HOME\033[0m?\n"
      read -p  "(y/n) " -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
	printf "\nMoving dotfiles from \033[31m${PWD}\033[0m to \033[31m$HOME\033[0m\n"
        shopt -s dotglob nullglob
        cp -r .\.* ~/
	fi
        echo "Dotfiles install complete!"
