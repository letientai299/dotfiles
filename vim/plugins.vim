" Auto install on the first time if there no plug.vim found {{{
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('$HOME/.vim-plugged')
" }}}

Plug 'kshenoy/vim-signature'
Plug 'mhinz/vim-signify'
Plug 'vim-airline/vim-airline'
Plug 'mhinz/vim-startify'

" Plug 'tpope/vim-fugitive'
" Plug 'tpope/vim-rhubarb'
" Plug 'shumphrey/fugitive-gitlab.vim'
Plug 'kannokanno/previm' | Plug 'tyru/open-browser.vim'

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'Chiel92/vim-autoformat'
Plug 'raimondi/delimitmate'
Plug 'ntpeters/vim-better-whitespace'
Plug 'wellle/tmux-complete.vim'
Plug 'w0rp/ale'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'simeji/winresizer'
Plug 'airblade/vim-rooter'

if !has('nvim')
  Plug 'tpope/vim-sensible'
endif

Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-repeat'
Plug 'junegunn/vim-easy-align'
Plug 'scrooloose/nerdcommenter'
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-line'
Plug 'mattn/emmet-vim', { 'for': ['html', 'xml', 'js', 'ts'] }
Plug 'plasticboy/vim-markdown', { 'for': ['md','markdown'] } | Plug 'godlygeek/tabular'

Plug 'sheerun/vim-polyglot', {'do': './build'}
Plug 'vimwiki/vimwiki'
Plug 'lifepillar/pgsql.vim'
Plug 'alcesleo/vim-uppercase-sql'

" Leave a place to try some new plugins, before add it into this list
if !empty(glob('~/.local.plugins.vim'))
  source ~/.local.plugins.vim
endif

call plug#end()
