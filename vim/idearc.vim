let mapleader=" "
" Include common settings
source ~/.vim/plugin/common.vim

# Disable auto wrap at textwidth
set textwidth=0


" https://github.com/JetBrains/ideavim/blob/master/doc/set-commands.md

nmap <A-p> :action PinActiveTabToggle<cr>
nmap <leader>va :source ~/.ideavimrc<cr>

" https://github.com/JetBrains/ideavim/wiki/IdeaVim-Plugins
set surround
set commentary
set ideajoin
set ideamarks
set anyobject
set exchange
" set functiontextobj

set matchit


" https://github.com/JetBrains/ideavim/blob/master/doc/NERDTree-support.md
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


nnoremap <leader>va :source ~/.ideavimrc<CR>
nnoremap gr :action Refactorings.QuickListPopupAction<CR>
nnoremap <leader>gr :action RenameElement<CR>
nnoremap gi :action GotoImplementation<CR>
nnoremap gu :action FindUsages<CR>
nnoremap gt :action GotoRelated<CR>

map <leader>a <Action>(Annotate)
