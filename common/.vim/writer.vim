" ========== Basic Settings ==========
set nocompatible
set encoding=utf-8
filetype plugin indent on
syntax on

set cursorline
set formatoptions+=t
set hidden
set hlsearch
set linebreak
set nobackup
set nofoldenable
set noshowcmd
set noshowmode
set noswapfile
set nowritebackup
"set number
set relativenumber
set scrolloff=999
set softtabstop=4
set spell spelllang=en_us
set tabstop=4
set textwidth=80
set updatetime=300
set wrap

" Leader key
let mapleader = ","

" ========== Load Plugins ==========
call plug#begin('~/.vim/plugged')

" Gruvbox
Plug 'gruvbox-community/gruvbox'

Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'preservim/vim-markdown'
Plug 'preservim/vim-pencil'
Plug 'reedes/vim-lexical'
Plug 'rhysd/vim-grammarous'

call plug#end()

" ========== Plugin Configuration ==========

" Markdown settings
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_conceal = 0

" Grammar checking
nnoremap <leader>g :GrammarousCheck<CR>
nnoremap <leader>G :GrammarousReset<CR>

" Thesaurus (use <leader>t on a word)
let g:tq_enabled_backends = ['datamuse', 'wordnik']
nnoremap <leader>t :ThesaurusQueryReplaceCurrentWord<CR>

" Toggle spellcheck
nnoremap <leader>s :setlocal spell!<CR>

" Save
nnoremap <leader>w :w<CR>

" Toggle Goyo
nnoremap <leader>z :Goyo<CR>

"let g:limelight_conceal_guifg = 'DarkGray'
"let g:limelight_conceal_guifg = '#777777'
let g:goyo_width = 100

function! s:WriterStartup()
  silent! call pencil#init({'wrap': 'soft'})
  silent! call lexical#init()
  silent! call wordy#enable()
  silent! Goyo
  silent! Limelight
endfunction

autocmd VimEnter * call s:WriterStartup()

" Colorscheme
colorscheme gruvbox
set background=dark
let g:gruvbox_contrast_dark = 'hard'
set termguicolors
hi SpellBad cterm=underline
