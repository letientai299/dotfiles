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
nnoremap [c :action VcsShowPrevChangeMarker<cr>
nnoremap ]c :action VcsShowNextChangeMarker<cr>
nnoremap [b :action PreviousTab<cr>
nnoremap ]b :action NextTab<cr>
nnoremap [e :action MoveLineUp<cr>
nnoremap ]e :action MoveLineDown<cr>

# Jumpings
nnoremap <c-k> :action MethodUp<cr>
nnoremap <c-j> :action MethodDown<cr>



" TODO (tai): there's https://plugins.jetbrains.com/plugin/7282-liveplugin to
" write adhoc plugin for intelllij,
" https://github.com/JetBrains/ideavim/discussions/303#discussioncomment-9974302

nnoremap <leader>va :source ~/.ideavimrc<CR>
nnoremap <leader>gr :action Refactorings.QuickListPopupAction<CR>
nnoremap gr :action RenameElement<CR>
nnoremap gi :action GotoImplementation<CR>
nnoremap gu :action ShowUsages<CR>
nnoremap gU :action FindUsages<CR>
nnoremap gl :action GotoRelated<CR>
nnoremap <A-j> :action NextOccurence<CR>
nnoremap <A-k> :action PreviousOccurence<cr>

" google search word under cursor
nnoremap <leader>gs <esc>:!open https://google.com/ai\?q=define\ csharp\ asp.net\ <c-r><c-w><cr>
