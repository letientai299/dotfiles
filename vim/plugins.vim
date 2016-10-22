" Auto install on the first time if there no plug.vim found
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

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
Plug 'ntpeters/vim-airline-colornum'
Plug 'flazz/vim-colorschemes'
Plug 'junegunn/goyo.vim', { 'on':  ['Goyo'] }
Plug 'junegunn/limelight.vim', { 'on':  ['Limelight'] }
Plug 'yggdroot/indentline'
Plug 'mhinz/vim-startify'
Plug 'majutsushi/tagbar'
Plug 'Konfekt/FastFold'


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
Plug 'xolox/vim-session'
Plug 'xolox/vim-misc'
Plug 'ntpeters/vim-better-whitespace'
Plug 'editorconfig/editorconfig-vim'
Plug 'schickling/vim-bufonly'
Plug 'wellle/tmux-complete.vim'
Plug 'alvan/vim-closetag'
Plug 'tpope/vim-endwise', { 'for': 'ruby'}


" deoplete completion engine can only work with neovim
if(has('nvim'))
  function! DoRemote(arg)
    UpdateRemotePlugins
  endfunction
  " The completion engine
  Plug 'Shougo/deoplete.nvim', { 'tag': '1.1', 'do': function('DoRemote') }
  Plug 'zchee/deoplete-jedi', { 'for': 'python' }
  Plug 'davidhalter/jedi-vim', { 'for': 'python' }
  " deoplete source for Go
  Plug 'zchee/deoplete-go', { 'do': 'make', 'for': 'go' }

  let g:deoplete#auto_completion_start_length=1
else
  Plug 'Shougo/neocomplete.vim'
endif

Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'letientai299/vim-react-snippets', { 'branch': 'es6' }

Plug 'tpope/vim-endwise', {'for': 'ruby'}

" Gist
Plug 'mattn/webapi-vim' | Plug 'mattn/gist-vim'


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
Plug 'tpope/vim-speeddating'
Plug 'junegunn/vim-easy-align'
Plug 'scrooloose/nerdcommenter'
Plug 'christoomey/vim-titlecase'
Plug 'mattn/emmet-vim'


"------------------------------------------------------------------------------
" Text objects
"
Plug 'wellle/targets.vim'
Plug 'kana/vim-textobj-line'
Plug 'thalesmello/vim-textobj-methodcall'
Plug 'reedes/vim-textobj-sentence'
Plug 'kana/vim-textobj-user'


"------------------------------------------------------------------------------
" Additional language plugins
"
Plug 'godlygeek/tabular', {'on': 'Tabularize'}| Plug 'plasticboy/vim-markdown', { 'for': ['md','markdown'] }
Plug 'tfnico/vim-gradle', { 'for': 'gradle' }
Plug 'vimwiki/vimwiki'
Plug 'tmux-plugins/vim-tmux', { 'for': 'tmux' }
Plug 'sheerun/vim-polyglot', {'do': './build'}
Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'heavenshell/vim-jsdoc'
Plug 'chikamichi/mediawiki.vim', { 'for': 'mediawiki'}
Plug 'heavenshell/vim-pydocstring', {'for': 'python'}


" Setup for nodejs
Plug 'ternjs/tern_for_vim', { 'do': 'npm install' }
Plug 'moll/vim-node'


"------------------------------------------------------------------------------
" Helper
"
Plug 'scrooloose/syntastic'


" Leave a place to try some new plugins, before add it into this list
if !empty(glob('~/.local.plugins.vim'))
  source ~/.local.plugins.vim
endif

call plug#end()

" H to open help docs
function! s:plug_doc()
  let name = matchstr(getline('.'), '^- \zs\S\+\ze:')
  if has_key(g:plugs, name)
    for doc in split(globpath(g:plugs[name].dir, 'doc/*.txt'), '\n')
      execute 'tabe' doc
    endfor
  endif
endfunction

augroup PlugHelp
  autocmd!
  autocmd FileType vim-plug nnoremap <buffer> <silent> H :call <sid>plug_doc()<cr>
augroup END



" gx to open GitHub URLs on browser
function! s:plug_gx()
  let line = getline('.')
  let sha  = matchstr(line, '^  \X*\zs\x\{7}\ze ')
  let name = empty(sha) ? matchstr(line, '^[-x+] \zs[^:]\+\ze:')
                      \ : getline(search('^- .*:$', 'bn'))[2:-2]
  let uri  = get(get(g:plugs, name, {}), 'uri', '')
  if uri !~ 'github.com'
    return
  endif
  let repo = matchstr(uri, '[^:/]*/'.name)
  let url  = empty(sha) ? 'https://github.com/'.repo
                      \ : printf('https://github.com/%s/commit/%s', repo, sha)
  call netrw#BrowseX(url, 0)
endfunction

augroup PlugGx
  autocmd!
  autocmd FileType vim-plug nnoremap <buffer> <silent> gx :call <sid>plug_gx()<cr>
augroup END


