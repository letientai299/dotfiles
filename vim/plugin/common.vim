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
xnoremap jk <ESC>
xnoremap kj <ESC>

" Always show the line number
set number

" Use space (I hate tab)
set expandtab

" Use 2-spaces per tab
" set tabstop=2 softtabstop=2 shiftwidth=2
set tabstop=2 softtabstop=2 shiftwidth=2
set ignorecase smartcase incsearch hls
set textwidth=79
if !has('nvim')
  set encoding=utf8
endif
set cursorline
set nofoldenable

" Set spelling language to English, not sure if this setting could be included
" in the common.Vim
set spelllang=en_us
set nospell

" Quickly format the paragraph, and also a way to avoid enter Ex-mode
nnoremap gQ gqap


" Settings that required Leader key
"------------------------------------------------------------------------------

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

" Quickly toggle the color column
function! g:ToggleColorColumn() abort
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
nnoremap * *zz
nnoremap # #zz

" Simulate Vim-surround behavior for deleting space around world
nmap ds<space> F<space>xf<space>x

" Insert mode delete forward one char
inoremap <C-d> <Del>

" Look up for help with vim keyword
augroup AutoCmdVim
    autocmd!
    autocmd FileType vim setlocal keywordprg=:help
augroup END

