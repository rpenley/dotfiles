#!/bin/bash
mkdir -p ~/.vim/pack/themes/start
cd ~/.vim/pack/themes/start
git clone https://github.com/dracula/vim.git dracula
echo "packadd! dracula" >> ~/.vimrc 
echo "colorscheme dracula" >> ~/.vimrc 
