" vim:set et sw=2 ts=2 tw=80 spell:
" Auto install on the first time if there no plug.vim found {{{
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('$HOME/.vim-plugged')
" }}}

" I'm try hard to reduce at much as possible the list of vim plugins I'm using,
" yet I keep experience with new stuff, while compare them with built-in vim
" feature (if it has one). Following plugins is what I feel essential.

" Sensible vim config, unnecessary for neovim, but still leave it here just in
" case I've to use Vim instead of Neovim
if !has('nvim')
  Plug 'tpope/vim-sensible'
endif

" This plugin is said that should be built-in with Vim instead.
Plug 'tpope/vim-surround'

" Many keymap that felt natural enough for a wide range of built-in vim
" commands
Plug 'tpope/vim-unimpaired'

" This provide the repeat functionality for vim-surround and some other Tim Pope plugins
Plug 'tpope/vim-repeat'

" A strong enhancement for vim built-in abbreviation functions, but, to be
" honest, I only uses it to fix some common typos.
Plug 'tpope/vim-abolish'

" One plugins to rule all the different syntax and filetypes.
Plug 'sheerun/vim-polyglot', {'do': './build'}

" Another plugin that provide many themes. Unnecessary if I can settle down
" for just one single theme. But, fuck it, I can't.
Plug 'flazz/vim-colorschemes'

" I'm using vimwiki for taking note. Markdown is not enough and I can't get into
" emacs and org mode despite all the times I've tried.
Plug 'vimwiki/vimwiki'

" Fuzzy finder for ... everything in vim, from Files, Buffers to Colors theme and
" Helptags. It helps my brain a lots.
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'kshenoy/vim-signature'
Plug 'mhinz/vim-signify'
Plug 'vim-airline/vim-airline'
Plug 'mhinz/vim-startify'

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'shumphrey/fugitive-gitlab.vim'
Plug 'kannokanno/previm' | Plug 'tyru/open-browser.vim'

Plug 'Chiel92/vim-autoformat'
Plug 'raimondi/delimitmate'
Plug 'ntpeters/vim-better-whitespace'
Plug 'wellle/tmux-complete.vim'
Plug 'w0rp/ale'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'simeji/winresizer'
Plug 'airblade/vim-rooter'

Plug 'junegunn/vim-easy-align'
Plug 'scrooloose/nerdcommenter'
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-line'
Plug 'mattn/emmet-vim', { 'for': ['html', 'xml', 'js', 'ts'] }
Plug 'plasticboy/vim-markdown', { 'for': ['md','markdown'] } | Plug 'godlygeek/tabular'

Plug 'lifepillar/pgsql.vim'
Plug 'alcesleo/vim-uppercase-sql'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'freitass/todo.txt-vim'

" Leave a place to try some new plugins, before add it into this list
if !empty(glob('~/.local.plugins.vim'))
  source ~/.local.plugins.vim
endif

call plug#end()
