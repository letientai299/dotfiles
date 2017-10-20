" Auto install on the first time if there no plug.vim found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin()

"------------------------------------------------------------------------------
" UI
Plug 'kshenoy/vim-signature'
Plug 'mhinz/vim-signify'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'flazz/vim-colorschemes'
Plug 'yggdroot/indentline'
Plug 'mhinz/vim-startify'
Plug 'majutsushi/tagbar'


"------------------------------------------------------------------------------
" Searching
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'rking/ag.vim', { 'on' : 'Ag'}


"------------------------------------------------------------------------------
" Automate stuff
Plug 'Chiel92/vim-autoformat'
Plug 'raimondi/delimitmate'
Plug 'ntpeters/vim-better-whitespace'
Plug 'schickling/vim-bufonly'
Plug 'wellle/tmux-complete.vim'

" deoplete completion engine can only work with neovim
if(has('nvim'))
  function! DoRemote(arg)
    UpdateRemotePlugins
  endfunction
  " The completion engine
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
  Plug 'zchee/deoplete-jedi', { 'for': 'python' }
  Plug 'davidhalter/jedi-vim', { 'for': 'python' }
  let g:deoplete#auto_completion_start_length=1
else
  Plug 'Shougo/neocomplete.vim'
endif

Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

" Resize panel quickly
Plug 'tomtom/tinykeymap_vim' | Plug 'tomtom/tlib_vim'
Plug 'airblade/vim-rooter'


"------------------------------------------------------------------------------
" Custom keymap
Plug 'tommcdo/vim-exchange'

if !has('nvim')
  Plug 'tpope/vim-sensible'
endif

Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-repeat'
" Plug 'tpope/vim-fugitive'
Plug 'junegunn/vim-easy-align'
Plug 'scrooloose/nerdcommenter'
Plug 'christoomey/vim-titlecase'


Plug 'vimwiki/vimwiki'
Plug 'tmux-plugins/vim-tmux', { 'for': 'tmux' }
Plug 'sheerun/vim-polyglot', {'do': './build'}
Plug 'heavenshell/vim-jsdoc'
Plug 'diepm/vim-rest-console'

"------------------------------------------------------------------------------
" Helper
Plug 'scrooloose/syntastic'


" Leave a place to try some new plugins, before add it into this list
if !empty(glob('~/.local.plugins.vim'))
  source ~/.local.plugins.vim
endif

call plug#end()

" H to open help docs
function! s:plug_doc()
  let name = matchstr(getline('.'), '^- \zs\S\+\ze:')
  if has_key(g:plugs, name)
    for doc in split(globpath(g:plugs[name].dir, 'doc/*.txt'), '\n')
      execute 'tabe' doc
    endfor
  endif
endfunction

augroup PlugHelp
  autocmd!
  autocmd FileType vim-plug nnoremap <buffer> <silent> H :call <sid>plug_doc()<cr>
augroup END



