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
let g:polyglot_disabled = ['markdown']

" Vim-polyglot only provide filetype detection and syntax highlighting. I need
" more than that for editing markdown
Plug 'plasticboy/vim-markdown', {'for': ['md','markdown']}
" Plug 'gabrielelana/vim-markdown', {'for': ['md','markdown']}
Plug 'godlygeek/tabular', {'for': ['md','markdown']}

" Live-review markdown
Plug 'kannokanno/previm', {'for': ['md','markdown', 'wiki']}
Plug 'tyru/open-browser.vim', {'for': ['md','markdown', 'wiki']}

" Another plugin that provide many themes. Unnecessary if I can settle down
" for just one single theme. But, fuck it, I can't.
Plug 'flazz/vim-colorschemes'

" I'm using vimwiki for taking note. Markdown is not enough and I can't get into
" emacs and org mode despite all the times I've tried.
Plug 'vimwiki/vimwiki', {'branch': 'dev'}

" Fuzzy finder for ... everything in vim, from Files, Buffers to Colors theme and
" Helptags. It helps my brain a lots.
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" Auto close the bracket and quotation pairs
Plug 'raimondi/delimitmate'

" The snippets engine and the a big collection of snippets
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

" Quickly toggle line or block comment.
" I've considered switching to another commenting plugins (tcomment and
" commentary), but I hate switching my muscle memory for commenting code.
Plug 'scrooloose/nerdcommenter'

" Can't live without autoformating. Can't also live with unformatted code
Plug 'Chiel92/vim-autoformat'

" Pair with autoformat is auto stripping whitespace. This plugin also provide
" highlighting for trailing whitespsaces
Plug 'ntpeters/vim-better-whitespace'

" Linting engine
Plug 'w0rp/ale'

" Completion engine and supporting plugins
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'wellle/tmux-complete.vim'
Plug 'zchee/deoplete-go'

" Auto cd to git project root when open a file in vim
" This seems doesn't work well with tmux continuum
" Plug 'airblade/vim-rooter'

" Quickly resize vim split windows. Rarely use, but very annoying when doing
" that without this plugin
Plug 'simeji/winresizer'

" More text objects
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-line'

" Yeah, just make vim GUI more beautiful.
Plug 'vim-airline/vim-airline'

" Useful for review and reopen recent editing files, also serves as a bookmark.
Plug 'mhinz/vim-startify'

" More GUI stuffs
Plug 'kshenoy/vim-signature'
Plug 'mhinz/vim-signify'

" Vim-tabular provide a function to align text, and is required by vim-markdown
" for formatting table. But, it doens't provide any easy keymap to formatting
" text manually. Easy-align really does a better job in this case. But, it's
" ironic that I have to keep 2 plugins with the same feature within my vim.
Plug 'junegunn/vim-easy-align'

" Everyone say that this is a most powerful Git integrating for vim. I actually
" have a todo item for learning fugitive. But, right now, I use this mostly as a
" Commit browser and some nice syntax. Hope that I can find time to really learn
" it (or remove it, as oh-my-zsh with its git plugins is really enough for
" my work right now).
Plug 'tpope/vim-fugitive'
Plug 'shumphrey/fugitive-gitlab.vim'
Plug 'tpope/vim-rhubarb'

" Polyglot provided SQL syntax doensn't play nice with postgres code.
" Plug 'lifepillar/pgsql.vim', {'for': ['sql', 'pgsql']}

" For SQL, I also follow the convention of making all SQL keyword uppercase.
" Plug 'alcesleo/vim-uppercase-sql', {'for': ['sql', 'pgsql']}

" For editing todo note
Plug 'freitass/todo.txt-vim', {'for': ['todo']}

" Rails development
Plug 'tpope/vim-rails'

" To run script or command without blocking vim
" Plug 'skywind3000/asyncrun.vim'

" Distraction free mode
" Plug 'junegunn/goyo.vim'
" Plug 'mattn/emmet-vim'
Plug 'majutsushi/tagbar'
Plug 'fatih/vim-go', {'for': ['go']}
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'schickling/vim-bufonly'

" Loading local plugins {{{ "
" Leave a place to try some new plugins, before add it into this list
if !empty(glob('~/.local.plugins.vim'))
  source ~/.local.plugins.vim
endif

call plug#end()
" 1}}} "
