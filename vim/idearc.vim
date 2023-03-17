let mapleader=" "

" Include common settings
source ~/.vim/plugin/common.vim

" https://github.com/JetBrains/ideavim/blob/master/doc/set-commands.md

" Use the new surround plugin
set surround
set commentary
set ideajoin
set ideamarks
set argtextobj
set NERDTree

" unimpaired mappings - from https://github.com/saaguero/ideavimrc/blob/master/.ideavimrc
nnoremap [<space> O<esc>j
nnoremap ]<space> o<esc>k
nnoremap [q :action PreviousOccurence<cr>
nnoremap ]q :action NextOccurence<cr>
nnoremap [m :action MethodUp<cr>
nnoremap ]m :action MethodDown<cr>
nnoremap [c :action VcsShowPrevChangeMarker<cr>
nnoremap ]c :action VcsShowNextChangeMarker<cr>
" Tabs
nnoremap [b :action PreviousTab<cr>
nnoremap ]b :action NextTab<cr>

" Moving lines
nmap [e :action MoveLineUp<cr>
nmap ]e :action MoveLineDown<cr>

" Moving statements
nmap [s :action MoveStatementUp<cr>
nmap ]s :action MoveStatementDown<cr>

nmap <A-p> :action PinActiveTabToggle<cr>
nmap <leader>va :source ~/.ideavimrc<cr>

