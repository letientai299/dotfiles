" Insert a code bloke in markdown
nnoremap <buffer> Q i```<CR><CR>```<ESC>ki

map <buffer> j gj
map <buffer> k gk

" Insert bold mark
imap <buffer> <C-b> ****<ESC>hi


" When writing markdown document, I often like to see the spelling error
" But the hemisu theme won't display it correctly in the current line
" So, I disable cursorline and turn on the spell checking also
setlocal nocursorline
setlocal spell

call WordProcessorMode()
