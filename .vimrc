" Show Information
syntax enable                   " enable syntax hightlighting
set number                      " Show line number
set ruler                       " Show current line position
set showmode                    " Show current editing mode
set wrap                        " Wrap Lines
set linebreak                   " Wrap only on words
set showmatch                   " set show matching parenthesis

" Formatting options
set tabstop=4                   " a tab is four spaces
set softtabstop=4               " when hitting <BS>, pretend like a tab is removed, even if spaces
set noexpandtab                 " don't expand tabs to spaces by default
set shiftwidth=4                " number of spaces to use for autoindenting
set shiftround                  " use multiple of shiftwidth when indenting with '<' and '>'
set backspace=indent,eol,start  " allow backspacing over everything in insert mode
set autoindent                  " always set autoindenting on
set copyindent                  " copy the previous indentation on autoindenting

" Search Options
set hlsearch
set incsearch                   " show search matches as you type
set ignorecase                  " ignore case
set smartcase                   " unless searching with capitalization

" System Configuration
filetype on                     " enable filetype detection
set nocompatible                " disable vi mode
set t_Co=256                    " enable 256 color mode.
set history=100                 " keep 100 lines of history

" Dracula Theme Fix
let g:dracula_italic = 0
let g:dracula_colorterm = 0

packadd! dracula
colorscheme dracula
