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
" Plug 'ntpeters/vim-airline-colornum'
Plug 'flazz/vim-colorschemes'
Plug 'junegunn/goyo.vim', { 'on':  ['Goyo'] }
Plug 'yggdroot/indentline'
Plug 'mhinz/vim-startify'
Plug 'drn/zoomwin-vim'
Plug 'gorodinskiy/vim-coloresque'
Plug 'luochen1990/rainbow'


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
Plug 'vimwiki/vimwiki'
Plug 'derekwyatt/vim-scala', { 'for': 'scala' }
Plug 'pangloss/vim-javascript', { 'for': 'js' }
Plug 'hail2u/vim-css3-syntax',  { 'for': ['css', 'scss'] }
Plug 'tmux-plugins/vim-tmux', { 'for': 'tmux' }
Plug 'lervag/vimtex', { 'for': 'tex' }


"------------------------------------------------------------------------------
" Helper
"
Plug 'scrooloose/syntastic'


"------------------------------------------------------------------------------
" Other
"
Plug 'yuratomo/w3m.vim', { 'on' : 'W3m' }

call plug#end()

" Auto install missing plugins on startup
autocmd VimEnter *
  \  if !empty(filter(copy(g:plugs), '!isdirectory(v:val.dir)'))
  \|   PlugInstall | q
  \| endif



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

