" Auto install on the first time if there no plug.vim found
" ---------------------------------------------------------
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif


" List of plugin
" --------------
call plug#begin()
Plug 'Chiel92/vim-autoformat'
Plug 'bling/vim-airline'
Plug 'chase/vim-ansible-yaml'
Plug 'flazz/vim-colorschemes'
Plug 'ingydotnet/yaml-vim'
Plug 'plasticboy/vim-markdown'
Plug 'raimondi/delimitmate'
Plug 'ryanoasis/vim-devicons'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'tommcdo/vim-exchange'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
call plug#end()


" Avoid using the Escape key
" --------------------------
inoremap jk <ESC>
vnoremap jk <ESC>


" Use space as leader key, it's easy to touch
" -------------------------------------------
let mapleader="\<SPACE>"


" Quickly open vimrc and apply change
" -----------------------------------
nnoremap <leader>es :tabedit $MYVIMRC<CR>
nnoremap <leader>as :so $MYVIMRC<CR>


" Shortcut to quickly open the NerdTree panel
"---------------------------------------------
nnoremap <c-f12> :NERDTreeToggle<CR>

set number nocompatible
set expandtab tabstop=4 softtabstop=4 shiftwidth=4
set ignorecase smartcase incsearch hls
set textwidth=79
set cc=80
set nospell spelllang=en_us
set encoding=utf8
set cursorline
syntax on
filetype plugin indent on


" Remove the triangle default in Vim-airline, because I'm lazy to install
" custom font
"-------------------------------------------------------------------------
let g:airline_powerline_fonts=1
let g:airline_left_sep=''
let g:airline_right_sep=''


" Insert an blank line below or above the current line in normal mode
"---------------------------------------------------------------------
nnoremap <leader>o o<ESC>k
nnoremap <leader>O O<ESC>j


" Toggle highlight search
nnoremap <leader>n :set hls!<CR>

" Toggle spelling
nnoremap <leader>s :set spell!<CR>

" Toggle foldenable
nnoremap <leader>f :set foldenable!<CR>


" Quickly paste from clipboard
" ----------------------------
nnoremap <leader>p "+p
nnoremap <leader>P "+P


" Auto remove trailing white space on saving file
" -----------------------------------------------
fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun
autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()


" Custom theme
" ------------
colo hemisu
