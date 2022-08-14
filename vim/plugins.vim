" vim:set et sw=2 ts=2 tw=80:
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
Plug 'sheerun/vim-polyglot'
let g:polyglot_disabled = ['md', 'markdown', 'log']

" Vim-polyglot only provide filetype detection and syntax highlighting. I need
" more than that for editing markdown
Plug 'godlygeek/tabular'
" Plug 'gabrielelana/vim-markdown'
" slow with large file and many code fences
Plug 'plasticboy/vim-markdown'
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_fenced_languages = [
      \'viml=vim',
      \'bash=sh',
      \'ini=dosini',
      \'yaml',
      \'go'
      \]

" Live-review markdown
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npm i' }
let g:mkdp_echo_preview_url = 1
Plug 'tyru/open-browser.vim', {'for': ['md','markdown', 'wiki']}

" Plug 'flazz/vim-colorschemes'
Plug 'NLKNguyen/papercolor-theme'

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
" Plug 'SirVer/ultisnips'
" Required for coc-snippets to works
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
" Plug 'w0rp/ale'

" Completion engine and supporting plugins
Plug 'neoclide/coc.nvim', {'branch': 'release'}
let g:coc_global_extensions = [
      \'coc-snippets',
      \'coc-json',
      \'coc-go',
      \'coc-rust-analyzer',
      \'coc-html',
      \'coc-tsserver',
      \'coc-css',
      \'coc-cssmodules',
      \'coc-prettier',
      \'coc-toml'
      \]

let g:coc_disable_transparent_cursor = 1
Plug 'wellle/tmux-complete.vim'

" For c/c++
" Plug 'jackguo380/vim-lsp-cxx-highlight'

" Auto cd to git project root when open a file in vim
" This seems doesn't work well with tmux continuum
Plug 'airblade/vim-rooter'

" Quickly resize vim split windows. Rarely use, but very annoying when doing
" that without this plugin
Plug 'simeji/winresizer'

" More text objects
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-line'


" More GUI stuffs
let g:airline_extensions = ['branch', 'tabline']
Plug 'vim-airline/vim-airline'

Plug 'kshenoy/vim-signature'
Plug 'mhinz/vim-signify'

" Vim-tabular provide a function to align text, and is required by vim-markdown
" for formatting table. But, it doens't provide any easy keymap to formatting
" text manually. Easy-align really does a better job in this case. But, it's
" ironic that I have to keep 2 plugins with the same feature within my vim.
Plug 'junegunn/vim-easy-align'

Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'

" For editing todo note
" Plug 'freitass/todo.txt-vim', {'for': ['todo']}

Plug 'mattn/emmet-vim'

" For a quickly outline of what to expect in a new/big source code file
Plug 'majutsushi/tagbar'

" Still few more familiar with nerdtree than the built-in netrw
let g:NERDTreeHijackNetrw = 1
Plug 'preservim/nerdtree'
" Plug 'Xuyuanp/nerdtree-git-plugin'
" Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
" Plug 'ryanoasis/vim-devicons'

" To respect editorconfig file
Plug 'editorconfig/editorconfig-vim'

" To load vim settings per project
Plug 'thinca/vim-localrc'

" Show git commit message of the current line
Plug 'rhysd/git-messenger.vim'

" Loading local plugins {{{ "
" Leave a place to try some new plugins, before add it into this list
if !empty(glob('~/.local.plugins.vim'))
  source ~/.local.plugins.vim
endif

call plug#end()
" 1}}} "
