let mapleader=" "
" Include common settings
source ~/.vim/plugin/common.vim

# Disable auto wrap at textwidth
set textwidth=0


" https://github.com/JetBrains/ideavim/blob/master/doc/set-commands.md

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

nmap <A-p> :action PinActiveTabToggle<cr>
nmap <leader>va :source ~/.ideavimrc<cr>

" https://github.com/JetBrains/ideavim/wiki/IdeaVim-Plugins
set surround
set commentary
set ideajoin
set ideamarks
set anyobject
set functiontextobj

set dial
nnoremap <C-a> :DialIncrement<cr>
nnoremap <C-x> :DialDecrement<cr>

set matchit


" https://github.com/JetBrains/ideavim/blob/master/doc/NERDTree-support.md
set NERDTree

