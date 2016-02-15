" Insert a code bloke in markdown
nnoremap Q i```<CR><CR>```<ESC>ki

map j gj
map k gk

" Insert bold mark
imap <C-b> ****<ESC>hi


" When writing markdown document, I often like to see the spelling error
" But the hemisu theme won't display it correctly in the current line
" So, I disable cursorline and turn on the spell checking also
set nocursorline
set spell
