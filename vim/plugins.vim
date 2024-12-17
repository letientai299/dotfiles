" vim:set et sw=2 ts=2 tw=80:
" Auto install on the first time if there no plug.vim found {{{
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('$HOME/.vim-plugged')

Plug 'https://github.com/lewis6991/impatient.nvim'

" I'm try hard to reduce at much as possible the list of vim plugins I'm using,
" yet I keep experience with new stuff, while compare them with built-in vim
" feature (if it has one). Following plugins is what I feel essential.

Plug 'tpope/vim-abolish'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-repeat'
Plug 'romainl/vim-cool' " disables search highlighting when done
Plug 'wellle/targets.vim'

Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug'], 'on': 'MarkdownPreview' }
let g:mkdp_echo_preview_url = 1
let g:mkdp_auto_close = 0
let g:mkdp_refresh_slow = 1
let g:mkdp_combine_preview = 1

Plug 'tyru/open-browser.vim', { 'for': [ 'md', 'markdown', 'wiki']}
" Plug 'MTDL9/vim-log-highlighting', {'for': 'log'}

Plug 'folke/tokyonight.nvim'
Plug 'folke/todo-comments.nvim'
Plug 'catppuccin/nvim', { 'as': 'catppuccin'}
Plug 'EdenEast/nightfox.nvim'

" I'm using vimwiki for taking note. Markdown is not enough and I can't get into
" emacs and org mode despite all the times I've tried.
" let vimwiki_ext2syntax = {}
" Plug 'vimwiki/vimwiki', {'branch': 'dev'}


" Fuzzy finder for ... everything in vim, from Files, Buffers to Colors theme and
" Helptags. It helps my brain a lots.
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'ibhagwan/fzf-lua'

Plug 'junegunn/vim-easy-align'

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
Plug 'sbdchd/neoformat'

" Pair with autoformat is auto stripping whitespace. This plugin also provide
" highlighting for trailing whitespsaces
Plug 'ntpeters/vim-better-whitespace', { 'on': [ 'StripWhitespace', 'DisableWhitespace']}

" Completion engine and supporting plugins
Plug 'neoclide/coc.nvim', {'branch': 'release'}
let g:coc_disable_transparent_cursor = 0
let g:coc_global_extensions = [
      \'coc-snippets',
      \'coc-json',
      \'coc-go',
      \'coc-sumneko-lua',
      \'coc-yaml',
      \'coc-docker',
      \'coc-sh',
      \'coc-rust-analyzer',
      \'coc-html',
      \'coc-tsserver',
      \'coc-css',
      \'coc-cssmodules'
      \]

" Auto cd to git project root when open a file in vim
" This seems doesn't work well with tmux continuum
Plug 'airblade/vim-rooter'

" Quickly resize vim split windows. Rarely use, but very annoying when doing
" that without this plugin
Plug 'simeji/winresizer'

" More GUI stuffs, mostly lua for nvim
Plug 'nvim-lualine/lualine.nvim'
Plug 'akinsho/bufferline.nvim'
Plug 'akinsho/toggleterm.nvim', { 'on': 'ToggleTerm' }
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'HiPhish/rainbow-delimiters.nvim'
Plug 'xiyaowong/virtcolumn.nvim'
" Plug 'stevearc/dressing.nvim'
Plug 'lewis6991/gitsigns.nvim'

Plug 'liuchengxu/vista.vim', { 'on': 'Vista' }
let g:vista_default_executive='coc'

Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-lua/plenary.nvim'
Plug 'MunifTanjim/nui.nvim'
Plug 'stevearc/oil.nvim'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
Plug 'max397574/better-escape.nvim'
Plug 'willothy/flatten.nvim'

Plug 'goolord/alpha-nvim'

" Test and debugging plugins
" --------------------------
" Plug 'pfeiferj/nvim-hurl'
" Plug 'https://github.com/rest-nvim/rest.nvim'
" Plug 'antoinemadec/FixCursorHold.nvim'
" Plug 'nvim-neotest/neotest'
" Plug 'rouge8/neotest-rust'
" Plug 'nvim-neotest/neotest-go'
" Plug 'nvim-neotest/neotest-vim-test'
" Plug 'vim-test/vim-test'
" let g:vimspector_enable_mappings = 'HUMAN'
" Plug 'puremourning/vimspector'


" config fold using treesitter, however, by default, don't fold on enter
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
autocmd BufReadPost,FileReadPost * normal zR

" Git related
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb' " for GBrowse
Plug 'https://github.com/shumphrey/fugitive-gitlab.vim'

Plug 'mattn/emmet-vim'

" To respect editorconfig file
Plug 'gpanders/editorconfig.nvim'

" https://github.com/embear/vim-localvimrc
let g:localvimrc_sandbox=0
let g:localvimrc_ask=0
let g:localvimrc_persistent=2
Plug 'embear/vim-localvimrc'

Plug 'fladson/vim-kitty', {'for': 'kitty'}


" Editing text on web browser using embedded nvim
Plug 'glacambre/firenvim',
      \ { 'do' : { _ -> firenvim#install(0) } }


" Loading local plugins {{{ "
" Leave a place to try some new plugins, before add it into this list
if !empty(glob('~/.local.plugins.vim'))
  source ~/.local.plugins.vim
endif

call plug#end()

lua require('impatient')
" lua require'impatient'.enable_profile()
lua require("config")
lua require("firenvim_config")
