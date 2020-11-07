"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""   Installs   """""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

call plug#begin('~/.config/nvim/plugged')

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'morhetz/gruvbox'
Plug 'arcticicestudio/nord-vim'
Plug 'joshdick/onedark.vim'
Plug 'jacoborus/tender.vim'

Plug 'ryanoasis/vim-devicons'
Plug 'webdevel/tabulous'

Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

Plug 'junegunn/gv.vim'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-unimpaired'

Plug 'tmux-plugins/vim-tmux-focus-events'

Plug 'easymotion/vim-easymotion'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'frazrepo/vim-rainbow'

Plug 'TaDaa/vimade'

Plug 'mhinz/vim-startify'

Plug 'nathanaelkane/vim-indent-guides'

Plug 'nvim-treesitter/nvim-treesitter'
Plug 'sheerun/vim-polyglot'
Plug 'neoclide/coc.nvim', { 'branch' : 'release' }
Plug 'herringtondarkholme/yats.vim'
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'maxmellon/vim-jsx-pretty'

call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""   Config   """""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""" General
let mapleader = ','
syntax on

set number relativenumber

filetype plugin on
filetype plugin indent on
filetype off

set nocompatible
set encoding=UTF-8

set wildmenu
set wildmode=longest,list,full

" Ignored files ; In NerdTree part I imply to ignore those
set wildignore+=*.swp,*.DS_Store

set showmatch
set ignorecase
set smartcase
set wildignorecase
set infercase
set hlsearch
set autoindent
set cursorline

set softtabstop=4
set ts=4 sw=4 noet

set list listchars=extends:>,precedes:<,tab:→\•,eol:↲,nbsp:␣,trail:•,space:•

" Enabled in all modes ( usefull for tmux )
set mouse=a

""""""""""""""""""""" Theming
colorscheme tender
set termguicolors " important!!

let g:tabulousCloseStr=''

set guifont=Hack\ Nerd\ Font:h12 "compatible with NerdTree, tabs and arirline

"""""""""""""""""""""" Splits
set splitbelow

set foldmethod=manual "To enable manual split

" Hide whitespaces, tabs ... when inactive pabe
autocmd BufEnter *.ts,*.tsx,*.js,*.jsx,*.json,*.yaml,*.yml,*.sh,*.py :set list
autocmd WinEnter *.ts,*.tsx,*.js,*.jsx,*.json,*.yaml,*.yml,*.sh,*.py :set list
autocmd BufLeave *.ts,*.tsx,*.js,*.jsx,*.json,*.yaml,*.yml,*.sh,*.py :set nolist
autocmd WinLeave *.ts,*.tsx,*.js,*.jsx,*.json,*.yaml,*.yml,*.sh,*.py :set nolist

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""   Commands   """"""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Custom command to clear registers
command! ClearReg for i in range(34,122) | silent! call setreg(nr2char(i), []) | endfor

command! ClearQuickfixList cexpr []

command! ClearBuffers bufdo bd

" For Vim integrated terminal :
"	Scroll up will put in Normal mode
"	Right click will exit out of Normal mode
" @see : https://github.com/vim/vim/issues/2490
function! EnterNormalMode()
    if &buftype == 'terminal' && mode('') == 't'
        call feedkeys("\<c-w>N")
        call feedkeys("\<c-y>")
    endif
endfunction

tmap <silent> <ScrollWheelUp> <c-w>:call EnterNormalMode()<CR>

" Remap how to browse between splits
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Scroll faster with Ctrl E / Y
nnoremap <C-e> 5<C-e>
nnoremap <C-y> 5<C-y>

" Delete buffer with Ctrl Shift w
nnoremap <leader>w :bd<CR>
nnoremap <leader><tab> :bn<CR>
nnoremap <leader><S-tab> :bp<CR>

" Clear searchs on Esc
nnoremap <esc> :noh<return><esc>

" Moving lines arround : https://vim.fandom.com/wiki/Moving_lines_up_or_down
nnoremap <S-Down> :m .+1<CR>==
nnoremap <S-Up> :m .-2<CR>==
vnoremap <S-Down> :m '>+1<CR>gv=gv
vnoremap <S-Up> :m '<-2<CR>gv=gv

" Vertical split
nnoremap <C-v> :vsplit<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""   Pluggins   """"""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


"""""""""""""""""""""" GitGutter
command Githl GitGutterLineHighlightsToggle
command Gitnext GitGutterNextHunk
command Gitprev GitGutterPrevHunk
command Gitstage GitGutterStageHunk
command Gitunstage GitGutterUndoHunk
command Gdiff Gdiffsplit

nmap <leader>g <Plug>(GitGutterNextHunk)
nmap <leader><S-g> <Plug>(GitGutterPrevHunk)

""""""""""""""""""""" NerdTree
map <C-n> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1
let NERDTreeRespectWildIgnore=1

let g:NERDTreeGitStatusIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "☉",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ 'Ignored'   : '☒',
    \ "Unknown"   : "?"
    \ }

"""""""""""""""""""""" Airline
let g:airline_theme='onedark' 
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#tab_nr_type = 1
let g:airline#extensions#tabline#buffer_nr_show = 1

"""""""""""""""""""""" COC
let g:coc_global_extensions = [
	\ 'coc-pairs',
	\ 'coc-tsserver',
	\ 'coc-json',
	\ 'coc-rome',
	\ 'coc-yank',
	\ 'coc-snippets',
	\ 'coc-prettier',
	\ 'coc-git',
	\ 'coc-python',
	\ 'coc-css',
	\ ]

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Navigate Diagnostics 
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <leader>d <Plug>(coc-diagnostic-next)
nmap <leader><S-d> <Plug>(coc-diagnostic-prev)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
nnoremap <expr><C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <expr><C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <expr><C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<Right>"
inoremap <expr><C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<Left>"

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')


"""""""""""""""""""""" FZF
nnoremap <C-p> :FZF .<CR>
nnoremap <C-f> :Rg<CR>

let g:fzf_layout = { 'down': '~40%' }

"""""""""""""""""""""" Indent Guides
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_exclude_filetypes = ['help', 'nerdtree', 'startify']

"""""""""""""""""""""" Rainbow
let g:rainbow_active = 1
let g:rainbow_load_separately = [
    \ [ '*.*' , [['(', ')'], ['\[', '\]'], ['{', '}']] ],
    \ [ '*.tex' , [['(', ')'], ['\[', '\]']] ],
    \ [ '*.cpp' , [['(', ')'], ['\[', '\]'], ['{', '}']] ],
    \ [ '*.{html,htm}' , [['(', ')'], ['\[', '\]'], ['{', '}'], ['<\a[^>]*>', '</[^>]*>']] ],
    \ ]

"""""""""""""""""""""" Vimade
let g:vimade = {}
let g:vimade.fadelevel = 0.8
let g:vimade.groupdiff = 0

"""""""""""""""""""""" Startify
let g:startify_change_to_vcs_root = 1

"""""""""""""""""""""" YATS
let g:yats_host_keyword = 1
