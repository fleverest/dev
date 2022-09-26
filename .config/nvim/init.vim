autocmd!

filetype plugin indent on
let mapleader = ","
set laststatus=2 mouse=a cursorline

" Numbering
set rnu
set nu

" Remove trailing whitespace on :w
autocmd BufWritePre * %s/\s\+$//e

" Tab to spaces
:set expandtab tabstop=2 shiftwidth=2
:retab

" Python-specific indents
autocmd FileType python set sw=4
autocmd FileType python set ts=4
autocmd FileType python set sts=4

" Nerdtree by default
function! StartUp()
    if 0 == argc()
        NERDTree
    end
endfunction

autocmd VimEnter * call StartUp()

" Vim-Plug
call plug#begin('~/.config/nvim/site/autoload')
  " NERDTree for NERDTree.
  Plug 'preservim/nerdtree' |
    \ Plug 'Xuyuanp/nerdtree-git-plugin'
  " Icons
  Plug 'ryanoasis/vim-devicons'
  " AirLine
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  " GitGutter
  Plug 'airblade/vim-gitgutter'
  " OneDark Theme for pretty highlights
  Plug 'joshdick/onedark.vim'
  "coc
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

" NERDTree
nnoremap <C-t> :NERDTreeToggle<CR>
let g:NERDTreeGitStatusIndicatorMapCustom = {
                \ 'Modified'  :'✹',
                \ 'Staged'    :'✚',
                \ 'Untracked' :'✭',
                \ 'Renamed'   :'➜',
                \ 'Unmerged'  :'═',
                \ 'Deleted'   :'✖',
                \ 'Dirty'     :'✗',
                \ 'Ignored'   :'☒',
                \ 'Clean'     :'✔︎',
                \ 'Unknown'   :'?',
                \ }

" AirLine
" TabLine
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#enabled = 1
"Theme
let g:airline_theme='solarized'
" PowerLine symbols
let g:airline_powerline_fonts = 1
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_symbols.branch = ''
let g:airline_symbols.colnr = ' :'
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ' :'
let g:airline_symbols.maxlinenr = '☰ '
let g:airline_symbols.dirty='⚡'

" Colour scheme
autocmd VimEnter * hi Normal ctermbg=none
syntax on
if !empty(glob(stdpath('data') . '/site/autoload/onedark.vim'))
  colorscheme onedark
endif
