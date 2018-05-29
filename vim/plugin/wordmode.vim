"------------------------------------------------------------------------------
" The following script is copied from (with modification to use with my setup)
" https://davidxmoody.com/vim-auto-capitalisation/
" This make vim capitalize the first letter of the sentence.
func! WordProcessorMode()
    " Auto-capitalize script
    augroup SENTENCES
        au!
        autocmd InsertCharPre <buffer> if search('\v(%^|[.!?]\_s+|\_^\-\s|\_^title\:\s|\n\n)%#', 'bcnw') != 0 | let v:char = toupper(v:char) | endif
    augroup END

    map <buffer> j gj
    map <buffer> k gk
    setlocal wrap
endfu

com! WordProcessorMode call WordProcessorMode()
