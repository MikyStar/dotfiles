set nocompatible              " be iMproved, required
set encoding=UTF-8
filetype off                  " required
" set shell=bash

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'webdevel/tabulous'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'scrooloose/nerdtree'
Plugin 'leafgarland/typescript-vim'
"Plugin 'peitalin/vim-jsx-typescript'
Plugin 'valloric/youcompleteme'
Plugin 'luochen1990/rainbow'
Plugin 'tpope/vim-fugitive'
Plugin 'sheerun/vim-polyglot'
Plugin 'ryanoasis/vim-devicons'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'mhartington/oceanic-next'
Plugin 'airblade/vim-gitgutter'
Plugin 'herringtondarkholme/yats.vim'
Plugin 'quramy/tsuquyomi'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'arcticicestudio/nord-vim'

call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""" My items
syntax on
set number relativenumber

filetype plugin on

" Theming
let g:airline_theme='nord'
let g:oceanic_next_terminal_bold = 1
let g:oceanic_next_terminal_italic = 1
colorscheme nord

"Ctrl+n to toggle NerdTree
map <C-n> :NERDTreeToggle<CR> 
set wildmenu
set wildmode=longest,list,full
filetype plugin indent on
set showmatch
set ignorecase
set hlsearch
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set list listchars=extends:>,precedes:<,tab:→\•,eol:↲,nbsp:␣,trail:•,space:•
let NERDTreeShowHidden=1
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let tabulousCloseStr=''

" important!!
set termguicolors

"Terminal settings
:set splitbelow
:set termwinsize=10x0

"To enable manual split
:set foldmethod=manual

" Remap how to browse between splits
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Custom command to clear registers
command! WipeReg for i in range(34,122) | silent! call setreg(nr2char(i), []) | endfor

" Go to install nerdtree fonts and select them for the terminal application

let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ 'Ignored'   : '☒',
    \ "Unknown"   : "?"
    \ }

set guifont=Hack\ Nerd\ Font:h12 "compatible with NerdTree, tabs and arirline
set guioptions= "to remove scrollbars

" GitGutter
command Githl GitGutterLineHighlightsToggle
command Gitnext GitGutterNextHunk
command Gitprev GitGutterPrevHunk
command Gitstage GitGutterStageHunk
command Gitunstage GitGutterUndoHunk
command Gitsplit Gdiffsplit

" Vim indent
let g:indent_guides_enable_on_vim_startup = 1
set ts=4 sw=4 noet
let g:indent_guides_start_level = 2
let indent_guides_guide_size = 1
