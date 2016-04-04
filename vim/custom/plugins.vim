" List of plugins
call plug#begin()
Plug 'Chiel92/vim-autoformat'
Plug 'vim-airline/vim-airline'
Plug 'raimondi/delimitmate'
Plug 'ryanoasis/vim-devicons'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree', { 'on':  ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'tommcdo/vim-exchange'

Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/Vim-abolish'
Plug 'tpope/Vim-repeat'

" For working with git
Plug 'Xuyuanp/nerdtree-git-plugin', { 'on':  'NERDTreeToggle' }
Plug 'airblade/vim-gitgutter'

" Show mark
Plug 'kshenoy/vim-signature'

" Fuzzy file finder
Plug 'ctrlpvim/ctrlp.vim'

" This plugin adds a number of text objects to make vim editing more convenient
Plug 'wellle/targets.vim'

" Help making the table in markdown easier
Plug 'junegunn/vim-easy-align'

" Additional lanuage plugins
Plug 'godlygeek/tabular' | Plug 'plasticboy/vim-markdown', { 'for': ['md','markdown'] }
Plug 'tfnico/vim-gradle', { 'for': 'gradle' }
Plug 'kchmck/vim-coffee-script', { 'for': 'coffee' }

" Make searching in Vim easier
Plug 'haya14busa/incsearch.vim'
call plug#end()
