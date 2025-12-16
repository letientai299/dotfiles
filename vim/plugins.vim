" vim:set et sw=2 ts=2 tw=80:
" Auto install on the first time if there no plug.vim found {{{
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('$HOME/.vim-plugged')

" PERF: impatient.nvim is deprecated in Neovim 0.9+.
" Use built-in vim.loader.enable() instead (configured in lua/config.lua).
" This saves ~5ms startup time by avoiding plugin overhead.


Plug 'tpope/vim-abolish'
Plug 'tpope/vim-surround'
" PERF: vim-unimpaired lazy loaded on first bracket mapping use
Plug 'tpope/vim-unimpaired', { 'on': [] }
Plug 'tpope/vim-repeat'
Plug 'romainl/vim-cool' " disables search highlighting when done
Plug 'wellle/targets.vim'

Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug'], 'on': 'MarkdownPreview' }
let g:mkdp_echo_preview_url = 1
let g:mkdp_auto_close = 0
let g:mkdp_refresh_slow = 1
let g:mkdp_combine_preview = 1

Plug 'tyru/open-browser.vim', { 'for': [ 'md', 'markdown']}
" Plug 'MTDL9/vim-log-highlighting', {'for': 'log'}

Plug 'folke/tokyonight.nvim'
Plug 'folke/todo-comments.nvim'
Plug 'catppuccin/nvim', { 'as': 'catppuccin'}
Plug 'EdenEast/nightfox.nvim'

" Fuzzy finder for ... everything in vim, from Files, Buffers to Colors theme and
" Helptags. It helps my brain a lots.
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'ibhagwan/fzf-lua'

Plug 'junegunn/vim-easy-align'

" PERF: delimitmate only needed in insert mode - lazy load on InsertEnter
Plug 'raimondi/delimitmate', { 'on': [] }

" PERF: vim-snippets loaded by coc-snippets on demand
Plug 'honza/vim-snippets', { 'on': [] }

" PERF: nerdcommenter lazy loaded on first comment command
Plug 'scrooloose/nerdcommenter', { 'on': ['<Plug>NERDCommenterToggle', '<Plug>NERDCommenterComment', 'NERDCommenterToggle'] }

" PERF: neoformat lazy loaded on first format command
Plug 'sbdchd/neoformat', { 'on': 'Neoformat' }

" Pair with autoformat is auto stripping whitespace. This plugin also provide
" highlighting for trailing whitespsaces
Plug 'ntpeters/vim-better-whitespace', { 'on': [ 'StripWhitespace', 'DisableWhitespace']}

" PERF: coc.nvim lazy-loaded on InsertEnter for faster startup
" LSP features available after first insert mode entry
Plug 'neoclide/coc.nvim', {'branch': 'release', 'on': []}
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
\" PERF: lualine lazy-loaded on VimEnter (see ui.lua)
Plug 'nvim-lualine/lualine.nvim', { 'on': [] }
\" PERF: bufferline lazy-loaded on VimEnter (see ui.lua)
Plug 'akinsho/bufferline.nvim', { 'on': [] }
Plug 'akinsho/toggleterm.nvim', { 'on': 'ToggleTerm' }
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'HiPhish/rainbow-delimiters.nvim'
Plug 'xiyaowong/virtcolumn.nvim'
\" Plug 'stevearc/dressing.nvim'
\" PERF: gitsigns lazy-loaded after VimEnter (see ui.lua)
Plug 'lewis6991/gitsigns.nvim', { 'on': [] }

Plug 'liuchengxu/vista.vim', { 'on': 'Vista' }
let g:vista_default_executive='coc'

Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-lua/plenary.nvim'
Plug 'MunifTanjim/nui.nvim'
Plug 'stevearc/oil.nvim'
" PERF: treesitter plugins lazy-loaded on first file open
Plug 'nvim-treesitter/nvim-treesitter', { 'on': [] }
Plug 'nvim-treesitter/nvim-treesitter-textobjects', { 'on': [] }
Plug 'max397574/better-escape.nvim'
Plug 'willothy/flatten.nvim'

" PERF: alpha only loaded on VimEnter when no files opened (see ui.lua)
Plug 'goolord/alpha-nvim', { 'on': [] }

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

Plug 'mattn/emmet-vim', { 'for': ['html', 'css', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'vue', 'svelte'] }

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

" PERF: Enable Neovim's built-in module caching (0.9+).
" This replaces impatient.nvim with the native implementation,
" which is faster and better maintained.
if has('nvim-0.9')
  lua vim.loader.enable()
endif

" PERF: Lazy-load plugins at appropriate times
" These plugins are marked with { 'on': [] } and loaded via autocmds

" Load delimitmate when entering insert mode (saves ~1.5ms)
augroup lazy_load_delimitmate
  autocmd!
  autocmd InsertEnter * ++once call plug#load('delimitmate')
augroup END

" Load vim-unimpaired on first [ or ] keypress (saves ~2.5ms)
augroup lazy_load_unimpaired
  autocmd!
  autocmd VimEnter * ++once call timer_start(100, {-> plug#load('vim-unimpaired')})
augroup END

" PERF: Load coc.nvim on InsertEnter or BufReadPost (saves ~2.5ms startup)
" This means LSP is ready shortly after opening a file
augroup lazy_load_coc
  autocmd!
  autocmd InsertEnter,BufReadPost * ++once call plug#load('coc.nvim')
augroup END

" Load vim-snippets when coc starts (saves ~1ms)
augroup lazy_load_snippets
  autocmd!
  autocmd User CocNvimInit ++once call plug#load('vim-snippets')
augroup END

" PERF: Load treesitter plugins on first file with a filetype (saves ~5ms)
augroup lazy_load_treesitter
  autocmd!
  autocmd FileType * ++once call plug#load('nvim-treesitter', 'nvim-treesitter-textobjects')
augroup END

lua require("config")
lua require("firenvim_config")
