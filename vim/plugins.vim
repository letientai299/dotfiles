" vim:set et sw=2 ts=2 tw=80:
" PERF: Disable netrw (use oil.nvim instead) - saves ~0.8ms
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1
" PERF: Disable matchit (rarely used) - saves ~0.8ms
let g:loaded_matchit = 1

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


" PERF: vim-abolish lazy loaded on command use
Plug 'tpope/vim-abolish', { 'on': ['Abolish', 'Subvert', 'S'] }
Plug 'tpope/vim-surround'
" PERF: vim-unimpaired lazy loaded on first bracket mapping use
Plug 'tpope/vim-unimpaired', { 'on': [] }
Plug 'tpope/vim-repeat'
" PERF: vim-cool lazy loaded on CmdlineEnter for / or ? (saves ~0.1ms)
Plug 'romainl/vim-cool', { 'on': [] }
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
" PERF: fzf lazy-loaded with fzf-lua (saves ~0.5ms)
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all', 'on': [] }
Plug 'ibhagwan/fzf-lua', { 'on': 'FzfLua' }

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
" PERF: vim-rooter lazy-loaded on BufReadPost (saves ~0.1ms)
Plug 'airblade/vim-rooter', { 'on': [] }

" Quickly resize vim split windows. Rarely use, but very annoying when doing
" that without this plugin
" PERF: winresizer lazy-loaded on command (saves ~0.15ms)
Plug 'simeji/winresizer', { 'on': ['WinResizerStartResize', 'WinResizerStartMove', 'WinResizerStartFocus'] }

" More GUI stuffs, mostly lua for nvim
\" PERF: lualine lazy-loaded on VimEnter (see ui.lua)
Plug 'nvim-lualine/lualine.nvim', { 'on': [] }
\" PERF: bufferline lazy-loaded on VimEnter (see ui.lua)
Plug 'akinsho/bufferline.nvim', { 'on': [] }
Plug 'akinsho/toggleterm.nvim', { 'on': 'ToggleTerm' }
" PERF: ibl lazy-loaded on FileType (saves ~1.5ms)
Plug 'lukas-reineke/indent-blankline.nvim', { 'on': [] }
" PERF: rainbow-delimiters lazy-loaded on FileType (saves ~1ms)
Plug 'HiPhish/rainbow-delimiters.nvim', { 'on': [] }
" PERF: virtcolumn lazy-loaded on FileType (saves ~0.18ms)
Plug 'xiyaowong/virtcolumn.nvim', { 'on': [] }
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

" Git related - lazy loaded on git commands
Plug 'tpope/vim-fugitive', { 'on': ['Git', 'Gstatus', 'Gdiff', 'Gblame', 'GBrowse', 'Gread', 'Gwrite'] }
Plug 'tpope/vim-rhubarb', { 'on': 'GBrowse' }
Plug 'https://github.com/shumphrey/fugitive-gitlab.vim', { 'on': 'GBrowse' }

Plug 'mattn/emmet-vim', { 'for': ['html', 'css', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'vue', 'svelte'] }

" To respect editorconfig file
" PERF: editorconfig lazy-loaded on BufReadPost (saves ~0.15ms)
Plug 'gpanders/editorconfig.nvim', { 'on': [] }

" https://github.com/embear/vim-localvimrc
" PERF: localvimrc lazy loaded on file read
let g:localvimrc_sandbox=0
let g:localvimrc_ask=0
let g:localvimrc_persistent=2
Plug 'embear/vim-localvimrc', { 'on': [] }

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

" Load vim-cool when starting a search (saves ~0.1ms)
augroup lazy_load_cool
  autocmd!
  autocmd CmdlineEnter /,\? ++once call plug#load('vim-cool')
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
  autocmd FileType * ++once call plug#load('nvim-treesitter', 'nvim-treesitter-textobjects', 'indent-blankline.nvim', 'rainbow-delimiters.nvim', 'virtcolumn.nvim')
augroup END

" PERF: Load localvimrc and editorconfig on file read
augroup lazy_load_localvimrc
  autocmd!
  autocmd BufReadPost * ++once call plug#load('vim-localvimrc', 'vim-rooter', 'editorconfig.nvim')
augroup END

lua require("config")
lua require("firenvim_config")
