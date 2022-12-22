" vim:set et sw=2 ts=2 tw=80:
" Auto install on the first time if there no plug.vim found {{{
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('$HOME/.vim-plugged')

" I'm try hard to reduce at much as possible the list of vim plugins I'm using,
" yet I keep experience with new stuff, while compare them with built-in vim
" feature (if it has one). Following plugins is what I feel essential.

" Sensible vim config, unnecessary for neovim, but still leave it here just in
" case I've to use Vim instead of Neovim
if !has('nvim')
  Plug 'tpope/vim-sensible'
endif

Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-repeat'
Plug 'romainl/vim-cool' " disables search highlighting when done
Plug 'wellle/targets.vim'

" Markdown
Plug 'preservim/vim-markdown'
let g:vim_markdown_math = 1
let g:vim_markdown_strikethrough = 1
let g:vim_markdown_new_list_item_indent = 2
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_fenced_languages = [
      \'viml=vim',
      \'bash=sh',
      \'ini=dosini',
      \'jsx=javascriptreact',
      \'tsx=typescriptreact',
      \]

Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
let g:mkdp_theme = 'light'
let g:mkdp_echo_preview_url = 1

Plug 'tyru/open-browser.vim', { 'for': [ 'md', 'markdown', 'wiki']}

Plug 'folke/tokyonight.nvim'
Plug 'catppuccin/nvim', { 'as': 'catppuccin'}
Plug 'EdenEast/nightfox.nvim'

" I'm using vimwiki for taking note. Markdown is not enough and I can't get into
" emacs and org mode despite all the times I've tried.
Plug 'vimwiki/vimwiki', {'branch': 'dev'}


" Fuzzy finder for ... everything in vim, from Files, Buffers to Colors theme and
" Helptags. It helps my brain a lots.
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'ibhagwan/fzf-lua'

" Auto close the bracket and quotation pairs
Plug 'raimondi/delimitmate'

" The snippets engine and the a big collection of snippets
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

" Completion engine and supporting plugins
Plug 'neoclide/coc.nvim', {'branch': 'release'}
let g:coc_disable_transparent_cursor = 1
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

let g:cursorhold_updatetime = 100
Plug 'antoinemadec/FixCursorHold.nvim'

let g:vimspector_enable_mappings = 'HUMAN'

Plug 'puremourning/vimspector'

" Auto cd to git project root when open a file in vim
" This seems doesn't work well with tmux continuum
Plug 'airblade/vim-rooter'

" Quickly resize vim split windows. Rarely use, but very annoying when doing
" that without this plugin
Plug 'simeji/winresizer'

" More GUI stuffs, mostly lua for nvim
Plug 'feline-nvim/feline.nvim'
Plug 'akinsho/bufferline.nvim'
Plug 'akinsho/toggleterm.nvim'
Plug 'folke/which-key.nvim'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'xiyaowong/virtcolumn.nvim'
Plug 'stevearc/dressing.nvim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'liuchengxu/vista.vim'
let g:vista_default_executive='coc'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'nvim-lua/plenary.nvim'
Plug 'MunifTanjim/nui.nvim'
Plug 'nvim-neo-tree/neo-tree.nvim'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'karb94/neoscroll.nvim'
Plug 'p00f/nvim-ts-rainbow'

Plug 'https://github.com/rest-nvim/rest.nvim'

Plug 'nvim-neotest/neotest'
Plug 'https://github.com/rouge8/neotest-rust'
Plug 'https://github.com/nvim-neotest/neotest-go'
Plug 'https://github.com/nvim-neotest/neotest-vim-test'
Plug 'https://github.com/vim-test/vim-test'

" config fold using treesitter, however, by default, don't fold on enter
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
autocmd BufReadPost,FileReadPost * normal zR

" Git related
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'
Plug 'rhysd/git-messenger.vim'

Plug 'mattn/emmet-vim'

" To respect editorconfig file
Plug 'gpanders/editorconfig.nvim'

Plug 'thinca/vim-localrc'

" Show git commit message of the current line

" Loading local plugins {{{ "
" Leave a place to try some new plugins, before add it into this list
if !empty(glob('~/.local.plugins.vim'))
  source ~/.local.plugins.vim
endif

call plug#end()

lua require("config")
