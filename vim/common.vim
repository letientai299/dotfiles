" This file include the common settings that be shared between Vim and other
" IDE Vim-plugins. They includes:
" - IdeaVim for JetBrains family
" - Vrapper for Eclipse family
" - (hopefully someday I could add VsVim here, when I have some project that
"   need Visual Studio)
"
" Unsurprisingly, some of following settings are not work on all the IDE
" plugins. But since they are not harm at all, I still keep them here.
" Hopefully in the future, the plugins authors will add support for those
" settings.
"----------------------------------------------------------------------------

" Avoid using the Escape key
inoremap jk <ESC>
inoremap kj <ESC>
vnoremap jk <ESC>
vnoremap kj <ESC>

" Always show the line number
set number

" Use space (I hate tab)
set expandtab

" Use 4-spaces per tab
set tabstop=4 softtabstop=4 shiftwidth=4
set ignorecase smartcase incsearch hls
set textwidth=79
set encoding=utf8
set cursorline
set nofoldenable
set nospell

" Set spelling language to English, not sure if this setting could be included
" in the common.Vim
set spelllang=en_us

" Quickly format the paragraph, and also a way to avoid enter Ex-mode
nnoremap gQ gqap


" Settings that required Leader key
"------------------------------------------------------------------------------

" Insert an blank line below or above the current line in normal mode
nnoremap <Leader>o o<ESC>k
nnoremap <Leader>O O<ESC>j


" Toggle highlight search
nnoremap <Leader>n :set hls!<CR>

" Toggle spelling
nnoremap <Leader>s :set spell!<CR>

" Toggle foldenable
nnoremap <Leader>f :set foldenable!<CR>


" Quickly paste from clipboard
nnoremap <Leader>p "+p
nnoremap <Leader>P "+P

" And quickly copy to clipboard also
nnoremap <Leader>y "+y
nnoremap <Leader>Y :.y+<CR>
vnoremap <Leader>y "+y

" Make Y copy to end the line like the D command
nnoremap Y y$

" Insert a second level or first level header line below the current line in
" normal mode
nnoremap <Leader>l yypVr-
nnoremap <Leader>L yypVr=

" Quickly toggle the color column
function! g:ToggleColorColumn()
    if &colorcolumn != ''
        setlocal colorcolumn&
    else
        setlocal colorcolumn=+1
    endif
endfunction

nnoremap <silent> <leader>q :call g:ToggleColorColumn()<CR>


" Center the cursor on the screen after a search
nnoremap n nzz
nnoremap N Nzz
