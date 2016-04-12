" List of plugins
call plug#begin()
"------------------------------------------------------------------------------
" UI
"
Plug 'kshenoy/vim-signature'
Plug 'ryanoasis/vim-devicons'
Plug 'scrooloose/nerdtree', { 'on':  ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'ivalkeen/nerdtree-execute/'
Plug 'Xuyuanp/nerdtree-git-plugin', { 'on':  'NERDTreeToggle' }
Plug 'airblade/vim-gitgutter'
Plug 'vim-airline/vim-airline'

"------------------------------------------------------------------------------
" Searching
"
Plug 'haya14busa/incsearch.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

"------------------------------------------------------------------------------
" Automate stuff
Plug 'Chiel92/vim-autoformat'
Plug 'raimondi/delimitmate'

"------------------------------------------------------------------------------
" Custom keymap
"
Plug 'tommcdo/vim-exchange'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-repeat'
Plug 'junegunn/vim-easy-align'
Plug 'scrooloose/nerdcommenter'

"------------------------------------------------------------------------------
" Text objects
"
Plug 'wellle/targets.vim'
Plug 'kana/vim-textobj-user' | Plug 'kana/vim-textobj-line'

"------------------------------------------------------------------------------
" Additional language plugins
"
Plug 'godlygeek/tabular' | Plug 'plasticboy/vim-markdown', { 'for': ['md','markdown'] }
Plug 'tfnico/vim-gradle', { 'for': 'gradle' }
Plug 'kchmck/vim-coffee-script', { 'for': 'coffee' }
Plug 'vimwiki/vimwiki'
call plug#end()
