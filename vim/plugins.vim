call plug#begin()

"------------------------------------------------------------------------------
" UI
"
Plug 'kshenoy/vim-signature'
Plug 'ryanoasis/vim-devicons'
Plug 'scrooloose/nerdtree', { 'on':  ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'ivalkeen/nerdtree-execute', { 'on':  ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'Xuyuanp/nerdtree-git-plugin', { 'on':  ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'airblade/vim-gitgutter'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'flazz/vim-colorschemes'
Plug 'junegunn/goyo.vim', { 'on':  ['Goyo'] }
Plug 'yggdroot/indentline'
Plug 'mhinz/vim-startify'
Plug 'drn/zoomwin-vim'
Plug 'gorodinskiy/vim-coloresque'


"------------------------------------------------------------------------------
" Searching
"
Plug 'haya14busa/incsearch.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'rking/ag.vim', { 'on' : 'Ag'}


"------------------------------------------------------------------------------
" Automate stuff
"
Plug 'Chiel92/vim-autoformat'
Plug 'raimondi/delimitmate'
Plug 'airblade/vim-rooter'

" deoplete completion engine can only work with neovim
if(has('nvim'))
  function! DoRemote(arg)
    UpdateRemotePlugins
  endfunction
  Plug 'Shougo/deoplete.nvim', { 'do': function('DoRemote') }
else
  Plug 'Shougo/neocomplete.vim'
endif


"------------------------------------------------------------------------------
" Custom keymap
"
Plug 'tommcdo/vim-exchange'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/vim-easy-align'
Plug 'scrooloose/nerdcommenter'
Plug 'christoomey/vim-titlecase'


"------------------------------------------------------------------------------
" Text objects
"
Plug 'wellle/targets.vim'
Plug 'kana/vim-textobj-line'
Plug 'reedes/vim-textobj-sentence'
Plug 'kana/vim-textobj-user'


"------------------------------------------------------------------------------
" Additional language plugins
"
Plug 'godlygeek/tabular' | Plug 'plasticboy/vim-markdown', { 'for': ['md','markdown'] }
Plug 'tfnico/vim-gradle', { 'for': 'gradle' }
Plug 'kchmck/vim-coffee-script', { 'for': 'coffee' }
Plug 'vimwiki/vimwiki', { 'for' : 'wiki' }
Plug 'derekwyatt/vim-scala', { 'for': 'scala' }
Plug 'pangloss/vim-javascript', { 'for': 'js' }
Plug 'hail2u/vim-css3-syntax',  { 'for': ['css', 'scss'] }
Plug 'keith/tmux.vim', { 'for': '*tmux.conf*' }


"------------------------------------------------------------------------------
" Helper
"
Plug 'scrooloose/syntastic', { 'on' : ['SyntasticCheck', 'SyntasticInfo'] }


"------------------------------------------------------------------------------
" Other
"
Plug 'yuratomo/w3m.vim', { 'on' : 'W3m' }

call plug#end()
